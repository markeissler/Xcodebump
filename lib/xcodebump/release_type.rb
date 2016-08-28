#
# lib/release_type.rb
#
# @author  Mark Eissler
#
module Xcodebump
  # Static release type definitions.
  #
  # @example
  #   my_release_type = ReleaseType.new("beta")
  #
  # @author [mark]
  #
  class ReleaseType
    include Enumerable

    attr_reader :type

    def initialize(release_type="beta")
      _release_type = release_type
      if _release_type.nil? || _release_type.empty?
        _release_type = self.first
      else
        unless self.include? _release_type
          raise TypeError, "release_type is invalid, valid values are: #{self.to_a}"
        end
      end

      @type = _release_type
    end

    def each
      yield "beta"
      yield "release"
    end
  end
end
