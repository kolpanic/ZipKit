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
//  ZKDataArchive.m
//  ZipKit
//
//  Created by Karl Moskowski on 07/05/09.
//

#import "ZKDataArchive.h"
#import "ZKCDHeader.h"
#import "ZKCDTrailer.h"
#import "ZKLFHeader.h"
#import "GMAppleDouble+ZKAdditions.h"
#import "NSData+ZKAdditions.h"
#import "NSFileManager+ZKAdditions.h"
#import "NSString+ZKAdditions.h"
#import "ZKDefs.h"
#import "zlib.h"

@implementation ZKDataArchive

+ (ZKDataArchive *) archiveWithArchivePath:(NSString *) path {
	ZKDataArchive *archive = [ZKDataArchive new];
	archive.archivePath = path;
	if ([archive.fileManager fileExistsAtPath:archive.archivePath]) {
		archive.data = [NSMutableData dataWithContentsOfFile:path];
		archive.cdTrailer = [ZKCDTrailer recordWithData:archive.data];
		if (archive.cdTrailer) {
			unsigned long long offset = archive.cdTrailer.offsetOfStartOfCentralDirectory;
			for (NSUInteger i = 0; i < archive.cdTrailer.totalNumberOfCentralDirectoryEntries; i++) {
				ZKCDHeader *cdHeader = [ZKCDHeader recordWithArchivePath:path atOffset:offset];
				[archive.centralDirectory addObject:cdHeader];
				offset += [cdHeader length];
			}
		} else {
			archive = nil;
		}
	}
	
	return archive;
}

#pragma mark -
#pragma mark Inflation

- (NSUInteger) inflateAll {
	[self.inflatedFiles removeAllObjects];
	NSDictionary *fileAttributes;
	NSData *inflatedData;
	for (ZKCDHeader *cdHeader in self.centralDirectory) {
		inflatedData = [self inflateFile:cdHeader attributes:&fileAttributes];
		if (!inflatedData)
			return zkFailed;
		
		if ([cdHeader isSymLink] || [cdHeader isDirectory]) {
			[self.inflatedFiles addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									 fileAttributes, ZKFileAttributesKey,
									 [[NSString alloc] initWithData:inflatedData encoding:NSUTF8StringEncoding], ZKPathKey,
									 nil]];
		} else {
			[self.inflatedFiles addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									 inflatedData, ZKFileDataKey,
									 fileAttributes, ZKFileAttributesKey,
									 cdHeader.filename, ZKPathKey,
									 nil]];
		}
	}
	return zkSucceeded;
}

- (NSData *) inflateFile:(ZKCDHeader *) cdHeader attributes:(NSDictionary **) fileAttributes {
//	if (self.delegate) {
//		if ([NSThread isMainThread])
//			[self willUnzipPath:cdHeader.filename];
//		else
//			[self performSelectorOnMainThread:@selector(willUnzipPath:) withObject:cdHeader.filename waitUntilDone:NO];
//	}
	BOOL isDirectory = [cdHeader isDirectory];
	
	ZKLFHeader *lfHeader = [ZKLFHeader recordWithData:self.data atOffset:cdHeader.localHeaderOffset];
	
	NSData *deflatedData = nil;
	if (!isDirectory)
		deflatedData = [self.data subdataWithRange:
						NSMakeRange(cdHeader.localHeaderOffset + [lfHeader length], cdHeader.compressedSize)];
	
	NSData *inflatedData = nil;
	NSString *fileType;
	if ([cdHeader isSymLink]) {
		inflatedData = deflatedData; // UTF-8 encoded symlink destination path
		fileType = NSFileTypeSymbolicLink;
	} else if (isDirectory) {
		inflatedData = [cdHeader.filename dataUsingEncoding:NSUTF8StringEncoding];
		fileType = NSFileTypeDirectory;
	} else {
		inflatedData = [deflatedData inflate];
		fileType = NSFileTypeRegular;
	}
	
	if (inflatedData)
		*fileAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
						   [cdHeader posixPermissions], NSFilePosixPermissions,
						   [cdHeader lastModDate], NSFileCreationDate,
						   [cdHeader lastModDate], NSFileModificationDate,
						   fileType, NSFileType, nil];
	else
		*fileAttributes = nil;
	
	return inflatedData;
}

#pragma mark -
#pragma mark Deflation

- (NSInteger) deflateFiles:(NSArray *) paths relativeToPath:(NSString *) basePath usingResourceFork:(BOOL) rfFlag {
	NSInteger rc = zkSucceeded;
	for (NSString *path in paths) {
		if ([self.fileManager isDirAtPath:path] && ![self.fileManager isSymLinkAtPath:path]) {
			rc = [self deflateDirectory:path relativeToPath:basePath usingResourceFork:rfFlag];
			if (rc != zkSucceeded)
				break;
		} else {
			rc = [self deflateFile:path relativeToPath:basePath usingResourceFork:rfFlag];
			if (rc != zkSucceeded)
				break;
		}
	}
	return rc;
}

