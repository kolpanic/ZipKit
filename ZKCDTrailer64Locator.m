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
//  ZKCDTrailer64Locator.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKCDTrailer64Locator.h"
#import "NSData+ZKAdditions.h"
#import "ZKDefs.h"

@implementation ZKCDTrailer64Locator

- (id) init {
	if (self = [super init]) {
		self.magicNumber = ZKCDTrailer64LocatorMagicNumber;
		self.diskNumberWithStartOfCentralDirectory = 0;
		self.numberOfDisks = 1;
	}
	return self;
}

+ (ZKCDTrailer64Locator *) recordWithData:(NSData *)data atOffset:(NSUInteger) offset {
	NSUInteger mn = [data hostInt32OffsetBy:&offset];
	if (mn != ZKCDTrailer64LocatorMagicNumber) return nil;
	ZKCDTrailer64Locator *record = [ZKCDTrailer64Locator new];
	record.magicNumber = mn;
	record.diskNumberWithStartOfCentralDirectory = [data hostInt32OffsetBy:&offset];
	record.offsetOfStartOfCentralDirectoryTrailer64 = [data hostInt64OffsetBy:&offset];
	record.numberOfDisks = [data hostInt32OffsetBy:&offset];
	return record;
}

+ (ZKCDTrailer64Locator *) recordWithArchivePath:(NSString *)path andCDTrailerLength:(NSUInteger)cdTrailerLength {
	NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
	unsigned long long fileOffset = [file seekToEndOfFile] - cdTrailerLength - ZKCDTrailer64LocatorFixedDataLength;
	[file seekToFileOffset:fileOffset];
	NSData *data = [file readDataOfLength:ZKCDTrailer64LocatorFixedDataLength];
	[file closeFile];
	return [self recordWithData:data atOffset:0];
}

- (NSData *) data {
	NSMutableData *data = [NSMutableData dataWithLittleInt32:self.magicNumber];
	[data appendLittleInt32:self.diskNumberWithStartOfCentralDirectory];
	[data appendLittleInt64:self.offsetOfStartOfCentralDirectoryTrailer64];
	[data appendLittleInt32:self.numberOfDisks];
	return data;
}

- (NSUInteger) length {
	return ZKCDTrailer64LocatorFixedDataLength;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"offset of CD64: %qu", self.offsetOfStartOfCentralDirectoryTrailer64];
}

@synthesize magicNumber, diskNumberWithStartOfCentralDirectory, offsetOfStartOfCentralDirectoryTrailer64, numberOfDisks;

@end