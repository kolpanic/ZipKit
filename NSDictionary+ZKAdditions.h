//
//  NSDictionary+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZKAdditions)

+ (NSDictionary *) totalSizeAndCountDictionaryWithSize:(unsigned long long) size andItemCount:(unsigned long long) count;
- (unsigned long long) totalFileSize;
- (unsigned long long) itemCount;

@end