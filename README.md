## Xcodebump

This script does the following:

1. Update the Xcode marketing version string (CFBundleShortVersionString) to the releaseVersion supplied.
2. Increment the Xcode build version (CFBundleVersion) to the buildNumber supplied or increment an existing number (extracted from the Info.plist).
3. Commit changes to git.
4. Generate a tag to identify the commit the release/build and tag the commit.

## Why?

The standard tool for manipulating version strings and build numbers in Xcode is *agvtool(1)* after having set your project to use *apple-generic* versioning. Using that tool is a great way to go if you also use CVS or SVN as your VCS because ultimately you will want to checkin your version bumps. Since so many of us have moved on to *git(1)* the need for a better tool is obvious.

With Xcodebump you can specify a marketing version string and everything else will be taken care of for you. That is, Xcodebump will update the CFBundleVersionShortString, increment the CFBundleVersion, generate a commit tag by combining those strings, commit your changes to the current branch, extract that specific commit id, and finally tag the specific commit for your convenience. How cool is that?

## Installation

Copy .xcodebump.sh (script) and .xcodebump.cfg (config) files into the top-level of your Xcode project. Edit the config file parameters and PATH parameters in the script as needed.

**NOTE:** It is intended that you copy **both** of these files into your project so that you won't have to worry about future changes to this code.

### Config file
You should script to setup defaults at the least:

	BUILDVER_START="1.0.0"
	BUILDNUM_START=1

You can also specify the target here so you won't have to supply it on the command line:

	TARGETNAME="MyProject"

### Script PATHs
Verify paths to git, cut, head, grep:

	PATH_GIT="/usr/local/bin/git"
	PATH_CUT="/usr/bin/cut"
	PATH_HEAD="/usr/bin/head"
	PATH_GREP="/usr/local/bin/ggrep"
	
**WARNING: Make sure you point to the correct version of git installed on your machine.**

Note that in the above example both git and ggrep have custom paths. The custom path to grep is absolutely necessary as it must point to a GNU grep, which is not installed on current distributions of OSX. As noted in the .xcodebump.cfg file, you can install that version of grep using [homebrew](http://brew.sh/):

	>brew tap homebrew/dupes
	>brew install homebrew/dupes/grep

The above commands will install the new grep as "ggrep" so you can avoid any potential conflicts with the BSD version of grep native to OSX.
	
## Usage

Once you're ready to create a build (for testing, release, whatever) just run Xcodebump from the top level of your project. The following example would update the marketing version string to "2.5.1" and increment the build number:

	>sh ./.xcodebump.sh 2.5.1
	
The target for the above command is the one specified by the **TARGETNAME** parameter in the config file. You can also specify the TARGETNAME on the command line:

	>sh ./.xcodebump.sh -t MyTarget 2.5.1
	
To get a list of supported command line flags and parameters:

	>sh ./.xcodebump.sh -h

In general, options specified on the command line will override defaults and those found in the config file. There is one exception: if a value is set for tagPrefix in the config file, you can override the value from the command line as long as the override is not an empty string. To clear the tagPrefix, use the -e command line option.

## Release Version
The marketing version string (CFBundleShortVersionString, or releaseVersion) is never changed automatically by Xcodebump: it's a feature, not a bug. In general, it's minimally destructive to create additional builds by bumping the buildNumber, but generating a new releaseVersion should always be viewed as a major event in the development cycle.

## Commit Tags
Xcodebump will generate a commit tag based on tagPrefix, releaseVersion, and buildNumber. The format looks like this:

	build-2.5.1-248
	
Where "build" is a configured tagPrefix string. You can set the tagPrefix on the command line or in the config file. The default is set to "build-".
 
## Todo

This version of Xcodebump expects that your target's Info.plist file is located in the top-level of your project. This limitation will be fixed shortly.

## Bugs and such

Submit bugs by opening an issue on this project's github page.

## License

Xcodebump is licensed under the MIT open source license.

## Appreciation
Like this script? Let me know! You can send some kudos my way courtesy of Flattr:

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=markeissler&url=https://github.com/markeissler/Xcodebump&title=Xcodebump&language=bash&tags=github&category=software)
