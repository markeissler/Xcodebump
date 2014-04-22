#!/usr/bin/bash
#
# STEmacsModelines:
# -*- Shell-Unix-Generic -*-
#
# This script does the following:
# 1. Update the Xcode marketing version string (CFBundleShortVersionString) to
#   the releaseVersion supplied.
# 2. Increment the Xcode build number (CFBundleVersion) to the bundleVersion
#   supplied or increment an existing number.
# 3. Commit changes to git.
# 4. Generate a tag to identify the commit the release/build and tag the commit.
#
# Dependency: Gnu Grep is required to support PCRE regex. On OSX you will have
# to install this version of grep. Use homebrew. See instructions below.
#

# Copyright (c) 2014 Mark Eissler

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

PATH_GIT="/usr/bin/git"
PATH_CUT="/usr/bin/cut"
PATH_HEAD="/usr/bin/head"

# Install gnu grep via homebrew... (this will not symlink for you)
#
# >brew tap homebrew/dupes
# >brew install homebrew/dupes/grep
#
# This will install the new grep as "ggrep" to avoid any conflicts with the BSD
# version of grep native to OSX.
#
PATH_GREP="/usr/local/bin/ggrep"


###### NO SERVICABLE PARTS BELOW ######
VERSION=1.0.1
PROGNAME=`basename $0`

# standard config file location
PATH_CONFIG=".xcodebump.cfg"
PATH_PLIST_BUDDY="/usr/libexec/PlistBuddy"

# reset internal vars (do not touch these here)
DEBUG=0
FORCEEXEC=0
GETOPT_OLD=0
TARGETNAME=""
BUILDNUM=-1
BUILDNUM_START=1
BUILDVER=-1
BUILDVER_START="1.0.0"
PATH_PLIST=""

#
# FUNCTIONS
#
function usage {
  if [ ${GETOPT_OLD} -eq 1 ]; then
    usage_old
  else
    usage_new
  fi
}

function usage_new {
cat << EOF
usage: ${PROGNAME} [options] releaseVersion

Update the marketing and build numbers for the xcode project. This script will
grab the info from the command line or configuration file.

OPTIONS:
   -b, --build buildNumber  Sets build to buildNumber specified
   -d, --debug              Turn debugging on (increases verbosity)
   -c, --config filePath    Path to config file (overrides default)
   -t, --target targetName  Sets target to work on
   -f, --force              Execute updates without user prompt
   -h, --help               Show this message
   -v, --version            Output version of this script

EOF
}

# support for old getopt (non-enhanced, only supports short param names)
#
function usage_old {
cat << EOF
usage: ${PROGNAME} [options] releaseVersion

Update the marketing and build numbers for the xcode project. This script will
grab the info from the command line or configuration file.

OPTIONS:
   -b Sets build to buildNumber specified
   -d Turn debugging on (increases verbosity)
   -c Path to config file (overrides default)
   -t Sets target to work on
   -f Execute updates without user prompt
   -h Show this message
   -v Output version of this script

EOF
}

function version {
  echo ${PROGNAME} ${VERSION};
}

# cleanString
#
# Pass a variable name and this function will determine its current value, clean
# up the value, and then assign it back to the variable. This is tricky because
# we will dereference the var in order to access its value.
#
# Given a variable ${example} - or - $example, you will want to access this
# function like this:
#
#   cleanString example
#
# Not:
#
#   cleanString ${example} - or - cleanString $example
#
# Because the latter two will past the value and not the name of the variable.
# Which means we wouldn't be able to dereference it and assign a new value.
#
function cleanString {
  # remove quotes (leading or trailing, single or double)
  if [ -n "${1}" ]; then
    # fetch name of variable passed in arg1
    _argVarName=\$${1}
    # get the current value of the variable
    _argVarValue=`eval "expr ${_argVarName}"`
    # clean up the value (1) - remove leading/trailing quotes (single or double)
    _argVarValue_Clean=$(echo ${_argVarValue} | sed "s/^[\'\"]//" |  sed "s/[\'\"]$//" );
    # clean up the value (2) - convert encoded values to unencoded
    _argVarValue_Clean=$(echo ${_argVarValue_Clean} |  sed 's@%3D@=@g' |  sed 's@%3A@:@g' | sed 's@%2F@\\/@g' );

    # assign the cleaned up value to the variable passed in arg1
    eval "${1}=\${_argVarValue_Clean}"
  fi
}

