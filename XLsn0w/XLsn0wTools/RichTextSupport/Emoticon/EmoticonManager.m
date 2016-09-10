//
//  EmoticonManager.m
//  IMY_RichText
//
//  Created by dm on 15/4/9.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "EmoticonManager.h"

@implementation EmoticonManager

+ (instancetype)sharedManager
{
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSArray *)emojiKeyArray
{
    if (!_emojiKeyArray)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmoticonKeyList" ofType:@"plist"];
        _emojiKeyArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _emojiKeyArray;
}

- (NSArray *)emojiValueArray
{
    if (!_emojiValueArray)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmoticonValueList" ofType:@"plist"];
        _emojiValueArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _emojiValueArray;
}



+ (void)emojiDeleteWithTextView:(UITextView *)textView
{
    NSRange range = textView.selectedRange;
    if (range.length == 0)
    {
        if (range.location > 0)
        {
            range.location -= 1;
            range.length = 1;
        }
    }
    
    if ([self emojiWithTextView:textView shouldChangeTextInRange:range replacementText:nil])
    {
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:@""];
        range.length = 0;
        textView.selectedRange = range;
        [textView scrollRangeToVisible:range];
    }
}

+ (void)emojiInsertWithTextView:(UITextView *)textView emojiKey:(NSString *)emojiKey
{
    NSInteger emoji_count = [self emojiCount:textView.text];
    if (emoji_count > 9)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"一次最多加入10个表情哦～" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    NSRange range = textView.selectedRange;
    if (range.location == NSNotFound) {
        range.location = textView.text.length;
    }
    NSString *emojiString = [NSString stringWithFormat:@"[%@]", emojiKey];
    
    if ([self emojiWithTextView:textView shouldChangeTextInRange:range replacementText:emojiString])
    {
        textView.text = [textView.text stringByReplacingCharactersInRange:range withString:emojiString];
        range.location += emojiString.length;
        range.length = 0;
        textView.selectedRange = range;
        [textView scrollRangeToVisible:range];
    }
}

+ (BOOL)emojiWithTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replaceText
{
    NSString *textViewString = textView.text;
    if (range.location + range.length > textViewString.length)
    {
        return YES;
    }
    
    NSCharacterSet *character = [NSMutableCharacterSet characterSetWithCharactersInString:@"[]"];
    int extends = 0;
    if (range.length > 0 || replaceText == nil)
    {
        extends = 1;
    }
    
    BOOL change = NO;
    do
    {
        //为了安全性 系统会矫正你的单词 所以先加个保护
        if (range.location + extends > textViewString.length)
            break;
        
        NSRange up = [textViewString rangeOfCharacterFromSet:character options:NSBackwardsSearch range:NSMakeRange(0, range.location + extends)];
        
        if (up.location + up.length > textViewString.length)
            break;
        
        NSString *findText = [textViewString substringWithRange:up];
        if ([findText isEqualToString:@"]"] && up.location == range.location)
        {
            NSRange r = [textViewString rangeOfString:@"[" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
            //没找到
            if (r.length == 0)
                break;
            
            r = NSMakeRange(r.location + 1, range.location - r.location - 1);
            NSString *emojiTxt = [textViewString substringWithRange:r];
            
            //找到符合表情格式的中间KEY
            if ([[EmoticonManager sharedManager].emojiKeyArray indexOfObject:emojiTxt] != NSNotFound)
            {
                range.location = r.location - 1;
                range.length += r.length + 1;
                change = YES;
            }
        }
        else if ([findText isEqualToString:@"["] && up.location < range.location)
        {
            NSRange r = [textViewString rangeOfString:@"]" options:0 range:NSMakeRange(range.location + extends, textViewString.length - range.location - extends)];
            //没找到
            if (r.length == 0)
                break;
            
            r = NSMakeRange(up.location + 1, r.location - up.location - 1);
            NSString *emojiTxt = [textViewString substringWithRange:r];
            if ([[EmoticonManager sharedManager].emojiKeyArray indexOfObject:emojiTxt] != NSNotFound)
            {
                if (replaceText.length == 0 || range.length > 0)
                {
                    if (range.location + range.length < r.location + r.length + 1)
                    {
                        range.location = r.location - 1;
                        range.length += r.length + 1;
                    }
                    else
                    {
                        NSInteger diff = range.location - (r.location - 1);
                        range.location = r.location - 1;
                        range.length += diff;
                    }
                }
                else
                {
                    range.location = r.location + r.length + 1;
                }
                change = YES;
            }
        }
    } while (0);
    
    do
    {
        
        NSRange nr = NSMakeRange(range.location + range.length, textViewString.length - range.location - range.length);
        if (nr.location + nr.length > textViewString.length)
            break;
        
        nr = [textViewString rangeOfCharacterFromSet:character options:0 range:nr];
        if (nr.length == 0)
            break;
        
        if ([[textViewString substringWithRange:nr] isEqualToString:@"]"] == NO)
            break;
        
        NSRange r = [textViewString rangeOfString:@"[" options:NSBackwardsSearch range:NSMakeRange(0, nr.location)];
        if (r.length == 0)
            break;
        
        //找到后面符合表情格式的中间KEY
        r = NSMakeRange(r.location + 1, nr.location - r.location - 1);
        NSString *emojiTxt = [textViewString substringWithRange:r];
        if ([[EmoticonManager sharedManager].emojiKeyArray indexOfObject:emojiTxt] != NSNotFound)
        {
            range.length = r.location + r.length + 1 - range.location;
            change = YES;
        }
        
    } while (0);
    
    if (change)
    {
        if (replaceText == nil)
        {
            replaceText = @"";
        }
        
        textView.text = [textViewString stringByReplacingCharactersInRange:range withString:replaceText];
        range.location += replaceText.length;
        range.length = 0;
        textView.selectedRange = range;
        [textView scrollRangeToVisible:range];
        return NO;
    }
    
    return YES;
}

+ (NSInteger)emojiCount:(NSString *)string
{
    int count = 0;
    if (string == nil)
    {
        return count;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\]^\\[]+\\]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSArray *keys = [EmoticonManager sharedManager].emojiKeyArray;
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range = [match range];
        range.location += 1;
        range.length -= 2;
        NSString *subTxt = [string substringWithRange:range];
        NSUInteger index = [keys indexOfObject:subTxt];
        if (index != NSNotFound)
        {
            count++;
        }
    }
    return count;
}

