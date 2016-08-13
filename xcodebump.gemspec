Gem::Specification.new do |s|
  s.name = 'xcodebump'
  s.version = '2.0.0'
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
end