# Support for urlEncode and urlDecode string manipulation.
#
export LANG=C

# urlEncode()
#
# Encode a string to html encoded.
#
# See: http://blogs.gnome.org/shaunm/2009/12/05/urlencode-and-urldecode-in-sh/
#
urlencode() {
  local arg
  arg="$1"
  while [[ "$arg" =~ ^([0-9a-zA-Z/:_\.\-]*)([^0-9a-zA-Z/:_\.\-])(.*) ]] ; do
    echo -n "${BASH_REMATCH[1]}"
    printf "%%%X" "'${BASH_REMATCH[2]}'"
    arg="${BASH_REMATCH[3]}"
  done
  # the remaining part
  echo -n "$arg"
}

# urlDecode()
#
# Decode an html encoded string.
#
# See: http://blogs.gnome.org/shaunm/2009/12/05/urlencode-and-urldecode-in-sh/
#
function urlDecode() {
  arg="$1"
  i="0"
  while [ "$i" -lt ${#arg} ]; do
    c0=${arg:$i:1}
    if [ "x$c0" = "x%" ]; then
      c1=${arg:$((i+1)):1}
      c2=${arg:$((i+2)):1}
      printf "\x$c1$c2"
      i=$((i+3))
    else
      echo -n "$c0"
      i=$((i+1))
    fi
  done
}

# isNumber()
#
function isNumber() {
  if [[ ${1} =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
    echo 1; return 0
  else
    echo 0; return 1
  fi
}

# semverToArray()
#
# Split a SemVer format version string (e.g. "1.0.0") into an array. We will
# write back the array to the variable that is passed to us.
#
# Call like this:
#
#   BUILDSTRING="1.2.3"
#   semverToArray BUILDSTRING
#   for e in "${BUILDSTRING[@]}"
#   do
#     echo $e
#   done
#
function semverToArray() {
  if [ -n "${1}" ]; then
    # fetch name of variable passed in arg1
    _argVarName=\$${1}
    # get the current value of the variable
    _argVarValue=`eval "expr ${_argVarName}"`
    # clean up the value (1) - remove leading/trailing quotes (single or double)
    _argVarValue_Clean=$(echo ${_argVarValue} | sed "s/^[\'\"]//" |  sed "s/[\'\"]$//" );

    # split into array, parse on dot character
    array=(${_argVarValue_Clean//./ })
    # if [[ ${DEBUG} -ne 0 ]]; then
    #   for i in "${array[@]}"
    #   do
    #     echo $i
    #   done
    # fi

    # assign the array to the variable passed in arg1
    eval "${1}=(\${array[@]})"
  fi
}

# isSemver()
#
# Check if string arg is in SemVer (1.0.0) format.
#
# NOTE: The return pattern here is structured so that all of the following tests
# will work because we echo a value and set the return status...
#
#  STAT=$(isSemver "${BUILDVER}")
#  STAC=$?
#  if [[ ${STAC} -eq 1 ]]; then
#
# - or -
#  if [[ $(isSemver "${BUILDVER}") -eq 0 ]]; then
#
# - or -
#  if [ ! $(isSemver "${BUILDVER}") ]; then
#
function isSemver() {
  if [[ -z "${1}" ]]; then
    echo 0; return 1;
  fi

  isSemverArgArray=${1}
  semverToArray isSemverArgArray
  if [[ ${#isSemverArgArray[@]} -ne 3 ]]; then
    echo 0; return 1;
  fi

  # check each element to make sure it is a number
  for elem in "${isSemverArgArray[@]}"
  do
    isSemverArgArrayElement=${elem}
    if [[ $(isNumber "${isSemverArgArrayElement}") -eq 0 ]] || [[ ${isSemverArgArrayElement} -lt 0 ]]; then
      echo 0; return 1;
    fi
  done

  # got this far, we must have a valid SemVer string!
  echo 1; return 0;
}

# isGnuGrep()
#
# Checks for GNU Grep which supports PCRE (perl-type regex).
#
function isGnuGrep() {
  if [[ -z "${1}" ]]; then
    echo 0; return 1;
  fi

  RESP=$({ ${1} -V | ${PATH_HEAD} -n 1; } 2>&1 )
  RSLT=$?
  if [[ ! $RESP =~ "${1} (GNU grep)" ]]; then
    echo 0; return 1;
  fi

  echo 1; return 0;
}

# promptConfirm()
#
# Confirm a user action. Input case insensitive.
#
# Returns "yes" or "no" (default).
#
function promptConfirm() {
  read -p "$1 ([y]es or [N]o): "
  case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
    y|yes) echo "yes" ;;
    *)     echo "no" ;;
  esac
}

# parse cli parameters
#
# Our options:
#   --build, b
#   --config, c
#   --target, t
#   --debug, d
#   --force, f
#   --help, h
#   --version, v
#
params=""
getopt -T > /dev/null
if [ $? -eq 4 ]; then
  # GNU enhanced getopt is available
  PROGNAME=`basename $0`
  params="$(getopt --name "$PROGNAME" --long build:,config:,target:,force,help,version,debug --options b:c:t:fhvd -- "$@")"
else
  # Original getopt is available
  GETOPT_OLD=1
  PROGNAME=`basename $0`
  params="$(getopt b:c:t:fhvd "$@")"
fi

# check for invalid params passed; bail out if error is set.
if [ $? -ne 0 ]
then
  usage; exit 1;
fi

eval set -- "$params"
unset params

while [ $# -gt 0 ]; do
  case "$1" in
    -b | --build)           cli_BUILDNUM="$2"; shift;;
    -c | --config)          cli_CONFIGPATH="$2"; shift;;
    -t | --target)          cli_TARGETNAME="$2"; shift;;
    -d | --debug)           cli_DEBUG=1; DEBUG=${cli_DEBUG};;
    -f | --force)           cli_FORCEEXEC=1;;
    -v | --version)         version; exit;;
    -h | --help)            usage; exit;;
    --)                     shift; break;;
  esac
  shift
