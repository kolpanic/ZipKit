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
//  ZKArchive.m
//  ZipKit
//
//  Created by Karl Moskowski on 08/05/09.
//

#import "ZKArchive.h"
#import "NSDictionary+ZKAdditions.h"
#import "NSFileManager+ZKAdditions.h"
#import "ZKCDTrailer.h"
#import "ZKDefs.h"

@interface NSObject (ZipKitDelegate)
- (void) onZKArchiveDidBeginZip:(ZKArchive *) archive;
- (void) onZKArchiveDidBeginUnzip:(ZKArchive *) archive;
- (void) onZKArchive:(ZKArchive *) archive willZipPath:(NSString *) path;
- (void) onZKArchive:(ZKArchive *) archive willUnzipPath:(NSString *) path;
- (void) onZKArchive:(ZKArchive *) archive didUpdateTotalSize:(unsigned long long) size;
- (void) onZKArchive:(ZKArchive *) archive didUpdateTotalCount:(unsigned long long) count;
- (void) onZKArchive:(ZKArchive *) archive didUpdateBytesWritten:(unsigned long long) byteCount;
- (void) onZKArchiveDidEndZip:(ZKArchive *) archive;
- (void) onZKArchiveDidEndUnzip:(ZKArchive *) archive;
- (void) onZKArchiveDidCancel:(ZKArchive *) archive;
- (void) onZKArchiveDidFail:(ZKArchive *) archive;
- (BOOL) zkDelegateWantsSizes;
@end

#pragma mark -

@implementation ZKArchive

#pragma mark -
#pragma mark Utility

+ (BOOL) validArchiveAtPath:(NSString *) path {
	// check that the first few bytes of the file are a local file header
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	NSData *fileHeader = [fileHandle readDataOfLength:4];
	[fileHandle closeFile];
	UInt32 headerValue;
	[fileHeader getBytes:&headerValue];
	return (CFSwapInt32LittleToHost(headerValue) == ZKLFHeaderMagicNumber);
}

+ (NSString *) uniquify:(NSString *) path {
	// avoid name collisions by adding a sequence number if needed
	NSString * uniquePath = [NSString stringWithString:path];
	NSString *dir = [path stringByDeletingLastPathComponent];
	NSString *fileNameBase = [[path lastPathComponent] stringByDeletingPathExtension];
	NSString *ext = [path pathExtension];
	NSUInteger i = 2;
	NSFileManager *fm = [NSFileManager new];
	while ([fm fileExistsAtPath:uniquePath]) {
		uniquePath = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %u", fileNameBase, i++]];
		if (ext && [ext length] > 0)
			uniquePath = [uniquePath stringByAppendingPathExtension:ext];
	}
	return uniquePath;
}

- (void) calculateSizeAndItemCount:(NSDictionary *) userInfo {
	NSArray *paths = [userInfo objectForKey:ZKPathsKey];
	BOOL rfFlag = [[userInfo objectForKey:ZKusingResourceForkKey] boolValue];
	unsigned long long size = 0;
	unsigned long long count = 0;
	NSFileManager *fmgr = [NSFileManager new];
	NSDictionary *dict;
	for (NSString *path in paths) {
		dict = [fmgr totalSizeAndItemCountAtPath:path usingResourceFork:rfFlag];
		size += [dict totalFileSize];
		count += [dict itemCount];
	}
	[self performSelectorOnMainThread:@selector(didUpdateTotalSize:)
						   withObject:[NSNumber numberWithUnsignedLongLong:size] waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(didUpdateTotalCount:)
						   withObject:[NSNumber numberWithUnsignedLongLong:count] waitUntilDone:NO];
}

#pragma mark -
#pragma mark Accessors

- (NSString *) comment {
	return self.cdTrailer.comment;
}
- (void) setComment:(NSString *)comment {
	self.cdTrailer.comment = comment;
}

#pragma mark -
#pragma mark Delegate 

- (BOOL) delegateWantsSizes {
	BOOL delegateWantsSizes = NO;
	if ([self.delegate respondsToSelector:@selector(zkDelegateWantsSizes)]) {
		delegateWantsSizes = [self.delegate zkDelegateWantsSizes];
	}
	return delegateWantsSizes;
}

- (void) didBeginZip  {
	if ([self.delegate respondsToSelector:@selector(onZKArchiveDidBeginZip:)])
		[self.delegate onZKArchiveDidBeginZip:self];
}

- (void) didBeginUnzip  {
	if ([self.delegate respondsToSelector:@selector(onZKArchiveDidBeginUnzip:)])
		[self.delegate onZKArchiveDidBeginUnzip:self];
}

- (void) willZipPath:(NSString *) path {
	if ([self.delegate respondsToSelector:@selector(onZKArchive:willZipPath:)])
		[self.delegate onZKArchive:self willZipPath:path];
}

- (void) willUnzipPath:(NSString *) path {
	if ([self.delegate respondsToSelector:@selector(onZKArchive:willUnzipPath:)])
		[self.delegate onZKArchive:self willUnzipPath:path];
}

- (void) didEndZip {
	if ([self.delegate respondsToSelector:@selector(onZKArchiveDidEndZip:)])
		[self.delegate onZKArchiveDidEndZip:self];
}

- (void) didEndUnzip {
	if ([self.delegate respondsToSelector:@selector(onZKArchiveDidEndUnzip:)])
		[self.delegate onZKArchiveDidEndUnzip:self];
}

- (void) didCancel {
	if ([self.delegate respondsToSelector:@selector(onZKArchiveDidCancel:)])
		[self.delegate onZKArchiveDidCancel:self];
}

- (void) didFail {
	if ([self.delegate respondsToSelector:@selector(onZKArchiveDidFail)])
		[self.delegate onZKArchiveDidFail:self];
}

- (void) didUpdateTotalSize:(NSNumber *) size {
	if ([self.delegate respondsToSelector:@selector(onZKArchive:didUpdateTotalSize:)])
		[self.delegate onZKArchive:self didUpdateTotalSize:[size unsignedLongLongValue]];
}

- (void) didUpdateTotalCount:(NSNumber *) count {
	if ([self.delegate respondsToSelector:@selector(onZKArchive:didUpdateTotalCount:)])
		[self.delegate onZKArchive:self didUpdateTotalCount:[count unsignedLongLongValue]];
}

- (void) didUpdateBytesWritten:(NSNumber *) byteCount {
	if ([self.delegate respondsToSelector:@selector(onZKArchive:didUpdateBytesWritten:)])
		[self.delegate onZKArchive:self didUpdateBytesWritten:[byteCount unsignedLongLongValue]];
}

#pragma mark -
#pragma mark Setup

- (id) init {
	if (self = [super init]) {
		self.invoker = nil;
		self.delegate = nil;
		self.archivePath = nil;
		self.centralDirectory = [NSMutableArray array];
		self.fileManager = [NSFileManager new];
		self.cdTrailer = [ZKCDTrailer new];
		self.throttleThreadSleepTime = 0.0;
	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat: @"%@\n\ttrailer:%@\n\tcentral directory:%@", self.archivePath, self.cdTrailer, self.centralDirectory];
}

@synthesize invoker = _invoker, delegate = _delegate, archivePath = _archivePath, centralDirectory = _centralDirectory, fileManager = _fileManager, cdTrailer = _cdTrailer, throttleThreadSleepTime = _throttleThreadSleepTime;
@dynamic comment;

@end