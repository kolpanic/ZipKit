//
//  ZKArchive.h
//  ZipKit
//
//  Created by Karl Moskowski on 08/05/09.
//

#import <Foundation/Foundation.h>

@class ZKCDTrailer;
@class ZKArchive;

@protocol ZipKitDelegate<NSObject>
@optional 
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

@interface ZKArchive : NSObject {
@private
	// invoker should be an NSOperation or NSThread; if [invoker isCancelled], inflation or deflation will be aborted
	id __weak _invoker;
	id __weak _delegate;
	NSString *_archivePath;
	NSMutableArray *_centralDirectory;
	NSFileManager *_fileManager;
	ZKCDTrailer *_cdTrailer;
	NSTimeInterval _throttleThreadSleepTime;

@protected
	// cached respondsToSelector: checks
	BOOL drtsDelegateWantsSizes;
	BOOL drtsDidBeginZip;
	BOOL drtsDidBeginUnzip;
	BOOL drtsWillZipPath;
	BOOL drtsWillUnzipPath;
	BOOL drtsDidEndZip;
	BOOL drtsDidEndUnzip;
	BOOL drtsDidCancel;
	BOOL drtsDidFail;
	BOOL drtsDidUpdateTotalSize;
	BOOL drtsDidUpdateTotalCount;
	BOOL drtsDidUpdateBytesWritten;
	
	BOOL irtsIsCancelled;
}

+ (BOOL) validArchiveAtPath:(NSString *) path;
+ (NSString *) uniquify:(NSString *) path;
- (void) calculateSizeAndItemCount:(NSDictionary *) userInfo;
- (NSString *) uniqueExpansionDirectoryIn:(NSString *) enclosingFolder;
- (void) cleanUpExpansionDirectory:(NSString *) expansionDirectory;

- (BOOL) delegateWantsSizes;

- (void) didBeginZip;
- (void) didBeginUnzip;
- (void) willZipPath:(NSString *)path;
- (void) willUnzipPath:(NSString *)path;
- (void) didEndZip;
- (void) didEndUnzip;
- (void) didCancel;
- (void) didFail;
- (void) didUpdateTotalSize:(NSNumber *) size;
- (void) didUpdateTotalCount:(NSNumber *) count;
- (void) didUpdateBytesWritten:(NSNumber *) byteCount;

@property (weak, nonatomic) id invoker;
@property (weak, nonatomic) id delegate;
@property (copy) NSString *archivePath;
@property (retain) NSMutableArray *centralDirectory;
@property (retain) NSFileManager *fileManager;
@property (retain) ZKCDTrailer *cdTrailer;
@property (assign) NSTimeInterval throttleThreadSleepTime;
@property (copy) NSString *comment;

@end
