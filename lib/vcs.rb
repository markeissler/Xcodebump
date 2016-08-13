#
# lib/vcs.rb
#
# @author  Mark Eissler
#
module Xcodebump
  require 'open3'
  require 'pathname'

  #
  # The VCS class.
  #
  class VCS
    class AbstractClassError < RuntimeError; end

    COMMAND_PATH = nil
    TAG_PREFIX = "build-"
    attr_reader :command_path
    attr_reader :command_path_raw
    attr_reader :working_directory
    attr_reader :working_directory_raw
    attr_reader :tag_prefix

    def initialize(working_directory="", command_path="")
      raise AbstractClassError, "call concrete class initialize method"
    end

    # Set the VCS command path.
    #
    # @param command_path [String] path for the VCS command line interface
    #
    # @return [Bool] true if command is valid, false otherwise
    #
    # @raise [ArgumentError] raises this exception if the command_path is
    #   invalid (either it doesn't exist or isn't a file).
    #
    def command_path=(command_path)
      _command_path = command_path
      # resolve command to a full path if needed
      unless _command_path =~ /^\/.*/
        _command_path, status = Open3.capture2("which #{_command_path}")
        _command_path.chomp!
      end

      @command_path_raw = Pathname.new(_command_path)
      begin
        @command_path = @command_path_raw.realpath
        @command_path.file?
      rescue
        raise ArgumentError, "invalid command_path specified: #{command_path}"
      end
    end

    # Set the working directory.
    #
    # @param directory [String] path to the working directory
    #
    # @return [Bool] true if directory is valid, false otherwise
    #
    # @raise [ArgumentError] raises this exception if the directory is invalid
    #   (either it doesn't exist of isn't a directory).
    def working_directory=(directory)
      @working_directory_raw = Pathname.new(directory.chomp('/'))
      begin
        @working_directory = @working_directory_raw.realpath
        @working_directory.directory?
      rescue
        raise ArgumentError, "invalid directory specified: #{directory}"
      end
    end

    # Set the commit tag name prefix.
    #
    # The prefix will be prepended to any tag name that is set.
    #
    # @param prefix [String] the tag name prefix
    #
    # @return [String] the tag name prefix
    #
    def tag_prefix=(prefix)
      @tag_prefix = prefix
    end

  protected
      # Run a VCS command with the supplied arguments.
      #
      # Parameter arguments (in the args array) should be double quoted.
      #
      # @example
      #   ["-m", "\"My message text is here.\""]
      #
      # @param command [String] the command to execute
      # @param args=[] [Array] list of quoted parameters and arguments
      #
      # @return [String, String, Process::Status] stdout, stderr, and the status
      #   of the command results.
      #
      # @see Process::Status
      #
      # @raise [ArgumentError] this exception is raised if the command
      #   parameter is set to an empty string.
      #
    def run_command(command, args=[])
      _command = command
      if _command.empty?
        raise ArgumentError, "command parameter required but not supplied"
      end
      _args_string = args.join(" ")
      _stdout, _stderr, _status = Open3.capture3("#{self.command_path} -C \"#{self.working_directory}\" #{_command} #{_args_string}")
    end
  end
end
