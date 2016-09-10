//
//  IMYEmoticonView.m
//  IMY_RichText
//
//  Created by dm on 15/4/15.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "IMYEmoticonView.h"
#import "EmoticonManager.h"
#import "StyledPageControl.h"

#define colorFromRGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]

@interface IMYEmoticonView()
@property (nonatomic, weak) id<IMYEmoticonViewDelegate> delegate;
@property (nonatomic, assign) IMYEmoticonViewType type;                             //表情键盘类型
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) StyledPageControl *pageControl;
+ (IMYEmoticonView *)shareInstance;
@end

@implementation IMYEmoticonView

+ (IMYEmoticonView *)shareInstance
{
    static IMYEmoticonView *_sharedInstance;
    static dispatch_once_t instanceOnceToken;
    dispatch_once(&instanceOnceToken, ^{
        _sharedInstance = [[IMYEmoticonView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 185)];
    });
    return _sharedInstance;
}

+ (UIView *)emoticonViewWithDelegate:(id<IMYEmoticonViewDelegate>)delegate
{
    return [self emoticonViewWithDelegate:delegate type:IMYEmoticonViewTypeDefault];
}

+ (UIView *)emoticonViewWithDelegate:(id<IMYEmoticonViewDelegate>)delegate type:(IMYEmoticonViewType)type
{
    [IMYEmoticonView shareInstance].delegate = delegate;
    if([IMYEmoticonView shareInstance].type != type)
    {
        [IMYEmoticonView shareInstance].scrollView.delegate = nil;
        [[IMYEmoticonView shareInstance].scrollView removeFromSuperview];
        [IMYEmoticonView shareInstance].scrollView = nil;
    }
    [IMYEmoticonView shareInstance].type = type;
    
    [[IMYEmoticonView shareInstance] setupBoard];
    [IMYEmoticonView shareInstance].scrollView.delegate = [IMYEmoticonView shareInstance];
    
    return [IMYEmoticonView shareInstance];
}

#pragma mark - 内部方法

- (void)setupBoard
{
    self.clipsToBounds = NO;
    if (!self.scrollView)
    {
        //背景图
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        UIImage *image = [UIImage imageNamed:@"all_bottom_bg"];
        NSInteger leftCapWidth = image.size.width * 0.5f;
        NSInteger topCapHeight = image.size.height * 0.5f;
        [bgImageView setImage:[image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight]];
        [self addSubview:bgImageView];
        
        //全部表情文字与表情图片
        NSMutableArray *symbolArray = [NSMutableArray arrayWithArray:[EmoticonManager sharedManager].emojiKeyArray];
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:[EmoticonManager sharedManager].emojiValueArray.count];
        for (NSInteger i = 0; i < [EmoticonManager sharedManager].emojiValueArray.count; i++)
        {
            [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"emo_%03ld.png", (long)(i + 1)]]];
        }
        //回复类型的键盘，每页只有19个表情
        NSInteger pageSize = self.type == IMYEmoticonViewTypeReview ? 19 : 20;
        NSInteger page = (imageArray.count - 1) / pageSize + 1;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.clipsToBounds = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * page, self.bounds.size.height);
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        //创建每个表情输入视图
        for (NSInteger i = 0; i < page; i++)
        {
            EmoticonPageView *pageView = [[EmoticonPageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * i, 0, self.bounds.size.width, 185)];
            pageView.backgroundColor = [UIColor clearColor];
            pageView.type = self.type;
            NSArray *viewEmojiArray;
            NSArray *viewEmojiSymbolArray;
            if (imageArray.count > pageSize)
            {
                viewEmojiArray = [imageArray subarrayWithRange:NSMakeRange(0, pageSize)];
                [imageArray removeObjectsInRange:NSMakeRange(0, pageSize)];
            }
            else
            {
                viewEmojiArray = imageArray;
            }
            
            if (symbolArray.count > pageSize)
            {
                viewEmojiSymbolArray = [symbolArray subarrayWithRange:NSMakeRange(0, pageSize)];
                [symbolArray removeObjectsInRange:NSMakeRange(0, pageSize)];
            }
            else
            {
                viewEmojiSymbolArray = symbolArray;
            }
            
            pageView.emojiArray = viewEmojiArray;
            pageView.symbolArray = viewEmojiSymbolArray;
            
            pageView.delegate = self.delegate;
            [_scrollView addSubview:pageView];
        }
        
        //pageControl
        _pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, _scrollView.frame.size.height - 26, _scrollView.frame.size.width, 20)];
        _pageControl.coreNormalColor = colorFromRGB(169, 169, 169);
        _pageControl.coreSelectedColor = colorFromRGB(255, 101, 1);
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.numberOfPages = page;
        [self addSubview:_pageControl];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.pageControl.currentPage = page;
}

@end
