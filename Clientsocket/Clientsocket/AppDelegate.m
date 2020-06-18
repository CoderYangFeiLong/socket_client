//
//  AppDelegate.m
//  socket
//
//  Created by cherish on 2020/6/17.
//  Copyright © 2020 cherish. All rights reserved.
//

#import "AppDelegate.h"
#import "ClientViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ClientViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
