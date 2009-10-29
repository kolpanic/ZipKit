//
//  ZKCDTrailer.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKCDTrailer.h"
#import "NSData+ZKAdditions.h"
#import "NSString+ZKAdditions.h"
#import "ZKDefs.h"
#import "zlib.h"

@implementation ZKCDTrailer

- (id) init {
	if (self = [super init]) {
		[self addObserver:self forKeyPath:@"comment" options:NSKeyValueObservingOptionNew context:nil];
		
		self.magicNumber = ZKCDTrailerMagicNumber;
		self.thisDiskNumber = 0;
		self.diskNumberWithStartOfCentralDirectory = 0;
		self.numberOfCentralDirectoryEntriesOnThisDisk = 0;
		self.totalNumberOfCentralDirectoryEntries = 0;
		self.sizeOfCentralDirectory = 0;
		self.offsetOfStartOfCentralDirectory = 0;
		self.comment = @"Archive created with ZipKit";
	}
	return self;
}

- (void) finalize {
	[self removeObserver:self forKeyPath:@"comment"];
	[super finalize];
}

- (void) observeValueForKeyPath:(NSString *) keyPath ofObject:(id) object change:(NSDictionary *) change context:(void *) context {
	// set iVars directly, to avoid potential infinite KVO recursion
	if ([keyPath isEqualToString:@"comment"]) {
		commentLength = [self.comment zkPrecomposedUTF8Length];
	}
}

+ (ZKCDTrailer *) recordWithData:(NSData *)data atOffset:(NSUInteger) offset {
	NSUInteger mn = [data zkHostInt32OffsetBy:&offset];
	if (mn != ZKCDTrailerMagicNumber) return nil;
	ZKCDTrailer *record = [ZKCDTrailer new];
	record.magicNumber = mn;
	record.thisDiskNumber = [data zkHostInt16OffsetBy:&offset];
	record.diskNumberWithStartOfCentralDirectory = [data zkHostInt16OffsetBy:&offset];
	record.numberOfCentralDirectoryEntriesOnThisDisk = [data zkHostInt16OffsetBy:&offset];
	record.totalNumberOfCentralDirectoryEntries = [data zkHostInt16OffsetBy:&offset];
	record.sizeOfCentralDirectory = [data zkHostInt32OffsetBy:&offset];
	record.offsetOfStartOfCentralDirectory = [data zkHostInt32OffsetBy:&offset];
	record.commentLength = [data zkHostInt16OffsetBy:&offset];
	if (record.commentLength > 0)
		record.comment = [data zkStringOffsetBy:&offset length:record.commentLength];
	else
		record.comment = nil;
	return record;
}

+ (ZKCDTrailer *) recordWithData:(NSData *)data {
	UInt32 trailerCheck = 0;
	NSUInteger offset = [data length] - sizeof(trailerCheck);
	while (trailerCheck != ZKCDTrailerMagicNumber && offset > 0) {
		NSUInteger o = offset;
		trailerCheck = [data zkHostInt32OffsetBy:&o];
		offset--;
	}
	if (offset < 1)
		return nil;
	ZKCDTrailer *record = [self recordWithData:data atOffset:++offset];
	return record;
}

+ (ZKCDTrailer *) recordWithArchivePath:(NSString *)path {
	NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
	unsigned long long fileOffset = [file seekToEndOfFile];
	for (UInt32 trailerCheck = 0; trailerCheck != ZKCDTrailerMagicNumber && fileOffset > 0; fileOffset--) {
		[file seekToFileOffset:fileOffset];
		NSData *data = [file readDataOfLength:sizeof(UInt32)];
		[data getBytes:&trailerCheck length:sizeof(UInt32)];
	}
	if (fileOffset < 1) {
		[file closeFile];
		return nil;
	}
	fileOffset++;
	[file seekToFileOffset:fileOffset];
	NSData *data = [file readDataToEndOfFile];
	[file closeFile];
	return [self recordWithData:data atOffset:(NSUInteger) 0];
}

- (NSData *) data {
	NSMutableData *data = [NSMutableData zkDataWithLittleInt32:self.magicNumber];
	[data zkAppendLittleInt16:self.thisDiskNumber];
	[data zkAppendLittleInt16:self.diskNumberWithStartOfCentralDirectory];
	[data zkAppendLittleInt16:self.numberOfCentralDirectoryEntriesOnThisDisk];
	[data zkAppendLittleInt16:self.totalNumberOfCentralDirectoryEntries];
	if ([self useZip64Extensions]) {
		[data zkAppendLittleInt32:0xFFFFFFFF];
		[data zkAppendLittleInt32:0xFFFFFFFF];
	} else {
		[data zkAppendLittleInt32:self.sizeOfCentralDirectory];
		[data zkAppendLittleInt32:self.offsetOfStartOfCentralDirectory];
	}
	[data zkAppendLittleInt16:[self.comment zkPrecomposedUTF8Length]];
	[data zkAppendPrecomposedUTF8String:self.comment];
	return data;
}

- (NSUInteger) length {
	return ZKCDTrailerFixedDataLength + [self.comment length];
}

- (BOOL) useZip64Extensions {
	return (self.sizeOfCentralDirectory >= 0xFFFFFFFF) || (self.offsetOfStartOfCentralDirectory >= 0xFFFFFFFF);
}

- (NSString *) description {
	return [NSString stringWithFormat:@"%u entries (%qu bytes) @: %qu",
			self.totalNumberOfCentralDirectoryEntries,
			self.sizeOfCentralDirectory,
			self.offsetOfStartOfCentralDirectory];
}

@synthesize magicNumber, thisDiskNumber, diskNumberWithStartOfCentralDirectory, numberOfCentralDirectoryEntriesOnThisDisk, totalNumberOfCentralDirectoryEntries, sizeOfCentralDirectory, offsetOfStartOfCentralDirectory, commentLength, comment;

@end