//
//  ZKArchive.h
//  ZipKit
//
//  Created by Karl Moskowski on 08/05/09.
//

#import <Foundation/Foundation.h>

@class ZKCDTrailer;

@interface ZKArchive : NSObject {
@private
	// invoker should be an NSOperation or NSThread; if [invoker isCancelled], inflation or deflation will be aborted
	id _invoker;
	id _delegate;
	NSString *_archivePath;
	NSMutableArray *_centralDirectory;
	NSFileManager *_fileManager;
	ZKCDTrailer *_cdTrailer;
	NSTimeInterval _throttleThreadSleepTime;
}

+ (BOOL) validArchiveAtPath:(NSString *) path;
+ (NSString *) uniquify:(NSString *) path;
- (void) calculateSizeAndItemCount:(NSDictionary *) userInfo;

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

@property (retain) id invoker;
@property (retain) id delegate;
@property (copy) NSString *archivePath;
@property (retain) NSMutableArray *centralDirectory;
@property (retain) NSFileManager *fileManager;
@property (retain) ZKCDTrailer *cdTrailer;
@property (assign) NSTimeInterval throttleThreadSleepTime;
@property (copy) NSString *comment;

@end