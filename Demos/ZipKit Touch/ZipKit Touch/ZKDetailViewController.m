//
//  ZKDetailViewController.m
//  ZipKit Touch
//
//  Created by Karl Moskowski on 2013-05-18.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "ZKDetailViewController.h"

@interface ZKDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation ZKDetailViewController

#pragma mark - Managing the detail item

- (void)setFileData:(NSData *)newFileData {
    _fileData = newFileData;
    [self configureView];
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}
- (void)setFileName:(NSString *)newFileName {
    _fileName = newFileName;
    [self configureView];
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView {
    if (self.fileName != nil && self.fileData != nil) {
        self.title = self.fileName;
        NSString *ext = [self.fileName pathExtension];
        if ([ext isEqualToString:@"txt"]) {
            UITextView *textView = [UITextView new];
            [textView setText:[[NSString alloc] initWithData:self.fileData encoding:NSUTF8StringEncoding]];
            self.view = textView;
        } else if ([ext isEqualToString:@"png"]) {
            UIImageView *imageView = [UIImageView new];
            [imageView setImage:[UIImage imageWithData:self.fileData]];
            self.view = imageView;
        } else {
            UITextView *textView = [UITextView new];
            [textView setText:@"Only txt and PNG files are supported"];
            self.view = textView;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Files", @"Files");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
