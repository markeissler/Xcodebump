#
# lib/cli.rb
#
# @author  Mark Eissler
#
module Xcodebump
  require 'open3'
  require 'pathname'
  require 'byebug'

  #
  # The CLI class.
  #
  # A class that implements a basic interface to command line programs.
  #
  class CLI
    attr_reader :command_path
    attr_reader :command_path_raw

    def initialize(command_path)
      if command_path.empty?
        raise ArgumentError, "command_path parameter required but not supplied"
      end
      self.command_path = command_path
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

  protected
    # Run a CLI command with the supplied arguments.
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
    def run_command(args=[])
      _args_string = args.join(" ")
      _stdout, _stderr, _status = Open3.capture3("#{self.command_path} #{_args_string}")
    end
  end

end