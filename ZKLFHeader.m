//
//  ZKLFHeader.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKLFHeader.h"
#import "NSDate+ZKAdditions.h"
#import "NSData+ZKAdditions.h"
#import "NSString+ZKAdditions.h"
#import "ZKDefs.h"
#import "zlib.h"

@implementation ZKLFHeader

- (id) init {
	if (self = [super init]) {
		self.magicNumber = ZKLFHeaderMagicNumber;
		self.versionNeededToExtract = 20;
		self.generalPurposeBitFlag = 0;
		self.compressionMethod = Z_DEFLATED;
		self.lastModDate = [NSDate date];
		self.crc = 0;
		self.compressedSize = 0;
		self.uncompressedSize = 0;
		self.filenameLength = 0;
		self.extraFieldLength = 0;
		self.filename = nil;
		self.extraField = nil;
		
		[self addObserver:self forKeyPath:@"compressedSize" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"uncompressedSize" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"extraField" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"filename" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void) finalize {
	[self removeObserver:self forKeyPath:@"compressedSize"];
	[self removeObserver:self forKeyPath:@"uncompressedSize"];
	[self removeObserver:self forKeyPath:@"extraField"];
	[self removeObserver:self forKeyPath:@"filename"];
	[super finalize];
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
	if ([keyPath isEqualToString:@"compressedSize"] || [keyPath isEqualToString:@"uncompressedSize"]) {
		self.versionNeededToExtract = ([self useZip64Extensions] ? 45 : 20);
	} else if ([keyPath isEqualToString:@"extraField"]) {
		self.extraFieldLength = [self.extraField length];
	} else if ([keyPath isEqualToString:@"filename"]) {
		self.filenameLength = [self.filename zkPrecomposedUTF8Length];
	}
}

+ (ZKLFHeader *) recordWithData:(NSData *) data atOffset:(NSUInteger) offset {
	if (!data) return nil;
	NSUInteger mn = [data zkHostInt32OffsetBy:&offset];
	if (mn != ZKLFHeaderMagicNumber) return nil;
	ZKLFHeader *record = [ZKLFHeader new];
	record.magicNumber = mn;
	record.versionNeededToExtract = [data zkHostInt16OffsetBy:&offset];
	record.generalPurposeBitFlag = [data zkHostInt16OffsetBy:&offset];
	record.compressionMethod = [data zkHostInt16OffsetBy:&offset];
	record.lastModDate = [NSDate zkDateWithDosDate:[data zkHostInt32OffsetBy:&offset]];
	record.crc = [data zkHostInt32OffsetBy:&offset];
	record.compressedSize = [data zkHostInt32OffsetBy:&offset];
	record.uncompressedSize = [data zkHostInt32OffsetBy:&offset];
	record.filenameLength = [data zkHostInt16OffsetBy:&offset];
	record.extraFieldLength = [data zkHostInt16OffsetBy:&offset];
	if ([data length] > ZKLFHeaderFixedDataLength) {
		if (record.filenameLength > 0)
			record.filename = [data zkStringOffsetBy:&offset length:record.filenameLength];
		if (record.extraFieldLength > 0) {
			record.extraField = [data subdataWithRange:NSMakeRange(offset, record.extraFieldLength)];
			[record parseZip64ExtraField];
		}
	}
	return record;
}

+ (ZKLFHeader *) recordWithArchivePath:(NSString *) path atOffset:(unsigned long long) offset {
	NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
	[file seekToFileOffset:offset];
	NSData *fixedData = [file readDataOfLength:ZKLFHeaderFixedDataLength];
	ZKLFHeader *record = [self recordWithData:fixedData atOffset:0];
	if (record.filenameLength > 0) {
		NSData *data = [file readDataOfLength:record.filenameLength];
		record.filename = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	if (record.extraFieldLength > 0) {
		record.extraField = [file readDataOfLength:record.extraFieldLength];
		[record parseZip64ExtraField];
	}
	[file closeFile];
	return record;
}

- (NSData *) data {
	self.extraField = [self zip64ExtraField];

	NSMutableData *data = [NSMutableData zkDataWithLittleInt32:self.magicNumber];
	[data zkAppendLittleInt16:self.versionNeededToExtract];
	[data zkAppendLittleInt16:self.generalPurposeBitFlag];
	[data zkAppendLittleInt16:self.compressionMethod];
	[data zkAppendLittleInt32:[self.lastModDate zkDosDate]];
	[data zkAppendLittleInt32:self.crc];
	if ([self useZip64Extensions]) {
		[data zkAppendLittleInt32:0xFFFFFFFF];
		[data zkAppendLittleInt32:0xFFFFFFFF];
	} else {
		[data zkAppendLittleInt32:self.compressedSize];
		[data zkAppendLittleInt32:self.uncompressedSize];
	}
	[data zkAppendLittleInt16:self.filenameLength];
	[data zkAppendLittleInt16:[self.extraField length]];
	[data zkAppendPrecomposedUTF8String:self.filename];
	[data appendData:self.extraField];
	return data;
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
		[zip64ExtraField zkAppendLittleInt16:16];
		[zip64ExtraField zkAppendLittleInt64:self.uncompressedSize];
		[zip64ExtraField zkAppendLittleInt64:self.compressedSize];
	}
	return zip64ExtraField;
}

- (NSUInteger) length {
	if (!self.extraField || [self.extraField length] == 0)
		self.extraField = [self zip64ExtraField];
	return ZKLFHeaderFixedDataLength + self.filenameLength + [self.extraField length];
}

- (BOOL) useZip64Extensions {
	return (self.uncompressedSize >= 0xFFFFFFFF) || (self.compressedSize >= 0xFFFFFFFF);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%@ modified %@, %qu bytes (%qu compressed)",
			self.filename, self.lastModDate, self.uncompressedSize, self.compressedSize];
}

- (BOOL) isResourceFork {
	return [self.filename zkIsResourceForkPath];
}

@synthesize magicNumber, versionNeededToExtract, generalPurposeBitFlag, compressionMethod, lastModDate, crc, compressedSize, uncompressedSize, filenameLength, extraFieldLength, filename, extraField;

@end