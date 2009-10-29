//
//  NSFileManager+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>
#import "ZKDefs.h"

@interface NSFileManager (ZKAdditions)

- (BOOL) zkIsSymLinkAtPath:(NSString *) path;
- (BOOL) zkIsDirAtPath:(NSString *) path;

- (unsigned long long) zkDataSizeAtFilePath:(NSString *) path;
- (NSDictionary *) zkTotalSizeAndItemCountAtPath:(NSString *) path usingResourceFork:(BOOL) rfFlag;
#if ZK_TARGET_OS_MAC
- (void) zkCombineAppleDoubleInDirectory:(NSString *) path;
#endif

- (NSDate *) zkModificationDateForPath:(NSString *) path;
- (NSUInteger) zkPosixPermissionsAtPath:(NSString *) path;
- (NSUInteger) zkExternalFileAttributesAtPath:(NSString *) path;
- (NSUInteger) zkExternalFileAttributesFor:(NSDictionary *) fileAttributes;

- (NSUInteger) zkCrcForPath:(NSString *) path;
- (NSUInteger) zkCrcForPath:(NSString *) path invoker:(id) invoker;
- (NSUInteger) zkCrcForPath:(NSString *) path invoker:(id)invoker;
- (NSUInteger) zkCrcForPath:(NSString *)path invoker:(id)invoker throttleThreadSleepTime:(NSTimeInterval) throttleThreadSleepTime;

@end