//
//  NSData+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSData (ZKAdditions)

- (UInt16) hostInt16OffsetBy:(NSUInteger *)offset;
- (UInt32) hostInt32OffsetBy:(NSUInteger *)offset;
- (UInt64) hostInt64OffsetBy:(NSUInteger *)offset;
- (BOOL) hostBoolOffsetBy:(NSUInteger *) offset;
- (NSString *) stringOffsetBy:(NSUInteger *)offset length:(NSUInteger)length;
- (NSUInteger) crc32;
- (NSUInteger) crc32:(NSUInteger)crc;
- (NSData *) inflate;
- (NSData *) deflate;

@end

@interface NSMutableData (ZKAdditions)

+ (NSMutableData *) dataWithLittleInt16:(UInt16)value;
+ (NSMutableData *) dataWithLittleInt32:(UInt32)value;
+ (NSMutableData *) dataWithLittleInt64:(UInt64)value;

- (void) appendLittleInt16:(UInt16)value;
- (void) appendLittleInt32:(UInt32)value;
- (void) appendLittleInt64:(UInt64)value;
- (void) appendLittleBool:(BOOL) value;
- (void) appendPrecomposedUTF8String:(NSString *)value;

@end