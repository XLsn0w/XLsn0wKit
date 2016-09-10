//
//  IMYEasyInputView.h
//  IMY_RichText
//
//  Created by dm on 15/4/16.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@class IMYEasyInputView;
@protocol IMYEasyInputViewDelegate <NSObject>
@optional
//changeHeight:改变的高度,正数为增加，负数为减小
- (void)inputViewDidChangeHeight:(IMYEasyInputView *)inputView changeHeight:(float)changeHeight;

- (void)inputViewWillBecomeFirstResponder:(IMYEasyInputView *)inputView keyboardHeight:(CGFloat)height animationDuration:(CGFloat)duration option:(UIViewAnimationOptions)option;

- (void)inputViewWillResignFirstResponder:(IMYEasyInputView *)inputView keyboardHeight:(CGFloat)height animationDuration:(CGFloat)duration option:(UIViewAnimationOptions)option;
//发送
- (void)inputViewWillSend:(IMYEasyInputView *)inputView;

- (BOOL)inputViewOfTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)inputViewOfTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView;
- (void)inputViewOfTextViewDidChange:(HPGrowingTextView *)growingTextView;

- (BOOL)inputViewShouldBeginEdit:(IMYEasyInputView *)inputView;
@end



@interface IMYEasyInputView : UIView
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, weak) id <IMYEasyInputViewDelegate> delegate;
@property CGFloat keyboardHeight;

+ (instancetype)inputView;

@end
