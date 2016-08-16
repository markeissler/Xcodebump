#
# lib/util/string.rb
#
# @author Mark Eissler
#
module Xcodebump
  module Util
    #
    # The String module is a mixin that encapsulates string manipulations.
    #
    # @author Mark Eissler
    #
    module String
      # Validate a string to see if it complies with Semantic Versioning
      # (SemVer) syntax.
      #
      # The following strings are valid:
      # @example
      #   1.0.1
      #   1.0.1-alpha
      #   1.0.1-b.12
      #   1.0.1-beta.123+456
      #   1.0.1-beta+exp.sha.5114f85
      #
      # @param version [String] version string to test
      #
      # @return [Bool] true if version complies, false otherwise
      #
      # @see http://semver.org/
      #
      def is_valid_semver?(version)
        !version.match(/^(?:[\d]+\.)(?:[\d]+\.)(?:[\d]+)(?:\-[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*)?(?:\+[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*)?$/).nil?
      end

      # Validate a string to see if it complies with Semantic Versioning
      # (SemVer) syntax for normal version data.
      #
      # The "normal version" data is the familiar "Major.minor.patch" syntax
      # (e.g. 1.0.1) and nothing more and nothing less. That is, all three
      # components must be present, separated by dots, and not preceded or
      # followed by another other data.
      #
      # @param normal_version [String] normal version string to test
      #
      # @return [Bool] true if normal_version string complies, false otherwise
      #
      def is_valid_semver_normal?(normal_version)
        !normal_version.match(/^(?:[\d]+\.)(?:[\d]+\.)(?:[\d]+)$/).nil?
      end

      # Validate a string to see if it complies with Semantic Versioning
      # (SemVer) syntax for pre-release metadata.
      #
      # SemVer pre-release metadata includes labels such as "alpha", "beta",
      # "RC" (release candidate). This data must appear after the version string
      # and before the build metadata string. This data is preceded by a "-"
      # character and may consist only of a series of dot-separated identifiers.
      # Identifers may only consist of the characters in the set: [0-9A-Za-z-].
      #
      # The following strings are valid:
      # @example
      #   -b
      #   -b.b
      #   -beta
      #   -beta.123
      #   -123
      #   -0.3.7
      #
      # @param prerelease [String] pre-release string to test
      #
      # @return [Bool] true if prerelease string complies, false otherwise
      #
      def is_valid_semver_prerelease?(prerelease)
        !prerelease.match(/^\-[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*$/).nil?
      end

      # Validate a string to see if it complies with Semantic Versioning
      # (SemVer) syntax for metadata.
      #
      # SemVer metadata includes build numbers. This data must appear as the
      # the last component in a SemVer string, is preceded by a "+" character
      # and may consist only of a series of dot-separated identifiers. The
      # identifiers may only consist of the characters in the set: [0-9A-Za-z-].
      #
      # The following strings are valid:
      # @example
      #   +001
      #   +20130313144700
      #   +exp.sha.5114f85
      #
      # @param metadata [String] metadata string to test
      #
      # @return [Bool] true if metadata complies, false otherwise
      #
      def is_valid_semver_metadata?(metadata)
        !metadata.match(/^\+[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*$/).nil?
      end
    end
  end
end
