//
//  ZKDetailViewController.h
//  ZipKit Touch
//
//  Created by Karl Moskowski on 2013-05-18.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) NSData *fileData;
@property (strong, nonatomic) NSString *fileName;

@end
