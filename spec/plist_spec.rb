require 'minitest/spec'
require 'minitest/autorun'
require 'byebug'
require 'plist'

describe Xcodebump::Plist do
  before do
    @plist = Xcodebump::Plist.new()
    @tmp_project_path = "/tmp/xcodebump_test_project/plist_test"
    @tmp_project_file = "test.plist"
    @tmp_project_file_path = [ "#{@tmp_project_path}", "#{@tmp_project_file}" ].join('/')
  end

  # test init methods
  it "can be created with no arguments" do
    _plist = Xcodebump::Plist.new()
    _plist.must_be_instance_of Xcodebump::Plist
  end

  it "can be created with a command argument" do
    _plist = Xcodebump::Plist.new("/usr/libexec/Plistbuddy")
    _plist.must_be_instance_of(Xcodebump::Plist)
  end

  it "implements the file_path property" do
    @plist.must_respond_to :file_path
  end

  it "implements the file_path_raw property" do
    @plist.must_respond_to :file_path_raw
  end

  it "implements the version property" do
    @plist.must_respond_to :version
  end

  it "implements the build property" do
    @plist.must_respond_to :build
  end

  # test instance methods
  it "sets property file_path correctly" do
    @plist.file_path = @tmp_project_file_path
    @plist.file_path.file?.must_equal true
  end

  it "sets property version correctly" do
    _version = "1.0.1"
    @plist.version = _version
    @plist.version.must_match(_version)
  end

  it "raises an ArgumentError unless version is passed a SemVer compliant String" do
    lambda { @plist.version = "1.0.1-" }.must_raise ArgumentError
  end

  it "sets property build correctly" do
    _build = "123"
    @plist.build = _build
    @plist.build.must_match(_build)
  end

  it "raises an ArgumentError unless build is passed a SemVer compliant String" do
    lambda { @plist.version = "@beta123" }.must_raise ArgumentError
  end

  it "responds to the find method" do
    @plist.must_respond_to :find
  end

  it "responds to the read method" do
    @plist.must_respond_to :read
  end

  it "responds to the write method" do
    @plist.must_respond_to :write
  end

  it "responds to the write_safe method" do
    @plist.must_respond_to :write_safe
  end

  it "responds to the bump_build method" do
    @plist.must_respond_to :bump_build
  end

  it "can bump the prerelease number correctly" do
    _version = "1.0.1"
    _build = "alpha.1"
    @plist.version = _version
    @plist.build = _build
    @plist.bump_build(true)
    @plist.build.must_match("alpha.2")
  end

  it "can increment the build number correctly" do
    _version = "1.0.1"
    _build = "alpha.2+124"
    @plist.version = _version
    @plist.build = _build
    @plist.bump_build()
    @plist.build.must_match("alpha.2+125")
  end

  it "can find the first plist matching the given name (Info.plist) in a directory" do
    @plist.find(@tmp_project_path, @tmp_project_file).must_be_instance_of ::String
  end

  it "can read the plist at file_path" do
    @plist.file_path = @tmp_project_file_path
    @plist.read().must_equal true
  end

  it "can write the plist at file_path" do
    @plist.file_path = @tmp_project_file_path
    @plist.version = "1.2.3"
    @plist.build = "4.5.6"
    @plist.write().must_equal true
  end

  it "raises a Xcodebump::Plist::MissingPlistSettingError unless version is set when calling write_safe()" do
    @plist.file_path = @tmp_project_file_path
    @plist.build = "4.5.6"
    lambda { @plist.write_safe() }.must_raise Xcodebump::Plist::MissingPlistSettingError
  end

  it "raises a Xcodebump::Plist::MissingPlistSettingError unless build is set when calling write_safe()" do
    @plist.file_path = @tmp_project_file_path
    @plist.version = "1.2.3"
    lambda { @plist.write_safe() }.must_raise Xcodebump::Plist::MissingPlistSettingError
  end

  it "can safely write the plist at file_path if all required settings were set" do
    @plist.file_path = @tmp_project_file_path
    @plist.version = "1.2.3"
    @plist.build = "4.5.6"
    @plist.write_safe().must_equal true
  end

  it "can update the plist with correct version" do
    @plist.file_path = @tmp_project_file_path
    @plist.read()
    _old_version = @plist.version
    _new_version = "1.2.4"
    @plist.version = _new_version
    @plist.write_safe()
    @plist.read()
    (_new_version != _old_version && @plist.version == _new_version).must_equal true
  end

  it "can update the plist with correct build" do
    @plist.file_path = @tmp_project_file_path
    @plist.read()
    _old_build = @plist.build
    _new_build = "4.5.7"
    @plist.build = _new_build
    @plist.write_safe()
    @plist.read()
    (_new_build != _old_build && @plist.build == _new_build).must_equal true
  end
end