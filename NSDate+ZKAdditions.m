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
//  NSDate+ZKAdditions.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "NSDate+ZKAdditions.h"

@implementation NSDate (ZKAdditions)

+ (NSDate *)dateWithDosDate : (NSUInteger)dosDate {
	NSUInteger date = (NSUInteger)(dosDate >> 16);
	NSDateComponents *comps = [NSDateComponents new];
	comps.year = ((date & 0x0FE00) / 0x0200) + 1980;
	comps.month = (date & 0x1E0) / 0x20;
	comps.day = date & 0x1f;
	comps.hour = (dosDate & 0xF800) / 0x800;
	comps.minute = (dosDate & 0x7E0) / 0x20;
	comps.second = 2 * (dosDate & 0x1f);
	return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (NSUInteger) dosDate {
	NSUInteger options = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
	NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *comps = [[NSCalendar currentCalendar] components:options fromDate:self];
	return ((comps.day + 32 * comps.month + 512 * (comps.year - 1980)) << 16) | (comps.second / 2 + 32 * comps.minute + 2048 * comps.hour);
}

@end