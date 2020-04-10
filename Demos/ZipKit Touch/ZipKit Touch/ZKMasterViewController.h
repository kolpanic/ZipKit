//
//  ZKMasterViewController.h
//  ZipKit Touch
//
//  Created by Karl Moskowski on 2013-05-18.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZKDetailViewController;
@class ZKDataArchive;

@interface ZKMasterViewController : UITableViewController

@property (strong, nonatomic) ZKDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet ZKDataArchive *archive;

@end
