ZipKit
======

ZipKit is an Objective-C framework for reading and writing Zip archives in Mac OS X and iOS apps. It supports:
* the standard [PKZip format](http://www.pkware.com/documents/casestudies/APPNOTE.TXT)
* files larger than 4GB in size using PKZip's zip64 extensions
* optionally, resource forks in a manner compatible with Mac OS X's Archive Utility (in the Mac OS X targets only)
* clean interruption, so archiving can be cancelled by the invoking object (e.g., a NSOperation or NSThread).
* It was developed by Karl Moskowski (aka [@kolpanic](https://twitter.com/kolpanic)) and released under the BSD license.

If you find ZipKit to be useful, please [let me know](http://about.me/kolpanic).

###Requirements

ZipKit requires Xcode 3.1. It works on Mac OS X Leopard 10.5 or greater (garbage collection is supported but not required), and iOS 3.0 or greater.

The Project
The Xcode project contains three targets:
* a Mac OS X framework
* a Mac OS X static library
* an iOS static library

###Using ZipKit

1. If you're using git for your project, first add ZipKit as a submodule to your project. If you're not using git, clone ZipKit into your project's directory; if you're using another VCS, make sure you ignore the ZipKit/ subdirectory.
2. Open your .xcodeproj and drag ZipKit.xcodeproj from the Finder to the Frameworks group in Xcode's Project Navigator for your project.
3. In the Project Navigator for your project, disclose ZipKit's Products and note the product you want to use in your project.
4. In the Project Navigator, select your project at the top, then add the relevant ZipKit product to your target's Linked Frameworks and Libraries section.

See the accompanying demo projects for guidance.
