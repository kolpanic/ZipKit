//
//  ZKFileArchive.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>
#import "ZKArchive.h"

@class ZKCDHeader;

@interface ZKFileArchive : ZKArchive 

+ (ZKFileArchive * _Nullable) process:(id _Nullable)item usingResourceFork:(BOOL)flag withInvoker:(id _Nullable)invoker andDelegate:(id _Nullable)delegate;
+ (ZKFileArchive * _Nullable) archiveWithArchivePath:(NSString * _Nonnull)archivePath;

- (NSInteger) inflateToDiskUsingResourceFork:(BOOL)flag;
- (NSInteger) inflateToDirectory:(NSString * _Nonnull)expansionDirectory usingResourceFork:(BOOL)rfFlag;
- (NSInteger) inflateFile:(ZKCDHeader *_Nonnull)cdHeader toDirectory:(NSString * _Null_unspecified)expansionDirectory;

- (NSInteger) deflateFiles:(NSArray * _Nonnull)paths relativeToPath:(NSString *_Null_unspecified)basePath usingResourceFork:(BOOL)flag;
- (NSInteger) deflateDirectory:(NSString * _Nonnull)dirPath relativeToPath:(NSString *_Nonnull)basePath usingResourceFork:(BOOL)flag;
- (NSInteger) deflateFile:(NSString * _Nonnull)path relativeToPath:(NSString * _Null_unspecified)basePath usingResourceFork:(BOOL)flag;
- (NSInteger) deflateFile:(NSString * _Nonnull)path relativeToPath:(NSString * _Null_unspecified)basePath usingResourceFork:(BOOL)flag andProgressHandler:(void(^ _Nullable)(CGFloat percent))progressHandler;

@property (assign) BOOL useZip64Extensions;
@property (atomic) int compressionLevel;

@end
