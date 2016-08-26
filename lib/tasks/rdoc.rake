#
#  rdoc.rake
#
#  @author Mark Eissler (mark@mixtur.com)
#
require 'rdoc/task'

namespace :doc do
  rdoc_converted_path = 'doc/rdoc_converted'

  desc 'Generate RDoc files from markdown files'
  task :convert_rdoc_markdown, [:paths] do |t, args|
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
        raise ArgumentError, "invalid path specified for markdown file: undefined"
      end
      path_extension = File.extname(path)
      if path_extension != '.md' && path_extension != '.markdown'
        raise ArgumentError, "invalid input file specified, must be markdown format"
      end
      expanded_path = File.expand_path(path)
      markdown_content = File.open(expanded_path, 'r+'){ |file| file.read }
      # formatter = RDoc::Markup::ToHtml.new(RDoc::Options.new, nil)
      formatter = RDoc::Markup::ToRdoc.new(nil)
      rdoc_content = RDoc::Markdown.parse(markdown_content).accept(formatter)

      # write converted file
      filename_rdoc = File.basename(path, '.*') + '.rdoc'
      filename_path = [rdoc_converted_path, filename_rdoc].join('/')
      FileUtils.mkdir_p(rdoc_converted_path) unless File.directory?(rdoc_converted_path)
      File.open(filename_path, 'w+'){ |file| file.write(rdoc_content) }
    end
  end

  desc 'Cleanup RDoc converted markdown files'
  task :clobber_rdoc_converted do
    FileUtils.rm_r(rdoc_converted_path, { force: true, secure: true }) if File.directory?(rdoc_converted_path)
  end

  desc 'Generate ri locally for testing'
  task :ri do
    sh 'rdoc --ri -o ri .'
  end

  desc 'Remove ri products'
  task :clobber_ri do
    rm_r 'ri' rescue nil
  end

  desc 'Generate RDoc documentation'
  RDoc::Task.new do |rdoc|
    rdoc.before_running_rdoc do
      Rake::Task['doc:convert_rdoc_markdown'].invoke(['README.md', 'LICENSE.md', 'Changelog.md'])
    end
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.title    = "#{PKG_NAME}-#{PKG_VERSION} Documentation"
    rdoc.options << '--line-numbers' << 'cattr_accessor=object' << '--charset' << 'utf-8'
    rdoc.template = "#{ENV['template']}.rb" if ENV['template']
    rdoc.main = 'doc/rdoc_converted/README.rdoc'
    rdoc.rdoc_files.include('doc/rdoc_converted/*.rdoc')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('vendor/gems/zapd_core/app/**/*.rb')
    rdoc.rdoc_files.include('vendor/gems/zapd_core/lib/**/*.rb')
  end

  desc 'Cleanup all RDoc generated files'
  task 'clobber' => ['doc:clobber_rdoc', 'doc:clobber_ri', 'doc:clobber_rdoc_converted']
end