- (NSInteger) deflateDirectory:(NSString *) dirPath relativeToPath:(NSString *) basePath usingResourceFork:(BOOL) rfFlag {
	NSInteger rc = [self deflateFile:dirPath relativeToPath:basePath usingResourceFork:rfFlag];
	if (rc == zkSucceeded) {
		NSDirectoryEnumerator *e = [self.fileManager enumeratorAtPath:dirPath];
		for (NSString *path in e) {
			rc = [self deflateFile:[dirPath stringByAppendingPathComponent:path] relativeToPath:basePath usingResourceFork:rfFlag];
			if (rc != zkSucceeded)
				break;
		}
	}
	return rc;
}

- (NSInteger) deflateFile:(NSString *) path relativeToPath:(NSString *) basePath usingResourceFork:(BOOL) rfFlag {
	BOOL isDir = [self.fileManager isDirAtPath:path];
	BOOL isSymlink = [self.fileManager isSymLinkAtPath:path];
	BOOL isFile = (!isSymlink && !isDir);
	
//	if (self.delegate) {
//		if ([NSThread isMainThread])
//			[self willZipPath:path];
//		else
//			[self performSelectorOnMainThread:@selector(willZipPath:) withObject:path waitUntilDone:NO];
//	}
	
	// append a trailing slash to directory paths
	if (isDir && !isSymlink && ![[path substringFromIndex:([path length] - 1)] isEqualToString:@"/"])
		path = [path stringByAppendingString:@"/"];
	
	// construct a relative path for storage in the archive directory by removing basePath from the beginning of path
	NSString *relativePath = path;
	if (basePath && [basePath length] > 0) {
		NSRange r = [path rangeOfString:basePath];
		if (r.location != NSNotFound)
			relativePath = [path substringFromIndex:r.length + 1];
	}
	
	if (isFile) {
		NSData *fileData = [NSData dataWithContentsOfFile:path];
		NSDictionary *fileAttributes = [self.fileManager fileAttributesAtPath:path traverseLink:NO];
		NSInteger rc = [self deflateData:fileData withFilename:relativePath andAttributes:fileAttributes];
		if (rc == zkSucceeded && rfFlag) {
			NSData *appleDoubleData = [GMAppleDouble appleDoubleDataForPath:path];
			if (appleDoubleData) {
				NSString *appleDoublePath = [[ZKMacOSXDirectory stringByAppendingPathComponent:
											  [relativePath stringByDeletingLastPathComponent]]
											 stringByAppendingPathComponent:
											 [ZKDotUnderscore stringByAppendingString:[relativePath lastPathComponent]]];
				rc = [self deflateData:appleDoubleData withFilename:appleDoublePath andAttributes:fileAttributes];
			}
		}
		return rc;
	}
	
	// create the local file header for the file
	ZKLFHeader *lfHeaderData = [ZKLFHeader new];
	lfHeaderData.uncompressedSize = 0;
	lfHeaderData.lastModDate = [self.fileManager modificationDateForPath:path];
	lfHeaderData.filename = relativePath;
	lfHeaderData.filenameLength = [lfHeaderData.filename precomposedUTF8Length];
	lfHeaderData.crc = 0;
	lfHeaderData.compressedSize = 0;
	
	// remove the existing central directory from the data
	unsigned long long lfHeaderDataOffset = self.cdTrailer.offsetOfStartOfCentralDirectory;
	[self.data setLength:lfHeaderDataOffset];
	
	if (isSymlink) {
		NSString *symlinkPath = [self.fileManager destinationOfSymbolicLinkAtPath:path error:nil];
		NSData *symlinkData = [symlinkPath dataUsingEncoding:NSUTF8StringEncoding];
		lfHeaderData.crc = [symlinkData crc32];
		lfHeaderData.compressedSize = [symlinkData length];
		lfHeaderData.uncompressedSize = [symlinkData length];
		lfHeaderData.compressionMethod = Z_NO_COMPRESSION;
		lfHeaderData.versionNeededToExtract = 10;
		[self.data appendData:[lfHeaderData data]];
		[self.data appendData:symlinkData];
	} else if (isDir) {
		lfHeaderData.crc = 0;
		lfHeaderData.compressedSize = 0;
		lfHeaderData.uncompressedSize = 0;
		lfHeaderData.compressionMethod = Z_NO_COMPRESSION;
		lfHeaderData.versionNeededToExtract = 10;
		[self.data appendData:[lfHeaderData data]];
	}
	
	// create the central directory header and add it to central directory
	ZKCDHeader *cdHeaderData = [ZKCDHeader new];
	cdHeaderData.uncompressedSize = lfHeaderData.uncompressedSize;
	cdHeaderData.lastModDate = lfHeaderData.lastModDate;
	cdHeaderData.crc = lfHeaderData.crc;
	cdHeaderData.compressedSize = lfHeaderData.compressedSize;
	cdHeaderData.filename = lfHeaderData.filename;
	cdHeaderData.filenameLength = lfHeaderData.filenameLength;
	cdHeaderData.localHeaderOffset = lfHeaderDataOffset;
	cdHeaderData.compressionMethod = lfHeaderData.compressionMethod;
	cdHeaderData.generalPurposeBitFlag = lfHeaderData.generalPurposeBitFlag;
	cdHeaderData.versionNeededToExtract = lfHeaderData.versionNeededToExtract;
	cdHeaderData.externalFileAttributes = [self.fileManager externalFileAttributesAtPath:path];
	[self.centralDirectory addObject:cdHeaderData];
	
	// update the central directory trailer
	self.cdTrailer.numberOfCentralDirectoryEntriesOnThisDisk++;
	self.cdTrailer.totalNumberOfCentralDirectoryEntries++;
	self.cdTrailer.sizeOfCentralDirectory += [cdHeaderData length];
	
	self.cdTrailer.offsetOfStartOfCentralDirectory = [self.data length];
	for (ZKCDHeader *cdHeader in self.centralDirectory)
		[self.data appendData:[cdHeader data]];
	
	[self.data appendData:[self.cdTrailer data]];
	
	return zkSucceeded;
}

