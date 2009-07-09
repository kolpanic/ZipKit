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
//  ZKDefs.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZKDefs.h"

NSString* const ZKArchiveFileExtension = @"zip";
NSString* const ZKMacOSXDirectory = @"__MACOSX";
NSString* const ZKDotUnderscore = @"._";
NSString* const ZKExpansionDirectoryName = @".ZipKit";

NSString* const ZKPathsKey = @"paths";
NSString* const ZKusingResourceForkKey = @"usingResourceFork";

NSString* const ZKFileDataKey = @"fileData";
NSString* const ZKFileAttributesKey = @"fileAttributes";
NSString* const ZKPathKey = @"path";

const NSUInteger ZKZipBlockSize = 262144;
const NSUInteger ZKNotificationIterations = 100;

const NSUInteger ZKCDHeaderMagicNumber = 0x02014B50;
const NSUInteger ZKCDHeaderFixedDataLength = 46;

const NSUInteger ZKCDTrailerMagicNumber = 0x06054B50;
const NSUInteger ZKCDTrailerFixedDataLength = 22;

const NSUInteger ZKLFHeaderMagicNumber = 0x04034B50;
const NSUInteger ZKLFHeaderFixedDataLength = 30;

const NSUInteger ZKCDTrailer64MagicNumber = 0x06064b50;
const NSUInteger ZKCDTrailer64FixedDataLength = 56;

const NSUInteger ZKCDTrailer64LocatorMagicNumber = 0x07064b50;
const NSUInteger ZKCDTrailer64LocatorFixedDataLength = 20;
