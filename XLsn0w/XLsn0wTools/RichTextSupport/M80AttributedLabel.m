//
//  M80AttributedLabel.m
//  M80AttributedLabel
//
//  Created by amao on 13-9-1.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import "M80AttributedLabel.h"
#import "M80AttributedLabelAttachment.h"
#import "M80AttributedLabelURL.h"
//#import "NSString+Emojize.h"

static NSString* const kEllipsesCharacter = @"\u2026";

static dispatch_queue_t m80_attributed_label_parse_queue;
static dispatch_queue_t get_m80_attributed_label_parse_queue() \
{
    if (m80_attributed_label_parse_queue == NULL) {
        m80_attributed_label_parse_queue = dispatch_queue_create("com.m80.parse_queue", 0);
    }
    return m80_attributed_label_parse_queue;
}

@interface M80AttributedLabel ()
{
    CTFrameRef                  _textFrame;
    CGFloat                     _fontAscent;
    CGFloat                     _fontDescent;
    CGFloat                     _fontHeight;
    
    NSInteger _linesCount;
    BOOL _isShowAllText;
    
    BOOL hasLongPressed;
}
///计算中的attributedString
@property (nonatomic,strong)    NSMutableAttributedString *attributedString;
@property (nonatomic,strong)    M80AttributedLabelURL *touchedLink;
@property (nonatomic,assign)    BOOL linkDetected;
@property (nonatomic, strong)   UILongPressGestureRecognizer *longPressGestureRecognizer;
@end

@implementation M80AttributedLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)dealloc
{
    if (_textFrame)
    {
        CFRelease(_textFrame);
    }
    
}

#pragma mark - 初始化
-(void)setAttachments:(NSMutableArray *)attachments
{
    _attachments = [NSMutableArray arrayWithArray:attachments];
}
-(void)setLinkLocations:(NSMutableArray *)linkLocations
{
    _linkLocations = [NSMutableArray arrayWithArray:linkLocations];
}
- (void)commonInit
{
    _shouldLongPress        = YES;
    _attributedString       = [[NSMutableAttributedString alloc]init];
    _attachments            = [[NSMutableArray alloc]init];
    _linkLocations          = [[NSMutableArray alloc]init];
    _textFrame              = nil;
    _linkColor              = [UIColor colorWithRed:255/255.0 green:80/255.0 blue:115/255.0 alpha:1];
    _font                   = [UIFont fontWithName:@"STHeitiSC-Light" size:15];
    _textColor              = [UIColor blackColor];
    _highlightColor         = [UIColor colorWithWhite:0.73f alpha:0.4f];
    
    _lineBreakMode          = kCTLineBreakByCharWrapping;
    _underLineForLink       = NO;
    _autoDetectLinks        = NO;
    _lineSpacing            = 1.0;
    _paragraphSpacing       = 0.0;
    
    self.userInteractionEnabled = YES;
    [self resetFont];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.delegate = (id)self;
    [self addGestureRecognizer:longPress];
    self.longPressGestureRecognizer = longPress;
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    if (_shouldLongPress)
    {
        if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            hasLongPressed = YES;

            if (self.touchedLink)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(m80AttributedLabel:longedOnLink:)])
                {
                    [_delegate m80AttributedLabel:self longedOnLink:self.touchedLink];
                }
            }
        }
        else if(longPressGestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            if (self.touchedLink)
            {
                self.touchedLink = nil;
                [self setNeedsDisplay];
            }
        }
    }
}

