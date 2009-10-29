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
		self.filenameLength = [self.filename zkPrecomposedUTF8Length];
	} else if ([keyPath isEqualToString:@"comment"]) {
		self.commentLength = [self.comment zkPrecomposedUTF8Length];
	}
}

+ (ZKCDHeader *) recordWithData:(NSData *)data atOffset:(NSUInteger)offset {
	if (!data) return nil;
	NSUInteger mn = [data zkHostInt32OffsetBy:&offset];
	if (mn != ZKCDHeaderMagicNumber) return nil;
	ZKCDHeader *record = [ZKCDHeader new];
	record.magicNumber = mn;
	record.versionMadeBy = [data zkHostInt16OffsetBy:&offset];
	record.versionNeededToExtract = [data zkHostInt16OffsetBy:&offset];
	record.generalPurposeBitFlag = [data zkHostInt16OffsetBy:&offset];
	record.compressionMethod = [data zkHostInt16OffsetBy:&offset];
	record.lastModDate = [NSDate zkDateWithDosDate:[data zkHostInt32OffsetBy:&offset]];
	record.crc = [data zkHostInt32OffsetBy:&offset];
	record.compressedSize = [data zkHostInt32OffsetBy:&offset];
	record.uncompressedSize = [data zkHostInt32OffsetBy:&offset];
	record.filenameLength = [data zkHostInt16OffsetBy:&offset];
	record.extraFieldLength = [data zkHostInt16OffsetBy:&offset];
	record.commentLength = [data zkHostInt16OffsetBy:&offset];
	record.diskNumberStart = [data zkHostInt16OffsetBy:&offset];
	record.internalFileAttributes = [data zkHostInt16OffsetBy:&offset];
	record.externalFileAttributes = [data zkHostInt32OffsetBy:&offset];
	record.localHeaderOffset = [data zkHostInt32OffsetBy:&offset];
	if ([data length] > ZKCDHeaderFixedDataLength) {
		if (record.filenameLength)
			record.filename = [data zkStringOffsetBy:&offset length:record.filenameLength];
		if (record.extraFieldLength) {
			record.extraField = [data subdataWithRange:NSMakeRange(offset, record.extraFieldLength)];
			offset += record.extraFieldLength;
			[record parseZip64ExtraField];
		}
		if (record.commentLength)
			record.comment = [data zkStringOffsetBy:&offset length:record.commentLength];
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
		
		self.cachedData = [NSMutableData zkDataWithLittleInt32:self.magicNumber];
		[self.cachedData zkAppendLittleInt16:self.versionMadeBy];
		[self.cachedData zkAppendLittleInt16:self.versionNeededToExtract];
		[self.cachedData zkAppendLittleInt16:self.generalPurposeBitFlag];
		[self.cachedData zkAppendLittleInt16:self.compressionMethod];
		[self.cachedData zkAppendLittleInt32:[self.lastModDate zkDosDate]];
		[self.cachedData zkAppendLittleInt32:self.crc];
		if ([self useZip64Extensions]) {
			[self.cachedData zkAppendLittleInt32:0xFFFFFFFF];
			[self.cachedData zkAppendLittleInt32:0xFFFFFFFF];
		} else {
			[self.cachedData zkAppendLittleInt32:self.compressedSize];
			[self.cachedData zkAppendLittleInt32:self.uncompressedSize];
		}
		[self.cachedData zkAppendLittleInt16:[self.filename zkPrecomposedUTF8Length]];
		[self.cachedData zkAppendLittleInt16:[self.extraField length]];
		[self.cachedData zkAppendLittleInt16:[self.comment zkPrecomposedUTF8Length]];
		[self.cachedData zkAppendLittleInt16:self.diskNumberStart];
		[self.cachedData zkAppendLittleInt16:self.internalFileAttributes];
		[self.cachedData zkAppendLittleInt32:self.externalFileAttributes];
		if ([self useZip64Extensions])
			[self.cachedData zkAppendLittleInt32:0xFFFFFFFF];
		else
			[self.cachedData zkAppendLittleInt32:self.localHeaderOffset];
		[self.cachedData zkAppendPrecomposedUTF8String:self.filename];
		[self.cachedData appendData:self.extraField];
		[self.cachedData zkAppendPrecomposedUTF8String:self.comment];
	}
	return self.cachedData;
}

- (void) parseZip64ExtraField {
	NSUInteger offset = 0, tag, length;
	while (offset < self.extraFieldLength) {
		tag = [self.extraField zkHostInt16OffsetBy:&offset];
		length = [self.extraField zkHostInt16OffsetBy:&offset];
		if (tag == 0x0001) {
			if (length >= 8)
				self.uncompressedSize = [self.extraField zkHostInt64OffsetBy:&offset];
			if (length >= 16)
				self.compressedSize = [self.extraField zkHostInt64OffsetBy:&offset];
			if (length >= 24)
				self.localHeaderOffset = [self.extraField zkHostInt64OffsetBy:&offset];
			break;
		} else {
			offset += length;
		}
	}
}

- (NSData *) zip64ExtraField {
	NSMutableData *zip64ExtraField = nil;
	if ([self useZip64Extensions]) {
		zip64ExtraField = [NSMutableData zkDataWithLittleInt16:0x0001];
		[zip64ExtraField zkAppendLittleInt16:24];
		[zip64ExtraField zkAppendLittleInt64:self.uncompressedSize];
		[zip64ExtraField zkAppendLittleInt64:self.compressedSize];
		[zip64ExtraField zkAppendLittleInt64:self.localHeaderOffset];
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
	return [self.filename zkIsResourceForkPath];
}

@synthesize magicNumber, versionNeededToExtract, versionMadeBy, generalPurposeBitFlag, compressionMethod, lastModDate, crc, compressedSize, uncompressedSize, filenameLength, extraFieldLength, commentLength, diskNumberStart, internalFileAttributes, externalFileAttributes, localHeaderOffset, filename, extraField, comment, cachedData;

@end