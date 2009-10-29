//
//  NSDictionary+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZKAdditions)

+ (NSDictionary *) zkTotalSizeAndCountDictionaryWithSize:(unsigned long long) size andItemCount:(unsigned long long) count;
- (unsigned long long) zkTotalFileSize;
- (unsigned long long) zkItemCount;

@end