+ (BOOL)hasContainEmojiWithString:(NSString *)string
{
    __block BOOL hasEmotion = NO;
    if (string == nil)
    {
        return hasEmotion;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\]^\\[]+\\]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSArray *keys = [EmoticonManager sharedManager].emojiKeyArray;
    [matches enumerateObjectsUsingBlock:^(NSTextCheckingResult *match, NSUInteger idx, BOOL *stop) {
        NSRange range = [match range];
        range.location += 1;
        range.length -= 2;
        NSString *subTxt = [string substringWithRange:range];
        NSUInteger index = [keys indexOfObject:subTxt];
        if (index != NSNotFound)
        {
            *stop = YES;
            hasEmotion = YES;
        }
    }];
    return hasEmotion;
}

+ (NSString *)emojiDeleteMoreWithString:(NSString *)string count:(int)maxCount
{
    int count = 0;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\]^\\[]+\\]" options:0
                                                                             error:nil];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (matches.count <= maxCount)
    {
        return nil;
    }
    
    NSArray *keys = [EmoticonManager sharedManager].emojiKeyArray;
    
    NSMutableArray *toDeleteMathch = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches)
    {
        NSRange range = [match range];
        range.location += 1;
        range.length -= 2;
        NSString *subTxt = [string substringWithRange:range];
        NSUInteger index = [keys indexOfObject:subTxt];
        if (index != NSNotFound)
        {
            count++;
            
            if (count > maxCount)
            {
                [toDeleteMathch addObject:match];
            }
            
        }
    }
    
    if (toDeleteMathch.count > 0)
    {
        
        NSMutableString *resultString = [NSMutableString stringWithString:string];
        int diffLength = 0;
        for (NSTextCheckingResult *match in toDeleteMathch)
        {
            NSRange range = [match range];
            range.location -= diffLength;
            if (range.location + range.length <= resultString.length)
            {
                diffLength += range.length;
                [resultString deleteCharactersInRange:range];
            }
        }
        
        return resultString;
    }
    return nil;
}

@end
