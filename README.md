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
* an OS X framework
* an OS X static library
* an iOS static library

###Using ZipKit

1. If you're using git for your project, first add ZipKit as a submodule to your project. If you're not using git, clone ZipKit into your project's directory; if you're using another VCS, make sure you ignore the ZipKit/ subdirectory.
2. Open your .xcodeproj and drag ZipKit.xcodeproj from the Finder to the Frameworks group in Xcode's Project Navigator for your project.
3. In the Project Navigator for your project, disclose ZipKit's Products and note the product you want to use in your project.
4. In the Project Navigator, select your project at the top, then add the relevant ZipKit product to your target's Linked Frameworks and Libraries section, and add it to the your target's Target Dependencies under Build Phases.
5. You may also have to add ./ZipKit/ to your target's User Header Search Paths setting.

See the accompanying demo projects for guidance.

###Demo Projects
* [ZipKit Utility](https://github.com/kolpanic/ZipKit-Utility) - an OS X Cocoa application
* [zku](https://github.com/kolpanic/zku) - an OS X command line tool
* [ZipKit Touch](https://github.com/kolpanic/ZipKit-Touch) - an iOS application

####Notes
1. If you're using Mac OS X < 10.7 or iOS < 5.0, make sure you "git checkout 1.0.0". That tag supports GC and manual memory management.
2. This project was originally hosted at [Bitbucket](https://bitbucket.org/kolpanic/zipkit). It was transferred using [fast-export](https://github.com/frej/fast-export), and all open issues were manually copied here.
