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

#import <UIKit/UIKit.h>

@protocol PopMenuDelegate;

@interface PopMenu : UIView

@property (nonatomic, assign) id<PopMenuDelegate>popMenuDelegate;

+ (instancetype)popMenuShowWithArray:(NSArray *)showArray; //显示弹出菜单
+ (void)popMenuDismiss;//隐藏弹出菜单

@end

@protocol PopMenuDelegate <NSObject>

@required
- (void)popMenu:(PopMenu *)menu didSelectItem:(id)item;

@end

@interface PopMenuCell : UITableViewCell

@property (nonatomic, strong) UILabel *infoLabel;

@end
