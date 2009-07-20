//
//  NSString+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSString (ZKAdditions)

- (NSUInteger) precomposedUTF8Length;
- (BOOL) isResourceForkPath;

@end