- (void)setShouldLongPress:(BOOL)shouldLongPress
{
    [self removeGestureRecognizer:_longPressGestureRecognizer];
    _shouldLongPress = shouldLongPress;
    if (shouldLongPress)
    {
        [self addGestureRecognizer:_longPressGestureRecognizer];
    }
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    if (gestureRecognizer.state == UIGestureRecognizerStateCancelled)
//    {
//        return NO;
//    }
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
//    {
//        return YES;
//    }
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
//    {
//        if ([touch.view isKindOfClass:[UIControl class]])
//        {
//            return NO;
//        }
//    }
//    return YES;
//}

- (void)cleanAll
{
    _linkDetected = NO;
    _attachments = [NSMutableArray array];
    _linkLocations = [NSMutableArray array];
    
    self.touchedLink = nil;
    
    ///在主线程中移除subviews
    if([NSThread isMainThread])
    {
        NSArray* subviews = self.subviews;
        for (UIView *subView in subviews)
        {
            [subView removeFromSuperview];
        }
    }
    
    [self resetTextFrame];
}


- (void)resetTextFrame
{
    if (_textFrame)
    {
        CFRelease(_textFrame);
        _textFrame = nil;
    }
    [self setNeedsDisplay];
}

- (void)resetFont
{
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    if (fontRef)
    {
        _fontAscent     = CTFontGetAscent(fontRef);
        _fontDescent    = CTFontGetDescent(fontRef);
        _fontHeight     = CTFontGetSize(fontRef);
        CFRelease(fontRef);
    }
}

#pragma mark - 属性设置
//保证正常绘制，如果传入nil就直接不处理
- (void)setFont:(UIFont *)font
{
    ///传nil 进来不管
    if(!font)
    {
        return;
    }
    
    BOOL newBold = ([font.fontName containsString:@"Bold"] || [font.fontName containsString:@"Medium"]);
    float newSize = font.pointSize;
    if(_font)
    {
        BOOL oldBold = ([_font.fontName containsString:@"Bold"] || [_font.fontName containsString:@"Medium"]);
        //字体大小和是否粗体都一样  就不更改字体了
        if(_font.pointSize == newSize && oldBold == newBold)
        {
            return;
        }
    }
    
    if(newBold)
    {
        ///把字体强制改为 STHeitiSC-Medium  略粗
        font = [UIFont fontWithName:@"STHeitiSC-Medium" size:newSize];
    }
    else
    {
        ///把字体强制改为 STHeitiSC-Light
        font = [UIFont fontWithName:@"STHeitiSC-Light" size:newSize];
    }

    ///如果没找到该字体 就是用系统字体
    if(!font)
    {
        if(newBold)
        {
            font = [UIFont boldSystemFontOfSize:newSize];
        }
        else
        {
            font = [UIFont systemFontOfSize:newSize];
        }
    }
    
    _font = font;
    
    [_attributedString setFont:_font];
    [self resetFont];
    for (M80AttributedLabelAttachment *attachment in _attachments)
    {
        attachment.fontAscent = _fontAscent;
        attachment.fontDescent = _fontDescent;
    }
    [self resetTextFrame];
}

- (void)setTextColor:(UIColor *)textColor
{
    if (textColor && _textColor != textColor)
    {
        _textColor = textColor;
        [_attributedString setTextColor:textColor];
        [self resetTextFrame];
    }
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    if (highlightColor && _highlightColor != highlightColor)
    {
        _highlightColor = highlightColor;
        
        [self resetTextFrame];
    }
}

- (void)setLinkColor:(UIColor *)linkColor
{
    if (_linkColor != linkColor)
    {
        _linkColor = linkColor;
        
        [self resetTextFrame];
    }
}

- (void)setFrame:(CGRect)frame
{
    CGRect oldRect = self.bounds;
    [super setFrame:frame];
    
    if (!CGRectEqualToRect(self.bounds, oldRect)) {
        [self resetTextFrame];
    }
}

- (void)setBounds:(CGRect)bounds
{
    CGRect oldRect = self.bounds;
    [super setBounds:bounds];
    
    if (!CGRectEqualToRect(self.bounds, oldRect))
    {
        [self resetTextFrame];
    }
}


#pragma mark - 辅助方法
- (NSAttributedString *)attributedString:(NSString *)text
{
    if ([text length])
    {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:text];
        [string setFont:self.font];
        [string setTextColor:self.textColor];
        return string;
    }
    else
    {
        return [[NSAttributedString alloc]init];
    }
}

- (NSInteger)numberOfDisplayedLines
{
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    return _numberOfLines > 0 ? MIN(CFArrayGetCount(lines), _numberOfLines) : CFArrayGetCount(lines);
}

