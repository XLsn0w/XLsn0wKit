
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KeyBoardHepler;

@protocol KeyBoardDelegate <NSObject>

-(void)keyBoardWillShowNotification:(NSNotification *)notification;
-(void)keyBoardWillDismissNotification:(NSNotification *)notification;

@end

@interface KeyBoardHepler : NSObject
/**
 *  注册键盘出现
 *
 *  @param target self
 */
+(void)registerKeyBoardShow:(id)target;
/**
 *  注册键盘消失
 *
 *  @param target self
 */
+(void)registerKeyBoardDismiss:(id)target;
/**
 *  返回键盘高度宽度
 *
 *  @return
 */
+(CGRect)getKeyBoardWindow:(NSNotification *)notification;
/**
 *  返回键盘上拉动画持续时间
 *
 *  @return
 */
+(double)getKeyBoardDuration:(NSNotification *)notification;
/**
 *  返回键盘上拉 下拉动画曲线
 *  @return 
 */
+(UIViewAnimationCurve)getKeyBoardAnimationCurve:(NSNotification *)notification;



@end
