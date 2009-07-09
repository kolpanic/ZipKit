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
//  RemainingTimeTransformer.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "RemainingTimeTransformer.h"

@implementation RemainingTimeTransformer

+ (Class) transformedValueClass {
	return [NSString class];
}

+ (BOOL) allowsReverseTransformation {
	return NO;
}

- (id) transformedValue:(id) value {
	NSTimeInterval timeInterval = [value doubleValue];
	if (timeInterval <= 0)
		return nil;
	else if (timeInterval == NSTimeIntervalSince1970)
		return NSLocalizedString(@"Estimating time left", @"remaining time message");
	
	float s = (float)ABS(timeInterval);
	float m = s / 60.0;
	float h = m / 60.0;
	float d = h / 24.0;
	float w = d / 7.0;
	float mm = d / 30.0;

	NSUInteger seconds = roundf(s);
	NSUInteger minutes = roundf(m);
	NSUInteger hours = roundf(h);
	NSUInteger days = roundf(d);
	NSUInteger weeks = roundf(w);
	NSUInteger months = roundf(mm);

	NSString *transformedValue = NSLocalizedString(@"About a second left", @"remaining time message");
	if (weeks > 8)
		transformedValue = [NSString stringWithFormat:NSLocalizedString(@"About %u months left", @"remaining time message"), months];
	else if (days > 10)
		transformedValue = [NSString stringWithFormat:NSLocalizedString(@"About %u weeks left", @"remaining time message"), weeks];
	else if (hours > 48)
		transformedValue = [NSString stringWithFormat:NSLocalizedString(@"About %u days left", @"remaining time message"), days];
	else if (minutes > 100)
		transformedValue = [NSString stringWithFormat:NSLocalizedString(@"About %u hours left", @"remaining time message"), hours];
	else if (seconds > 100)
		transformedValue = [NSString stringWithFormat:NSLocalizedString(@"About %u minutes left", @"remaining time message"), minutes];
	else if (seconds > 50)
		transformedValue = NSLocalizedString(@"About a minute left", @"remaining time message");
	else if (seconds > 30)
		transformedValue = NSLocalizedString(@"Less than a minute left", @"remaining time message");
	else if (seconds > 1)
		transformedValue = [NSString stringWithFormat:NSLocalizedString(@"About %u seconds left", @"remaining time message"), seconds];
	
	return transformedValue;
}

@end