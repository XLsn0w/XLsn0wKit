/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "XLsn0wMethods.h"

@implementation XLsn0wMethods

+ (void)initNavigationControllerWithRootViewController:(UIViewController *)viewController
                                       tabBarItemTitle:(NSString *)title
                                   tabBarItemImageName:(NSString *)imageName
                           tabBarItemSelectedImageName:(NSString *)selectedImageName
                                           currentSelf:(UIViewController *)currentSelf {
    UINavigationController *childNC = [[UINavigationController alloc] initWithRootViewController:viewController];
    childNC.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [currentSelf addChildViewController:childNC];
}

+ (void)xl_showTimeoutWithCurrentSelf:(UIViewController *)currentSelf {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"超时提醒" message:@"网络请求超时 !" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAlertAction];
    [currentSelf presentViewController:alertController animated:YES completion:nil];
}

+ (void)xl_setURLCache {
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

@end