-(NSAttributedString *)showAttributedString
{
    if(_showAttributedString == nil)
    {
        @synchronized(self)
        {
            if (_attributedString.length > 0)
            {
                //添加排版格式
                NSMutableAttributedString *drawString = [_attributedString mutableCopy];
                
                //如果LineBreakMode为TranncateTail,那么默认排版模式改成kCTLineBreakByCharWrapping,使得尽可能地显示所有文字
                CTLineBreakMode lineBreakMode = self.lineBreakMode;
                if (self.lineBreakMode == kCTLineBreakByTruncatingTail)
                {
                    lineBreakMode = _numberOfLines == 1 ? kCTLineBreakByCharWrapping : kCTLineBreakByWordWrapping;
                    
                }
                
                CGFloat fontLineHeight = self.font.lineHeight;
                CTParagraphStyleSetting settings[]={
                    {kCTParagraphStyleSpecifierAlignment,sizeof(_textAlignment),&_textAlignment},
                    {kCTParagraphStyleSpecifierLineBreakMode,sizeof(lineBreakMode),&lineBreakMode},
                    {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
                    {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(_lineSpacing),&_lineSpacing},
                    {kCTParagraphStyleSpecifierParagraphSpacing,sizeof(_paragraphSpacing),&_paragraphSpacing},
                    {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(fontLineHeight),&fontLineHeight},
                };
                CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings,sizeof(settings) / sizeof(settings[0]));
                [drawString addAttribute:(id)kCTParagraphStyleAttributeName
                                   value:(__bridge id)paragraphStyle
                                   range:NSMakeRange(0, [drawString length])];
                CFRelease(paragraphStyle);
                
                
                for (int i=0; i<_linkLocations.count;)
                {
                    M80AttributedLabelURL *url = _linkLocations[i];
                    ///移除不符合条件的url
                    if([url isKindOfClass:[M80AttributedLabelURL class]] && (url.range.location + url.range.length <= [_attributedString length]))
                    {
                        UIColor *drawLinkColor = url.color ? : self.linkColor;
                        [drawString setTextColor:drawLinkColor range:url.range];
                        [drawString setUnderlineStyle:_underLineForLink ? kCTUnderlineStyleSingle : kCTUnderlineStyleNone
                                             modifier:kCTUnderlinePatternSolid
                                                range:url.range];
                        
                        i++;
                    }
                    else
                    {
                        [_linkLocations removeObjectAtIndex:i];
                    }
                }
                _showAttributedString = drawString;
            }
            else
            {
                _showAttributedString = nil;
            }
        }
    }
    return _showAttributedString;
}
- (NSAttributedString *)attributedStringForDraw
{
    if (!_showAttributedString)
    {
        [self showAttributedString];
    }
    return _showAttributedString;
}

-(void)fillURLFrames
{
    if (_textFrame == nil || _linkLocations.count == 0)
    {
        return;
    }
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    if (!lines)
    {
        return;
    }
    
    CFIndex lineCount = CFArrayGetCount(lines);
    M80AttributedLabelURL* firstCheck = _linkLocations[0];
    if(firstCheck.displayLineCount == lineCount)
    {
        //行数限制的 已有缓存
        return;
    }
    
    if(_isShowAllText)
    {
        if(firstCheck.showFrames.count > 0)
        {
            //全文显示 也有缓存了
            return;
        }
    }
    else
    {
        for (M80AttributedLabelURL* url in _linkLocations)
        {
            [url.displayFrames removeAllObjects];
        }
    }
    
    CGPoint origins[lineCount];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0,0), origins);
    
    NSInteger lineTextIndex = 0;
    for (int i = 0; i < lineCount; i++)
    {
        CGPoint linePoint = origins[i];
        
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        NSInteger lineTextCount = CTLineGetGlyphCount(line);
        
        for (M80AttributedLabelURL* url in _linkLocations)
        {
            BOOL isLineContainURL = NO;
            if(lineTextIndex <= url.range.location && url.range.location <= (lineTextIndex + lineTextCount))
            {
                isLineContainURL = YES;
            }
            else if(lineTextIndex > url.range.location && url.range.location + url.range.length > lineTextIndex)
            {
                isLineContainURL = YES;
            }
            if(isLineContainURL)
            {
                CGRect highlightRect = [self rectForRange:url.range
                                                   inLine:line
                                               lineOrigin:linePoint];
                if(CGRectIsEmpty(highlightRect) == NO)
                {
                    highlightRect.origin.y = self.frame.size.height - highlightRect.origin.y - highlightRect.size.height;

                    highlightRect.origin.y -= 1;
                    highlightRect.size.height += 1;
                    
                    if(_isShowAllText)
                    {
                        [url.showFrames addObject:[NSValue valueWithCGRect:highlightRect]];
                    }
                    else
                    {
                        url.displayLineCount = lineCount;
                        [url.displayFrames addObject:[NSValue valueWithCGRect:highlightRect]];
                    }
                }
            }
        }
        
        lineTextIndex += lineTextCount;
    }
}
- (M80AttributedLabelURL *)urlForPoint: (CGPoint)point
{
    for (M80AttributedLabelURL* url in _linkLocations)
    {
        NSMutableArray* showFrames = nil;
        if(_isShowAllText)
        {
            showFrames = url.showFrames;
        }
        else
        {
            showFrames = url.displayFrames;
        }
        
        for (NSValue* frameValue in showFrames) {
            
            CGRect frame = frameValue.CGRectValue;
            frame.origin.y -= 2;
            frame.origin.x -= 2;
            frame.size.width += 4;
            frame.size.height += 4;
            
            if(CGRectContainsPoint(frame, point))
            {
                url.frame = frame;
                return url;
            }
        }
    }
    return nil;
}


- (id)linkDataForPoint:(CGPoint)point
{
    M80AttributedLabelURL *url = [self urlForPoint:point];
    return url ? url.linkData : nil;
}

- (CGAffineTransform)transformForCoreText
{
    return CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);
}

- (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint) point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    
    return CGRectMake(point.x, point.y - descent, width, height);
}