done

# Grab final argument (the release version aka BUILDVER)
shift $((OPTIND-1))
if [ -z "${1}" ]; then
  echo "ABORTING. You must specify a releaseVersion string."
  echo
  usage
  exit 1
else
  BUILDVER=$1
  cleanString BUILDVER
  # use BUILDVER for BUILDVER_START
  BUILDVER_START=${BUILDVER};
  # # make sure BUILDVER
  # BUILDVER_ARRAY=${BUILDVER}
  # semverToArray BUILDVER_ARRAY
  # if [[ ${DEBUG} -ne 0 ]]; then
  #   for elem in "${BUILDVER_ARRAY[@]}"
  #   do
  #     echo "${elem}"
  #   done
  # fi

  # We should now check that the BUILDVER provided is in semVer format, if the
  # array is empty, we can be pretty sure that it isn't. There should be three
  # elements, and each shoudl be a number.
  if [[ $(isSemver "${BUILDVER}") -eq 0 ]]; then
    echo "ABORTING. You have specified a non-conforming releaseVersion. The"
    echo "release version string should conform to SemVer (Semantic Versioning)"
    echo "format."
    exit 1
  fi
fi

if [ "${DEBUG}" -ne 0 ]; then
  echo "BUILDVER set from cli: ${BUILDVER}"
fi


# Grab our config file path from the cli if provided
#
if [ -n "${cli_CONFIGPATH}" ]; then
  cleanString cli_CONFIGPATH;
  PATH_CONFIG=${cli_CONFIGPATH};
fi

# load config
echo
echo "Reading config file..."
echo

# Add RVM to PATH for scripting
# pathadd ${HOME}/.rvm/bin

if [ -s "${PATH_CONFIG}" ]; then
  source "${PATH_CONFIG}" &> /dev/null
else
  echo "ABORTING. The xcodebump config file ("${PATH_CONFIG}") is missing or empty!"
  echo
  exit 1
fi

