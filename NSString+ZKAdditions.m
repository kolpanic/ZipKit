//
//  NSString+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "NSString+ZKAdditions.h"
#import "ZKDefs.h"

@implementation NSString (ZKAdditions)

- (NSUInteger) precomposedUTF8Length {
	return [[self precomposedStringWithCanonicalMapping] lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL) isResourceForkPath {
	return [[[self pathComponents] objectAtIndex:0] isEqualToString:ZKMacOSXDirectory];
}


@end