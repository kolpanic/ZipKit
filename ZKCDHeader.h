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
//  ZKCDHeader.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface ZKCDHeader : NSObject {
@private
	NSUInteger magicNumber;
	NSUInteger versionMadeBy;
	NSUInteger versionNeededToExtract;
	NSUInteger generalPurposeBitFlag;
	NSUInteger compressionMethod;
	NSDate *lastModDate;
	NSUInteger crc;
	unsigned long long compressedSize;
	unsigned long long uncompressedSize;
	NSUInteger filenameLength;
	NSUInteger extraFieldLength;
	NSUInteger commentLength;
	NSUInteger diskNumberStart;
	NSUInteger internalFileAttributes;
	NSUInteger externalFileAttributes;
	unsigned long long localHeaderOffset;
	NSString *filename;
	NSData *extraField;
	NSString *comment;
	NSMutableData *cachedData;
}

+ (ZKCDHeader *) recordWithData:(NSData *)data atOffset:(NSUInteger)offset;
+ (ZKCDHeader *) recordWithArchivePath:(NSString *)path atOffset:(unsigned long long)offset;
- (void) parseZip64ExtraField;
- (NSData *) zip64ExtraField;
- (NSData *) data;
- (NSUInteger) length;
- (BOOL) useZip64Extensions;
- (NSNumber *) posixPermissions;
- (BOOL) isDirectory;
- (BOOL) isSymLink;
- (BOOL) isResourceFork;

@property (assign) NSUInteger magicNumber;
@property (assign) NSUInteger versionMadeBy;
@property (assign) NSUInteger versionNeededToExtract;
@property (assign) NSUInteger generalPurposeBitFlag;
@property (assign) NSUInteger compressionMethod;
@property (retain) NSDate *lastModDate;
@property (assign) NSUInteger crc;
@property (assign) unsigned long long compressedSize;
@property (assign) unsigned long long uncompressedSize;
@property (assign) NSUInteger filenameLength;
@property (assign) NSUInteger extraFieldLength;
@property (assign) NSUInteger commentLength;
@property (assign) NSUInteger diskNumberStart;
@property (assign) NSUInteger internalFileAttributes;
@property (assign) NSUInteger externalFileAttributes;
@property (assign) unsigned long long localHeaderOffset;
@property (copy) NSString *filename;
@property (retain) NSData *extraField;
@property (copy) NSString *comment;
@property (retain) NSMutableData *cachedData;

@end