# Clean up config file parameters
#
cleanString TARGETNAME
cleanString BUILDNUM_START

# Verify grep version
echo "Checking for a compatible version of grep..."
if [[ $(isGnuGrep "${PATH_GREP}") -ne 1 ]]; then
  echo "ABORTING. Couldn't find a compatible version of grep. GNU grep is required."
  echo
  exit 1
fi

# Rangle our vars
#
# The cli_VARS will override config file vars!!
#
if [ -n "${cli_FORCEEXEC}" ]; then
  FORCEEXEC=${cli_FORCEEXEC};
fi

if [ -n "${cli_BUILDNUM}" ]; then
  cleanString cli_BUILDNUM;
  BUILDNUM=${cli_BUILDNUM};
  # use cli_BUIILDNUM for BUILDNUM_START
  BUILDNUM_START=${BUILDNUM};
  # if a number, buildnum must not be negative
  if [[ $(isNumber "${BUILDNUM}") -eq 1 ]] && [[ ${BUILDNUM} -lt 0 ]]; then
    echo "ABORTING. You have specified a Buildnum with a negative value!"
    exit 1
  fi
  # if a string, warn the user!
  if [[ $(isNumber "${BUILDNUM}") -eq 0 ]] && [[ ! -z ${BUILDNUM} ]]; then
    echo "WARNING. You have specificed a Buildnum that is a string."
    # prompt user for confirmation
    if [[ "no" == $(promptConfirm "Update CFBundleVersion key with a string?") || \
      "no" == $(promptConfirm "Are you *really* sure?") ]]
    then
      echo "Aborting."
      exit 1
    fi
  fi
fi

if [ -n "${cli_TARGETNAME}" ]; then
  cleanString cli_TARGETNAME;
  TARGETNAME=${cli_TARGETNAME};
fi

# bail out if minimum config isn't available
if [ -z "${TARGETNAME}" ] || [ -z "${BUILDNUM}" ] || [ -z "${BUILDVER}" ]; then
  usage
  exit 1
fi

# bail out if invalid BUILDNUM_START found
if [ -z "${BUILDNUM_START}" ]; then
  echo "ABORTING. Invalid or missing value for BUILDNUM_START in conif file."
  exit 1
fi

#
# Let's GO!
#

# Grab info from plist
PATH_PLIST="${TARGETNAME}-Info.plist"
if [[ ! -w ${PATH_PLIST} ]]; then
  echo "ABORTING. Unable to open plist file: ${PATH_PLIST}"
  echo
  exit 1
fi

#
# UPDATE CFBundleShortVersionString
#
RESP=$({ $PATH_PLIST_BUDDY -c "Print CFBundleShortVersionString" "${PATH_PLIST}"; } 2>&1 )
RSLT=$?
if [[ $RESP =~ "Print: Entry, \"CFBundleShortVersionString\", Does Not Exist" || ${RSLT} -ne 0 ]]; then
  #
  # Need to add a CFBundleShortVersionString key to plist
  #
  echo "CFBundleShortVersionString key not found in plist file."
  echo
  if [ "${FORCEEXEC}" -eq 0 ]; then
    echo "Ready to add a CFBundleShortVersionString key with start value of: ${BUILDVER_START}"
    # prompt user for confirmation
    if [[ "no" == $(promptConfirm "Add CFBundleShortVersionString key?") || \
      "no" == $(promptConfirm "Are you *really* sure?") ]]
    then
      echo "Aborting."
      exit 1
    fi
  fi

  echo "Adding CFBundleShortVersionString key with start value of: ${BUILDVER_START}"

  RESP=$({ $PATH_PLIST_BUDDY -c "Set CFBundleShortVersionString ${BUILDVER_START}" "${PATH_PLIST}"; } 2>&1 )
  RSLT=$?
  if [[ ${RSLT} -ne 0 ]]; then
    echo "ABORTING. Unable to add CFBundleShortVersionString key to plist file."
    echo "Not sure what the problem is."
    echo
    exit 1
  fi

