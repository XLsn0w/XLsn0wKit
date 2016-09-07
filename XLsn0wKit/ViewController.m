//
//  ViewController.m
//  WebImageDemo
//
//  Created by YueWen on 16/3/20.
//  Copyright © 2016年 YueWen. All rights reserved.
//

#import "ViewController.h"

#import "UIImageView+XLsn0wWebImage.h"
#import "XLsn0wFileStore.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *inputView;

@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}


//开始加载图片
- (IBAction)startLoadImage:(id)sender {
    //默认初始化label为本地
    self.label.text = @"本地图片！";

    NSString *imageURL = @"http://news.hainan.net/Editor/img/201304/20130428/big/20130428114534772_9485643.jpg";
    //可看进度的方法   
    [self.imageView xlsn0w_setImageWithUrl:imageURL withProgressHandle:^(CGFloat didFinish, CGFloat didFinishTotal, CGFloat Total) {
        
        //更改Label
        NSString * progress = [NSString stringWithFormat:@"%.1f%%",(didFinishTotal * 1.0 / Total) * 100.0];
        self.label.text = progress;
        
    }];
}


//开始计算文件大小
- (IBAction)lookFileSize:(id)sender
{
    NSString * fileSize = [NSString stringWithFormat:@"缓存大小为:%@MB",[[XLsn0wFileStore shareInstance] fileSize]];
    
    self.lblFileSize.text = fileSize;
}


//删除所有的文件
- (IBAction)deleteAllFile:(id)sender
{
    [[XLsn0wFileStore shareInstance] deleteAllCAchesProgress:^(NSString *fileName) {
        
        //更改lable的显示
        self.label.text = [NSString stringWithFormat:@"正在删除%@",fileName];
        
    } Complete:^{
        
        //更改lable的显示
        self.label.text = @"删除完毕!";
        self.imageView.image = [UIImage imageNamed:@""];
        
    }];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
