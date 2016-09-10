//
//  IMYEasyInputView.m
//  IMY_RichText
//
//  Created by dm on 15/4/16.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "IMYEasyInputView.h"
#import "EmoticonManager.h"

@interface IMYEasyInputView()<HPGrowingTextViewDelegate>
@property (nonatomic, strong) UIImageView *bg;
@end

@implementation IMYEasyInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
        CGRect bgFrame = frame;
        UIImageView *bg = [[UIImageView alloc] initWithFrame:bgFrame];
        bg.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        bg.image = [[UIImage imageNamed:@"all_bottom_inputbg_chat"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [self addSubview:bg];
        self.bg = bg;
        //right View这样设置
        //_cameraButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(8, 5.5, frame.size.width - 16 , frame.size.height - 11)];
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 4;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont boldSystemFontOfSize:15];
        _textView.backgroundColor = [UIColor yellowColor];
        [self addSubview:_textView];
        [self addKeyboardNotify];
    }
    
    return self;
}

+ (instancetype)inputView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 45)];
}

- (void)setLeftView:(UIView *)leftView
{
    CGFloat height = MIN(leftView.frame.size.height, 45 - 11);
    leftView.frame = CGRectMake(8, 45 - 5.5 - height, leftView.frame.size.width, height);
    leftView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self addSubview:leftView];
    _leftView = leftView;
    
    CGFloat textViewWidth = self.frame.size.width - 8 * 2;
    if(_leftView)
    {
        textViewWidth -= (_leftView.frame.size.width + 8);
    }
    if(_rightView)
    {
        textViewWidth -= (_rightView.frame.size.width + 8);
    }
    
    _textView.frame = CGRectMake(_leftView.frame.origin.x + _leftView.frame.size.width + 8, 5.5, textViewWidth, 45 - 11);
}

- (void)setRightView:(UIView *)rightView
{
    CGFloat height = MIN(rightView.frame.size.height, 45 - 11);
    rightView.frame = CGRectMake(self.frame.size.width - 8 - rightView.frame.size.width, 45 - 5.5 - height, rightView.frame.size.width, height);
    rightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:rightView];
    _rightView = rightView;
    
    CGFloat textViewWidth = self.frame.size.width - 8 * 2;
    if(_leftView)
    {
        textViewWidth -= (_leftView.frame.size.width + 8);
    }
    if(_rightView)
    {
        textViewWidth -= (_rightView.frame.size.width + 8);
    }
    
    _textView.frame = CGRectMake(_leftView.frame.origin.x + _leftView.frame.size.width + 8, 5.5, textViewWidth, 45 - 11);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addKeyboardNotify
{
    [self removeKeyboardNotify];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotify
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    if (self.isFirstResponder)
    {
        _textView.text = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (_textView.text.length == 0 || [_textView.text isEqualToString:@""])
        {
            _textView.text = @"";
        }
        CGRect keyboardBounds;
        NSUInteger option = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
        {
            option = option << 16;
        }
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
        NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        
        self.keyboardHeight = keyboardBounds.size.height;
        if (_delegate && [_delegate respondsToSelector:@selector(inputViewWillBecomeFirstResponder:keyboardHeight:animationDuration:option:)])
        {
            [_delegate inputViewWillBecomeFirstResponder:self keyboardHeight:keyboardBounds.size.height animationDuration:duration.floatValue option:option];
            if (_textView.text.length == 0)
            {
                _textView.text = @"";
                _textView.selectedRange = NSMakeRange(0, 0);
            }
            CGRect keyboardBounds;
            NSUInteger option = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
            if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
            {
                option = option << 16;
            }
            [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
            NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
            if (_delegate && [_delegate respondsToSelector:@selector(inputViewWillBecomeFirstResponder:keyboardHeight:animationDuration:option:)])
            {
                [_delegate inputViewWillBecomeFirstResponder:self keyboardHeight:keyboardBounds.size.height animationDuration:duration.floatValue option:option];
            }
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
    if (self.isFirstResponder)
    {
        CGRect keyboardBounds;
        NSInteger option = [note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
        {
            option = option << 16;
        }
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
        NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        if (_delegate && [_delegate respondsToSelector:@selector(inputViewWillResignFirstResponder:keyboardHeight:animationDuration:option:)])
        {
            [_delegate inputViewWillResignFirstResponder:self keyboardHeight:keyboardBounds.size.height animationDuration:duration.floatValue option:option];
        }
    }
}

#pragma mark HPGrowingTextViewDelegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    if (_delegate && [_delegate respondsToSelector:@selector(inputViewDidChangeHeight:changeHeight:)])
    {
        [_delegate inputViewDidChangeHeight:self changeHeight:-diff];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //发送
    if ([text isEqualToString:@"\n"])
    {
        if (growingTextView.text.length > 0)
        {
            [growingTextView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0];
            if (_delegate && [_delegate respondsToSelector:@selector(inputViewWillSend:)])
            {
                [_delegate inputViewWillSend:self];
            }
        }
        else
        {
            [IMYEasyInputView alertWithTitle:@"您还没有输入任何内容"];
        }
        return NO;
    }
    
    BOOL b = [EmoticonManager emojiWithTextView:growingTextView.internalTextView shouldChangeTextInRange:range replacementText:text];
    if(!b && ![IMYEasyInputView isBlankString:text]){
        [self growingTextViewDidChange:growingTextView];
    }
    
    if(!b)
    {
        __weak HPGrowingTextView* wtextview = _textView;
        dispatch_async(dispatch_get_main_queue(), ^{
            [wtextview refreshHeight];
        });
        return NO;
    }
    
    if([_delegate respondsToSelector:@selector(inputViewOfTextView:shouldChangeTextInRange:replacementText:)])
    {
        return [_delegate inputViewOfTextView:growingTextView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}
-(void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView
{
    UITextView* textView = growingTextView.internalTextView;
    if(textView.text.length > 0)
    {
        NSString* string = [EmoticonManager emojiDeleteMoreWithString:textView.text count:10];
        if(string)
        {
            textView.text = string;
            [IMYEasyInputView alertWithTitle:@"一次最多加入10个表情哦～"];
        }
    }
    if([_delegate respondsToSelector:@selector(inputViewOfTextViewDidChangeSelection:)])
    {
        [_delegate inputViewOfTextViewDidChangeSelection:growingTextView];
    }
}
-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if([_delegate respondsToSelector:@selector(inputViewOfTextViewDidChange:)])
    {
        [_delegate inputViewOfTextViewDidChange:growingTextView];
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (_delegate && [_delegate respondsToSelector:@selector(inputViewShouldBeginEdit:)]) {
        return [_delegate inputViewShouldBeginEdit:self];
    }
    return YES;
}

#pragma mark - inner methods

- (BOOL)isFirstResponder
{
    return _textView.isFirstResponder;
}

// 判断字符串为空或只为空格
+ (BOOL)isBlankString:(NSString *)string
{
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if([string isKindOfClass:[NSString class]] == NO)
    {
        return YES;
    }
    if(string.length == 0)
    {
        return YES;
    }
    NSString* trimString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimString.length == 0) {
        return YES;
    }
    NSString* lowercaseString = trimString.lowercaseString;
    if ([lowercaseString isEqualToString:@"(null)"] || [lowercaseString isEqualToString:@"null"] || [lowercaseString isEqualToString:@"<null>"])
    {
        return YES;
    }
    return NO;
}

+ (void)alertWithTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

@end