elif [[ $(isSemver "${RESP}") -eq 0 ]]; then
  #
  # CFBundleShortVersionString exists, but it's not SemVer format!
  #
  echo "CFBundleShortVersionString key found in plist file: ${RESP}"
  echo
  echo "ABORTING. Found a CFBundleShortVersionString in the plist file, but it"
  echo "does not conform to SemVer (Semantic Versioning) format. You will have"
  echo "to fix this manually."
  echo
  exit 1
else
  #
  # Update CFBundleShortVersionString key in plist
  #
  # @TODO!!
  #
  # if [[ ${BUILDVER} -eq -1 ]]; then
  #   # increment existing CFBundleShortVersionString
  #   BUILDVER=$(expr ${RESP} + 1)
  # fi

  RESP=$({ $PATH_PLIST_BUDDY -c "Set CFBundleShortVersionString ${BUILDVER}" "${PATH_PLIST}"; } 2>&1 )
  RSLT=$?
  if [[ ${RSLT} -ne 0 ]]; then
    echo "ABORTING. Unable to update CFBundleShortVersionString key in plist file."
    echo "Not sure what the problem is."
    echo
    exit 1
  fi

  # verify success by re-reading updated value
  RESP=$({ $PATH_PLIST_BUDDY -c "Print CFBundleShortVersionString" "${PATH_PLIST}"; } 2>&1 )
  RSLT=$?
  if [[ ${RSLT} -ne 0 ]]; then
    echo "ABORTING. Unable to verify updated CFBundleShortVersionString key in"
    echo "plist file."
    echo "Not sure what the problem is."
    echo
    exit 1
  fi
  echo "Updated CFBundleShortVersionString key value to: ${RESP}"
  echo
fi


#
# UPDATE CFBundleVersion
#
RESP=$({ $PATH_PLIST_BUDDY -c "Print CFBundleVersion" "${PATH_PLIST}"; } 2>&1 )
RSLT=$?
if [[ $RESP =~ "Print: Entry, \"CFBundleVersion\", Does Not Exist" || ${RSLT} -ne 0 ]]; then
  #
  # Need to add a CFBundleVersion key to plist
  #
  echo "CFBundleVersion key not found in plist file."
  echo
  if [ "${FORCEEXEC}" -eq 0 ]; then
    echo "Ready to add a CFBundleVersion key with start value of: ${BUILDNUM_START}"
    # prompt user for confirmation
    if [[ "no" == $(promptConfirm "Add CFBundleVersion key?") || \
      "no" == $(promptConfirm "Are you *really* sure?") ]]
    then
      echo "Aborting."
      exit 1
    fi
  fi

  echo "Adding CFBundleVersion key with start value of: ${BUILDNUM_START}"

  RESP=$({ $PATH_PLIST_BUDDY -c "Set CFBundleVersion ${BUILDNUM_START}" "${PATH_PLIST}"; } 2>&1 )
  RSLT=$?
  if [[ ${RSLT} -ne 0 ]]; then
    echo "ABORTING. Unable to add CFBundleVersion key to plist file."
    echo "Not sure what the problem is."
    echo
    exit 1
  fi
elif [[ $(isNumber "${RESP}") -eq 0 ]] && [[ ${BUILDNUM} -eq -1 ]]; then
  #
  # CFBundleVersion exists, but it's not a number!
  #
  echo "CFBundleVersion key found in plist file: ${RESP}"
  echo
  echo "ABORTING. Found a CFBundleVersion in the plist file, but it's not an"
  echo "integer. So I can't increment it. You will have to fix this manually."
  echo
  exit 1
else
  #
  # Update CFBundleVersion key in plist by incrementing it
  #
  if [[ ${BUILDNUM} -eq -1 ]]; then
    # increment existing CFBundleVersion
    BUILDNUM=$(expr ${RESP} + 1)
  fi

  RESP=$({ $PATH_PLIST_BUDDY -c "Set CFBundleVersion ${BUILDNUM}" "${PATH_PLIST}"; } 2>&1 )
  RSLT=$?
  if [[ ${RSLT} -ne 0 ]]; then
    echo "ABORTING. Unable to update CFBundleVersion key in plist file."
    echo "Not sure what the problem is."
    echo
    exit 1
  fi

  # verify success by re-reading updated value
  RESP=$({ $PATH_PLIST_BUDDY -c "Print CFBundleVersion" "${PATH_PLIST}"; } 2>&1 )
  RSLT=$?
  if [[ ${RSLT} -ne 0 ]]; then
    echo "ABORTING. Unable to verify updated CFBundleVersion key in plist file."
    echo "Not sure what the problem is."
    echo
    exit 1
  fi
  echo "Updated CFBundleVersion key value to: ${RESP}"
  echo
