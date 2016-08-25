#
# lib/plist.rb
#
# @author  Mark Eissler
#
module Xcodebump
  require_relative 'cli'
  require_relative 'util/string'
  require 'pathname'

  #
  # The Plist class
  #
  class Plist < CLI
    include Xcodebump::Util::String

    class MissingPlistSettingError < RuntimeError; end

    COMMAND_PATH = "/usr/libexec/Plistbuddy"
    attr_reader :file_path
    attr_reader :file_path_raw
    attr_reader :version
    attr_reader :build

    def initialize(command_path="")
      _command_path = command_path
      if _command_path.nil? || _command_path.empty?
        _command_path = COMMAND_PATH
      end
      self.command_path = _command_path
    end

    # Set the Plist file path.
    #
    # @param file_path [String] the Plist file path
    #
    # @return [Bool] true if file path is valid, false otherwise
    #
    # @raise [ArgumentError] raises this exception if the file path is
    #   invalid (it doesn't exist).
    #
    def file_path=(file_path)
      @file_path_raw = Pathname.new(file_path)
      begin
        @file_path = @file_path_raw.realpath
        @file_path.file?
      rescue
        raise ArgumentError, "invalid file_path specified: #{file_path}"
      end
    end

    # Set the marketing version.
    #
    # The marketing version must be compliant with Semantic Versioning (SemVer)
    # syntax. That is, it must match common format: M.m.p
    #
    #   +M = Major version
    #   +m = minor version
    #   +p = patch version
    #
    # Where each component above is mandatory and consists of digits only.
    #
    # @param version [String] the marketing version
    #
    # @return [String] marketing version on success, nil otherwise
    #
    # @raise [ArgumentError] raises this exception if the version is nil or
    #   invalid (it doesn't comply with SemVer syntax).
    #
    def version=(version)
      if version.empty?
        raise ArgumentError, "version parameter required but not supplied"
      end
      if self.is_valid_semver_normal?(version) == false
        raise ArgumentError, "specified version is not SemVer compliant: #{version}"
      end
      @version = version
    end

    # Set the build number.
    #
    # The build number must be compliant with Semantic Versioning (SemVer)
    # syntax. Specifically, the build number can consist of a concatonated
    # string containing SemVer pre-release and metadata components.
    #
    # @example
    #   alpha.1
    #   beta.193
    #   build.2045
    #   build.2054+1234
    #   beta+exp.sha.5114f85 (not recommended)
    #
    # <b>Warning:</b> Keep in mind that Apple uses the build number to identify
    #   different submission to the App Store. Build numbers must increase from
    #   previous submissions of the same app; therfore, using a build number
    #   that doesn't feature an incrementing number (eg. a hash) is not advised.
    #
    # @param build [String] the build number
    #
    # @return [String] build number on success, nil otherwise
    #
    # @raise [ArgumentError] raises this exception if the build number is nil or
    #   invalid (it doesn't comply with SemVer syntax).
    #
    def build=(build)
      if build.strip.empty?
        raise ArgumentError, "build parameter required but not supplied"
      end

      # need to split prerelease and metadata components to test separately!
      if build.start_with?('+')
        _metadata = build[1..-1]
      else
        _prerelease, _metadata = build.split('+')
      end

      _prerelease ||= ""
      _metadata ||= ""

      if (_prerelease.empty? == false and self.is_valid_semver_prerelease?("-#{_prerelease}") == false) \
        or (_metadata.empty? == false and self.is_valid_semver_metadata?("+#{_metadata}") == false)
        raise ArgumentError, "specified build is not SemVer compliant: #{build}"
      end

      @build = build
    end

    # Increment the build number.
    #
    # By default, the build component will be updated; set the prerelease
    # parameter to "true" to update the prerelease component instead.
    #
    # @param prerelease=false [Bool] if false (default), metadata component
    #   will be incremented, otherwise prerelease component will be updated.
    #
    # @return [String] updated build string
    #
    def bump_build(prerelease=false)
      _semver = self.version
      _build = "-"
      # no prerelease data but metadata present? remove "-"
      if self.build[0] == '+'
        _build = ""
      end
      _semver += "#{_build}#{self.build}"

      if prerelease
        _new_semver = self.increment_semver(_semver, true)
      else
        _new_semver = self.increment_semver(_semver)
      end

      # parse and store
      _version, _prerelease, _metadata = self.parse_semver(_new_semver)
      self.build = "#{_prerelease.sub(/^\-/,"")}#{_metadata}"
    end

    # Find a plist file in the specified search_directory.
    #
    # @param search_directory [String] directory to search in
    # @param filename="Info.plist" [String] name of file to search for
    #
    # @return [String, nil] string containing path to found file on success,
    #   nil otherwise
    #
    # @raise [ArgumentError] raises this exception if search_directory or
    #   filename parameter are invalid.
    #
    def find(search_directory, filename="Info.plist")
      if search_directory.strip.empty?
        raise ArgumentError, "search_directory parameter required but not supplied"
      end
      _search_directory_raw = Pathname.new(search_directory.chomp('/'))
      _search_directory = nil
      begin
        _search_directory = _search_directory_raw.realpath
        raise unless _search_directory.directory?
      rescue
        raise ArgumentError, "invalid directory specified: #{search_directory}"
      end

      if filename.nil? || filename.strip.empty?
        raise ArgumentError, "filename invalid: undefined or empty"
      end
      _foundfile_fullpath = nil
      _search_directory.find() do |path|
        if path.basename.to_s == filename
          _foundfile_fullpath = path.to_s
          break
        end
      end

      _foundfile_fullpath
    end

    # Read the plist file at file_path.
    #
    # You must set the file_path before calling this method.
    #
    # @return [Bool] true if file was read successfully, false otherwise
    #
    # @see Xcodebump::Plist.file_path()
    #
    def read
      _cfBundleShortVersionString, _stderr, _status = self.run_command("Print", [":CFBundleShortVersionString"])
      return false unless _status.success?
      self.version = _cfBundleShortVersionString.chomp
      _cfBundleVersion, _stderr, _status = self.run_command("Print", [":CFBundleVersion"])
      self.build = _cfBundleVersion.chomp
      return _status.success?
    end

    # Write the plist file at file_path.
    #
    # You must set the file_path before calling this method.
    #
    # @return [Bool] true if file was written successfully, false otherwise
    #
    # @see Xcodebump::Plist.file_path()
    # @see Xcodebump::Plist.write_safe()
    #
    # @raise [RuntimeError] this exception is raised if the file_path has not
    #   been set.
    #
    def write
      if self.file_path.nil?
        raise RuntimeError, "invalid file_path: undefined"
      end
      _stdout, _stderr, _status = self.run_command("Set", [":CFBundleShortVersionString", "\"#{self.version}\""])
      return false unless _status.success?
      _stdout, _stderr, _status = self.run_command("Set", [":CFBundleVersion", "\"#{self.build}\""])
      return _status.success?
    end

    # Safely write the plist file at file_path.
    #
    # Ensure that all values to be written have been set and are not empty or
    # nil values. In general, you should call this method instead of the less-
    # safe Xcodebump::Plist.write() method.
    #
    # @return [Bool] true if file was written successfully, false otherwise
    #
    # @see Xcodebump::Plist.write()
    #
    # @raise [MissingPlistSettingError] this exception is raised if any of the
    #   settings to be written have not been set correctly (i.e. they are nil or
    #   empty).
    #
    def write_safe
      if self.version.nil? || self.version.strip.empty?
        raise MissingPlistSettingError, "unable to write Plist, missing setting: \"version\" (did you set it?)"
      end

      if self.build.nil? || self.build.strip.empty?
        raise MissingPlistSettingError, "unable to write Plist, missing setting: \"build\" (did you set it?)"
      end

      self.write()
    end

  protected
    # Run a PlistBuddy command with the supplied arguments.
    #
    # Parameter arguments (in the args array) should be double quoted.
    #
    # @example
    #   ["-c",  "\"Print CFBundleVersion\""]
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
      # format command with args, add file_path as separate arg
      _command_args = ["-c \"#{command} #{args.join(" ")}\"", "\"#{self.file_path}\""]
      _stdout, _stderr, _status = super(_command_args)
    end
  end
end

