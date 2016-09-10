//
//  RichTextViewController.m
//  IMY_RichText
//
//  Created by dm on 15/4/15.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "RichTextViewController.h"
#import "M80AttributedLabel+IMY.h"
#import "M80AttributedLabelURL.h"

@interface RichTextViewController ()<M80AttributedLabelDelegate>

@end

@implementation RichTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    M80AttributedLabel *label = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
    //如果要处理链接的单击或长按事件，必须设置delegate
    label.delegate = self;
    label.backgroundColor = [UIColor yellowColor];
    NSString *text  = @"The game which [尔康] I current [不是表情] play is hearthstone,and [开心] its website is www.hearthstone.com.cn";
    [label setSYText:text];
    label.frame = CGRectMake(20, 10, self.view.bounds.size.width - 40, self.view.bounds.size.height);
    //计算label内容的真实高度
    [label autoAdjustHeight];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - M80AttributedLabelDelegate

- (void)m80AttributedLabel:(M80AttributedLabel *)label
             clickedOnLink:(M80AttributedLabelURL*)linkURL
{
    NSLog(@"单击链接:%@",linkURL.linkData);
}

- (void)m80AttributedLabel:(M80AttributedLabel *)label
              longedOnLink:(M80AttributedLabelURL*)linkURL
{
    NSLog(@"长按链接:%@",linkURL.linkData);
}

@end
