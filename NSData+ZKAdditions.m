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
//  NSData+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "NSData+ZKAdditions.h"
#import "NSFileManager+ZKAdditions.h"
#import "ZKCDHeader.h"
#import "ZKCDTrailer.h"
#import "ZKLFHeader.h"
#import "zlib.h"

@implementation NSData (ZKAdditions)

- (UInt16) hostInt16OffsetBy:(NSUInteger *)offset {
	UInt16 value;
	NSUInteger length = sizeof(value);
	[self getBytes:&value range:NSMakeRange(*offset, length)];
	*offset += length;
	return CFSwapInt32LittleToHost(value);
}

- (UInt32) hostInt32OffsetBy:(NSUInteger *)offset {
	UInt32 value;
	NSUInteger length = sizeof(value);
	[self getBytes:&value range:NSMakeRange(*offset, length)];
	*offset += length;
	return CFSwapInt32LittleToHost(value);
}

- (UInt64) hostInt64OffsetBy:(NSUInteger *)offset {
	UInt64 value;
	NSUInteger length = sizeof(value);
	[self getBytes:&value range:NSMakeRange(*offset, length)];
	*offset += length;
	return CFSwapInt64LittleToHost(value);
}

- (BOOL) hostBoolOffsetBy:(NSUInteger *) offset {
	UInt32 value = [self hostInt32OffsetBy:offset];
	return (value != 0);
}

- (NSString *) stringOffsetBy:(NSUInteger *)offset length:(NSUInteger)length {
	NSString *value = nil;
	if (length > 0)
		value = [[NSString alloc] initWithData:[self subdataWithRange:NSMakeRange(*offset, length)] encoding:NSUTF8StringEncoding];
	*offset += length;
	return value;
}

- (NSUInteger) crc32 {
	return [self crc32:0];
}

- (NSUInteger) crc32:(NSUInteger)crc {
	return crc32(crc, [self bytes], [self length]);
}

- (NSData *) inflate {
	NSUInteger full_length = [self length];
	NSUInteger half_length = full_length / 2;
	
	NSMutableData *inflatedData = [NSMutableData dataWithLength: full_length + half_length];
	BOOL done = NO;
	int status;
	
	z_stream strm;
	
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit2(&strm, -MAX_WBITS) != Z_OK) return nil;
	while (!done) {
		if (strm.total_out >= [inflatedData length])
			[inflatedData increaseLengthBy:half_length];
		strm.next_out = [inflatedData mutableBytes] + strm.total_out;
		strm.avail_out = [inflatedData length] - strm.total_out;
		status = inflate(&strm, Z_SYNC_FLUSH);
		if (status == Z_STREAM_END) done = YES;
		else if (status != Z_OK) break;
	}
	if (inflateEnd(&strm) == Z_OK && done)
		[inflatedData setLength: strm.total_out];
	else
		inflatedData = nil;
	return inflatedData;
}

- (NSData *) deflate {
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = [self length];
	
	NSMutableData *deflatedData = [NSMutableData dataWithLength:16384];
	if (deflateInit2(&strm, Z_BEST_COMPRESSION, Z_DEFLATED, -MAX_WBITS, 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	do {
		if (strm.total_out >= [deflatedData length])
			[deflatedData increaseLengthBy:16384];
		strm.next_out = [deflatedData mutableBytes] + strm.total_out;
		strm.avail_out = [deflatedData length] - strm.total_out;
		deflate(&strm, Z_FINISH);
	} while (strm.avail_out == 0);
	deflateEnd(&strm);
	[deflatedData setLength:strm.total_out];
	
	return deflatedData;
}

@end

@implementation NSMutableData (ZKAdditions)

+ (NSMutableData *)dataWithLittleInt16: (UInt16)value {
	NSMutableData *data = [self data];
	[data appendLittleInt16:value];
	return data;
}

+ (NSMutableData *) dataWithLittleInt32:(UInt32)value {
	NSMutableData *data = [self data];
	[data appendLittleInt32:value];
	return data;
}

+ (NSMutableData *) dataWithLittleInt64:(UInt64)value {
	NSMutableData *data = [self data];
	[data appendLittleInt64:value];
	return data;
}

- (void) appendLittleInt16:(UInt16)value {
	UInt16 swappedValue = CFSwapInt16HostToLittle(value);
	[self appendBytes:&swappedValue length:sizeof(swappedValue)];
}

- (void) appendLittleInt32:(UInt32)value {
	UInt32 swappedValue = CFSwapInt32HostToLittle(value);
	[self appendBytes:&swappedValue length:sizeof(swappedValue)];
}

- (void) appendLittleInt64:(UInt64)value {
	UInt64 swappedValue = CFSwapInt64HostToLittle(value);
	[self appendBytes:&swappedValue length:sizeof(swappedValue)];
}

- (void) appendLittleBool:(BOOL) value {
	return [self appendLittleInt32:(value ? 1 : 0)];
}

- (void) appendPrecomposedUTF8String:(NSString *)value {
	return [self appendData:[[value precomposedStringWithCanonicalMapping] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end