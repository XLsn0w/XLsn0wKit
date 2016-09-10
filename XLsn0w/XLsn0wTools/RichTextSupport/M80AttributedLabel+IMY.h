//
//  M80AttributedLabel+IMY.h
//  IMY_RichText
//
//  Created by dm on 15/4/9.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "M80AttributedLabel.h"

typedef NS_ENUM(NSUInteger, SYTextParseType) {
    ///不解析
    SYTextParseTypeNone              = 0,
    ///解析Emoji
    SYTextParseTypeEmoji             = 1 << 0,
    ///解析普通URL的模块
    SYTextParseTypeURL               = 1 << 1,
    ///聊天模块
    SYTextParseTypeIM                = 1 << 2,
    ///强制解析URL
    SYTextParseTypeForceURL          = 1 << 3,
    
    ///解析普通模块  解析Emoji 并且 解析URL （不强制解析URL）
    SYTextParseTypeNormal            = (SYTextParseTypeEmoji|SYTextParseTypeURL),
};

@interface M80AttributedLabel (IMY)

#pragma mark- 直接设置文本
///按普通模块来解析 表情和url
- (void)setSYText:(NSString*)text;
///会自己解析 表情和url
- (void)setSYText:(NSString*)text parseType:(SYTextParseType)parseType;
//辅助key
- (void)setSYText:(NSString *)text parseType:(SYTextParseType)parseType otherKey:(NSString *)key;

#pragma mark- 追加文本到末尾
///按普通模块来解析 表情和url
- (void)appendSYText:(NSString*)text;
///是否解析 表情 或者 链接
- (void)appendSYText:(NSString *)text parseType:(SYTextParseType)parseType;

#pragma mark- 其他方法
///自动高度 宽度不变
- (void)autoAdjustHeight;

///是否有该text的缓存数据
+ (BOOL)containsCacheText:(NSString*)text parseType:(SYTextParseType)parseType font:(UIFont*)font otherKey:(NSString *)key;

///清除所有m80的缓存
+ (void)clearM80Cache;

@end
