//
//  EmoticonPageView.m
//  IMY_RichText
//
//  Created by dm on 15/4/15.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "EmoticonPageView.h"

#define TSEMOJIVIEW_COLUMNS 7
#define TSEMOJIVIEW_KEYTOP_WIDTH 68
#define TSEMOJIVIEW_KEYTOP_HEIGHT 80
#define TSEMOJI_SIZE 32
#define GLASS_SIZE  40      //放大后的图片大小

@implementation TSEmojiViewLayer

+ (instancetype)shareEmojiViewLayer
{
    static TSEmojiViewLayer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TSEmojiViewLayer alloc] initWithFrame:CGRectMake(0, 0, TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT)];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroup = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TSEMOJIVIEW_KEYTOP_WIDTH, TSEMOJIVIEW_KEYTOP_HEIGHT)];
        _backgroup.image = [UIImage imageNamed:@"sent_emotion_big"];
        [self addSubview:_backgroup];
        
        self.emojiView = [[UIImageView alloc] initWithFrame:CGRectMake(TSEMOJIVIEW_KEYTOP_WIDTH / 2 - GLASS_SIZE / 2, 16, GLASS_SIZE, GLASS_SIZE)];
        [self addSubview:_emojiView];
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

@end


@interface EmoticonPageView()
{
    NSInteger _touchedIndex;
}
@property(assign, nonatomic) BOOL isTouchCancel;
@end

@implementation EmoticonPageView

