#import "ZKDataArchive.h"

@interface ZipKit_TouchRootViewController : UITableViewController {
	UIViewController *nextViewController;
	UIImageView *imageView;
	UITextView *textView;
	ZKDataArchive *archive;
}

@property (nonatomic, retain) UIViewController *nextViewController;
@property (nonatomic, retain) IBOutlet ZKDataArchive *archive;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UITextView *textView;

@end