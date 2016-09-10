//
//  EmoticonViewController.m
//  IMY_RichText
//
//  Created by dm on 15/4/15.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "EmoticonViewController.h"
#import "IMYEmoticonView.h"
#import "EmoticonManager.h"
#import "IMYEasyInputView.h"

@interface EmoticonViewController ()<IMYEmoticonViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@end

@implementation EmoticonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTipAndTextFields];
}

- (void)setTipAndTextFields
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 50, 40)];
    label.text = @"Input:";
    [self.view addSubview:label];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(70, 20, self.view.bounds.size.width - 90, 80)];
    self.textView.backgroundColor = [UIColor yellowColor];
    self.textView.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.textView];
    self.textView.inputView = [IMYEmoticonView emoticonViewWithDelegate:self type:IMYEmoticonViewTypeReview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IMYEmoticonViewDelegate

- (void)didTouchEmojiView:(EmoticonPageView *)emojiView touchedEmoji:(NSString*)string
{
    [EmoticonManager emojiInsertWithTextView:self.textView emojiKey:string];
}

- (void)didDelEmojiView:(EmoticonPageView *)emojiView
{
    [EmoticonManager emojiDeleteWithTextView:self.textView];
}

- (void)didSendEmojiView:(EmoticonPageView *)emojiView
{
    NSLog(@"发送:%@",self.textView.text);
}

@end
