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
	NSFileManager *fm = [[NSFileManager new] autorelease];
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
	NSFileManager *fmgr = [[NSFileManager new] autorelease];
	NSDictionary *dict;
	for (NSString *path in paths) {
		dict = [fmgr zkTotalSizeAndItemCountAtPath:path usingResourceFork:rfFlag];
		size += [dict zk_totalFileSize];
		count += [dict zk_itemCount];
	}
	[self performSelectorOnMainThread:@selector(didUpdateTotalSize:)
						   withObject:[NSNumber numberWithUnsignedLongLong:size] waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(didUpdateTotalCount:)
						   withObject:[NSNumber numberWithUnsignedLongLong:count] waitUntilDone:NO];
}

- (NSString *) uniqueExpansionDirectoryIn:(NSString *) enclosingFolder {
	NSString *expansionDirectory = [enclosingFolder stringByAppendingPathComponent:ZKExpansionDirectoryName];
	NSUInteger i = 1;
	while ([self.fileManager fileExistsAtPath:expansionDirectory]) {
		expansionDirectory = [enclosingFolder stringByAppendingPathComponent:
							  [NSString stringWithFormat:@"%@ %u", ZKExpansionDirectoryName, i++]];
	}
	return expansionDirectory;
}

- (void) cleanUpExpansionDirectory:(NSString *) expansionDirectory {
	NSString *enclosingFolder = [expansionDirectory stringByDeletingLastPathComponent];
	NSArray *dirContents = [self.fileManager contentsOfDirectoryAtPath:expansionDirectory error:nil];
	for (NSString *item in dirContents) {
		if (![item isEqualToString:ZKMacOSXDirectory]) {
			NSString *subPath = [expansionDirectory stringByAppendingPathComponent:item];
			NSString *dest = [enclosingFolder stringByAppendingPathComponent:item];
			NSUInteger i = 2;
			while ([self.fileManager fileExistsAtPath:dest]) {
				NSString *ext = [item pathExtension];
				dest = [enclosingFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %u",
																		[item stringByDeletingPathExtension], i++]];
				if (ext && [ext length] > 0)
					dest = [dest stringByAppendingPathExtension:ext];
			}
			[self.fileManager moveItemAtPath:subPath toPath:dest error:nil];
		}
	}
	[self.fileManager removeItemAtPath:expansionDirectory error:nil];
	
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
		self.fileManager = [[NSFileManager new] autorelease];
		self.cdTrailer = [[ZKCDTrailer new] autorelease];
		self.throttleThreadSleepTime = 0.0;
	}
	return self;
}

- (void) dealloc {
	self.invoker = nil;
	self.delegate = nil;
	self.archivePath = nil;
	self.centralDirectory = nil;
	self.fileManager = nil;
	self.cdTrailer = nil;
	[super dealloc];
}

- (NSString *) description {
	return [NSString stringWithFormat: @"%@\n\ttrailer:%@\n\tcentral directory:%@", self.archivePath, self.cdTrailer, self.centralDirectory];
}

@synthesize invoker = _invoker, delegate = _delegate, archivePath = _archivePath, centralDirectory = _centralDirectory, fileManager = _fileManager, cdTrailer = _cdTrailer, throttleThreadSleepTime = _throttleThreadSleepTime;
@dynamic comment;

@end