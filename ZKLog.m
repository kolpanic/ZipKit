// ================================================================
// Copyright (c) 2009, Data Deposit Box
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above
//   copyright notice, this list of conditions and the following disclaimer
//   in the documentation and/or other materials provided with the
//   distribution.
// * Neither the name of Data Deposit Box nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ================================================================
//
//  ZKLog.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKLog.h"

NSString* const ZKLogLevelKey = @"ZKLogLevel";
NSString* const ZKLogToFileKey = @"ZKLogToFile";

@implementation ZKLog

- (void) logFile:(char*) sourceFile lineNumber:(NSUInteger) lineNumber level:(NSUInteger) level format:(NSString*) format, ... {
	if (level >= self.minimumLevel) {
		va_list args;
		va_start(args, format);
		NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
		va_end(args);
		NSString *label = [self levelToLabel:level];
		NSString *now = [self.dateFormatter stringFromDate:[NSDate date]];
		if (label) {
			fprintf(stderr, "%s [%i] %s %s (%s:%u)\r\n",
					[now UTF8String], self.pid, [label UTF8String], [message UTF8String],
					[[[NSString stringWithUTF8String:sourceFile] lastPathComponent] UTF8String], lineNumber);
			fflush(stderr);
		}
	}
	return;
}

- (NSUInteger) minimumLevel {
	return minimumLevel;
}
- (void) setMinimumLevel:(NSUInteger) value {
	switch (value) {
		case ZKLogLevelError:
		case ZKLogLevelNotice:
		case ZKLogLevelDebug:
		case ZKLogLevelAll:
			minimumLevel = value;
			break;
		default:
			ZKLogError(@"Invalid logging level: %u. Old value %@ unchanged.", value, [self levelToLabel:self.minimumLevel]);
			break;
	}
	return;
}

- (NSString *) levelToLabel:(NSUInteger) level {
	NSString *label = nil;
	switch (level) {
		case ZKLogLevelError:
			label = @"<ERROR->";
			break;
		case ZKLogLevelNotice:
			label = @"<Notice>";
			break;
		case ZKLogLevelDebug:
			label = @"<Debug->";
			break;
		default:
			label = nil;
			break;
	}
	return label;
}

static ZKLog *sharedInstance = nil;
+ (ZKLog *) sharedInstance {
	@synchronized(self) {
		if (sharedInstance == nil) {
			[self new];
		}
	}
	return sharedInstance;
}

- (id) init {
	@synchronized([self class]) {
		if (sharedInstance == nil) {
			if (self = [super init]) {
				sharedInstance = self;
				
				self.pid = [[NSProcessInfo processInfo] processIdentifier];
				self.minimumLevel = ZKLogLevelError;
				self.dateFormatter = [NSDateFormatter new];
				[self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
				
				if ([[NSUserDefaults standardUserDefaults] boolForKey:ZKLogToFileKey]) {
					NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
					NSString *libraryFolder = [searchPaths objectAtIndex:0];
					NSString *logFolder = [libraryFolder stringByAppendingPathComponent:@"Logs"];
					[[NSFileManager new] createDirectoryAtPath:logFolder withIntermediateDirectories:YES attributes:nil error:nil];
					self.logFilePath = [logFolder stringByAppendingPathComponent:
										[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"] 
										 stringByAppendingPathExtension:@"log"]];
					freopen([self.logFilePath fileSystemRepresentation], "a+", stderr);
				}
			}
		}
	}
	return sharedInstance;
}

+ (id) allocWithZone:(NSZone *) zone {
	@synchronized(self) {
		if (sharedInstance == nil) {
			return [super allocWithZone:zone];
		}
	}
	return sharedInstance;
}

+ (void) initialize {
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:ZKLogToFileKey]];
	[super initialize];
}

- (id) copyWithZone:(NSZone *) zone {
	return self;
}

- (void) finalize {
	if (self.logFilePointer)
		fclose(self.logFilePointer);
	[super finalize];
}

@synthesize dateFormatter, pid, logFilePath, logFilePointer;
@dynamic minimumLevel;

@end