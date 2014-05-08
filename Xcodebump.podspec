#
# STEmacsModelines:
# -*- Ruby -*-
#
Pod::Spec.new do |s|
  s.name           = "Xcodebump"
  s.version        = "1.1.5"
  s.license        = "MIT"
  s.authors        = { "Mark Eissler" => "mark@mixtur.com" }
  s.summary        = "Easier manipulation of version and build numbers for Xcode projects."
  s.description    = <<-DESC
    Easier manipulation of version and build numbers for Xcode projects. Xcodebump takes care of the dirty work when incrementing Xcode builds by updating the marketing version string (CFBundleShortVersionString), incrementing the build version (CFBundleVersion), updating a podspec (if applicable), and finally committing and tagging (in git).
  DESC
  s.homepage       = "https://github.com/markeissler/Xcodebump"
  s.source         = { :git => "https://github.com/markeissler/Xcodebump.git", :tag => "mx-#{s.version}" }
  s.preserve_paths = ".xcodebump.sh", ".xcodebump-wrapper.sh", ".xcodebump-example.cfg"
  s.requires_arc   = false
  s.prepare_command = <<-CMD
      cp ".xcodebump-wrapper.sh" "../../.xcodebump.sh"
      if [ ! -f "../../.xcodebump.cfg" ]; then
        cp ".xcodebump-example.cfg" "../../.xcodebump-example.cfg"
      fi
  CMD
end