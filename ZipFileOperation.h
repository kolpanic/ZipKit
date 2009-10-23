//
//  ZipFileOperation.h
//  ZipKit
//
//  Created by Karl Moskowski on 01/04/09.
//

#import <Foundation/Foundation.h>

@interface ZipFileOperation : NSOperation {
	id item;
	id delegate;
}

@property (assign) id item;
@property (assign) id delegate;

@end