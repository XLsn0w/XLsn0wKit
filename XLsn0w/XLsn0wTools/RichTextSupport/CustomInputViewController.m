//
//  CustomInputViewController.m
//  IMY_RichText
//
//  Created by dm on 15/4/17.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "CustomInputViewController.h"
#import "IMYEasyInputView.h"

@interface CustomInputViewController ()<IMYEasyInputViewDelegate>
@property (nonatomic, strong) IMYEasyInputView *easyInputView;
@end

@implementation CustomInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(setupInputView) withObject:nil afterDelay:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupInputView
{
    self.easyInputView = [IMYEasyInputView inputView];
    self.easyInputView.delegate = self;
    self.easyInputView.textView.placeholder = @"说点什么吧～";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"按钮" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 100, 60);
    button.backgroundColor = [UIColor whiteColor];
    self.easyInputView.rightView = button;
    [button addTarget:self action:@selector(rightButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    self.easyInputView.frame = CGRectMake(0, self.view.frame.size.height - self.easyInputView.frame.size.height, self.easyInputView.frame.size.width, self.easyInputView.frame.size.height);
    [self.view addSubview:self.easyInputView];
}

- (void)rightButtonTap:(UIButton *)button
{
    NSLog(@"change!");
}

#pragma mark - IMYEasyInputViewDelegate

- (void)inputViewWillBecomeFirstResponder:(IMYEasyInputView *)inputView keyboardHeight:(CGFloat)height animationDuration:(CGFloat)duration option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        inputView.frame = CGRectMake(inputView.frame.origin.x, self.view.frame.size.height - height - inputView.frame.size.height, inputView.frame.size.width, inputView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)inputViewWillResignFirstResponder:(IMYEasyInputView *)inputView keyboardHeight:(CGFloat)height animationDuration:(CGFloat)duration option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:duration delay:0 options:option animations:^{
        inputView.frame = CGRectMake(inputView.frame.origin.x, self.view.frame.size.height - inputView.frame.size.height, inputView.frame.size.width, inputView.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)inputViewWillSend:(IMYEasyInputView *)inputView
{
    NSLog(@"发送:%@",inputView.textView.text);
    inputView.textView.text = nil;
}

@end
