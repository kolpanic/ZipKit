//
//  NSFileManager+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>
#import "ZKDefs.h"

@interface NSFileManager (ZKAdditions)

- (BOOL) isSymLinkAtPath:(NSString *) path;
- (BOOL) isDirAtPath:(NSString *) path;

- (unsigned long long) dataSizeAtFilePath:(NSString *) path;
- (NSDictionary *) totalSizeAndItemCountAtPath:(NSString *) path usingResourceFork:(BOOL) rfFlag;
#if ZK_TARGET_OS_MAC
- (void) combineAppleDoubleInDirectory:(NSString *) path;
#endif

- (NSDate *) modificationDateForPath:(NSString *) path;
- (NSUInteger) posixPermissionsAtPath:(NSString *) path;
- (NSUInteger) externalFileAttributesAtPath:(NSString *) path;
- (NSUInteger) externalFileAttributesFor:(NSDictionary *) fileAttributes;

- (NSUInteger) crcForPath:(NSString *) path;
- (NSUInteger) crcForPath:(NSString *) path invoker:(id) invoker;
- (NSUInteger) crcForPath:(NSString *) path invoker:(id)invoker;
- (NSUInteger) crcForPath:(NSString *)path invoker:(id)invoker throttleThreadSleepTime:(NSTimeInterval) throttleThreadSleepTime;

@end