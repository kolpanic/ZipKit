//
//  GMAppleDouble+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "GMAppleDouble+ZKAdditions.h"
#include <sys/xattr.h>

@implementation GMAppleDouble (ZKAdditions)

+ (NSData *)zk_appleDoubleDataForPath:(NSString *)path {
	// extract a file's Finder info metadata and resource fork to a NSData object suitable for writing to a ._ file
	NSData *appleDoubleData = nil;
	if ([[[NSFileManager new] autorelease] fileExistsAtPath:path]) {
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

+ (void) zk_restoreAppleDoubleData:(NSData *) appleDoubleData toPath:(NSString *) path {
	// retsore AppleDouble NSData to a file's Finder info metadata and resource fork
	if ([[[NSFileManager new] autorelease] fileExistsAtPath:path]) {
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