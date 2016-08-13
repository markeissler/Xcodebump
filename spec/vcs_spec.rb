require 'minitest/spec'
require 'minitest/autorun'
require 'byebug'
require 'vcs'

describe Xcodebump::VCS do
  before do
    @vcs = Xcodebump::VCS.new
  end

  # test init methods
  it "can be created with no arguments" do
    @vcs.must_be_instance_of Xcodebump::VCS
  end

  it "can be created with a path" do
    _vcs = Xcodebump::VCS.new("/tmp/test")
    _vcs.must_be_instance_of(Xcodebump::VCS)
  end

  # test properties
  it "implements the command_path property" do
    @vcs.must_respond_to :command_path
  end

  it "implements the working_directory property" do
    @vcs.must_respond_to :working_directory
  end

  it "implements the tag_prefix property" do
    @vcs.must_respond_to :tag_prefix
  end

  # test instance methods
  it "raises a TypeError unless command_path= is passed a String" do
    lambda { @vcs.command_path = 100 }.must_raise TypeError
  end

  it "sets property command_path correctly" do
    @vcs.command_path = "/usr/bin/git"
    @vcs.command_path.file?.must_equal true
  end

  it "sets property working_directory correctly" do
    @vcs.working_directory = "/tmp"
    @vcs.working_directory.directory?.must_equal true
  end

  it "sets property tag_prefix correctly" do
    @vcs.tag_prefix = "test-"
    @vcs.tag_prefix.must_equal "test-"
  end

  it "implements the escape_string method" do
    @vcs.must_respond_to :escape_string
  end
end