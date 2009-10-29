//
//  NSString+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSString (ZKAdditions)

- (NSUInteger) zkPrecomposedUTF8Length;
- (BOOL) zkIsResourceForkPath;

@end