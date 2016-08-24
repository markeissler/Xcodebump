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
      require 'date'

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
        !version.match(/^(?:[\d]+\.){2}(?:[\d]+)(?:\-[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*)?(?:\+[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*)?$/).nil?
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
        !normal_version.match(/^(?:[\d]+\.){2}(?:[\d]+)$/).nil?
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

      # Increment the the trailing numerical portion of the build or prerelease
      # component of a string that conforms with Semantic Versioning (SemVer)
      # syntax.
      #
      # By default, the build component will be updated; set the prerelease
      # parameter to "true" to update the prerelease component instead.
      #
      # The following strings are valid:
      # @example
      #   1.0.1-alpha+123
      #   1.0.1-b.12+we13
      #   1.0.1-beta.123+456
      #
      #   <b>Expected output (prerelease=false)</b>
      #   1.0.1-alpha+124
      #   1.0.1-b.12+we14
      #   1.0.1-beta.123+457
      #
      #   <b>Expected output (prerelease=true)</b>
      #   1.0.1-alpha
      #   1.0.1-b.12
      #   1.0.1-beta.124+456
      #
      # @param semver [String] semver string to increment
      # @param prerelease=false [Bool] if false (default), metadata component
      #   will be incremented, otherwise prerelease component will be updated.
      #
      # @return [String] updated semver string
      #
      def increment_semver(semver, prerelease=false)
        _normal_version, _prerelease, _metadata = self.parse_semver(semver, true)

        if prerelease
          _new_prerelease = self.increment_semver_prerelease(_prerelease)
        else
          _new_metadata = self.increment_semver_metadata(_metadata)
        end
        _new_prerelease ||= _prerelease
        _new_metadata ||= _metadata

        self.build_semver(_normal_version,
          {
            prerelease: _new_prerelease,
            metadata: _new_metadata
          }
        )
      end

      # Increment the trailing numerical portion of the prerelease component of
      # a string that conforms with Semantic Versioning (SemVer) syntax.
      #
      # @example
      #   "build.2"
      #
      #   <b>Expected output</b>
      #   "build.3"
      #
      # @param semver [String] prerelease string to parse and increment
      #
      # @return [String] updated prerelease string
      #
      # @note This does not handle M.m.p format outside of incrementing the
      #   patch digits.
      #
      def increment_semver_prerelease(prerelease)
        unless is_valid_semver_prerelease?("-#{prerelease}")
          raise ArgumentError, "specified prerelease is not SemVer compliant: #{prerelease}"
        end
        # extract trailing digits from prerelease
        _trailing_digits_match = prerelease.match(/[0-9]+$/)
        # increment
        _digits = _trailing_digits_match.to_s.to_i
        _digits += 1
        # replace in _tmp_prerelease
        _new_prerelease = prerelease.sub(/[0-9]+$/, "#{_digits}")
      end

      # Increment the trailing numerical portion of the metadata component of a
      # string that conforms with Semantic Versioning (SemVer) syntax. Dates are
      # detected and updated with the current date if the date pattern conforms
      # to one of the following format specifiers:
      #
      #   +"%Y%m%d%H%M%S"
      #
      # @example
      #   "abcd.we13"
      #   "abcd.20130313144700" (date)
      #
      #   <b>Expected output</b>
      #   "abcd.we14"
      #   "abcd.20160818110330" (if Now is 20160818110330)
      #
      # @param semver [String] metadata string to parse and increment
      #
      # @return [String] updated metadata string
      #
      def increment_semver_metadata(metadata)
        unless is_valid_semver_metadata?("+#{metadata}")
          raise ArgumentError, "specified metadata is not SemVer compliant: #{metadata}"
        end
        # extract trailing digits from metadata
        _trailing_digits_match = metadata.match(/[0-9]+$/)

        ## is this a date?
        _digits = ""
        begin
          # _digits = DateTime.parse(_trailing_digits_match.to_s)
          # only parse for the output format we support
          _digits = DateTime.strptime(_trailing_digits_match.to_s, "%Y%m%d%H%M%S")
          _digits = DateTime.now()
          _digits = _digits.strftime("%Y%m%d%H%M%S")
        rescue
          # increment
          _digits = _trailing_digits_match.to_s.to_i
          _digits = _digits += 1
        end

        # replace in _metadata
        _new_metadata = metadata.sub(/[0-9]+$/, "#{_digits}")
      end

      # Parse a string that conforms with Semantic Versioning (SemVer) syntax
      # into three components:
      #   + normal version
      #   + pre-release
      #   + metadata
      #
      # @example
      #   +"1.2.1-build.2+abcd.we13"
      #
      #   <b>Expected output</b>
      #   +["1.2.1", "build.2", "abcd.we13"]
      #
      # @param semver [String] semver string to parse
      # @param strip_separators=true [Bool] if true, semver component separators
      #   (-, +) will be stripped from output
      #
      # @return [Array] string parsed into SemVer components
      #
      # @raise [ArgumentError] this exception is raised if the semver string
      #   does not conform to SemVer syntax.
      #
      def parse_semver(semver, strip_separators=false)
        unless is_valid_semver?(semver)
          raise ArgumentError, "specified semver is not SemVer compliant: #{semver}"
        end
        # extract normal version
        _normal_version_string = semver.match(/^(?:[\d]+\.)(?:[\d]+\.)(?:[\d]+)/).to_s
        # extract prerelease ("-build.2")
        _prerelease_string = semver.match(/\-[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*/).to_s
        if strip_separators && _prerelease_string[0] == '-'
          _prerelease_string[0] = ''
        end
        # extract metadata ("+abcd.we13")
        _metadata_string = semver.match(/\+[a-zA-z0-9]+(?:\.[a-zA-z0-9]+)*/).to_s
        if strip_separators && _metadata_string[0] == '+'
          _metadata_string[0] = ''
        end

        return [_normal_version_string, _prerelease_string, _metadata_string]
      end

      # Build a string compliant with Semantic Versioning (SemVer) syntax from
      # the specified components.
      #
      # At a minimum, the normal version string (M.m.p) must be provided.
      #
      # @param normal_version [String] the normal version string
      # @param options={} [Hash] specify the following SemVer components as
      #   strings:
      #   +prerelease
      #   +metadata
      #
      # @return [String] the resulting semver string
      #
      # @raise [ArgumentError] this exception is thrown if the normal_version
      #   is missing or any of the supplied values don't conform to SemVer
      #   syntax.
      #
      def build_semver(normal_version, options={})
        unless is_valid_semver_normal?(normal_version)
          raise ArgumentError, "specified normal_version is not SemVer compliant: #{normal_version}"
        end
        _semver = normal_version
        if options.key?(:prerelease) and !(options[:prerelease].empty?)
          unless is_valid_semver_prerelease?("-#{options[:prerelease]}")
            raise ArgumentError, "specified prerelease is not SemVer compliant: #{options[:prerelease]}"
          end
          _semver += "-#{options[:prerelease].strip}"
        end
        if options.key?(:metadata) and !(options[:metadata].strip.empty?)
          unless is_valid_semver_metadata?("+#{options[:metadata]}")
            raise ArgumentError, "specified metadata is not SemVer compliant: #{options[:metadata]}"
          end
          _semver += "+#{options[:metadata].strip}"
        end

        return _semver
      end
    end
  end
end
