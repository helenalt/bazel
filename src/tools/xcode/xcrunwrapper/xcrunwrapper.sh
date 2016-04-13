#!/bin/bash
#
# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# xcrunwrapper runs the command passed to it using xcrun.
# It replaces __BAZEL_XCODE_DEVELOPER_DIR__ with $DEVELOPER_DIR (or reasonable
# default) and __BAZEL_XCODE_SDKROOT__ with a valid path based on SDKROOT (or
# reasonable default).
# These values (__BAZEL_XCODE_*) are a shared secret withIosSdkCommands.java.

set -eu

# Pick values for DEVELOPER_DIR and SDKROOT as appropriate (if they weren't set)

WRAPPER_DEVDIR="${DEVELOPER_DIR:-}"
if [[ -z "${WRAPPER_DEVDIR}" ]] ; then
  WRAPPER_DEVDIR="$(xcode-select -p)"
fi

# TODO(blaze-team): Remove this once all build environments are setting SDKROOT
# for us.
WRAPPER_SDKROOT="${SDKROOT:-}"
if [[ -z "${WRAPPER_SDKROOT:-}" ]] ; then
  WRAPPER_SDK=iphonesimulator
  for ARG in "$@" ; do
    case "${ARG}" in
      armv6|armv7|armv7s|arm64)
        WRAPPER_SDK=iphoneos
        ;;
      i386|x86_64)
        WRAPPER_SDK=iphonesimulator
        ;;
    esac
  done
  WRAPPER_SDKROOT="$(/usr/bin/xcrun --show-sdk-path --sdk ${WRAPPER_SDK})"
fi

UPDATEDARGS=()
for ARG in "$@" ; do
  ARG="${ARG//__BAZEL_XCODE_DEVELOPER_DIR__/${WRAPPER_DEVDIR}}"
  ARG="${ARG//__BAZEL_XCODE_SDKROOT__/${WRAPPER_SDKROOT}}"
  UPDATEDARGS+=("${ARG}")
done

/usr/bin/xcrun "${UPDATEDARGS[@]}"