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
//  NSFileManager+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "NSFileManager+ZKAdditions.h"
#import "NSData+ZKAdditions.h"
#import "NSDictionary+ZKAdditions.h"
#import "GMAppleDouble+ZKAdditions.h"
#import "ZKDefs.h"

const NSUInteger ZKMaxEntriesPerFetch = 40;

@implementation  NSFileManager (ZKAdditions)

- (BOOL) isSymLinkAtPath:(NSString *) path {
	return [[[self fileAttributesAtPath:path traverseLink:NO] fileType] isEqualToString:NSFileTypeSymbolicLink];
}

- (BOOL) isDirAtPath:(NSString *) path {
	BOOL isDir;
	BOOL pathExists = [self fileExistsAtPath:path isDirectory:&isDir];
	return pathExists && isDir;
}

- (unsigned long long) dataSizeAtFilePath:(NSString *) path {
	return [[self fileAttributesAtPath:path traverseLink:NO] fileSize];
}

- (void) totalsAtDirectoryFSRef:(FSRef*) fsRef usingResourceFork:(BOOL) rfFlag
					  totalSize:(unsigned long long *) size
					  itemCount:(unsigned long long *) count {
	FSIterator iterator;
	OSErr fsErr = FSOpenIterator(fsRef, kFSIterateFlat, &iterator);
	if (fsErr == noErr) {
		ItemCount actualFetched;
		FSRef fetchedRefs[ZKMaxEntriesPerFetch];
		FSCatalogInfo fetchedInfos[ZKMaxEntriesPerFetch];
		while (fsErr == noErr) {
			fsErr = FSGetCatalogInfoBulk(iterator, ZKMaxEntriesPerFetch, &actualFetched, NULL,
										 kFSCatInfoDataSizes | kFSCatInfoRsrcSizes | kFSCatInfoNodeFlags,
										 fetchedInfos, fetchedRefs, NULL, NULL);
			if ((fsErr == noErr) || (fsErr == errFSNoMoreItems)) {
				(*count) += actualFetched;
				for (ItemCount i = 0; i < actualFetched; i++) {
					if (fetchedInfos[i].nodeFlags & kFSNodeIsDirectoryMask)
						[self totalsAtDirectoryFSRef:&fetchedRefs[i] usingResourceFork:rfFlag totalSize:size itemCount:count];
					else
						(*size) += fetchedInfos [i].dataLogicalSize + (rfFlag ? fetchedInfos [i].rsrcLogicalSize : 0);
				}
			}
		}
		FSCloseIterator(iterator);
	}
	return ;
}

- (NSDictionary *) totalSizeAndItemCountAtPath:(NSString *) path usingResourceFork:(BOOL) rfFlag {
	unsigned long long size = 0;
	unsigned long long count = 0;
	FSRef fsRef;
	Boolean isDirectory;
	OSStatus status = FSPathMakeRef((const unsigned char*)[path fileSystemRepresentation], &fsRef, &isDirectory);
	if (status != noErr)
		return nil;
	if (isDirectory) {
		[self totalsAtDirectoryFSRef:&fsRef usingResourceFork:rfFlag totalSize:&size itemCount:&count];
	} else {
		count = 1;
		FSCatalogInfo info;
		OSErr fsErr = FSGetCatalogInfo(&fsRef, kFSCatInfoDataSizes | kFSCatInfoRsrcSizes, &info, NULL, NULL, NULL);
		if (fsErr == noErr)
			size = info.dataLogicalSize + (rfFlag ? info.rsrcLogicalSize : 0);
	}
	return [NSDictionary totalSizeAndCountDictionaryWithSize:size andItemCount:count];
}

- (NSDate *) modificationDateForPath:(NSString *) path {
	return [[self fileAttributesAtPath:path traverseLink:NO] fileModificationDate];
}

- (NSUInteger) posixPermissionsAtPath:(NSString *) path {
	return [[self fileAttributesAtPath:path traverseLink:NO] filePosixPermissions];
}