fi

#
# Checkin to git
#

# When we commit, we will get a line back that includes the commit hash like so:
#
# $ git commit -m "Refactored the fidgety method."
# [develop 109fd18] Refactored the fidgety method.
# 3 files changed, 6 insertions(+), 6 deletions(-)
# ...
#

# create commit tag from BUILDVER and BUILDNUM
#
# NOTE: man git-check-ref-format for valid characters
#
GIT_COMMIT_TAG=${BUILDVER}-${BUILDNUM}

RESP=$({ $PATH_GIT check-ref-format "xxx/${GIT_COMMIT_TAG}"; } 2>&1 )
RSLT=$?
if [[ ${RSLT} -ne 0 ]]; then
  #
  # GIT_COMMIT_TAG is an invalid git refname.
  #
  echo "The generated git commit tag is invalid: ${GIT_COMMIT_TAG}."
  echo
  echo "ABORTING. Consider revising the specified releaseVersion and/or Buildnum."
  echo
  exit 1
fi

# determine current branch so we can extract our commit hash after committing
RESP=$({ $PATH_GIT rev-parse --abbrev-ref HEAD; } 2>&1 )
RSLT=$?
if [[ $RESP =~ "fatal: " || ${RSLT} -ne 0 ]]; then
  #
  # Couldn't determine current branch, maybe we're not in the right directory?
  #
  echo "ABORTING. Couldn't determine current branch or something else went wrong."
  echo "Are you in the correct directory?"
  echo
  exit 1
fi
GIT_CURRENT_BRANCH=${RESP}

# we need to escape GIT_CURRENT_BRANCH to use in a regex
GIT_CURRENT_BRANCH_ESC=$( echo ${GIT_CURRENT_BRANCH} | sed -e 's/[\/&]/\\&/g' )

# add all files and commit
RESP=$({ $PATH_GIT add .; $PATH_GIT commit -am "Updated build to ${GIT_COMMIT_TAG}"; } 2>&1 )
RSLT=$?
if [[ $RESP =~ "fatal: " || ${RSLT} -ne 0 ]]; then
  #
  # Unable to commit?!
  #
  echo "ABORTING. Unable to commit changes to git repo. Maybe you should try and"
  echo "run git manually with the --dry-run flag to see what's wrong."
  echo
  exit 1
fi

# Grab our commit hash, we do it this way because we cannot be sure that another
# commit hasn't occurred after ours and we want to tag *our* commit.
GIT_COMMIT_HASH=$( echo "${RESP}" | ${PATH_GREP} -oP "(?<=\[${GIT_CURRENT_BRANCH_ESC} )[a-f0-9]{7}(?=\])" )

# tag the commit
RESP=$({ $PATH_GIT tag -a -m "Added build tag ${GIT_COMMIT_TAG}" "${GIT_COMMIT_TAG}" ${GIT_COMMIT_HASH}; } 2>&1 )
RSLT=$?
if [[ $RESP =~ "fatal: " || ${RSLT} -ne 0 ]]; then
  #
  # Unable to commit?!
  #
  echo "ABORTING. Unable to apply tag to commit: ${GIT_COMMIT_HASH}"
  echo "Not sure what the problem is."
  echo
  exit 1
fi

echo
echo "All done..."
echo "Release Version (CFBundleShortVersionString) has been set to: ${BUILDVER}"
echo "Build Number (CFBundleVersion) has been set to: ${BUILDNUM}"
echo "Changes have been committed to git branch: ${GIT_CURRENT_BRANCH}"
echo "                               git commit: ${GIT_COMMIT_HASH}"
echo "                               and tagged: ${GIT_COMMIT_TAG}"
echo
echo "WARNING: You still need to push these changes to git remotes."
echo
