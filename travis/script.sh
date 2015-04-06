#!/bin/sh
set -e

xcodebuild -workspace THCCoreData.xcworkspace -scheme 'THCCoreData' -configuration Debug clean test