//
//  EmoticonManager.h
//  IMY_RichText
//
//  Created by dm on 15/4/9.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EmoticonManager : NSObject
@property (strong, nonatomic) NSArray *emojiKeyArray;
@property (strong, nonatomic) NSArray *emojiValueArray;

+ (instancetype)sharedManager;

//删除表情
+ (void)emojiDeleteWithTextView:(UITextView *)textView;
//插入表情
+ (void)emojiInsertWithTextView:(UITextView *)textView emojiKey:(NSString *)emojiKey;

+ (BOOL)emojiWithTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
//查找一串文字里包含几个表情
+ (NSInteger)emojiCount:(NSString *)string;
//查看是否包含表情
+ (BOOL)hasContainEmojiWithString:(NSString*)string;
//截取多余表情的字符串
+ (NSString*)emojiDeleteMoreWithString:(NSString *)string count:(int)count;

@end
