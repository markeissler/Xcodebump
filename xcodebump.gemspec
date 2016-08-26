#
#
require_relative 'lib/util/file'
include Xcodebump::Util::File

#
# load config, set some constants
#
config = Xcodebump::Util::File.load_config('./lib/version.json')

Gem::Specification.new do |s|
  s.name = config[:appname]
  s.version = config[:version]
  s.licenses = ['MIT']
  s.date = '2016-08-09'
  s.summary = 'Easier manipulation of version and build numbers for Xcode projects.'
  s.descrption = <<-EOF
    Xcodebump lets you specify a marketing version string for your Xcode projects
    and all other aspects of versioning will be taken care of; that is, Xcodebump
    will update the CFBundleVersionShortString, increment the CFBundleVersion,
    generate a commit tag by combining those strings, commit your changes to the
    current branch, extract that specific commit id, and finally tag the specific
    commit for your convenience.
  EOF
  s.authors = ['Mark Eissler']
  s.email = []
  s.files = ['lib/xcodebump.rb']
  s.homepage = 'https://github.com/markeissler/Xcodebump'
  s.require_paths = ['lib']
  s.add_development_dependency 'bundler', '~> 1.4'
  s.add_development_dependency 'rake', '~> 10.4.2'
  s.add_development_dependency 'yard', '0.9.5'
  s.add_development_dependency 'redcarpet', '3.3.4'
end
