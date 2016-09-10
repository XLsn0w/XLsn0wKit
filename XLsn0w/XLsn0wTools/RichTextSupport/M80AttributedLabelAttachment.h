//
//  M80AttributedLabelImage.h
//  M80AttributedLabel
//
//  Created by amao on 13-8-31.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "M80AttributedLabelDefines.h"

void deallocCallback(void* ref);
CGFloat ascentCallback(void *ref);
CGFloat descentCallback(void *ref);
CGFloat widthCallback(void* ref);

@interface M80AttributedLabelAttachment : NSObject
@property (nonatomic,strong)    id                  content;
@property (nonatomic,assign)    UIEdgeInsets        margin;
@property (nonatomic,assign)    M80ImageAlignment   alignment;
@property (nonatomic,assign)    CGFloat             fontAscent;
@property (nonatomic,assign)    CGFloat             fontDescent;
@property (nonatomic,assign)    CGSize              maxSize;

///行数限制时用的
@property (nonatomic,assign)    NSUInteger          displayLineCount;
@property (nonatomic,assign)    CGRect              displayFrame;
@property (nonatomic,assign)    NSUInteger          displayLine;

///全文显示用的frame
@property (nonatomic,assign)    CGRect              allFrame;
@property (nonatomic,assign)    NSUInteger          allLine;

+ (M80AttributedLabelAttachment *)attachmentWith: (id)content
                                          margin: (UIEdgeInsets)margin
                                       alignment: (M80ImageAlignment)alignment
                                         maxSize: (CGSize)maxSize;

- (CGSize)boxSize;

@end
