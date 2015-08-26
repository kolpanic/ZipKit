#
#  Be sure to run `pod spec lint ZipKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ZipKit"
  s.version      = "1.0.3"
  s.summary      = "An Objective-C Zip framework for Mac OS X and iOS."

  s.description  = <<-DESC
	ZipKit is an Objective-C framework for reading and writing Zip archives 
	in Mac OS X and iOS apps. It supports the standard PKZip format, files 
	larger than 4GB in size using PKZip's zip64 extensions, optionally, 
	resource forks in a manner compatible with Mac OS X's Archive 
	Utility (in the Mac OS X targets only), and clean interruption so archiving 
	can be cancelled by the invoking object (e.g., a NSOperation or NSThread).
                   DESC

  s.homepage     = "https://github.com/kolpanic/ZipKit"

  s.license      = { :type => "BSD", :file => "COPYING.TXT" }

  s.authors            = { "Karl Moskowski" => "kmoskowski@me.com" }
  s.social_media_url   = "http://twitter.com/kolpanic"

  s.ios.deployment_target = "6.1"
  s.osx.deployment_target = "10.8"

  s.source       = { :git => "https://github.com/kolpanic/ZipKit.git", :tag => "1.0.3" }

  s.source_files  = "**/*.{h,m}"
  s.ios.exclude_files = "GMAppleDouble"

  s.ios.frameworks = "Foundation"
  s.osx.frameworks = "Foundation", "CoreServices"
  s.library   = "z"

  s.requires_arc = true

end
