//
//  GMAppleDouble+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "GMAppleDouble.h"

@interface GMAppleDouble (ZKAdditions)

+ (NSData *)zkAppleDoubleDataForPath:(NSString *)path;
+ (void) zkRestoreAppleDoubleData:(NSData *) appleDoubleData toPath:(NSString *) path;

@end