- (M80AttributedLabelURL *)linkAtIndex:(CFIndex)index
{
    for (M80AttributedLabelURL *url in _linkLocations)
    {
        if (NSLocationInRange(index, url.range))
        {
            return url;
        }
    }
    return nil;
}


- (CGRect)rectForRange:(NSRange)range
                inLine:(CTLineRef)line
            lineOrigin:(CGPoint)lineOrigin
{
    CGRect rectForRange = CGRectZero;
    CFArrayRef runs = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runs);
    
    // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
    // intersect with the range.
    for (CFIndex k = 0; k < runCount; k++)
    {
        CTRunRef run = CFArrayGetValueAtIndex(runs, k);
        
        CFRange stringRunRange = CTRunGetStringRange(run);
        NSRange lineRunRange = NSMakeRange(stringRunRange.location, stringRunRange.length);
        NSRange intersectedRunRange = NSIntersectionRange(lineRunRange, range);
        
        if (intersectedRunRange.length == 0)
        {
            // This run doesn't intersect the range, so skip it.
            continue;
        }
        
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        
        // Use of 'leading' doesn't properly highlight Japanese-character link.
        CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                           CFRangeMake(0, 0),
                                                           &ascent,
                                                           &descent,
                                                           NULL); //&leading);
        CGFloat height = ascent + descent;
        
        CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
        
        CGRect linkRect = CGRectMake(lineOrigin.x + xOffset - leading, lineOrigin.y - descent, width + leading, height);
        
        linkRect.origin.y = roundf(linkRect.origin.y);
        linkRect.origin.x = roundf(linkRect.origin.x);
        linkRect.size.width = roundf(linkRect.size.width);
        linkRect.size.height = roundf(linkRect.size.height);
        
        rectForRange = CGRectIsEmpty(rectForRange) ? linkRect : CGRectUnion(rectForRange, linkRect);
    }
    
    return rectForRange;
}

- (void)appendAttachment: (M80AttributedLabelAttachment *)attachment
{
    attachment.fontAscent                   = _fontAscent;
    attachment.fontDescent                  = _fontDescent;
    unichar objectReplacementChar           = 0xFFFC;
    NSString *objectReplacementString       = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSMutableAttributedString *attachText   = [[NSMutableAttributedString alloc]initWithString:objectReplacementString];
    
    CTRunDelegateCallbacks callbacks;
    callbacks.version       = kCTRunDelegateVersion1;
    callbacks.getAscent     = ascentCallback;
    callbacks.getDescent    = descentCallback;
    callbacks.getWidth      = widthCallback;
    callbacks.dealloc       = deallocCallback;
    
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void *)attachment);
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)delegate,kCTRunDelegateAttributeName, nil];
    [attachText setAttributes:attr range:NSMakeRange(0, 1)];
    CFRelease(delegate);
    
    [_attachments addObject:attachment];
    [self appendAttributedText:attachText];
}


#pragma mark - 设置文本
- (void)setText:(NSString *)text
{
    NSAttributedString *attributedText = [self attributedString:text];
    [self setAttributedText:attributedText];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _linesCount = 0;
    _showAttributedString = nil;
    _attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedText];
    
    NSInteger stringLength = _attributedString.length;
    if(stringLength > 0)
    {
        int i = 0;
        NSRange range;
        while (i < stringLength)
        {
            NSDictionary* dic = [_attributedString attributesAtIndex:i effectiveRange:&range];
            if(range.length == 0)
            {
                break;
            }
            else
            {
                NSArray* array = dic.allKeys;
                if([array containsObject:@"CTRunDelegate"] == NO)
                {
                    if([array containsObject:@"NSFont"] == NO)
                    {
                        [_attributedString setFont:_font range:range];
                    }
                    if([array containsObject:@"CTForegroundColor"] == NO)
                    {
                        [_attributedString setTextColor:_textColor range:range];
                    }
                }
                
                i+= range.length;
            }
        }
    }
    [self cleanAll];
}


#pragma mark - 添加文本
- (void)appendText:(NSString *)text
{
    NSAttributedString *attributedText = [self attributedString:text];
    [self appendAttributedText:attributedText];
}

- (void)appendAttributedText: (NSAttributedString *)attributedText
{
    [_attributedString appendAttributedString:attributedText];
    [self resetTextFrame];
}


#pragma mark - 添加图片
- (void)appendImage: (UIImage *)image
{
    [self appendImage:image
              maxSize:image.size];
}

- (void)appendImage: (UIImage *)image
            maxSize: (CGSize)maxSize
{
    [self appendImage:image
              maxSize:maxSize
               margin:UIEdgeInsetsZero];
}

- (void)appendImage: (UIImage *)image
            maxSize: (CGSize)maxSize
             margin: (UIEdgeInsets)margin
{
    [self appendImage:image
              maxSize:maxSize
               margin:margin
            alignment:M80ImageAlignmentBottom];
}