- (void)drawRect:(CGRect)rect
{
    int index = 0;
    
    float elementWidth = (self.bounds.size.width / TSEMOJIVIEW_COLUMNS);
    float elementHeight = (320/TSEMOJIVIEW_COLUMNS);
    for (UIImage *image in _emojiArray)
    {
        int row = index / TSEMOJIVIEW_COLUMNS;
        float originX = elementWidth * (index % TSEMOJIVIEW_COLUMNS) + 6;
        float originY = row * (elementHeight + 6) + 10 + 6;
        [image drawInRect:CGRectMake(originX, originY, TSEMOJI_SIZE, TSEMOJI_SIZE)];
        index++;
    }
    
    //删除按钮
    UIButton *delbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    delbutton.frame = CGRectMake(0, 118, 40, 40);
    [delbutton setImageEdgeInsets:UIEdgeInsetsMake(0, 4, 0, 0)];
    [delbutton setImage:[UIImage imageNamed:@"sent_delet"] forState:UIControlStateNormal];
    [delbutton addTarget:self action:@selector(delEmoji:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delbutton];
    delbutton.center = CGPointMake(elementWidth*(6%TSEMOJIVIEW_COLUMNS)+6+TSEMOJI_SIZE/2, 2*(elementHeight+6)+10+8+TSEMOJI_SIZE/2);
    
    if (self.type == IMYEmoticonViewTypeReview)
    {
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sendButton.frame = CGRectMake(0, 127, 44, 23);
        UIImage *image = [[UIImage imageNamed:@"all_redbutton"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        [sendButton setBackgroundImage:image forState:UIControlStateNormal];
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendEmoji:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendButton];
        delbutton.center = CGPointMake(elementWidth*(5%TSEMOJIVIEW_COLUMNS)+6+TSEMOJI_SIZE/2, 2*(elementHeight+6)+10+8+TSEMOJI_SIZE/2);
        sendButton.center = CGPointMake(elementWidth*(6%TSEMOJIVIEW_COLUMNS)+6+TSEMOJI_SIZE/2, 2*(elementHeight+6)+10+8+TSEMOJI_SIZE/2);
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    TSEmojiViewLayer *emojiLayer = [TSEmojiViewLayer shareEmojiViewLayer];
    if (emojiLayer.superview != newSuperview.superview)
    {
        emojiLayer.hidden = YES;
        [newSuperview.superview addSubview:emojiLayer];
    }
}

#pragma mark -
#pragma mark Actions

- (NSUInteger)indexWithEvent:(UIEvent *)event
{
    float elementWidth = self.bounds.size.width / TSEMOJIVIEW_COLUMNS;
    UITouch *touch = [[event allTouches] anyObject];
    NSUInteger x = [touch locationInView:self].x / elementWidth;
    NSUInteger y = [touch locationInView:self].y / (elementWidth + 6);
    return x + (y * TSEMOJIVIEW_COLUMNS);
}

- (void)updateWithIndex:(NSUInteger)index
{
    TSEmojiViewLayer *emojiLayer = [TSEmojiViewLayer shareEmojiViewLayer];
    //删除表情按钮
    if (index == 21)
    {
        emojiLayer.hidden = YES;
        return;
    }
    
    if (index < _emojiArray.count)
    {
        _touchedIndex = index;
        
        if (emojiLayer.hidden)
        {
            emojiLayer.alpha = 0;
            emojiLayer.hidden = NO;
            [UIView animateWithDuration:0.2 animations:^{
                emojiLayer.alpha = 1;
            }];
        }
        
        float elementWidth = self.bounds.size.width / TSEMOJIVIEW_COLUMNS;
        float originX = elementWidth * (index % TSEMOJIVIEW_COLUMNS);
        float originY = (index / TSEMOJIVIEW_COLUMNS) * (elementWidth + 6) - 10;
        
        UIImage *image = _emojiArray[index];
        if (emojiLayer.emojiView.image != image)
        {
            emojiLayer.emojiView.image = image;
        }
        
        CGPoint origin = CGPointMake(originX - (TSEMOJIVIEW_KEYTOP_WIDTH - TSEMOJI_SIZE) / 2 + 6, originY - (TSEMOJIVIEW_KEYTOP_HEIGHT - TSEMOJI_SIZE) + 6);
        [emojiLayer setFrame:CGRectMake(origin.x, origin.y, emojiLayer.frame.size.width, emojiLayer.frame.size.height)];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIScrollView *scrollView = [self findViewParentWithClass:[UIScrollView class]];
    scrollView.scrollEnabled = NO;
    
    NSUInteger index = [self indexWithEvent:event];
    if (index < _emojiArray.count)
    {
        [self updateWithIndex:index];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger index = [self indexWithEvent:event];
    if (_touchedIndex >= 0 && index != _touchedIndex && index < _emojiArray.count && !_isTouchCancel)
    {
        [self updateWithIndex:index];
    }
    else if (index >= _emojiArray.count)
    {
        TSEmojiViewLayer *emojiLayer = [TSEmojiViewLayer shareEmojiViewLayer];
        emojiLayer.hidden = YES;
        _isTouchCancel = YES;
    }
    else if (index < _emojiArray.count)
    {
        TSEmojiViewLayer *emojiLayer = [TSEmojiViewLayer shareEmojiViewLayer];
        emojiLayer.hidden = NO;
        _isTouchCancel = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIScrollView *scrollView = [self findViewParentWithClass:[UIScrollView class]];
    scrollView.scrollEnabled = YES;
    
    if (self.delegate && _touchedIndex >= 0 && !_isTouchCancel)
    {
        if ([self.delegate respondsToSelector:@selector(didTouchEmojiView:touchedEmoji:)])
        {
            [self.delegate didTouchEmojiView:self touchedEmoji:_symbolArray[_touchedIndex]];
        }
    }
    _touchedIndex = -1;
    _isTouchCancel = NO;
    
    [TSEmojiViewLayer shareEmojiViewLayer].hidden = YES;
    
    [self setNeedsDisplay];
}

- (void)delEmoji:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDelEmojiView:)])
        [self.delegate didDelEmojiView:self];
}

- (void)sendEmoji:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSendEmojiView:)])
    {
        [self.delegate didSendEmojiView:self];
    }
}

#pragma mark - 内部方法

- (id)findViewParentWithClass:(Class)clazz
{
    if ([self isKindOfClass:clazz])
    {
        return self;
    }
    UIView *view = self.superview;
    while (view && ![view isKindOfClass:clazz])
    {
        view = view.superview;
    }
    return view;
}

@end
