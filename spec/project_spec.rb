require 'minitest/spec'
require 'minitest/autorun'

require 'project'
require 'release_type'

describe Xcodebump::Project do
  before do
    @project = Xcodebump::Project.new
  end

  # test init methods
  it "can be created with no argumuments" do
    @project.must_be_instance_of Xcodebump::Project
  end

  # test properties
  it "implements the name property" do
    @project.must_respond_to :name
  end

  it "implements the version_major property" do
    @project.must_respond_to :version_major
  end

  it "implements the version_minor property" do
    @project.must_respond_to :version_minor
  end

  it "implements the version_bug property" do
    @project.must_respond_to :version_bug
  end

  it "implements the build property" do
    @project.must_respond_to :build
  end

  it "implements the release_type property" do
    @project.must_respond_to :release_type
  end

  it "implements the repo property" do
    @project.must_respond_to :repo
  end

  it "implements the info_plist property" do
    @project.must_respond_to :info_plist
  end

  it "implements the pod_spec property" do
    @project.must_respond_to :pod_spec
  end

  # test instance methods
  it "raises a TypeError unless name= is passed a String" do
    lambda { @project.name = 100 }.must_raise TypeError
  end

  it "sets property name correctly" do
    @project.name = "Transporter"
    @project.name.must_equal "Transporter"
  end

  it "raises a TypeError unless version_major= is passed an Integer" do
    lambda { @project.version_major = "dummytext" }.must_raise TypeError
  end

  it "sets property version_major correctly" do
    @project.version_major = 1
    @project.version_major.must_equal 1
  end

  it "raises a TypeError unless version_minor= is passed an Integer" do
    lambda { @project.version_minor = "dummytext" }.must_raise TypeError
  end

  it "sets property version_minor correctly" do
    @project.version_minor = 1
    @project.version_minor.must_equal 1
  end

  it "raises a TypeError unless version_bug= is passed an Integer" do
    lambda { @project.version_bug = "dummytext" }.must_raise TypeError
  end

  it "sets property version_bug correctly" do
    @project.version_bug = 1
    @project.version_bug.must_equal 1
  end

  it "raises a TypeError unless build= is passed an Integer" do
    lambda { @project.build = "dummytext" }.must_raise TypeError
  end

  it "sets property build correctly" do
    @project.build = 1
    @project.build.must_equal 1
  end

  it "raises a TypeError unless release_type= is passed a ReleaseType" do
    lambda { @project.release_type = "dummytext" }.must_raise TypeError
  end

  it "sets property release_type correctly" do
    @project.release_type = ReleaseType.new("release")
    @project.release_type.must_be_instance_of(Xcodebump::ReleaseType)
  end

  it "raises a TypeError unless repo= is passed a VCS" do
    lambda { @project.repo = "dummytext" }.must_raise TypeError
  end

  it "sets property repo correctly" do
    @project.repo = Git.new()
    @project.repo.must_be_instance_of(Xcodebump::Git)
  end

  it "raises a TypeError unless info_plist= is passed a Plist" do
    lambda { @project.info_plist = "dummytext" }.must_raise TypeError
  end

  it "sets property info_plist correctly" do
    @project.info_plist = Plist.new()
    @project.info_plist.must_be_instance_of(Xcodebump::Plist)
  end

  it "raises a TypeError unless pod_spec= is passed a Podspec" do
    lambda { @project.pod_spec = "dummytext" }.must_raise TypeError
  end

  it "sets property pod_spec correctly" do
    @project.pod_spec = Podspec.new()
    @project.pod_spec.must_be_instance_of(Xcodebump::Podspec)
  end
end
