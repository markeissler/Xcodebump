require 'minitest/autorun'
require 'release_type'

class ReleaseType < MiniTest::Test
  def setup
  end

  # test init methods
  def test_init_without_args_returns_object
    _release_type = Xcodebump::ReleaseType.new
    assert_instance_of(Xcodebump::ReleaseType, _release_type, "Could not init a ReleaseType object")
  end

  def test_init_with_args_returns_object
    _release_type = Xcodebump::ReleaseType.new("beta")
    assert_instance_of(Xcodebump::ReleaseType, _release_type, "Could not init a ReleaseType object")
  end

  def test_init_with_invalid_args_raises_TypeError
    lambda { Xcodebump::ReleaseType.new("blue") }.must_raise TypeError
  end

  # test for values
  def test_init_for_beta_returns_object
    assert_instance_of(Xcodebump::ReleaseType, Xcodebump::ReleaseType.new("beta"), "Could not init a ReleaseType object for beta")
  end

  def test_init_for_release_returns_object
    assert_instance_of(Xcodebump::ReleaseType, Xcodebump::ReleaseType.new("release"), "Could not init a ReleaseType object for beta")
  end

  # test properties
  def test_property_type_implemented
    _release_type = Xcodebump::ReleaseType.new("beta")
    assert_respond_to(_release_type, :type)
  end
end