- (NSInteger) deflateData:(NSData *)data withFilename:(NSString *) filename andAttributes:(NSDictionary *) fileAttributes {
	if (!filename || [filename length] < 1)
		return zkFailed;
	
	NSData *deflatedData = [data deflate];
	if (!deflatedData)
		return zkFailed;
	
	unsigned long long lfHeaderDataOffset = self.cdTrailer.offsetOfStartOfCentralDirectory;
	[self.data setLength:lfHeaderDataOffset];
	
	ZKLFHeader *lfHeaderData = [ZKLFHeader new];
	lfHeaderData.uncompressedSize = [data length];
	lfHeaderData.filename = filename;
	lfHeaderData.filenameLength = [lfHeaderData.filename precomposedUTF8Length];
	lfHeaderData.crc = [data crc32];
	lfHeaderData.compressedSize = [deflatedData length];
	
	ZKCDHeader *cdHeaderData = [ZKCDHeader new];
	cdHeaderData.uncompressedSize = lfHeaderData.uncompressedSize;
	cdHeaderData.crc = lfHeaderData.crc;
	cdHeaderData.compressedSize = lfHeaderData.compressedSize;
	cdHeaderData.filename = lfHeaderData.filename;
	cdHeaderData.filenameLength = lfHeaderData.filenameLength;
	cdHeaderData.localHeaderOffset = lfHeaderDataOffset;
	cdHeaderData.compressionMethod = lfHeaderData.compressionMethod;
	cdHeaderData.generalPurposeBitFlag = lfHeaderData.generalPurposeBitFlag;
	cdHeaderData.versionNeededToExtract = lfHeaderData.versionNeededToExtract;
	[self.centralDirectory addObject:cdHeaderData];
	
	self.cdTrailer.numberOfCentralDirectoryEntriesOnThisDisk++;
	self.cdTrailer.totalNumberOfCentralDirectoryEntries++;
	self.cdTrailer.sizeOfCentralDirectory += [cdHeaderData length];
	
	if (fileAttributes) {
		if ([[fileAttributes allKeys] containsObject:NSFileModificationDate]) {
			lfHeaderData.lastModDate = [fileAttributes objectForKey:NSFileModificationDate];
			cdHeaderData.lastModDate = lfHeaderData.lastModDate;
		}
		cdHeaderData.externalFileAttributes = [self.fileManager externalFileAttributesFor:fileAttributes];
	}
	
	[self.data appendData:[lfHeaderData data]];
	[self.data appendData:deflatedData];
	
	self.cdTrailer.offsetOfStartOfCentralDirectory = [self.data length];
	for (ZKCDHeader *cdHeader in self.centralDirectory)
		[self.data appendData:[cdHeader data]];
	
	[self.data appendData:[self.cdTrailer data]];
	
	return zkSucceeded;
}

#pragma mark -
#pragma mark Setup

- (id) init {
	if (self = [super init]) {
		self.data = [NSMutableData data];
		self.inflatedFiles = [NSMutableArray array];
	}
	return self;
}

- (void) finalize {
	self.data = nil;
	[self.inflatedFiles removeAllObjects];
	self.inflatedFiles = nil;
	[super finalize];
}

@synthesize data = _data, inflatedFiles = _inflatedFiles;

@end