- (void)appendImage: (UIImage *)image
            maxSize: (CGSize)maxSize
             margin: (UIEdgeInsets)margin
          alignment: (M80ImageAlignment)alignment
{
    M80AttributedLabelAttachment *attachment = [M80AttributedLabelAttachment attachmentWith:image
                                                                                     margin:margin
                                                                             alignment:alignment
                                                                               maxSize:maxSize];
    [self appendAttachment:attachment];
}

#pragma mark - 添加UI控件
- (void)appendView: (UIView *)view
{
    [self appendView:view
              margin:UIEdgeInsetsZero];
}

- (void)appendView: (UIView *)view
            margin: (UIEdgeInsets)margin
{
    [self appendView:view
              margin:margin
           alignment:M80ImageAlignmentBottom];
}


- (void)appendView: (UIView *)view
            margin: (UIEdgeInsets)margin
         alignment: (M80ImageAlignment)alignment
{
    M80AttributedLabelAttachment *attachment = [M80AttributedLabelAttachment attachmentWith:view
                                                                                     margin:margin
                                                                                  alignment:alignment
                                                                                    maxSize:CGSizeZero];
    [self appendAttachment:attachment];
}

#pragma mark - 添加链接
- (void)addCustomLink: (id)linkData
             forRange: (NSRange)range
{
    [self addCustomLink:linkData
               forRange:range
              linkColor:self.linkColor];
    
}

- (void)addCustomLink: (id)linkData
             forRange: (NSRange)range
            linkColor: (UIColor *)color
{
    M80AttributedLabelURL *url = [M80AttributedLabelURL urlWithLinkData:linkData
                                                                  range:range
                                                                  color:color];
    [_linkLocations addObject:url];
    [self resetTextFrame];
}

#pragma mark - 计算大小
- (CGSize)sizeThatFits:(CGSize)size
{
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString == nil)
    {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter)
    {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0)
        {
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter)
    {
        CFRelease(framesetter);
    }
    return CGSizeMake(ceilf(newSize.width), ceilf(newSize.height));

    //hack:
    //1.需要加上额外的一部分size,有些情况下计算出来的像素点并不是那么精准
    //2.ios7的CTFramesetterSuggestFrameSizeWithConstraints方法比较残,需要多加一部分height
    //3.ios7多行中如果首行带有很多空格，会导致返回的suggestionWidth远小于真是width,那么多行情况下就是用传入的width
//    if (M80IOS7)
//    {
//        if (newSize.height < _fontHeight * 2)   //单行
//        {
//            return CGSizeMake(ceilf(newSize.width) + 2.0, ceilf(newSize.height) + 4.0);
//        }
//        else
//        {
//            return CGSizeMake(size.width, ceilf(newSize.height) + 4.0);
//        }
//    }
//    else
//    {
//        return CGSizeMake(ceilf(newSize.width) + 2.0, ceilf(newSize.height) + 2.0);
//    }
}
-(NSInteger)getLinesCount
{
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString == nil)
    {
        _linesCount = 0;
    }
    else if(_linesCount == 0)
    {
        CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
        if (framesetter)
        {
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathAddRect(path, NULL, CGRectMake(0, 0, self.frame.size.width, CGFLOAT_MAX));
            CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
            CFArrayRef lines = CTFrameGetLines(frame);
            
            if (nil != lines)
            {
                _linesCount = CFArrayGetCount(lines);
            }
            CFRelease(frame);
            CFRelease(path);
            CFRelease(framesetter);
        }
    }
    return _linesCount;
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)];
}

#pragma mark - 
+ (void)setCustomDetectMethod:(M80CustomDetectLinkBlock)block
{
    [M80AttributedLabelURL setCustomDetectMethod:block];
}

#pragma mark - 绘制方法
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil)
    {
        return;
    }
    CGContextSaveGState(ctx);
    CGAffineTransform transform = [self transformForCoreText];
    CGContextConcatCTM(ctx, transform);
    
    [self recomputeLinksIfNeeded];
    
    NSAttributedString *drawString = [self attributedStringForDraw];
    if (drawString)
    {
        [self prepareTextFrame:drawString rect:rect];
        [self drawHighlightWithRect:rect];
        [self drawAttachments];
        [self drawText:drawString
                  rect:rect
               context:ctx];
    }
    CGContextRestoreGState(ctx);
}

- (void)prepareTextFrame: (NSAttributedString *)string
                    rect: (CGRect)rect
{
    if (_textFrame == nil)
    {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil,rect);
        _textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CGPathRelease(path);
        CFRelease(framesetter);
        
        if(_textFrame)
        {
            CFArrayRef lines = CTFrameGetLines(_textFrame);
            if (lines)
            {
                CFIndex lineCount = CFArrayGetCount(lines);
                _isShowAllText = (self.getLinesCount == lineCount);
            }
        }
        
        [self fillURLFrames];
    }
}

