#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController

- (IBAction)open:(id)sender;
- (IBAction)cancel:(id)sender;

@property (copy) NSString *message;
@property (copy) NSString *action;
@property (strong) NSDate *startTime;
@property (assign) double progress;
@property (assign) NSTimeInterval remainingTime;
@property (assign) unsigned long long sizeWritten;
@property (assign) unsigned long long totalSize;
@property (assign) unsigned long long totalCount;
@property (assign) BOOL isIndeterminate;
@property (strong) NSOperationQueue *zipQueue;

@end
