#import <Foundation/Foundation.h>

@interface ZipFileOperation : NSOperation

@property (strong) id item;
@property (weak) id delegate;

@end