- (void)drawHighlightWithRect: (CGRect)rect
{
    if (self.touchedLink && self.highlightColor)
    {
        [self.highlightColor setFill];
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        NSArray* showFrames = nil;
        if(_isShowAllText)
        {
            showFrames = self.touchedLink.showFrames;
        }
        else
        {
            showFrames = self.touchedLink.displayFrames;
        }
        
        for (NSValue* frameValue in showFrames)
        {
            CGRect highlightRect = frameValue.CGRectValue;
            ///绘制的时候 坐标是倒着的 so...
            highlightRect.origin.y = rect.size.height - highlightRect.origin.y - highlightRect.size.height;
            highlightRect = CGRectOffset(highlightRect, 0, -rect.origin.y);
            
            CGFloat pi = (CGFloat)M_PI;
            
            CGFloat radius = 1.0f;
            CGContextMoveToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + radius);
            CGContextAddLineToPoint(ctx, highlightRect.origin.x, highlightRect.origin.y + highlightRect.size.height - radius);
            CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + highlightRect.size.height - radius,
                            radius, pi, pi / 2.0f, 1.0f);
            CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                                    highlightRect.origin.y + highlightRect.size.height);
            CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius,
                            highlightRect.origin.y + highlightRect.size.height - radius, radius, pi / 2, 0.0f, 1.0f);
            CGContextAddLineToPoint(ctx, highlightRect.origin.x + highlightRect.size.width, highlightRect.origin.y + radius);
            CGContextAddArc(ctx, highlightRect.origin.x + highlightRect.size.width - radius, highlightRect.origin.y + radius,
                            radius, 0.0f, -pi / 2.0f, 1.0f);
            CGContextAddLineToPoint(ctx, highlightRect.origin.x + radius, highlightRect.origin.y);
            CGContextAddArc(ctx, highlightRect.origin.x + radius, highlightRect.origin.y + radius, radius,
                            -pi / 2, pi, 1);
            CGContextFillPath(ctx);
        }
    }
}

- (void)drawText: (NSAttributedString *)attributedString
            rect: (CGRect)rect
         context: (CGContextRef)context
{
    if (_textFrame)
    {
        if (_numberOfLines > 0)
        {
            CFArrayRef lines = CTFrameGetLines(_textFrame);
            NSInteger numberOfLines = [self numberOfDisplayedLines];
            
            CGPoint lineOrigins[numberOfLines];
            CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, numberOfLines), lineOrigins);
            
            for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++)
            {
                    CGPoint lineOrigin = lineOrigins[lineIndex];
                if (self.drawCenter) {
                    CGContextSetTextPosition(context, lineOrigin.x, (self.frame.size.height-self.font.lineHeight)/2+2);
                }
                else
                {
//                    if (_fixTopMargin && [NSString stringContainEmoji:self.showAttributedString.string])
//                    {
//                        //这个值待测试，不一定正确
//                        CGFloat scale = 2;
//                        if (IOS7)
//                        {
//                            scale = 0;
//                        }
//                        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y-_font.descender*scale);
//                    }
//                    else
//                    {
                        CGContextSetTextPosition(context, lineOrigin.x, lineOrigin.y);
//                    }
                }


                CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
                
                BOOL shouldDrawLine = YES;
                if (lineIndex == numberOfLines - 1 &&
                    _lineBreakMode == kCTLineBreakByTruncatingTail)
                {
                    // Does the last line need truncation?
                    CFRange lastLineRange = CTLineGetStringRange(line);
                    if (lastLineRange.location + lastLineRange.length < attributedString.length)
                    {
                        CTLineTruncationType truncationType = kCTLineTruncationEnd;
                        NSUInteger truncationAttributePosition = lastLineRange.location + lastLineRange.length - 1;
                        
                        NSDictionary *tokenAttributes = [attributedString attributesAtIndex:truncationAttributePosition
                                                                             effectiveRange:NULL];
                        NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:kEllipsesCharacter
                                                                                          attributes:tokenAttributes];
                        CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)tokenString);
                        
                        NSMutableAttributedString *truncationString = [[attributedString attributedSubstringFromRange:NSMakeRange(lastLineRange.location, lastLineRange.length)] mutableCopy];
                        
                        if (lastLineRange.length > 0)
                        {
                            // Remove last token
                            [truncationString deleteCharactersInRange:NSMakeRange(lastLineRange.length - 1, 1)];
                        }
                        [truncationString appendAttributedString:tokenString];

                        
                        CTLineRef truncationLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)truncationString);
                        CTLineRef truncatedLine = CTLineCreateTruncatedLine(truncationLine, rect.size.width, truncationType, truncationToken);
                        if (!truncatedLine)
                        {
                            // If the line is not as wide as the truncationToken, truncatedLine is NULL
                            truncatedLine = CFRetain(truncationToken);
                        }
                        CFRelease(truncationLine);
                        CFRelease(truncationToken);
                        
                        CTLineDraw(truncatedLine, context);
                        CFRelease(truncatedLine);
                        
                        
                        shouldDrawLine = NO;
                    }
                }
                if(shouldDrawLine)
                {
                    CTLineDraw(line, context);
                }
            }
        }
        else
        {
            CTFrameDraw(_textFrame,context);
        }
    }
}


