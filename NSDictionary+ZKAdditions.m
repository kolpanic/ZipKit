//
//  NSDictionary+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "NSDictionary+ZKAdditions.h"

NSString* const ZKTotalFileSize = @"ZKTotalFileSize";
NSString* const ZKItemCount = @"ZKItemCount";

@implementation NSDictionary (ZKAdditions)

+ (NSDictionary *) totalSizeAndCountDictionaryWithSize:(unsigned long long) size andItemCount:(unsigned long long) count {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithUnsignedLongLong:size], ZKTotalFileSize,
			[NSNumber numberWithUnsignedLongLong:count], ZKItemCount, nil];
}

- (unsigned long long) totalFileSize {
	return [[self objectForKey:ZKTotalFileSize] unsignedLongLongValue];
}

- (unsigned long long) itemCount {
	return [[self objectForKey:ZKItemCount] unsignedLongLongValue];
}

@end