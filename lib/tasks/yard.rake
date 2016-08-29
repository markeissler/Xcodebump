#
#  yard.rake
#
#  Generate documentation for this project:
#  @example
#    >rake doc
#    (or)
#    >rake doc:yard
#
#  @author Mark Eissler (mark@mixtur.com)
#
require 'rake'
require 'byebug'

begin
  require 'yard'
  require 'yard/rake/yardoc_task'

  namespace :doc do
    yard_output_path = "doc/yard"
    stripped_files_path = 'doc/yard_static'

    namespace :yard do
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
    end

    desc 'Generate Yardoc documentation'
    YARD::Rake::YardocTask.new do |yardoc|
      yardoc.name = 'yard'
      yardoc.options = [
        '--no-yardopts',
        '--no-cache',
        '--output-dir', yard_output_path,
        '--verbose',
        '--protected',
        '--private',
        '--embed-mixins',
        '--template', 'default',
        '--template-path', 'doc/yard_templates',
      ]
      yardoc.options += ['--title', "#{PKG_NAME}-#{PKG_VERSION} Documentation"]
      yardoc.options += ['--markup', "markdown"]
      yardoc.before = Proc.new do
        Rake::Task['doc:yard:strip'].invoke(['README.md'])
        stripped_files_glob = [stripped_files_path, '*.*'].join('/')
        yardoc.files += [
          stripped_files_glob
        ]
        # update readme file if README was stripped
        stripped_readme_path = [stripped_files_path, 'README.md'].join('/')
        if File.file?(stripped_readme_path)
          yardoc.options += [
            '--readme', "#{stripped_files_path}/README.md",
          ]
        else
          yardoc.options += [
            '--readme', "README.md",
          ]
        end
      end
      yardoc.files += [
        'lib/**/*.rb'
      ]
      # yardoc extra files
      #
      # NOTE: The '-' is necessary to flag extra files.
      #
      yardoc.files += [
        '-',
        'Changelog.md',
        'LICENSE.md'
      ]
    end

    # cleanup the yard generated files
    desc 'Remove Yard HTML files'
    task :clobber_yard do
      FileUtils.rm_r(yard_output_path, { force: true, secure: true }) if File.directory?(yard_output_path)
    end

    desc 'Cleanup all Yard generated files'
    task 'clobber' => ['doc:clobber_yard', 'doc:yard:clobber_stripped']
  end

  desc 'Alias to doc:yard'
  task 'doc' => 'doc:yard'
rescue LoadError
  # Yard not available? Let's try rdoc instead!
  desc 'Alias to doc:rdoc'
  task 'doc' => 'doc:rdoc'

rescue LoadError
  # yard not installed (gem install yard)
  # http://yardoc.org
end
