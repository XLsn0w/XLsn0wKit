//
//  IMYEmoticonView.h
//  IMY_RichText
//
//  Created by dm on 15/4/15.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonPageView.h"

//@protocol IMYEmoticonViewDelegate;

@class StyledPageControl;
@interface IMYEmoticonView : UIView<UIScrollViewDelegate>

+ (UIView *)emoticonViewWithDelegate:(id<IMYEmoticonViewDelegate>)delegate;
+ (UIView *)emoticonViewWithDelegate:(id<IMYEmoticonViewDelegate>)delegate type:(IMYEmoticonViewType)type;

@end
