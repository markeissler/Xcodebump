
1.2.2 / 2016-08-04
==================

  * Update README to clarify how release promotion works.
  * Add support to allow creating a release without committing further changes.

1.2.1 / 2016-08-04
==================

  * Bugfix. Init ADDCONFIG.

1.2.0 / 2016-08-04
==================

  * Add Changelog.
  * Add support for copying example config file to current directory.
  * Fix pattern match for podspec url.
  * Only call showPodspec if there is a podspec!
  * Update README with manual install instructions.
  * Remove deprecated support installation with Cocoapods.
  * Rename files for traditional install.
  * Fix findInfoPlist() func to search for TARGET/Info.plist as well.

mx-1.1.5 / 2014-05-08
=====================

  * Implemented better info functionality.
  * Bugfix. We were checking for an executable core script but we don't want to set execution bits on install.
  * Updated documentation for Cocoapods.
  * Implemented support for Cocoapods.

mx-1.1.4 / 2014-05-08
=====================

  * Fixed documentation regarding return values in isSemver() function.

mx-1.1.3 / 2014-04-30
=====================

  * Bugfix. Debug code for outputting cli setting of BUILDVER was in wrong place.

mx-1.1.2 / 2014-04-29
=====================

  * Updated README to discuss the idea of build promotion when creating a release.

mx-1.1.1 / 2014-04-29
=====================

  * Implemented plist and podspec summary functions.
  * Added -i (info) option. Improved formatting of some status messages.
  * Bugfix. The BUILDNUM for releases was supposed to have an r prefix instead of f.
  * Implemented notion of promoting a build to a release.

mx-1.1.0 / 2014-04-27
=====================

  * Updated documentation for podspec support.
  * Added preliminary podspec support.

mx-1.0.3 / 2014-04-22
=====================

  * Added support for specifying the path to a TARGET-Info.plist file.
  * Added support for searching for the TARGET-Info.plist. 

mx-1.0.2 / 2014-04-22
=====================

  * Added support for a tagPrefix string.

mx-1.0.1 / 2014-04-21
=====================

  * Updated references to .xcodebump to include filename extension.
  * Added .sh extension to facilitate running the script.

mx-1.0.0 / 2014-04-21
=====================

  * Initial release.
