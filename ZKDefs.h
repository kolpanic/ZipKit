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
//  ZKDefs.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

enum ZKReturnCodes {
	zkFailed = -1,
	zkCancelled = 0,
	zkSucceeded = 1,
};

// File & path naming
extern NSString* const ZKArchiveFileExtension;
extern NSString* const ZKMacOSXDirectory;
extern NSString* const ZKDotUnderscore;
extern NSString* const ZKExpansionDirectoryName;

// Keys for dictionary passed to size calculation thread
extern NSString* const ZKPathsKey;
extern NSString* const ZKusingResourceForkKey;

// Keys for dictionary returned from ZKDataArchive inflation
extern NSString* const ZKFileDataKey;
extern NSString* const ZKFileAttributesKey;
extern NSString* const ZKPathKey;

// Zipping & Unzipping
extern const NSUInteger ZKZipBlockSize;
extern const NSUInteger ZKNotificationIterations;

// Magic numbers and lengths for zip records
extern const NSUInteger ZKCDHeaderMagicNumber;
extern const NSUInteger ZKCDHeaderFixedDataLength;

extern const NSUInteger ZKCDTrailerMagicNumber;
extern const NSUInteger ZKCDTrailerFixedDataLength;

extern const NSUInteger ZKLFHeaderMagicNumber;
extern const NSUInteger ZKLFHeaderFixedDataLength;

extern const NSUInteger ZKCDTrailer64MagicNumber;
extern const NSUInteger ZKCDTrailer64FixedDataLength;

extern const NSUInteger ZKCDTrailer64LocatorMagicNumber;
extern const NSUInteger ZKCDTrailer64LocatorFixedDataLength;
