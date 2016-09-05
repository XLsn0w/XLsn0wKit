
#import "XLsn0wMethods.h"

@implementation XLsn0wMethods

+ (void)initNavigationControllerWithRootViewController:(UIViewController *)viewController
                                       tabBarItemTitle:(NSString *)title
                                   tabBarItemImageName:(NSString *)imageName
                           tabBarItemSelectedImageName:(NSString *)selectedImageName {
    UINavigationController *childNC = [[UINavigationController alloc] initWithRootViewController:viewController];
    childNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [viewController addChildViewController:childNC];
}

@end
