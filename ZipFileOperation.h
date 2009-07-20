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

@property (retain) id item;
@property (retain) id delegate;

@end