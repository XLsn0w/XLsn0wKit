//
//  M80AttributedLabelURL.h
//  M80AttributedLabel
//
//  Created by amao on 13-8-31.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "M80AttributedLabelDefines.h"


@interface M80AttributedLabelURL : NSObject
@property (nonatomic,strong)    id      linkData;
@property (nonatomic,assign)    NSRange range;
@property (nonatomic,strong)    UIColor *color;
@property CGRect frame;

///显示的frames  因为url 可能占了多行  一行一个frame
@property (nonatomic,strong) NSMutableArray* showFrames;

///当有行数限制时的frames
@property (nonatomic,assign) NSInteger displayLineCount;
@property (nonatomic,strong) NSMutableArray* displayFrames;

+ (M80AttributedLabelURL *)urlWithLinkData: (id)linkData
                                     range: (NSRange)range
                                     color: (UIColor *)color;


+ (NSArray *)detectLinks: (NSString *)plainText;

+ (void)setCustomDetectMethod:(M80CustomDetectLinkBlock)block;
@end


