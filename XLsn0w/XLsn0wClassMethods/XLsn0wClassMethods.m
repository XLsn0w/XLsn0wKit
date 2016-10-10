//
//  XLsn0wClassMethods.m
//  XLsn0wKit
//
//  Created by XLsn0w on 2016/10/10.
//  Copyright © 2016年 XLsn0w. All rights reserved.
//

#import "XLsn0wClassMethods.h"

@implementation XLsn0wClassMethods

+ (void)initNavigationControllerWithRootViewController:(UIViewController *)viewController
                                       tabBarItemTitle:(NSString *)title
                                   tabBarItemImageName:(NSString *)imageName
                           tabBarItemSelectedImageName:(NSString *)selectedImageName
                                           currentSelf:(UIViewController *)currentSelf {
    UINavigationController *childNC = [[UINavigationController alloc] initWithRootViewController:viewController];
    childNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [currentSelf addChildViewController:childNC];
}

+ (void)xl_setURLCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}


@end
