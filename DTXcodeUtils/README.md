# DTXcodeUtils

[![Version](https://img.shields.io/cocoapods/v/DTXcodeUtils.svg?style=flat)](http://cocoadocs.org/docsets/DTXcodeUtils)
[![License](https://img.shields.io/cocoapods/l/DTXcodeUtils.svg?style=flat)](http://cocoadocs.org/docsets/DTXcodeUtils)
[![Platform](https://img.shields.io/cocoapods/p/DTXcodeUtils.svg?style=flat)](http://cocoadocs.org/docsets/DTXcodeUtils)

## Usage

This is a collection of useful helper functions I am developing to make writing Xcode plugins easier. They
provide access to various parts of Xcode internals by calling into Xcode's private APIs.

An example of how to use the library is included in the Example directory. This shows how to make a simple
plugin which toggles Xcode's syntax highlighting on or off.

To run the example project, clone the repo, and run `pod install` from the Example directory. Open the resulting
xcworkspace in Xcode and run the Example target. This should install the example plugin in the IDE. After
restarting Xcode, you should get a "Toggle Highlighting" option in the Xcode Edit menu.

## Installation

DTXcodeUtils is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DTXcodeUtils"

## License

DTXcodeUtils is available under the Creative Commons Zero license. See the LICENSE file for more info.
