//
//  ViewController.m
//  33
//
//  Created by XLsn0w on 16/9/11.
//  Copyright © 2016年 XLsn0w. All rights reserved.
//

#import "ViewController.h"
#import "XLsn0wComponents.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)show:(id)sender {
//    [XLsn0wShow showTopWithText:@"Top"];
//    [XLsn0wShow showBottomWithText:@"Bottom"];
//    [XLsn0wShow showTopWithText:@"Top" duration:5];
    [XLsn0wShow showBottomWithText:@"Bottom" duration:3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
