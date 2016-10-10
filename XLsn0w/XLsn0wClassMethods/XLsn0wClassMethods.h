//
//  XLsn0wClassMethods.h
//  XLsn0wKit
//
//  Created by XLsn0w on 2016/10/10.
//  Copyright © 2016年 XLsn0w. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//类开头是+开头

@interface XLsn0wClassMethods : NSObject

+ (void)initNavigationControllerWithRootViewController:(UIViewController *)viewController
                                       tabBarItemTitle:(NSString *)title
                                   tabBarItemImageName:(NSString *)imageName
                           tabBarItemSelectedImageName:(NSString *)selectedImageName currentSelf:(UIViewController *)currentSelf;


+ (void)xl_setURLCache;


@end
