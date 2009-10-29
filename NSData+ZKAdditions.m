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

- (UInt16) zkHostInt16OffsetBy:(NSUInteger *)offset {
	UInt16 value;
	NSUInteger length = sizeof(value);
	[self getBytes:&value range:NSMakeRange(*offset, length)];
	*offset += length;
	return CFSwapInt32LittleToHost(value);
}

- (UInt32) zkHostInt32OffsetBy:(NSUInteger *)offset {
	UInt32 value;
	NSUInteger length = sizeof(value);
	[self getBytes:&value range:NSMakeRange(*offset, length)];
	*offset += length;
	return CFSwapInt32LittleToHost(value);
}

- (UInt64) zkHostInt64OffsetBy:(NSUInteger *)offset {
	UInt64 value;
	NSUInteger length = sizeof(value);
	[self getBytes:&value range:NSMakeRange(*offset, length)];
	*offset += length;
	return CFSwapInt64LittleToHost(value);
}

- (BOOL) zkHostBoolOffsetBy:(NSUInteger *) offset {
	UInt32 value = [self zkHostInt32OffsetBy:offset];
	return (value != 0);
}

- (NSString *) zkStringOffsetBy:(NSUInteger *)offset length:(NSUInteger)length {
	NSString *value = nil;
	if (length > 0)
		value = [[NSString alloc] initWithData:[self subdataWithRange:NSMakeRange(*offset, length)] encoding:NSUTF8StringEncoding];
	*offset += length;
	return value;
}

- (NSUInteger) zkCrc32 {
	return [self zkCrc32:0];
}

- (NSUInteger) zkCrc32:(NSUInteger)crc {
	return crc32(crc, [self bytes], [self length]);
}

- (NSData *) zkInflate {
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

- (NSData *) zkDeflate {
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

+ (NSMutableData *)zkDataWithLittleInt16: (UInt16)value {
	NSMutableData *data = [self data];
	[data zkAppendLittleInt16:value];
	return data;
}

+ (NSMutableData *) zkDataWithLittleInt32:(UInt32)value {
	NSMutableData *data = [self data];
	[data zkAppendLittleInt32:value];
	return data;
}

+ (NSMutableData *) zkDataWithLittleInt64:(UInt64)value {
	NSMutableData *data = [self data];
	[data zkAppendLittleInt64:value];
	return data;
}

- (void) zkAppendLittleInt16:(UInt16)value {
	UInt16 swappedValue = CFSwapInt16HostToLittle(value);
	[self appendBytes:&swappedValue length:sizeof(swappedValue)];
}

- (void) zkAppendLittleInt32:(UInt32)value {
	UInt32 swappedValue = CFSwapInt32HostToLittle(value);
	[self appendBytes:&swappedValue length:sizeof(swappedValue)];
}

- (void) zkAppendLittleInt64:(UInt64)value {
	UInt64 swappedValue = CFSwapInt64HostToLittle(value);
	[self appendBytes:&swappedValue length:sizeof(swappedValue)];
}

- (void) zkAppendLittleBool:(BOOL) value {
	return [self zkAppendLittleInt32:(value ? 1 : 0)];
}

- (void) zkAppendPrecomposedUTF8String:(NSString *)value {
	return [self appendData:[[value precomposedStringWithCanonicalMapping] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end