//
//  ZKMasterViewController.m
//  ZipKit Touch
//
//  Created by Karl Moskowski on 2013-05-18.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "ZKMasterViewController.h"
#import "ZKDetailViewController.h"
#import "ZipKit/ZKDefs.h"
#import "ZipKit/ZKDataArchive.h"

@implementation ZKMasterViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.detailViewController = (ZKDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.archive = [ZKDataArchive new];
    [self.archive deflateFiles:@[[[NSBundle mainBundle] pathForResource:@"Read Me" ofType:@"txt"], [[NSBundle mainBundle] pathForResource:@"ZipKit" ofType:@"png"]] relativeToPath:[[NSBundle mainBundle] bundlePath] usingResourceFork:NO];
    [self.archive inflateAll];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.archive.inflatedFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *entry = self.archive.inflatedFiles[indexPath.row];
    cell.textLabel.text = entry[ZKPathKey];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDictionary *entry = self.archive.inflatedFiles[indexPath.row];
        self.detailViewController.fileData = entry[ZKFileDataKey];
        self.detailViewController.fileName = entry[ZKPathKey];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *entry = self.archive.inflatedFiles[indexPath.row];
        ZKDetailViewController *iPhoneDVC = (ZKDetailViewController *)[segue destinationViewController];
        iPhoneDVC.fileData = entry[ZKFileDataKey];
        iPhoneDVC.fileName = entry[ZKPathKey];
    }
}

@end
