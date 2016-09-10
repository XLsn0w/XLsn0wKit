//
//  EmoticonPageView.h
//  IMY_RichText
//
//  Created by dm on 15/4/15.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    IMYEmoticonViewTypeNormal,                                      //带“删除”按钮
    IMYEmoticonViewTypeReview,                                      //带“发送”与“删除”按钮
    IMYEmoticonViewTypeDefault = IMYEmoticonViewTypeNormal,
}IMYEmoticonViewType;

@class EmoticonPageView;
@protocol IMYEmoticonViewDelegate<NSObject>
@optional
- (void)didTouchEmojiView:(EmoticonPageView *)emojiView touchedEmoji:(NSString*)string;
- (void)didDelEmojiView:(EmoticonPageView *)emojiView;
- (void)didSendEmojiView:(EmoticonPageView *)emojiView;
@end

@interface EmoticonPageView : UIView
@property (nonatomic, weak) id<IMYEmoticonViewDelegate> delegate;
@property (assign, nonatomic) IMYEmoticonViewType type;
@property (strong, nonatomic) NSArray *emojiArray;
@property (strong, nonatomic) NSArray *symbolArray;
@end

@interface TSEmojiViewLayer : UIView
+ (instancetype)shareEmojiViewLayer;
@property (nonatomic, strong) UIImageView *backgroup;
@property (nonatomic, strong) UIImageView *emojiView;
@end
