require 'rake/testtask'
require 'date'
require 'fileutils'
require 'json'
require 'open3'
require 'pathname'
require 'byebug'

require_relative 'lib/xcodebump/util/file'
include Xcodebump::Util::File

#
# load config, set some constants
#
config = Xcodebump::Util::File.load_config('./lib/version.json')

PKG_DISPLAY_NAME   = config[:appname]
PKG_NAME           = PKG_DISPLAY_NAME.downcase.gsub(/\s/, '-')
PKG_VERSION        = config[:version]

# load all rake tasks
Dir.glob(File.expand_path("../lib/tasks/*.rake", __FILE__)).each do |file|
  import file
end

test_task = Rake::TestTask.new :test do |t|
  t.libs << 'lib/xcodebump'
  t.test_files = FileList['test/**/*_tests.rb', 'spec/**/*_spec.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test
task :test => ["test:prepare"]

# single file:
#   >rake test TEST=spec/vcs_spec.rb
namespace :test do
  test_tmp_project_path = "/tmp/xcodebump_test_project"

  desc "Run tests for single file"
  task :file, [:path] => ["test:prepare"] do |t, args|
    printf "Testing single file: #{args.path}...\n\n"
    test_task.test_files = FileList[args.path]
    Rake::Task[:test].invoke
  end

  desc "Prepare for tests"
  task :prepare do |t|
    printf "Preparing for tests..."
    # make master test directory in /tmp
    FileUtils.rm_r(test_tmp_project_path, { force: true, secure: true }) if File.directory?(test_tmp_project_path)
    FileUtils.mkdir_p(test_tmp_project_path) unless File.directory?(test_tmp_project_path)
    printf " Done!\n"
    # call other prepare tasks as needed
    Rake::Task["test:git:prepare"].invoke
    Rake::Task["test:plist:prepare"].invoke
  end

  desc "Cleanup for tests"
  task :cleanup do |t|
    # call other prepare tasks as needed
    Rake::Task["test:git:cleanup"].invoke
    Rake::Task["test:plist:cleanup"].invoke
    # remove master test directory in /tmp
    printf "Cleaning up remaining files..."
    FileUtils.rm_r(test_tmp_project_path, { force: true, secure: true }) if File.directory?(test_tmp_project_path)
    printf " Done!\n"
  end

  desc "Prepare for Git tests"
  namespace :git do
    _tmp_project_path = [test_tmp_project_path, "git_test"].join('/')
    _tmp_project_file = "test.txt"
    _tmp_project_tag = "build-1.0.1-b329"
    _tmp_project_message = "Updated build to #{_tmp_project_tag}"
    _tmp_project_file_path = [ "#{_tmp_project_path}", "#{_tmp_project_file}" ].join('/')
    task :prepare => [:cleanup] do |t|
      printf "Preparing for new Git tests..."
      # make git directory in /tmp project directory
      FileUtils.rm_r(_tmp_project_path, { force: true, secure: true }) if File.directory?(_tmp_project_path)
      FileUtils.mkdir_p(_tmp_project_path) unless File.directory?(_tmp_project_path)
      File.open(_tmp_project_file_path, 'w') do |f|
        f.puts "Example test file!"
      end

      # git init directory
      _rslt, _status = Open3.capture2("git -C #{_tmp_project_path} init")
      # git add test files
      _rslt, _status = Open3.capture2("git -C #{_tmp_project_path} add \"#{_tmp_project_file}\"")
      # git commit test files
      _rslt, _status = Open3.capture2("git -C #{_tmp_project_path} commit -m \"#{_tmp_project_message}\"")
      # git tag commit
      _rslt, _status = Open3.capture2("git -C #{_tmp_project_path} tag \"#{_tmp_project_tag}\"")

      printf " Done!\n"
    end

    desc "Cleanup for Git tests"
    task :cleanup do |t|
      printf "Cleaning up old Git tests (if present)..."
      # remove git directory in /tmp project directory
      FileUtils.rm_r(_tmp_project_path, { force: true, secure: true }) if File.directory?(_tmp_project_path)
      printf " Done!\n"
    end
  end

  desc "Prepare for Plist tests"
  namespace :plist do
    _tmp_project_path = [test_tmp_project_path, "plist_test"].join('/')
    _tmp_project_plist_file = "test.plist"
    _tmp_project_plist_file_path = [ "#{_tmp_project_path}", "#{_tmp_project_plist_file}" ].join('/')
    _tmp_project_plist_executable = "XcodebumpTest"
    _tmp_project_plist_bundleid = "com.markeissler.xcdodebump-test"
    _tmp_project_plist_vers_short = "0.0.1"
    _tmp_project_plist_vers_build = "123"
    _tmp_project_plist_copyright = "Copyright \u00a9 #{DateTime.now.strftime("%Y")} Felix Unger. All rights reserved."

    task :prepare => [:cleanup] do |t|
      printf "Preparing for new Plist tests..."
      # make plist directory in /tmp project directory
      FileUtils.rm_r(_tmp_project_path, { force: true, secure: true }) if File.directory?(_tmp_project_path)
      FileUtils.mkdir_p(_tmp_project_path) unless File.directory?(_tmp_project_path)
      # create plist file
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleDevelopmentRegion", "string", "en"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleExecutable", "string", "#{_tmp_project_plist_executable}"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleIdentifier", "string", "#{_tmp_project_plist_bundleid}"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleName", "string", "#{_tmp_project_plist_executable}"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundlePackageType", "string", "AAPL"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleShortVersionString", "string", "#{_tmp_project_plist_vers_short}"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleVersion", "string", "#{_tmp_project_plist_vers_build}"])
      run_plist_command("add", _tmp_project_plist_file_path, [":CFBundleSignature", "string", "????"])
      run_plist_command("add", _tmp_project_plist_file_path, [":NSHumanReadableCopyright", "string", "#{_tmp_project_plist_copyright}"])
      run_plist_command("add", _tmp_project_plist_file_path, [":NSMainNibFile", "string", "MainMenu"])
      run_plist_command("add", _tmp_project_plist_file_path, [":NSPrincipalClass", "string", "NSApplication"])
      printf " Done!\n"
    end

    desc "Cleanup for Plist tests"
    task :cleanup do |t|
      printf "Cleaning up old Plist tests (if present)..."
      # remove plist directory in /tmp project directory
      FileUtils.rm_r(_tmp_project_path, { force: true, secure: true }) if File.directory?(_tmp_project_path)
      printf " Done!\n"
    end
  end
end

def run_plist_command(command, file_path, args=[])
  _plist_path = Pathname.new("/usr/libexec/PlistBuddy")
  begin
    _plist_path_resolved = _plist_path.realpath
    raise unless _plist_path_resolved.file?
  rescue
    raise ArgumentError, "unable to locate PlistBuddy utility, did you install it?"
  end
  if command.empty?
    raise ArgumentError, "command parameter required but not supplied"
  end
  # add args to command, we need to provide command and args in one quoted string
  _args_string = args.join(" ")
  _stdout, _stderr, _status = Open3.capture3("\"#{_plist_path_resolved}\" -c \"#{command} #{_args_string}\" \"#{file_path}\"")
end
