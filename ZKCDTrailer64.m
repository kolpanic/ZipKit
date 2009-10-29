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
	NSUInteger mn = [data zkHostInt32OffsetBy:&offset];
	if (mn != ZKCDTrailer64MagicNumber) return nil;
	ZKCDTrailer64 *record = [ZKCDTrailer64 new];
	record.magicNumber = mn;
	record.sizeOfTrailer = [data zkHostInt64OffsetBy:&offset];
	record.versionMadeBy = [data zkHostInt16OffsetBy:&offset];
	record.versionNeededToExtract = [data zkHostInt16OffsetBy:&offset];
	record.thisDiskNumber = [data zkHostInt32OffsetBy:&offset];
	record.diskNumberWithStartOfCentralDirectory = [data zkHostInt32OffsetBy:&offset];
	record.numberOfCentralDirectoryEntriesOnThisDisk = [data zkHostInt64OffsetBy:&offset];
	record.totalNumberOfCentralDirectoryEntries = [data zkHostInt64OffsetBy:&offset];
	record.sizeOfCentralDirectory = [data zkHostInt64OffsetBy:&offset];
	record.offsetOfStartOfCentralDirectory = [data zkHostInt64OffsetBy:&offset];
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
	NSMutableData *data = [NSMutableData zkDataWithLittleInt32:self.magicNumber];
	[data zkAppendLittleInt64:self.sizeOfTrailer];
	[data zkAppendLittleInt16:self.versionMadeBy];
	[data zkAppendLittleInt16:self.versionNeededToExtract];
	[data zkAppendLittleInt32:self.thisDiskNumber];
	[data zkAppendLittleInt32:self.diskNumberWithStartOfCentralDirectory];
	[data zkAppendLittleInt64:self.numberOfCentralDirectoryEntriesOnThisDisk];
	[data zkAppendLittleInt64:self.totalNumberOfCentralDirectoryEntries];
	[data zkAppendLittleInt64:self.sizeOfCentralDirectory];
	[data zkAppendLittleInt64:self.offsetOfStartOfCentralDirectory];
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