// ================================================================
// Copyright (c) 2009, Data Deposit Box
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above
//   copyright notice, this list of conditions and the following disclaimer
//   in the documentation and/or other materials provided with the
//   distribution.
// * Neither the name of Data Deposit Box nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ================================================================
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