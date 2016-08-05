## Xcodebump

This script does the following:

1. Update the Xcode marketing version string (CFBundleShortVersionString) to the releaseVersion supplied.
2. Increment the Xcode build version (CFBundleVersion) to the buildNumber supplied or increment an existing number (extracted from the Info.plist).
3. Update an associated podspec file (for use when building distributable frameworks).
4. Commit changes to git.
5. Generate a tag to identify the commit the release/build and tag the commit.

**NOTE:** Podspec support is under active development and therefore unstable.

## Why?

The standard tool for manipulating version strings and build numbers in Xcode is *agvtool(1)* after having set your project to use *apple-generic* versioning. Using that tool is a great way to go if you also use CVS or SVN as your VCS because ultimately you will want to checkin your version bumps. Since so many of us have moved on to *git(1)* the need for a better tool is obvious.

With Xcodebump you can specify a marketing version string and everything else will be taken care of for you. That is, Xcodebump will update the CFBundleVersionShortString, increment the CFBundleVersion, generate a commit tag by combining those strings, commit your changes to the current branch, extract that specific commit id, and finally tag the specific commit for your convenience. How cool is that?

## Installation

The suggested installation involves copying the Xcodebump files into your home directory, followed by the creation of an alias pointing to the script.

1 - Create the Xcodebump directory in your home directory:

```
	>mkdir ~/.xcodebump
```

2 - Copy script and templates:

```
	>cp xcodebump.sh ~/.xcodebump
	>cp xcodebump.sh-example.cfg ~/.xcodebump/xcodebump.sh
	>chmod 755 ~/.xcodebump/xcodebump.sh
	>cp xcodebump-example.cfg ~/.xcodebump/xcodebump-example.cfg
	>chmod 644 ~/.xcodebump/xcodebump-example.cfg
```

3 - Add an alias to your `.bashrc` file:

```
	# xcodebump support
	alias xcodebump="sh ~/.xcodebump/xcodebump.sh"
```

**NOTE:** These instructions assume `bash` is your default shell. An alternative to the above alias is to create the following symlink in your `~/bin` directory (provided that you have that directory and it is contained in your search path):

```
	>ln -s ~/.xcodebump/xcodebump.sh ~/bin/xcodebump
```

### Cocoapods
>Due to technical and mission changes in the cocoapods project, it is no longer possible to install Xcodebump via cocoapods.

### Config file
Copy an example config file into the current directory:
```
	>xcodebump -a
```
Rename the example file to ".xcodebump.cfg" or it will be ignored. At a minimum, you should setup the following parameters in the configuration file:

	BUILDVER_START="1.0.0"
	BUILDNUM_START=1

You can also specify the target here so you won't have to supply it on the command line:

	TARGETNAME="MyProject"

### Info.plist path
Xcodebump will search the current directory for the appropriate Info.plist file based on the TARGETNAME using *find(1)*. Under some circumstances you may need to manually specify the path:

	>xcodebump -l MyTarget/Info.plist 2.5.1
	
### Script PATHs
Verify paths to grep, sed, git:

	PATH_GREP="/usr/local/bin/ggrep"
	PATH_SED="/usr/local/bin/gsed"
	PATH_GIT="/usr/local/bin/git"

It is unlikely you'll have to edit any remaining PATHs that are defined in the script as they point to system defaults.

