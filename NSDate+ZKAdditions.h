//
//  NSDate+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSDate (ZKAdditions)

+ (NSDate *)dateWithDosDate:(NSUInteger)dosDate;
- (NSUInteger) dosDate;
	
@end