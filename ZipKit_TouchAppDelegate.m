#import "ZipKit_TouchAppDelegate.h"
#import "ZipKit_TouchRootViewController.h"

@implementation ZipKit_TouchAppDelegate

@synthesize window;
@synthesize navigationController;

- (void)applicationDidFinishLaunching:(UIApplication *) application {	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end