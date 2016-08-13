require 'minitest/spec'
require 'minitest/autorun'
require 'byebug'
require 'git'
require 'date'
require 'fileutils'
require 'tmpdir'

describe Xcodebump::Git do
  before do
    @tag = "build-1.0.1-b329"
    @working_directory = "/tmp/xcodebump_test_project"
    @git = Xcodebump::Git.new(@working_directory)
  end

  # test init methods
  it "can be created with no arguments" do
    @git.must_be_instance_of Xcodebump::Git
  end

  it "can be created with a path and command argument" do
    _git = Xcodebump::Git.new("/tmp/xcodebump_test_project", "git")
    _git.must_be_instance_of(Xcodebump::Git)
  end

  # test properties

  # test instance methods
  it "returns a correct value when current_branch method is called" do
    @git.current_branch.must_be_instance_of String
  end

  it "returns a correct value when current_commit_hash is called" do
    @git.current_commit_hash.must_be_instance_of String
  end

  it "returns a correct value when is_existing_tag? is called with an existing tag" do
    @git.is_existing_tag?(@tag).must_equal true
  end

  it "returns a correct value when is_existing_tag is called with a non-existing tag" do
    @git.is_existing_tag?("zzzz123456").must_equal false
  end

  it "returns a correct value when is_valid_refname? is called with a valid tag (format)" do
    @git.is_valid_refname?(@tag).must_equal true
  end

  it "returns a correct value when is_valid_refname? is called with an invalid tag (format)" do
    @git.is_valid_refname?("[my-invalid-tag?").must_equal false
  end

  it "can write a new commit to an existing repo" do
    _tmp_project_path = "/tmp/xcodebump_test_project"
    _tmp_project_file = "test2.txt"
    _tmp_project_tag = "build-1.0.1-b330"
    _tmp_project_message = "Updated build to #{_tmp_project_tag}"
    _tmp_project_file_path = [ "#{_tmp_project_path}", "#{_tmp_project_file}" ].join('/')
    File.open(_tmp_project_file_path, 'w+') do |f|
      f.puts DateTime.now.to_s
    end
    @git.write_commit(_tmp_project_message).must_equal true
  end

  it "cannot write a new commit to a non-existing repo" do
    @git.working_directory = Dir.mktmpdir("xcodebump_test_")
    @git.write_commit("just a test message").must_equal false
    FileUtils.rm_r(@git.working_directory, { force: true, secure: true}) if File.directory?(@git.working_directory)
  end

  it "can write a new lightweight tag" do
    @git.write_tag("build-1.0.1-bTEST_lightweight-tag").must_equal true
  end

  it "can write a new annotated tag" do
    @git.write_tag("build-1.0.1-bTEST_annotated-tag", "Annotated tag!").must_equal true
  end

end