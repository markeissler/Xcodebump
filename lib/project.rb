#
# lib/project.rb
#
# @author  Mark Eissler
#
module Xcodebump
  require_relative './git'
  # require_relative './plist'
  # require_relative './podspec'
  require_relative './release_type'

  #
  # The Project class.
  #
  class Project
    attr_reader :name
    attr_reader :version_major
    attr_reader :version_minor
    attr_reader :version_bug
    attr_reader :build
    attr_reader :release_type
    attr_reader :repo
    attr_reader :info_plist
    attr_reader :pod_spec

    def initialize()
      @version_major = 0
      @version_minor = 0
      @verison_bug = 1
      @build = 1
      @release_type = ReleaseType.new("beta")
      # @info_plist = Xcodebump::Plist.new
    end

    def name=(name)
      unless name.is_a?(::String)
        raise TypeError, "name parameter must be type String"
      end

      @name = name
    end

    def version_major=(revision)
      unless revision.is_a?(::Integer)
        raise TypeError, "revision parameter must be type Integer"
      end

      @version_major = revision
    end

    def version_minor=(revision)
      unless revision.is_a?(::Integer)
        raise TypeError, "revision parameter must be type Integer"
      end

      @version_minor = revision
    end

    def version_bug=(revision)
      unless revision.is_a?(::Integer)
        raise TypeError, "revision parameter must be type Integer"
      end

      @version_bug = revision
    end

    def build=(build)
      unless build.is_a?(::Integer)
        raise TypeError, "build parameter must be type Integer"
      end

      @build = build
    end

    def release_type=(release_type)
      unless release_type.is_a?(Xcodebump::ReleaseType)
        raise TypeError, "release_type parameter must be type ReleaseType"
      end

      @release_type = release_type
    end
  end
end
