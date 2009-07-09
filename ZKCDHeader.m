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
//  ZKCDHeader.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKCDHeader.h"
#import "NSDate+ZKAdditions.h"
#import "NSData+ZKAdditions.h"
#import "NSString+ZKAdditions.h"
#import "ZKDefs.h"
#import "zlib.h"

@implementation ZKCDHeader

- (id) init {
	if (self = [super init]) {
		self.magicNumber = ZKCDHeaderMagicNumber;
		self.versionNeededToExtract = 20;
		self.versionMadeBy = 789;
		self.generalPurposeBitFlag = 0;
		self.compressionMethod = Z_DEFLATED;
		self.lastModDate = [NSDate date];
		self.crc = 0;
		self.compressedSize = 0;
		self.uncompressedSize = 0;
		self.filenameLength = 0;
		self.extraFieldLength = 0;
		self.commentLength = 0;
		self.diskNumberStart = 0;
		self.internalFileAttributes = 0;
		self.externalFileAttributes = 0;
		self.localHeaderOffset = 0;
		self.extraField = nil;
		self.comment = nil;
		
		[self addObserver:self forKeyPath:@"compressedSize" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"uncompressedSize" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"localHeaderOffset" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"extraField" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"filename" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"comment" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}
- (void) finalize {
	self.cachedData = nil;
	[self removeObserver:self forKeyPath:@"compressedSize"];
	[self removeObserver:self forKeyPath:@"uncompressedSize"];
	[self removeObserver:self forKeyPath:@"localHeaderOffset"];
	[self removeObserver:self forKeyPath:@"extraField"];
	[self removeObserver:self forKeyPath:@"filename"];
	[self removeObserver:self forKeyPath:@"comment"];
	[super finalize];
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
	if ([keyPath isEqualToString:@"compressedSize"]
		|| [keyPath isEqualToString:@"uncompressedSize"]
		|| [keyPath isEqualToString:@"localHeaderOffset"]) {
		self.versionNeededToExtract = ([self useZip64Extensions] ? 45 : 20);
	} else if ([keyPath isEqualToString:@"extraField"]) {
		self.extraFieldLength = [self.extraField length];
	} else if ([keyPath isEqualToString:@"filename"]) {
		self.filenameLength = [self.filename precomposedUTF8Length];
	} else if ([keyPath isEqualToString:@"comment"]) {
		self.commentLength = [self.comment precomposedUTF8Length];
	}
}

+ (ZKCDHeader *) recordWithData:(NSData *)data atOffset:(NSUInteger)offset {
	if (!data) return nil;
	NSUInteger mn = [data hostInt32OffsetBy:&offset];
	if (mn != ZKCDHeaderMagicNumber) return nil;
	ZKCDHeader *record = [ZKCDHeader new];
	record.magicNumber = mn;
	record.versionMadeBy = [data hostInt16OffsetBy:&offset];
	record.versionNeededToExtract = [data hostInt16OffsetBy:&offset];
	record.generalPurposeBitFlag = [data hostInt16OffsetBy:&offset];
	record.compressionMethod = [data hostInt16OffsetBy:&offset];
	record.lastModDate = [NSDate dateWithDosDate:[data hostInt32OffsetBy:&offset]];
	record.crc = [data hostInt32OffsetBy:&offset];
	record.compressedSize = [data hostInt32OffsetBy:&offset];
	record.uncompressedSize = [data hostInt32OffsetBy:&offset];
	record.filenameLength = [data hostInt16OffsetBy:&offset];
	record.extraFieldLength = [data hostInt16OffsetBy:&offset];
	record.commentLength = [data hostInt16OffsetBy:&offset];
	record.diskNumberStart = [data hostInt16OffsetBy:&offset];
	record.internalFileAttributes = [data hostInt16OffsetBy:&offset];
	record.externalFileAttributes = [data hostInt32OffsetBy:&offset];
	record.localHeaderOffset = [data hostInt32OffsetBy:&offset];
	if ([data length] > ZKCDHeaderFixedDataLength) {
		if (record.filenameLength)
			record.filename = [data stringOffsetBy:&offset length:record.filenameLength];
		if (record.extraFieldLength) {
			record.extraField = [data subdataWithRange:NSMakeRange(offset, record.extraFieldLength)];
			offset += record.extraFieldLength;
			[record parseZip64ExtraField];
		}
		if (record.commentLength)
			record.comment = [data stringOffsetBy:&offset length:record.commentLength];
	}
	return record;
}

+ (ZKCDHeader *) recordWithArchivePath:(NSString *)path atOffset:(unsigned long long)offset {
	NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
	[file seekToFileOffset:offset];
	NSData *fixedData = [file readDataOfLength:ZKCDHeaderFixedDataLength];
	ZKCDHeader *record = [self recordWithData:fixedData atOffset:0];
	if (record.filenameLength > 0) {
		NSData *data = [file readDataOfLength:record.filenameLength];
		record.filename = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	if (record.extraFieldLength > 0) {
		record.extraField = [file readDataOfLength:record.extraFieldLength];
		[record parseZip64ExtraField];
	}
	if (record.commentLength > 0) {
		NSData *data = [file readDataOfLength:record.commentLength];
		record.comment = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	} else
		record.comment = nil;

	[file closeFile];
	return record;
}

- (NSData *) data {
	if (!self.cachedData || ([self.cachedData length] < ZKCDHeaderFixedDataLength)) {
		self.extraField = [self zip64ExtraField];
		
		self.cachedData = [NSMutableData dataWithLittleInt32:self.magicNumber];
		[self.cachedData appendLittleInt16:self.versionMadeBy];
		[self.cachedData appendLittleInt16:self.versionNeededToExtract];
		[self.cachedData appendLittleInt16:self.generalPurposeBitFlag];
		[self.cachedData appendLittleInt16:self.compressionMethod];
		[self.cachedData appendLittleInt32:[self.lastModDate dosDate]];
		[self.cachedData appendLittleInt32:self.crc];
		if ([self useZip64Extensions]) {
			[self.cachedData appendLittleInt32:0xFFFFFFFF];
			[self.cachedData appendLittleInt32:0xFFFFFFFF];
		} else {
			[self.cachedData appendLittleInt32:self.compressedSize];
			[self.cachedData appendLittleInt32:self.uncompressedSize];
		}
		[self.cachedData appendLittleInt16:[self.filename precomposedUTF8Length]];
		[self.cachedData appendLittleInt16:[self.extraField length]];
		[self.cachedData appendLittleInt16:[self.comment precomposedUTF8Length]];
		[self.cachedData appendLittleInt16:self.diskNumberStart];
		[self.cachedData appendLittleInt16:self.internalFileAttributes];
		[self.cachedData appendLittleInt32:self.externalFileAttributes];
		if ([self useZip64Extensions])
			[self.cachedData appendLittleInt32:0xFFFFFFFF];
		else
			[self.cachedData appendLittleInt32:self.localHeaderOffset];
		[self.cachedData appendPrecomposedUTF8String:self.filename];
		[self.cachedData appendData:self.extraField];
		[self.cachedData appendPrecomposedUTF8String:self.comment];
	}
	return self.cachedData;
}

- (void) parseZip64ExtraField {
	NSUInteger offset = 0, tag, length;
	while (offset < self.extraFieldLength) {
		tag = [self.extraField hostInt16OffsetBy:&offset];
		length = [self.extraField hostInt16OffsetBy:&offset];
		if (tag == 0x0001) {
			if (length >= 8)
				self.uncompressedSize = [self.extraField hostInt64OffsetBy:&offset];
			if (length >= 16)
				self.compressedSize = [self.extraField hostInt64OffsetBy:&offset];
			if (length >= 24)
				self.localHeaderOffset = [self.extraField hostInt64OffsetBy:&offset];
			break;
		} else {
			offset += length;
		}
	}
}

- (NSData *) zip64ExtraField {
	NSMutableData *zip64ExtraField = nil;
	if ([self useZip64Extensions]) {
		zip64ExtraField = [NSMutableData dataWithLittleInt16:0x0001];
		[zip64ExtraField appendLittleInt16:24];
		[zip64ExtraField appendLittleInt64:self.uncompressedSize];
		[zip64ExtraField appendLittleInt64:self.compressedSize];
		[zip64ExtraField appendLittleInt64:self.localHeaderOffset];
	}
	return zip64ExtraField;
}

- (NSUInteger) length {
	if (!self.extraField || [self.extraField length] == 0)
		self.extraField = [self zip64ExtraField];
	return ZKCDHeaderFixedDataLength + self.filenameLength + self.commentLength + [self.extraField length];
}

- (BOOL) useZip64Extensions {
	return (self.uncompressedSize >= 0xFFFFFFFF) || (self.compressedSize >= 0xFFFFFFFF) || (self.localHeaderOffset >= 0xFFFFFFFF);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ modified %@, %qu bytes (%qu compressed), @ %qu",
			self.filename, self.lastModDate, self.uncompressedSize, self.compressedSize, self.localHeaderOffset];
}

- (NSNumber *) posixPermissions {
	return [NSNumber numberWithUnsignedInteger:self.externalFileAttributes >> 16 & 0x1FF];
}

- (BOOL) isDirectory {
	uLong type = self.externalFileAttributes >> 29 & 0x1F;
	return (0x02 == type)  && ![self isSymLink];
}

- (BOOL) isSymLink {
	uLong type = self.externalFileAttributes >> 29 & 0x1F;
	return (0x05 == type);
}

- (BOOL) isResourceFork {
	return [self.filename isResourceForkPath];
}

@synthesize magicNumber, versionNeededToExtract, versionMadeBy, generalPurposeBitFlag, compressionMethod, lastModDate, crc, compressedSize, uncompressedSize, filenameLength, extraFieldLength, commentLength, diskNumberStart, internalFileAttributes, externalFileAttributes, localHeaderOffset, filename, extraField, comment, cachedData;

@end