The custom path to grep is absolutely necessary as it must point to GNU grep), which is not installed on current distributions of OSX. As noted in the .xcodebump.cfg file, you can install GNU grep using [homebrew](http://brew.sh/):

	>brew tap homebrew/dupes
	>brew install grep

The above commands will install the GNU grep as "ggrep" (instead of just "grep") so you can avoid any potential conflicts with the BSD version of grep native to OSX.

You will also need to install GNU sed in the same way:

	>brew install gnu-sed

The above commands will install the new sed as "gsed" so you can avoid any potential conflicts with the BSD version of grep native to OSX.

Configure a custom path to git if you've installed (and have been using) another version on your system.

**WARNING: Make sure you point to the correct version of git on your machine.**
	
## Usage

Once you're ready to create a build (for testing, release, whatever) just run Xcodebump from the top level of your project. The following example would update the marketing version string to "2.5.1" and increment the build number:

	>xcodebump 2.5.1
	
The target for the above command is the one specified by the **TARGETNAME** parameter in the config file. You can also specify the TARGETNAME on the command line:

	>xcodebump -t MyTarget 2.5.1
	
To get a list of supported command line flags and parameters:

	>xcodebump -h

In general, options specified on the command line will override defaults and those found in the config file. There is one exception: if a value is set for tagPrefix in the config file, you can override the value from the command line as long as the override is not an empty string. To clear the tagPrefix, use the -e command line option.

### Parameter Value Preference
Configured values are considered in this order of preference where each subsequent level is awarded a higher preference:

* .xcodebump.cfg (config file)
* command line options (flag and parameters)

Command line options are always given the highest preference.

## Release Version
The marketing version string (CFBundleShortVersionString, or releaseVersion) is never changed automatically by Xcodebump: it's a feature, not a bug. In general, it's minimally destructive to create additional builds by bumping the buildNumber, but generating a new releaseVersion should always be viewed as a major event in the development cycle. But with that said, support for incrementing the marketing version string will likely be added soon just for the convenience.

When creating a release, you should specify the -r (release) flag, doing so changes the format of the git commit tag and also changes the format of the podspec version flag (see below). The commit tag will include the "r" ("release") character ahead of the build number:

	build-2.5.1-r248

The command would look like this:

	>xcodebump -r -b 4 2.5.1
	
### Release Promotion (from Build)
An important concept is the idea of *release promotion*. When you create a release, you actually promote an existing tagged build. The idea is that once development has completed on a build, the build is tested, and if everything checks out, then you move that build into the release stage.

The release process might result in additional updated files, typically updated documentation (although often times those may have already been updated during development) but in general, the build itself will not change at this point. You will want to tag your repo to identify it as a release, you will likely want to maintain some sort of relationship between the release commit and the build commit it came from. And if you are developing a library or framework that is distributed via Cocoapods, you will want to update your podspec file to point to the correct release commit in the repo. All of these tasks are handled by Xcodebump.

When you specify the -r (release) flag you will also have to specify a buildNumber with the -b (build) flag. Xcodebump will analyze your Info.plist file and will only attempt to create a release if the buildNumber and releaseVersion that you specified match those found the aforementioned files. If the parameters match, then the podspec file will be updated as documented in the Podspec Support section below.

## Commit Tags
Xcodebump will generate a commit tag based on tagPrefix, releaseVersion, and buildNumber. The format looks like this:

	build-2.5.1-b248
	
Where "build" is a configured tagPrefix string. You can set the tagPrefix on the command line or in the config file. The default is set to "build-". The tagPrefix can be suppressed with the -e flag.

	>xcodedbump.sh -e 2.5.1

## Multiple Targets
There is no specific support for projects with multiple targets at this time. Just run Xcodebump for each target separately.

## Podspec Support
Preliminary support for updating a podspec file is under development. This is very much a moving target right now. Current support includes updating the version and source strings in a podspec file, but this requires that the podspec file follows a specific (more or less "common") format.

To update a podspec file, specify the -u (update-podspec) flag and the -w (url-podspec) flag at a minimum. The name of the podspec file will be assumed to be "TARGET.podspec" and the current directory will be searched. You can also specify a path to the podspec explicitly with the -s (path-podspec) flag.

	>xcodebump -u -e -w "'https://github.com/USERNAME/'" 2.5.1

In the above example, the user supplied a base url, in which case the "TARGET.git" string would be appended. You can also specify the entire url. The above command will result in the following changes:

	TARGET.plist
		CFBundleShortVersionString:	 2.5.1-bXXX
		CFBundleVersion: 2.5.1-bXXX
		
	TARGET.podspec
		s.version = '2.5.1-bXXX'
		s.source: { :git => 'https://github.com/USERNAME/TARGET.git', 
			:branch => 'develop', :tag => '2.5.1-bXXX' }
		
	Where XXX is a build number. Note that the tagPrefix has been suppressed.

Running the command for a release like this:

	>xcodebump -r -u -e -w "'https://github.com/USERNAME/'" 2.5.1

Will result in the following changes:

	TARGET.plist
		CFBundleShortVersionString:	 2.5.1
		CFBundleVersion: 2.5.1-rXXX
		
	TARGET.podspec
		s.version = '2.5.1'
		s.source: { :git => 'https://github.com/USERNAME/TARGET.git', 
			:branch => 'master', :tag => '2.5.1-rXXX' }
		
	Where XXX is a build number. Note that the tagPrefix has been suppressed.

The dash and build number sequence are only included for non-release builds because SemVer format associates this pattern with "pre-release" version strings.

## Bugs and such

Submit bugs by opening an issue on this project's github page.

## License

Xcodebump is licensed under the MIT open source license.
