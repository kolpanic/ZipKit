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
//  ZKCDTrailer64.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKCDTrailer64.h"
#import "NSData+ZKAdditions.h"
#import "ZKDefs.h"

@implementation ZKCDTrailer64

- (id) init {
	if (self = [super init]) {
		self.magicNumber = ZKCDTrailer64MagicNumber;
		self.sizeOfTrailer = 44;
		self.versionMadeBy = 789;
		self.versionNeededToExtract = 45;
		self.thisDiskNumber = 0;
		self.diskNumberWithStartOfCentralDirectory = 0;
	}
	return self;
}

+ (ZKCDTrailer64 *) recordWithData:(NSData *)data atOffset:(NSUInteger)offset {
	if (!data) return nil;
	NSUInteger mn = [data hostInt32OffsetBy:&offset];
	if (mn != ZKCDTrailer64MagicNumber) return nil;
	ZKCDTrailer64 *record = [ZKCDTrailer64 new];
	record.magicNumber = mn;
	record.sizeOfTrailer = [data hostInt64OffsetBy:&offset];
	record.versionMadeBy = [data hostInt16OffsetBy:&offset];
	record.versionNeededToExtract = [data hostInt16OffsetBy:&offset];
	record.thisDiskNumber = [data hostInt32OffsetBy:&offset];
	record.diskNumberWithStartOfCentralDirectory = [data hostInt32OffsetBy:&offset];
	record.numberOfCentralDirectoryEntriesOnThisDisk = [data hostInt64OffsetBy:&offset];
	record.totalNumberOfCentralDirectoryEntries = [data hostInt64OffsetBy:&offset];
	record.sizeOfCentralDirectory = [data hostInt64OffsetBy:&offset];
	record.offsetOfStartOfCentralDirectory = [data hostInt64OffsetBy:&offset];
	return record;
}

+ (ZKCDTrailer64 *) recordWithArchivePath:(NSString *)path atOffset:(unsigned long long)offset {
	NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
	[file seekToFileOffset:offset];
	NSData *data = [file readDataOfLength:ZKCDTrailer64FixedDataLength];
	[file closeFile];
	return [self recordWithData:data atOffset:0];
}

- (NSData *) data {
	NSMutableData *data = [NSMutableData dataWithLittleInt32:self.magicNumber];
	[data appendLittleInt64:self.sizeOfTrailer];
	[data appendLittleInt16:self.versionMadeBy];
	[data appendLittleInt16:self.versionNeededToExtract];
	[data appendLittleInt32:self.thisDiskNumber];
	[data appendLittleInt32:self.diskNumberWithStartOfCentralDirectory];
	[data appendLittleInt64:self.numberOfCentralDirectoryEntriesOnThisDisk];
	[data appendLittleInt64:self.totalNumberOfCentralDirectoryEntries];
	[data appendLittleInt64:self.sizeOfCentralDirectory];
	[data appendLittleInt64:self.offsetOfStartOfCentralDirectory];
	return data;
}

- (NSUInteger) length {
	return ZKCDTrailer64FixedDataLength;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%qu entries @ offset of CD: %qu (%qu bytes)",
			self.numberOfCentralDirectoryEntriesOnThisDisk,
			self.offsetOfStartOfCentralDirectory,
			self.sizeOfCentralDirectory];
}

@synthesize magicNumber, sizeOfTrailer, versionMadeBy, versionNeededToExtract, thisDiskNumber, diskNumberWithStartOfCentralDirectory, numberOfCentralDirectoryEntriesOnThisDisk, totalNumberOfCentralDirectoryEntries, sizeOfCentralDirectory, offsetOfStartOfCentralDirectory;

@end