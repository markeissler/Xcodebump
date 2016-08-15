require 'rake/testtask'
require 'fileutils'
require 'Open3'

test_task = Rake::TestTask.new :test do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_tests.rb', 'spec/**/*_spec.rb']
  t.verbose = true
end

desc "Run tests"
task :default => :test
task :test => ["test:git:cleanup", "test:git:prepare"]

# single file:
#   >rake test TEST=spec/vcs_spec.rb
namespace :test do
  desc "Run tests for single file"
  task :file, [:path] => ["test:git:cleanup", "test:git:prepare"] do |t, args|
    printf "Testing single file: #{args.path}...\n\n"
    test_task.test_files = FileList[args.path]
    Rake::Task[:test].invoke
  end

  desc "Prepare for Git tests"
  namespace :git do
      _tmp_project_path = "/tmp/xcodebump_test_project"
      _tmp_project_file = "test.txt"
      _tmp_project_tag = "build-1.0.1-b329"
      _tmp_project_message = "Updated build to #{_tmp_project_tag}"
      _tmp_project_file_path = [ "#{_tmp_project_path}", "#{_tmp_project_file}" ].join('/')
    task :prepare do |t|
      printf "Preparing for new Git tests..."
      # make a fake git project in /tmp
      FileUtils.rm_r(_tmp_project_path, { force: true, secure: true}) if File.directory?(_tmp_project_path)
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
      # remove fake git project in /tmp
      FileUtils.rm_r(_tmp_project_path, { force: true, secure: true}) if File.directory?(_tmp_project_path)
      printf " Done!\n"
    end
  end
end
