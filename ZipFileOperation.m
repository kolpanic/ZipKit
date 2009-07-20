//
//  ZipFileOperation.m
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import "ZipFileOperation.h"
#import <ZipKit/ZKFileArchive.h>
#import <ZipKit/ZKLog.h>

@implementation ZipFileOperation

- (void) main {
	[ZKFileArchive process:self.item usingResourceFork:YES withInvoker:self andDelegate:self.delegate];
}

@synthesize item, delegate;

@end