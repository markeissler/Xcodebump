require 'minitest/autorun'
require 'xcodebump'

class ApplicationTest < MiniTest::Test
  def setup
    @app = Xcodebump::Application.new
  end

  # test init methods
  def test_init_returns_object
    assert_instance_of(Xcodebump::Application, @app, "Could not in an Application object")
  end

  # test class methods

  # test instance methods
  def test_method_run_implemented
    assert_respond_to(@app, :run, "Method not implemented")
  end

  def test_method_config_copy_implemented
    assert_respond_to(@app, :config_copy, "Method not implemented")
  end

  def test_method_build_implemented
    assert_respond_to(@app, :build, "Method not implemented")
  end

  def test_method_config_path_implemented
    assert_respond_to(@app, :config_path, "Method not implemented")
  end
end
