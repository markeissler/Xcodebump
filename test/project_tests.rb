require 'minitest/autorun'
require 'project'

class ProjectTest < MiniTest::Test
  def setup
    @project = Xcodebump::Project.new
  end

  # test init methods
  def test_init_returns_object
    assert_instance_of(Xcodebump::Project, @project, "Could not init a Project object")
  end

  # test properties
  def test_property_name_implemented
    assert_respond_to(@project, :name)
  end

  def test_property_version_major_implemented
    assert_respond_to(@project, :version_major)
  end

  def test_property_version_minor_implemented
    assert_respond_to(@project, :version_minor)
  end

  def test_property_version_bug_implemented
    assert_respond_to(@project, :version_bug)
  end

  # test instance methods
  def test_method_version_major_raises_TypeError
    assert_raises TypeError do
      @project.version_major = "dummytext"
    end
  end
end
