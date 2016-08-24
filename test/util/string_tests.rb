require 'minitest/autorun'
require 'util/string'
require 'date'

class XcodebumpUtilString < MiniTest::Test
  include Xcodebump::Util::String

  def setup
    @valid_semver_list = [
      "1.0.1",
      "1.0.1-alpha",
      "1.0.1-b.12",
      "1.0.1-beta.123+456",
      "1.0.1-beta+exp.sha.5114f85"
    ]

    @invalid_semver_list = [
      "1",
      "1.0",
      "1.0.",
      "1.0.1-alpha.",
      "1.0.1-@beta"
    ]

    @valid_semver_normal_list = [
      "0.7.0",
      "1.1.23",
      "1.23.456"
    ]

    @invalid_semver_normal_list = [
      "0",
      "1",
      "1.0",
      "1.2.b",
      "a.b.c",
      "1.0.1-alpha"
    ]

    @valid_semver_prerelease_list = [
      "-b",
      "-b.b",
      "-beta",
      "-beta.123",
      "-123",
      "-0.3.7"
    ]

    @invalid_semver_prerelease_list = [
      "b",
      "-b@",
      "-b0-7",
      "-b1.#"
    ]

    @valid_semver_metadata_list = [
      "+001",
      "+20130313144700",
      "+exp.sha.5114f85"
    ]

    @invalid_semver_metadata_list = [
      "-001",
      "+abcd-we13",
      "abcd12143"
    ]
  end

  # test method is_valid_semver
  def test_is_valid_semver_with_valid_data
    for _valid_string in @valid_semver_list
      assert(self.is_valid_semver?(_valid_string), "Method is_valid_semver? returned false for valid string: #{_valid_string} ")
    end
  end

  def test_is_valid_semver_with_invalid_data
    for _invalid_string in @invalid_semver_list
      assert(!self.is_valid_semver?(_invalid_string), "Method is_valid_semver? returned true for invalid string: #{_invalid_string} ")
    end
  end

  def test_is_valid_semver_normal_with_valid_data
    for _valid_string in @valid_semver_normal_list
      assert(self.is_valid_semver_normal?(_valid_string), "Method is_valid_semver_normal? returned false for valid string: #{_valid_string} ")
    end
  end

  def test_is_valid_semver_normal_with_invalid_data
    for _invalid_string in @invalid_semver_normal_list
      assert(!self.is_valid_semver_normal?(_invalid_string), "Method is_valid_semver_normal? returned true for invalid string: #{_invalid_string} ")
    end
  end

  def test_is_valid_semver_prerelease_with_valid_data
    for _valid_string in @valid_semver_prerelease_list
      assert(self.is_valid_semver_prerelease?(_valid_string), "Method is_valid_semver_prerelease? returned false for valid string: #{_valid_string} ")
    end
  end

  def test_is_valid_semver_prerelease_with_invalid_data
    for _invalid_string in @invalid_semver_prerelease_list
      assert(!self.is_valid_semver_prerelease?(_invalid_string), "Method is_valid_semver_prerelease? returned true for invalid string: #{_invalid_string} ")
    end
  end

  def test_is_valid_semver_metadata_with_valid_data
    for _valid_string in @valid_semver_metadata_list
      assert(self.is_valid_semver_metadata?(_valid_string), "Method is_valid_semver_metadata? returned false for valid string: #{_valid_string} ")
    end
  end

  def test_is_valid_semver_metadata_with_invalid_data
    for _invalid_string in @invalid_semver_metadata_list
      assert(!self.is_valid_semver_metadata?(_invalid_string), "Method is_valid_semver_metadata? returned true for invalid string: #{_invalid_string} ")
    end
  end

  def test_increment_semver_prerelease_with_valid_data
    _valid_input_string = "1.2.1-build.2+abcd.we13"
    _expected_output_string = "1.2.1-build.3+abcd.we13"
    assert_equal(_expected_output_string, self.increment_semver_prerelease(_valid_input_string))
  end

  def test_increment_semver_prerelease_with_invalid_data
    _invalid_input_string = "1.0.1-@beta"
    assert_raises ArgumentError do
      self.increment_semver_prerelease(_invalid_input_string)
    end
  end

  def test_increment_semver_metadata_with_valid_data
    _valid_input_string = "1.2.1-build.2+abcd.we13"
    _expected_output_string = "1.2.1-build.2+abcd.we14"
    assert_equal(_expected_output_string, self.increment_semver_metadata(_valid_input_string))
  end

  def test_increment_semver_metadata_with_invalid_data
    _invalid_input_string = "1.0.1-@beta"
    assert_raises ArgumentError do
      self.increment_semver_metadata(_invalid_input_string)
    end
  end

  def test_increment_semver_metadata_with_valid_date_metadata
    _valid_input_string = "1.2.1-build.2+abcd.we.20130313144700"
    _unexpected_output_string = "1.2.1-build.2+abcd.we.20130313144701"
    refute_equal(_unexpected_output_string, self.increment_semver_metadata(_valid_input_string))
  end

  def test_parse_semver_with_valid_data
    _valid_input_string = "1.2.1-build.2+abcd.we13"
    _expected_output_array = ["1.2.1", "build.2", "abcd.we13"]
    assert_equal(_expected_output_array, self.parse_semver(_valid_input_string))
  end

  def test_parse_semver_with_valid_data_and_strip_separators_is_false
    _valid_input_string = "1.2.1-build.2+abcd.we13"
    _expected_output_array = ["1.2.1", "-build.2", "+abcd.we13"]
    assert_equal(_expected_output_array, self.parse_semver(_valid_input_string, false))
  end

  def test_parse_semver_with_invalid_data
    _invalid_input_string = "1.0.1-@beta"
    assert_raises ArgumentError do
      self.parse_semver(_invalid_input_string)
    end
  end
end