- (void)drawAttachments
{
    if ([_attachments count] == 0)
    {
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (ctx == nil)
    {
        return;
    }
    CFArrayRef lines = CTFrameGetLines(_textFrame);
    CFIndex lineCount = CFArrayGetCount(lines);
    NSInteger numberOfLines = (_numberOfLines > 0 ? MIN(lineCount, _numberOfLines) : lineCount);
    
    M80AttributedLabelAttachment* firstCheckFrame = _attachments[0];
    ///有行数限定
    if(firstCheckFrame.displayLineCount == numberOfLines)
    {
        for (M80AttributedLabelAttachment* attachment in _attachments)
        {
            ///在显示的行数内
            if(attachment.displayLine < numberOfLines)
            {
                [self drawAttachments:attachment frame:attachment.displayFrame context:ctx];
            }
        }
        return;
    }
    ///显示全文
    if(numberOfLines == self.getLinesCount)
    {
        if(CGRectIsEmpty(firstCheckFrame.allFrame) == NO)
        {
            for (M80AttributedLabelAttachment* attachment in _attachments)
            {
                [self drawAttachments:attachment frame:attachment.allFrame context:ctx];
            }
            return;
        }
    }
    
    ///没缓存就去计算
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(_textFrame, CFRangeMake(0, 0), lineOrigins);
    for (CFIndex i = 0; i < numberOfLines; i++)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(runs);
        CGPoint lineOrigin = lineOrigins[i];
        CGFloat lineAscent;
        CGFloat lineDescent;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
        CGFloat lineHeight = lineAscent + lineDescent;
        CGFloat lineBottomY = lineOrigin.y - lineDescent;
        
        // Iterate through each of the "runs" (i.e. a chunk of text) and find the runs that
        // intersect with the range.
        for (CFIndex k = 0; k < runCount; k++)
        {
            CTRunRef run = CFArrayGetValueAtIndex(runs, k);
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (nil == delegate)
            {
                continue;
            }
            M80AttributedLabelAttachment* attributedImage = (M80AttributedLabelAttachment *)CTRunDelegateGetRefCon(delegate);
            if(attributedImage == nil || [attributedImage isKindOfClass:[M80AttributedLabelAttachment class]] == NO)
            {
                continue;
            }
            CGFloat ascent = 0.0f;
            CGFloat descent = 0.0f;
            CGFloat width = (CGFloat)CTRunGetTypographicBounds(run,
                                                               CFRangeMake(0, 0),
                                                               &ascent,
                                                               &descent,
                                                               NULL);
            
            CGFloat imageBoxHeight = [attributedImage boxSize].height;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
            
            CGFloat imageBoxOriginY = 0.0f;
            switch (attributedImage.alignment)
            {
                case M80ImageAlignmentTop:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight);
                    break;
                case M80ImageAlignmentCenter:
                    imageBoxOriginY = lineBottomY + (lineHeight - imageBoxHeight) / 2.0;
                    break;
                case M80ImageAlignmentBottom:
                    imageBoxOriginY = lineBottomY;
                    break;
            }
            
            CGRect rect = CGRectMake(lineOrigin.x + xOffset, imageBoxOriginY, width, imageBoxHeight);
            UIEdgeInsets flippedMargins = attributedImage.margin;
            CGFloat top = flippedMargins.top;
            flippedMargins.top = flippedMargins.bottom;
            flippedMargins.bottom = top;
            
            CGRect attatchmentRect = UIEdgeInsetsInsetRect(rect, flippedMargins);
            
            if (i == numberOfLines - 1 &&
                k >= runCount - 2 &&
                 _lineBreakMode == kCTLineBreakByTruncatingTail)
            {
                //最后行最后的2个CTRun需要做额外判断
                CGFloat attachmentWidth = CGRectGetWidth(attatchmentRect);
                const CGFloat kMinEllipsesWidth = attachmentWidth;
                if (CGRectGetWidth(self.bounds) - CGRectGetMinX(attatchmentRect) - attachmentWidth <  kMinEllipsesWidth)
                {
                    continue;
                }
            }
            
            [self drawAttachments:attributedImage frame:attatchmentRect context:ctx];
            
            if(numberOfLines == self.getLinesCount)
            {
                attributedImage.allFrame = attatchmentRect;
                attributedImage.allLine = i;
            }
            else
            {
                attributedImage.displayLineCount = numberOfLines;
                attributedImage.displayFrame = attatchmentRect;
                attributedImage.displayLine = i;
            }
        }
    }
}
-(void)drawAttachments:(M80AttributedLabelAttachment*)attributedImage frame:(CGRect)attatchmentRect context:(CGContextRef)ctx
{
    id content = attributedImage.content;
    if ([content isKindOfClass:[UIImage class]])
    {
        CGContextDrawImage(ctx, attatchmentRect, ((UIImage *)content).CGImage);
    }
    else if ([content isKindOfClass:[UIView class]])
    {
        UIView *view = (UIView *)content;
        if (view.superview == nil)
        {
            [self addSubview:view];
        }
        CGRect viewFrame = CGRectMake(attatchmentRect.origin.x,
                                      self.bounds.size.height - attatchmentRect.origin.y - attatchmentRect.size.height,
                                      attatchmentRect.size.width,
                                      attatchmentRect.size.height);
        [view setFrame:viewFrame];
    }
    else
    {
        NSLog(@"Attachment Content Not Supported %@",content);
    }
}


