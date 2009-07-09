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
//  GMAppleDouble+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "GMAppleDouble+ZKAdditions.h"
#include <sys/xattr.h>

@implementation GMAppleDouble (ZKAdditions)

+ (NSData *)appleDoubleDataForPath:(NSString *)path {
	// extract a file's Finder info metadata and resource fork to a NSData object suitable for writing to a ._ file
	NSData *appleDoubleData = nil;
	if ([[NSFileManager new] fileExistsAtPath:path]) {
		GMAppleDouble *appleDouble = [GMAppleDouble appleDouble];
		NSMutableData *data;
		
		size_t finderInfoSize = getxattr([path fileSystemRepresentation], XATTR_FINDERINFO_NAME, NULL, ULONG_MAX, 0, XATTR_NOFOLLOW );
		if (finderInfoSize == ULONG_MAX) finderInfoSize = 0;
		if (finderInfoSize > 0 && finderInfoSize < ULONG_MAX) {
			data = [NSMutableData dataWithLength:finderInfoSize];
			getxattr([path fileSystemRepresentation], XATTR_FINDERINFO_NAME, [data mutableBytes], [data length], 0, XATTR_NOFOLLOW );
			[appleDouble addEntryWithID:DoubleEntryFinderInfo data:data];
		}
		
		size_t resourceForkSize = getxattr([path fileSystemRepresentation], XATTR_RESOURCEFORK_NAME, NULL, ULONG_MAX, 0, XATTR_NOFOLLOW );
		if (resourceForkSize == ULONG_MAX) resourceForkSize = 0;
		if (resourceForkSize > 0 && resourceForkSize < ULONG_MAX) {
			data = [NSMutableData dataWithLength:resourceForkSize];
			getxattr([path fileSystemRepresentation], XATTR_RESOURCEFORK_NAME, [data mutableBytes], [data length], 0, XATTR_NOFOLLOW );
			[appleDouble addEntryWithID:DoubleEntryResourceFork data:data];
		}
		
		if (finderInfoSize > 0 || resourceForkSize > 0)
			appleDoubleData = [appleDouble data];
	}
	return appleDoubleData;
}

+ (void) restoreAppleDoubleData:(NSData *) appleDoubleData toPath:(NSString *) path {
	// retsore AppleDouble NSData to a file's Finder info metadata and resource fork
	if ([[NSFileManager new] fileExistsAtPath:path]) {
		GMAppleDouble *appleDouble = [GMAppleDouble appleDoubleWithData:appleDoubleData];
		if ([appleDouble entries] && [[appleDouble entries] count] > 0) {
			for (GMAppleDoubleEntry *entry in [appleDouble entries]) {
				char *key = NULL;
				if ([entry entryID] == DoubleEntryFinderInfo)
					key = XATTR_FINDERINFO_NAME;
				else if ([entry entryID] == DoubleEntryResourceFork)
					key = XATTR_RESOURCEFORK_NAME;
				if (key != NULL)
					setxattr([path fileSystemRepresentation], key, [[entry data] bytes], [[entry data] length], 0, XATTR_NOFOLLOW );
			}
		}
	}
}

@end