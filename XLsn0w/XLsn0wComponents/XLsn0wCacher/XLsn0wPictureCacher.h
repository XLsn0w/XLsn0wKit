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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XLsn0wPictureCacher : NSObject
/*!
 * @author XLsn0w
 *
 * [XLsn0wCacher defaultCacher]
 */
+ (XLsn0wPictureCacher *)defaultCacher;

/*!
 * @author XLsn0w
 *
 * UIImageView
 */
- (void)xl_setCacheImageView:(UIImageView *)imageView imageURL:(NSString *)imageURL imageKey:(NSString *)imageKey;

/*!
 * @author XLsn0w
 *
 * UIButton
 */
- (void)xl_setCacheImageButton:(UIButton *)imageButton imageURL:(NSString *)imageURL imageKey:(NSString *)imageKey;

@end
