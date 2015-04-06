#!/bin/sh
xcodebuild -workspace THCCoreData.xcworkspace -scheme 'THCCoreData' -configuration Debug clean test
