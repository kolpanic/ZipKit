//
//  ZKAppDelegate.m
//  ZipKit Touch
//
//  Created by Karl Moskowski on 2013-05-18.
//  Copyright (c) 2013 Karl Moskowski. All rights reserved.
//

#import "ZKAppDelegate.h"

@implementation ZKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    return YES;
}

@end
