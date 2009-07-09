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