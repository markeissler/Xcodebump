# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/xcodebump/util/file'
include Xcodebump::Util::File

#
# load config, set some constants
#
config = Xcodebump::Util::File.load_config('./lib/version.json')

Gem::Specification.new do |spec|
  spec.name = config[:appname]
  spec.version = config[:version]
  spec.authors = ['Mark Eissler']
  spec.email = ['mark@mixtur.com']
  spec.date = '2016-08-09'
  spec.summary = 'Easier manipulation of version and build numbers for Xcode projects.'
  spec.description = <<-EOF
    Xcodebump lets you specify a marketing version string for your Xcode projects
    and all other aspects of versioning will be taken care of; that is, Xcodebump
    will update the CFBundleVersionShortString, increment the CFBundleVersion,
    generate a commit tag by combining those strings, commit your changes to the
    current branch, extract that specific commit id, and finally tag the specific
    commit for your convenience.
  EOF
  spec.homepage = 'https://github.com/markeissler/Xcodebump'
  spec.licenses = ['MIT']

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib', 'lib/xcodebump']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.4.2'
  spec.add_development_dependency 'yard', '0.9.5'
  spec.add_development_dependency 'redcarpet', '3.3.4'
  spec.add_development_dependency 'byebug', '~> 9.0.5'
end
