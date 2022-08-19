
#import <UIKit/UIKit.h>
/** 使用例子
 [view xlsn0w_shadowColor:[UIColor redColor]
            shadowOpacity:0.5
             shadowRadius:5
           shadowPathType:UIShadowPathAround
          shadowPathWidth:3];
 */
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger , UIShadowPathType) {
    UIShadowPathTop    = 1,
    UIShadowPathBottom = 2,
    UIShadowPathLeft   = 3,
    UIShadowPathRight  = 4,
    UIShadowPathCommon = 5,
    UIShadowPathAround = 6,
};

@interface UIView (shadowPath)

/**
 给UIView添加阴影

 @param shadowColor 阴影颜色
 @param shadowOpacity 阴影透明度 默认0
 @param shadowRadius 阴影半径 也就是阴影放射程度 默认3
 @param shadowPathType 阴影方向
 @param shadowPathWidth 阴影放射g宽度
 */
- (void)xlsn0w_shadowColor:(UIColor *)shadowColor
             shadowOpacity:(CGFloat)shadowOpacity
              shadowRadius:(CGFloat)shadowRadius
            shadowPathType:(UIShadowPathType)shadowPathType
           shadowPathWidth:(CGFloat)shadowPathWidth;

@end

NS_ASSUME_NONNULL_END
