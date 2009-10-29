//
//  NSFileHandle+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "NSFileHandle+ZKAdditions.h"

@implementation NSFileHandle (ZKAdditions)

+ (NSFileHandle *)zkNewFileHandleForWritingAtPath:(NSString *)path {
	NSFileManager *fileManager = [NSFileManager new];
	if (![fileManager fileExistsAtPath:path]) {
		[fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
		[fileManager createFileAtPath:path contents:nil attributes:nil];
	}
	return [self fileHandleForWritingAtPath:path];
}

@end