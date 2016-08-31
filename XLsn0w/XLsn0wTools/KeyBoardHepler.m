//
//  KeyBoardHepler.m
//  KeyBoard
//
//  Created by 换一换 on 16/2/25.
//  Copyright © 2016年 张洋. All rights reserved.
//

#import "KeyBoardHepler.h"

@implementation KeyBoardHepler
+(void)registerKeyBoardShow:(id)target{
    //键盘将要出现的时 进行监听
    [[NSNotificationCenter defaultCenter] addObserver:target selector:@selector(keyBoardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];

}
+(void)registerKeyBoardDismiss:(id)target{
    //将要消失时 进行监听
    [[NSNotificationCenter defaultCenter] addObserver:target selector:@selector(keyBoardWillDismissNotification:) name:UIKeyboardWillHideNotification object:nil];
}


+(CGRect)getKeyBoardWindow:(NSNotification *)notification
{    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrameWindow];
    return keyboardEndFrameWindow;
}

+(double)getKeyBoardDuration:(NSNotification *)notification
{
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    return keyboardTransitionDuration;
}
+(UIViewAnimationCurve)getKeyBoardAnimationCurve:(NSNotification *)notification
{
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    return keyboardTransitionAnimationCurve;
}
@end
