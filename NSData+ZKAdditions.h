//
//  NSData+ZKAdditions.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface NSData (ZKAdditions)

- (UInt16) zkHostInt16OffsetBy:(NSUInteger *)offset;
- (UInt32) zkHostInt32OffsetBy:(NSUInteger *)offset;
- (UInt64) zkHostInt64OffsetBy:(NSUInteger *)offset;
- (BOOL) zkHostBoolOffsetBy:(NSUInteger *) offset;
- (NSString *) zkStringOffsetBy:(NSUInteger *)offset length:(NSUInteger)length;
- (NSUInteger) zkCrc32;
- (NSUInteger) zkCrc32:(NSUInteger)crc;
- (NSData *) zkInflate;
- (NSData *) zkDeflate;

@end

@interface NSMutableData (ZKAdditions)

+ (NSMutableData *) zkDataWithLittleInt16:(UInt16)value;
+ (NSMutableData *) zkDataWithLittleInt32:(UInt32)value;
+ (NSMutableData *) zkDataWithLittleInt64:(UInt64)value;

- (void) zkAppendLittleInt16:(UInt16)value;
- (void) zkAppendLittleInt32:(UInt32)value;
- (void) zkAppendLittleInt64:(UInt64)value;
- (void) zkAppendLittleBool:(BOOL) value;
- (void) zkAppendPrecomposedUTF8String:(NSString *)value;

@end