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

begin
  require 'yard'
  require 'yard/rake/yardoc_task'

  namespace :doc do
    yard_output_path = "doc/yard"

    desc 'Generate Yardoc documentation'
    YARD::Rake::YardocTask.new do |yardoc|
      yardoc.name = 'yard'
      yardoc.options = [
        '--readme', 'README.md',
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
      yardoc.files = [
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
    task 'clobber' => ['doc:clobber_yard']
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
