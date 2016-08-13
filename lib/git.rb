#
# lib/git.rb
#
# @author  Mark Eissler
#
module Xcodebump
  require_relative 'vcs'
  require 'open3'
  require 'pathname'

  #
  # The Git class.
  #
  class Git < VCS
    COMMAND_PATH = "git"

    def initialize(working_directory="", command_path="")
      _working_directory = working_directory
      if _working_directory.nil? || _working_directory.empty?
        _working_directory = "./"
      end
      self.working_directory = _working_directory

      _command_path = command_path
      if _command_path.nil? || _command_path.empty?
        _command_path = COMMAND_PATH
      end
      self.command_path = _command_path
    end

    # Return the current branch name.
    #
    # @return [String] current branch name
    #
    def current_branch
      _branch, _stderr, _status = self.run_command("rev-parse", ["--abbrev-ref HEAD"])
      _branch.chomp
    end

    # [master (root-commit) b0a072d] Updated build to build-1.2.1-b93
    # [feature/rubygem-refactor 914cc9d] Updated build to build-1.2.1-b93
    # /\[feature\\/rubygem-refactor ([a-f0-9]{7})\]/
    # handle both of the above:
    # \[feature\/rubygem-refactor\ (?:\([a-zA-Z\-]+\)\ )?([a-f0-9]{7})\]

    # Return the most-recent commit hash for the specified branch.
    #
    # @param branch="" [String] branch to check
    #
    # @return [String] 20-character SHA1 hash representing current commit
    #
    def current_commit_hash(branch="")
      _branch = branch
      if _branch.nil? || _branch.empty?
        _branch = self.current_branch()
      else
        _branch.chomp!
      end
      _commit, _stderr, _status = self.run_command("rev-parse", ["--verify \"#{_branch}\""])
      _commit.chomp
    end

    # Check whether tag already exists.
    #
    # @param tag [String] tag to check
    #
    # @return [Bool] true if tag exists, false otherwise
    #
    def is_existing_tag?(tag)
      _tag = tag.chomp
      _commit, _stderr, _status = self.run_command("rev-parse", ["#{_tag}"])
      _commit.chomp!
      _status.success? && _commit.length > 0
    end

    # Check whether a refname (tag or branch name) are well formed.
    #
    # By "well formed" we mean syntactically correct as required by the git
    # "check-ref-format" command.
    #
    # @param refname [String] refname to check
    #
    # @return [Bool] true if refname is well formed, false otherwise
    #
    def is_valid_refname?(refname)
      _refname_pattern = "xxx/#{refname}"
      _refname, _stderr, _status = self.run_command("check-ref-format", ["--normalize \"#{_refname_pattern}\""])
      _status.success?
    end

    # Create a new commit object.
    #
    # @param message [String] the commit message
    #
    # @return [Bool] true if operation succeeded, false otherwise
    #
    # @raise [ArgumentError] raises this exception if the message parameter is
    #   set to an empty string.
    #
    def write_commit(message)
      _message = message.chomp
      if _message.empty?
        raise ArgumentError, "message parameter required but not supplied"
      end
      # first add all files
      _stderr, _stderr, _status = self.run_command("add", ["#{self.working_directory.to_s}"])
      return false unless _status.success?
      # then commit all files
      _stdout, _stderr, _status = self.run_command("commit", ["-m \"#{_message}\""])
      _status.success?
    end

    # Create a new commit tag.
    #
    # This method will verify that the specified tag name is well formed and
    # that it doesn't already exist.
    #
    # The message parameter is optional and if not supplied a lightweight tag
    # will be created instead of an annotated tag.
    #
    # The commit parameter is optional and if not supplied the most-recent
    # commit on the current branch will be used as the target commit hash.
    #
    # @param tag [String] the commit tag name
    # @param message="" [String] the annotated commit tag message
    # @param commit="" [type] the commit to tag
    #
    # @return [Bool] [description]
    #
    # @see Xcodebump::Git::is_existing_tag?
    # @see Xcodebump::Git::is_valid_refname?
    #
    # @raise [ArgumentError] raises this exception if the tag name parameter is
    #   set to an empty string, the tag is not well formed or the tag already
    #   exists.
    #
    def write_tag(tag, message="", commit="")
      _tag = tag.chomp
      if _tag.empty?
        raise ArgumentError, "tag parameter required but not supplied"
      end
      # add prefix
      _tag = "#{self.tag_prefix}#{_tag}"

      # verify tag is syntactically correct and doesn't already exist
      if self.is_valid_refname?(_tag) == false
        raise ArgumentError, "specified tag name is not well formed: #{_tag}"
      end

      if self.is_existing_tag?(_tag) == true
        raise ArgumentError, "specified tag name already exists: #{_tag}"
      end

      _commit = commit
      if _commit.nil? || _commit.empty?
        _commit = self.current_commit_hash
      else
        _commit.chomp!
      end

      # annotated or lightweight tag? we do the latter if no message
      _message = message
      _annotate_params = ["\"#{_tag}\"", "#{_commit}"]
      unless _message.nil? || _message.empty?
        _message.chomp!
        _annotate_params.unshift("-a", "-m \"#{_message}\"")
      end

      _stdout, _stderr, _status = self.run_command("tag", _annotate_params)
      _status.success?
    end
  end

end
