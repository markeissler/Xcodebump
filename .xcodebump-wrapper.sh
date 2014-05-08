#!/bin/bash
#
# STEmacsModelines:
# -*- Shell-Unix-Generic -*-
#
# Simple Xcodebump wrapper script that will call Pods/Xcodebump/.xcodebump.sh.
#
# You may want to add the following line to your .bashrc file...
#
#   alias xcodebump="sh .xcodebump.sh"
#

# Copyright (c) 2014 Mark Eissler, mark@mixtur.com

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
PATH_XCODEBUMP="Pods/Xcodebump/.xcodebump.sh"
if [ ! -x "${PATH_XCODEBUMP}" ]; then
  echo "Unable to find Xcodebump. Have you installed it? If not, update your"
  echo "Podfile and then run:"
  echo
  echo "     >pod install"
  echo
  echo "For more information on Xcodebump, follow this link:"
  echo
  echo "     https://github.com/markeissler/Xcodebump"
  echo
  exit 1
fi

# run it and pass-through cli options!
${PATH_XCODEBUMP} "${@}"
