#
# lib/vcs.rb
#
# @author  Mark Eissler
#
module Xcodebump
  require 'cli'
  require 'pathname'

  #
  # The VCS class.
  #
  class VCS < CLI
    class AbstractClassError < RuntimeError; end

    TAG_PREFIX = "build-"
    attr_reader :working_directory
    attr_reader :working_directory_raw
    attr_reader :tag_prefix

    def initialize(working_directory="", command_path="")
      raise AbstractClassError, "call concrete class initialize method"
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
  end

end
