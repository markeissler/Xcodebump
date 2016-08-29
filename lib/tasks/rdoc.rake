#
#  rdoc.rake
#
#  @author Mark Eissler (mark@mixtur.com)
#
require 'rdoc/task'
require 'byebug'

namespace :doc do
  stripped_files_path = 'doc/rdoc_static'

  namespace :rdoc do
    desc 'Strip badges from static files'
    task :strip, [:paths] do |t, args|
      # paths could be a single string or an array of strings
      paths = nil
      if args.paths.is_a?(::String)
        paths = [args.paths]
      elsif args.paths.is_a?(::Array)
        paths = args.paths
      else
        raise ArgumentError, "invalid argument specified: #{paths.class.to_s}"
      end

      for path in paths do
        if path.nil? || path.strip.empty?
          raise ArgumentError, "invalid path specified for strip file: undefined"
        end
        path_extension = File.extname(path)
        if path_extension != '.md' && path_extension != '.markdown' && path_extension != '.rdoc'
          raise ArgumentError, "invalid input file specified, must be markdown or rdoc format"
        end
        expanded_path = File.expand_path(path)
        static_content = ""
        file = File.open(expanded_path, 'r') do |file|
          file.each_line do |line|
            unless line.match(/^\[\!\[Build Status/) || line.match(/^\[\!\[License/)
              static_content << line
            end
          end
        end

        # write stripped file
        filename_base = File.basename(path)
        filename_path = [stripped_files_path, filename_base].join('/')
        FileUtils.mkdir_p(stripped_files_path) unless File.directory?(stripped_files_path)
        File.open(filename_path, 'w+'){ |file| file.write(static_content) }
      end
    end

    desc 'Cleanup stripped files'
    task :clobber_stripped do
      FileUtils.rm_r(stripped_files_path, { force: true, secure: true }) if File.directory?(stripped_files_path)
    end

    desc 'Generate ri locally for testing'
    task :ri do
      sh 'rdoc --ri -o ri .'
    end

    desc 'Remove ri products'
    task :clobber_ri do
      rm_r 'ri' rescue nil
    end
  end

  desc 'Generate RDoc documentation'
  RDoc::Task.new do |rdoc|
    rdoc.before_running_rdoc do
      Rake::Task['doc:rdoc:strip'].invoke(['README.md'])
      stripped_files_glob = [stripped_files_path, '*.*'].join('/')
      rdoc.rdoc_files.include(stripped_files_glob)
      # update main file if README was stripped
      stripped_readme_path = [stripped_files_path, 'README.md'].join('/')
      if File.file?(stripped_readme_path)
        rdoc.main = stripped_readme_path
      end
    end
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.title    = "#{PKG_NAME}-#{PKG_VERSION} Documentation"
    rdoc.options << '--line-numbers' << 'cattr_accessor=object' << '--charset' << 'utf-8'
    rdoc.template = "#{ENV['template']}.rb" if ENV['template']
    rdoc.rdoc_files.include('LICENSE.md', 'Changelog.md')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.main = 'README.md'
  end

  desc 'Cleanup all RDoc generated files'
  task 'clobber' => ['doc:clobber_rdoc', 'doc:rdoc:clobber_ri', 'doc:rdoc:clobber_stripped']
end

