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

@interface XLsn0wTimeShaftModel : NSObject

/** 日期 */
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *status;
/** 图片地址 */
@property (nonatomic, strong) NSString *imgUrl;
/** 是滞是最后一个cell */
@property (nonatomic, assign) BOOL isLast;
/** cell高度 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;

@end

@interface NSString (MyExtensions)

- (CGSize)getUISize:(UIFont*)font limitWidth:(CGFloat)width;
/*
 * 将指定text转换成md5
 */
- (NSString *)md5;

/*
 * 计算指定text所需要的高度
 */
- (CGFloat)contentHeightWithFontSize:(float)fontSize maxWidth:(CGFloat)maxWidth;
- (CGFloat)contentHeightWithFontSize:(float)fontSize maxWidth:(CGFloat)maxWidth lineSpacing:(CGFloat)lineSpacing;

- (CGFloat)contentHeightWithBoldFontSize:(float)fontSize maxWidth:(CGFloat)maxWidth;

/*
 * 计算指定text所需要的宽度
 */
- (CGFloat)contentWidthWithFontSize:(float)fontSize maxHeight:(CGFloat) maxHeight;

- (NSDictionary *)dictionary;

- (NSData *) strToHexData;

@end
