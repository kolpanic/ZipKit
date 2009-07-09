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
//  ZKLog.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

enum ZKLogLevel {
	ZKLogLevelNotice = 3,
	ZKLogLevelError = 2,
	ZKLogLevelDebug = 1,
	ZKLogLevelAll = 0,
};

#define ZKLog(s, l, ...) [[ZKLog sharedInstance] logFile:__FILE__ lineNumber:__LINE__ level:l format:(s), ## __VA_ARGS__]

#define ZKLogError(s, ...) ZKLog((s), ZKLogLevelError, ## __VA_ARGS__)
#define ZKLogNotice(s, ...) ZKLog((s), ZKLogLevelNotice, ## __VA_ARGS__)
#define ZKLogDebug(s, ...) ZKLog((s), ZKLogLevelDebug, ## __VA_ARGS__)

#define ZKLogWithException(e) ZKLogError(@"Exception in %@: \n\tname: %@\n\treason: %@\n\tuserInfo: %@", NSStringFromSelector(_cmd), [e name], [e reason], [e userInfo]);
#define ZKLogWithError(e) ZKLogError(@"Error in %@: \n\tdomain: %@\n\tcode: %@\n\tdescription: %@", NSStringFromSelector(_cmd), [e domain], [e code], [e localizedDescription]);

#define ZKStringFromBOOL(b) (b ? @"YES": @"NO")

extern NSString* const ZKLogLevelKey;
extern NSString* const ZKLogToFileKey;

@interface ZKLog : NSObject {
@private
	NSUInteger minimumLevel;
	NSDateFormatter *dateFormatter;
	int pid;
	NSString *logFilePath;
	FILE *logFilePointer;
}

- (void) logFile:(char*) sourceFile lineNumber:(NSUInteger) lineNumber level:(NSUInteger) level format:(NSString*) format, ...;

- (NSString *) levelToLabel:(NSUInteger) level;

+ (ZKLog *) sharedInstance;

@property (assign) NSUInteger minimumLevel;
@property (retain) NSDateFormatter *dateFormatter;
@property (assign) int pid;
@property (copy) NSString *logFilePath;
@property (assign) FILE *logFilePointer;

@end