#
#  rdoc.rake
#
#  @author Mark Eissler (mark@mixtur.com)
#
require 'rdoc/task'

namespace :doc do
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
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.title    = "#{PKG_NAME}-#{PKG_VERSION} Documentation"
    rdoc.options << '--line-numbers' << 'cattr_accessor=object' << '--charset' << 'utf-8'
    rdoc.template = "#{ENV['template']}.rb" if ENV['template']
    rdoc.rdoc_files.include('README.md', 'LICENSE.md', 'Changelog.md')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.rdoc_files.include('app/**/*.rb')
    rdoc.rdoc_files.include('vendor/gems/zapd_core/app/**/*.rb')
    rdoc.rdoc_files.include('vendor/gems/zapd_core/lib/**/*.rb')
    rdoc.main = 'README.md'
  end

  desc 'Cleanup all RDoc generated files'
  task 'clobber' => ['doc:clobber_rdoc', 'doc:clobber_ri']
end