#pragma mark - 点击事件处理
#pragma mark - 链接处理
- (void)recomputeLinksIfNeeded
{
    const NSInteger kMinHttpLinkLength = 5;
    if (!_autoDetectLinks || _linkDetected)
    {
        return;
    }
    NSString *text = [[_attributedString string] copy];
    NSUInteger length = [text length];
    if (length <= kMinHttpLinkLength)
    {
        return;
    }
    BOOL sync = length <= M80MinAsyncDetectLinkLength;
    [self computeLink:text
                 sync:sync];
}

- (void)computeLink:(NSString *)text
               sync:(BOOL)sync
{
    __weak typeof(self) weakSelf = self;
    typedef void (^LinkBlock) (NSArray *);
    LinkBlock block = ^(NSArray *links)
    {
        weakSelf.linkDetected = YES;
        if ([links count])
        {
            for (M80AttributedLabelURL *link in links)
            {
                [weakSelf addAutoDetectedLink:link];
            }
            [weakSelf resetTextFrame];
        }
    };
    
    if (sync)
    {
        NSArray *links = [M80AttributedLabelURL detectLinks:text];
        block(links);
    }
    else
    {
        dispatch_sync(get_m80_attributed_label_parse_queue(), ^{
        
            NSArray *links = [M80AttributedLabelURL detectLinks:text];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *plainText = [[weakSelf attributedString] string];
                if ([plainText isEqualToString:text])
                {
                    block(links);
                }
            });
        });
    }
}

- (void)addAutoDetectedLink: (M80AttributedLabelURL *)link
{
    NSRange range = link.range;
    for (M80AttributedLabelURL *url in _linkLocations)
    {
        if (NSIntersectionRange(range, url.range).length != 0)
        {
            return;
        }
    }
    [self addCustomLink:link.linkData
               forRange:link.range];
}

#pragma mark - 点击事件相应
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    id value = [self urlForPoint:point];
    return (value !=nil );
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    hasLongPressed = NO;
    _isTouchPressedInside = YES;
    
    self.touchedLink = [self urlForPoint:point];
    if (self.touchedLink)
    {
          [self setNeedsDisplay];
    }
}
-(void)setNeedsDisplay
{
    if([NSThread isMainThread])
    {
        [super setNeedsDisplay];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(hasLongPressed)
    {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    M80AttributedLabelURL *touchedLink = [self urlForPoint:point];
    if (self.touchedLink != touchedLink)
    {
        self.touchedLink = touchedLink;
        [self setNeedsDisplay];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
     _isTouchPressedInside = NO;
    ///没触发长按手势 才 取消点击状态
    if(hasLongPressed)
    {
        return;
    }
    if (self.touchedLink)
    {
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isTouchPressedInside = NO;
    ///没触发长按手势 才 取消点击状态
    if(hasLongPressed)
    {
        return;
    }
    
    if (self.touchedLink)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(m80AttributedLabel:clickedOnLink:)])
        {
            [_delegate m80AttributedLabel:self clickedOnLink:self.touchedLink];
        }
        self.touchedLink = nil;
        [self setNeedsDisplay];
    }
}
-(void)resetLongPressedStatus
{
    hasLongPressed = NO;
    self.touchedLink = nil;
    [self setNeedsDisplay];
}

-(NSAttributedString *)getBuildAttributedString
{
    return _attributedString;
}
@end
