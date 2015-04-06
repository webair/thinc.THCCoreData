#!/bin/sh
set -e

gem install cocoapods --no-rdoc --no-ri --no-document --quiet
pod install