- (NSUInteger) externalFileAttributesAtPath:(NSString *) path {
	return [self externalFileAttributesFor:[self fileAttributesAtPath:path traverseLink:NO]];
}

- (NSUInteger) externalFileAttributesFor:(NSDictionary *) fileAttributes {
	NSUInteger externalFileAttributes = 0;
	@try {
		BOOL isSymLink = [[fileAttributes fileType] isEqualToString:NSFileTypeSymbolicLink];
		BOOL isDir = [[fileAttributes fileType] isEqualToString:NSFileTypeDirectory];
		NSUInteger posixPermissions = [fileAttributes filePosixPermissions];
		externalFileAttributes = posixPermissions << 16 | (isSymLink ? 0xA0004000 : (isDir ? 0x40004000 : 0x80004000));
	} @catch(NSException * e) {
		externalFileAttributes = 0;
	}
	return externalFileAttributes;
}

- (void) combineAppleDoubleInDirectory:(NSString *) path {
	if (![self isDirAtPath:path])
		return;
	NSArray *dirContents = [self contentsOfDirectoryAtPath:path error:nil];
	for (NSString *entry in dirContents) {
		NSString *subPath = [path stringByAppendingPathComponent:entry];
		if (![self isSymLinkAtPath:subPath]) {
			if ([self isDirAtPath:subPath])
				[self combineAppleDoubleInDirectory:subPath];
			else {
				// if the file is an AppleDouble file (i.e., it begins with "._") in the __MACOSX hierarchy,
				// find its corresponding data fork and combine them
				if ([subPath rangeOfString:ZKMacOSXDirectory].location != NSNotFound) {
					NSString *fileName = [subPath lastPathComponent];
					NSRange ZKDotUnderscoreRange = [fileName rangeOfString:ZKDotUnderscore];
					if (ZKDotUnderscoreRange.location == 0 && ZKDotUnderscoreRange.length == 2) {
						NSMutableArray *pathComponents = 
						(NSMutableArray *)[[[subPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:
											[fileName substringFromIndex:2]] pathComponents];
						for (NSString *pathComponent in pathComponents) {
							if ([ZKMacOSXDirectory isEqualToString:pathComponent]) {
								[pathComponents removeObject:pathComponent];
								break;
							}
						}
						NSData *appleDoubleData = [NSData dataWithContentsOfFile:subPath];
						[GMAppleDouble restoreAppleDoubleData:appleDoubleData toPath:[NSString pathWithComponents:pathComponents]];
					}
				}
			}
		}
	}
}

- (NSUInteger) crcForPath:(NSString *) path {
	return [self crcForPath:path invoker:nil throttleThreadSleepTime:0.0];
}

- (NSUInteger) crcForPath:(NSString *) path invoker:(id)invoker {
	return [self crcForPath:path invoker:invoker throttleThreadSleepTime:0.0];
}

- (NSUInteger) crcForPath:(NSString *)path invoker:(id)invoker throttleThreadSleepTime:(NSTimeInterval) throttleThreadSleepTime {
	NSUInteger crc32 = 0;
	path = [path stringByExpandingTildeInPath];
	BOOL isDirectory;
	if ([self fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory) {
		const NSUInteger crcBlockSize = 1048576;
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
		NSData *block = [fileHandle readDataOfLength:crcBlockSize] ;
		while ([block length] > 0) {
			crc32 = [block crc32:crc32];
			if ([invoker respondsToSelector:@selector(isCancelled)]) {
				if ([invoker isCancelled]) {
					[fileHandle closeFile];
					return 0;
				}
			}
			block = [fileHandle readDataOfLength:crcBlockSize];
			[NSThread sleepForTimeInterval:throttleThreadSleepTime];
		}
		[fileHandle closeFile];
	} else
		crc32 = 0;
	return crc32;
}

@end