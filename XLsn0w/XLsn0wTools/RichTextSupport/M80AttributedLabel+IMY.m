//
//  M80AttributedLabel+IMY.m
//  IMY_RichText
//
//  Created by dm on 15/4/9.
//  Copyright (c) 2015年 Meetyou. All rights reserved.
//

#import "M80AttributedLabel+IMY.h"
#import "EmoticonManager.h"

@interface M80ALinkObject : NSObject
@property NSRange                       range;
@property(strong, nonatomic) NSString   *href;
@property(strong, nonatomic) UIColor    *color;
@end

@implementation M80ALinkObject
- (UIColor *)color
{
    if (_color == nil) {
        return [UIColor colorWithRed:255/255.0 green:80/255.0 blue:115/255.0 alpha:1];
    }
    
    return _color;
}

@end

@interface M80CacheModel : NSObject
@property(strong, nonatomic) NSAttributedString *showAttributedString;
@property(strong, nonatomic) NSArray            *attachments;
@property(strong, nonatomic) NSArray            *linkLocations;
@end

@implementation M80CacheModel
- (void)setLinkLocations:(NSArray *)linkLocations
{
    _linkLocations = [NSArray arrayWithArray:linkLocations];
}

- (void)setAttachments:(NSArray *)attachments
{
    _attachments = [NSArray arrayWithArray:attachments];
}

@end

static __strong NSCache *cache;
@implementation M80AttributedLabel (IMY)

+ (void)clearM80Cache
{
    [cache removeAllObjects];
}

+ (void)load
{
    cache = [[NSCache alloc] init];
}

- (BOOL)readCacheWithKey:(NSString *)cacheKey
{
    [self setText:nil];
    M80CacheModel *cacheModel = [cache objectForKey:cacheKey];
    
    if (cacheModel) {
        self.showAttributedString = cacheModel.showAttributedString;
        self.attachments = (id)cacheModel.attachments;
        self.linkLocations = (id)cacheModel.linkLocations;
        [self autoAdjustHeight];
        
        return YES;
    }
    
    return NO;
}

- (void)saveCacheToKey:(NSString *)cacheKey
{
    if (self.getBuildAttributedString.length > 0) {
        M80CacheModel *cacheModel = [[M80CacheModel alloc] init];
        cacheModel.showAttributedString = self.showAttributedString;
        cacheModel.attachments = self.attachments;
        cacheModel.linkLocations = self.linkLocations;
        
        [cache setObject:cacheModel forKey:cacheKey];
    } else {
        [cache removeObjectForKey:cacheKey];
    }
}

#pragma mark- 基础方法

- (void)setSYText:(NSString *)text
{
    [self setSYText:text parseType:SYTextParseTypeNormal];
}

- (void)setSYText:(NSString *)text parseType:(SYTextParseType)parseType
{
    [self setSYText:text parseType:parseType otherKey:@""];
}

- (void)setSYText:(NSString *)text parseType:(SYTextParseType)parseType otherKey:(NSString *)key
{
    BOOL        isBold = [self.font.fontName containsString:@"Medium"];
    int         fontKey = self.font.pointSize * 10 + isBold;
    NSString    *cacheKey = [NSString stringWithFormat:@"text_%ld_%ld_%d_%@", (unsigned long)text.hash, parseType, fontKey, key];
    
    if ([self readCacheWithKey:cacheKey] == NO) {
        [self appendSYText:text parseType:parseType];
        [self autoAdjustHeight];
        
        [self saveCacheToKey:cacheKey];
    }
    
    ///内部判断了 只有在主线程才会调用 setNeedDisplay
    [self setNeedsDisplay];
}

#pragma mark- 追加文本到末尾

- (void)appendSYText:(NSString *)text
{
    [self appendSYText:text parseType:SYTextParseTypeNormal];
}

- (void)appendSYText:(NSString *)text parseType:(SYTextParseType)parseType
{
    if (text.length == 0) {
        return;
    }
    
    NSMutableArray *aLinkRangeArray = nil;
    
    ///转义A标签
    if ([text containsString:@"</a>"]) {
        aLinkRangeArray = [NSMutableArray array];
        
        ///寻找表情格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a[^<^>]+>.+?</a>" options:0
                                                                                 error:nil];
        NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        
        if (matches.count > 0) {
            NSMutableString *sb = [NSMutableString stringWithString:text];
            int             offset = 0;
            
            for (NSTextCheckingResult *match in matches) {
                NSRange range = match.range;
                range.location += offset;
                NSString *atext = [sb substringWithRange:range];
                
                NSInteger   location = [atext rangeOfString:@">"].location + 1;
                NSInteger   length = (atext.length - location - 4);
                NSString    *showText = [atext substringWithRange:NSMakeRange(location, length)];
                
                [sb replaceCharactersInRange:range withString:showText];
                
                M80ALinkObject *link = [[M80ALinkObject alloc]init];
                link.range = NSMakeRange(range.location, length);
                link.href = @"";
                
                ///寻找href
                NSRegularExpression     *hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"href[\\s]*?=[\\s]*?['\"].+?['\"]" options:0 error:nil];
                NSTextCheckingResult    *hrefMatch = [hrefRegex firstMatchInString:atext options:0 range:NSMakeRange(0, atext.length)];
                
                if (hrefMatch.range.length > 0) {
                    NSRange hrefRange = hrefMatch.range;
                    hrefRange.length -= 1;
                    NSString    *ahref = [atext substringWithRange:hrefRange];
                    NSRange     hrefStartRange = [ahref rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""] options:NSBackwardsSearch];
                    
                    if (hrefStartRange.length > 0) {
                        ahref = [ahref substringFromIndex:hrefStartRange.location + 1];
                        link.href = ahref;
                    }
                }
                
                ///寻找color
                NSRegularExpression     *colorRegex = [NSRegularExpression regularExpressionWithPattern:@"color[\\s]*?=[\\s]*?['\"].+?['\"]" options:0 error:nil];
                NSTextCheckingResult    *colorMatch = [colorRegex firstMatchInString:atext options:0 range:NSMakeRange(0, atext.length)];
                
                if (colorMatch.range.length > 0) {
                    NSRange colorRange = colorMatch.range;
                    colorRange.length -= 1;
                    NSString    *acolor = [atext substringWithRange:colorRange];
                    NSRange     hrefStartRange = [acolor rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"'\""] options:NSBackwardsSearch];
                    
                    if (hrefStartRange.length > 0) {
                        ///目前只支持#ffffff格式的颜色
                        acolor = [acolor substringFromIndex:hrefStartRange.location + 1];
                        link.color = [M80AttributedLabel colorWithHexString:acolor];
                    }
                }
                
                ///保存起来
                [aLinkRangeArray addObject:link];
                
                ///位移
                offset -= (location + 4);
            }
            
            ///裁剪完的text
            text = [NSString stringWithString:sb];
        }
    }
    
    ///是否需要解析URL
    BOOL convertURL = NO;
    
    if (parseType & SYTextParseTypeForceURL) {
        convertURL = YES;
    } else if (parseType & SYTextParseTypeURL) {
        convertURL = YES;
    } else if (parseType & SYTextParseTypeIM) {
        convertURL = YES;
    }
    
    // 只有需要解析URL的时候  才会保存原有的长度
    NSInteger offset = 0;
    
    if (convertURL) {
        offset = self.getBuildAttributedString.string.length;
    }
    
    ///是否已转义表情了
    BOOL hasConvertedEmoji = NO;
    do {
        // 外部传值  不需要转换
        if ((parseType & SYTextParseTypeEmoji) == 0) {
            break;
        }
        
        NSString *repString = @"$LINGGAN$";
        ///寻找表情格式
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\]^\\[]+\\]" options:0
                                                                                 error:nil];
        NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        
        ///正则匹配没找到 表情格式
        if (matches.count == 0) {
            break;
        }
        
        NSArray *keys = [EmoticonManager sharedManager].emojiKeyArray;
        NSArray *values = [EmoticonManager sharedManager].emojiValueArray;
        
        NSMutableArray  *emojiArray = [[NSMutableArray alloc] init];
        NSMutableString *htmlString = [NSMutableString stringWithString:text];
        
        int emojiOffset = 0;
        
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            range.location += 1;
            range.length -= 2;
            NSString *subTxt = [text substringWithRange:range];
            
            NSUInteger index = [keys indexOfObject:subTxt];
            
            if (index != NSNotFound) {
                [htmlString replaceCharactersInRange:NSMakeRange(match.range.location + emojiOffset, match.range.length) withString:repString];
                emojiOffset += repString.length - match.range.length;
                NSString *src = values[index];
                [emojiArray addObject:src];
                
                for (M80ALinkObject *linkObject in aLinkRangeArray) {
                    if (linkObject.range.location > range.location) {
                        NSRange linkRange = linkObject.range;
                        linkRange.location -= (range.length + 1);
                        linkObject.range = linkRange;
                    }
                }
            }
        }
        
        ///跟本地表情key匹配数量为0
        if (emojiArray.count == 0) {
            break;
        }
        
        ///终于到了替换表情阶段啦
        NSArray     *components = [htmlString componentsSeparatedByString:repString];
        NSUInteger  count = [components count];
        
        for (NSUInteger i = 0; i < count; i++) {
            [self appendText:components[i]];
            
            if (emojiArray.count) {
                NSString *imageName = emojiArray[0];
                [self appendImage:[UIImage imageNamed:imageName]
                     maxSize     :CGSizeMake(30, 30)
                     margin      :UIEdgeInsetsZero
                     alignment   :M80ImageAlignmentCenter];
                [emojiArray removeObjectAtIndex:0];
            }
        }
        
        ///不需要在设值了
        hasConvertedEmoji = YES;
    } while (0);
    
    if (hasConvertedEmoji == NO) {
        [self appendText:text];
    }
    
    if (parseType & SYTextParseTypeEmoji) {
        ///添加a标签的点击效果  当 converURL 为NO时   A标签不能点击
        for (M80ALinkObject *linkObject in aLinkRangeArray) {
            [self addCustomLink:linkObject.href forRange:linkObject.range linkColor:linkObject.color];
        }
    }
    
    do {
        ///外部传值 不需要转义
        if (convertURL == NO) {
            break;
        }
        
        ///简单的正则匹配查看是否有 url格式
        NSString *allString = self.getBuildAttributedString.string;
        
        if ([self sy_containsLinkURL_ForceConvert:allString] == NO) {
            break;
        }
        
        ///url正则匹配
        NSString            *regularStr = @"([[Hh][Tt][Tt][Pp]|[Hh][Tt][Tt][Pp][Ss]:\\/\\/]*)(([0-9]{1,3}\\.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*\\'()-]+\\.)*([0-9a-zA-Z-]*)\\.(aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mn|mn|mo|mp|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|nom|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ra|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw|arpa))(\\/[0-9a-zA-Z\\.\\?\\@\\&\\=\\#\\%\\_\\:\\$]*)*";
        NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
        NSArray             *urlMatches = [urlRegex matchesInString:allString options:NSMatchingReportCompletion range:NSMakeRange(offset, allString.length - offset)];
        
        for (NSTextCheckingResult *urlMatch in urlMatches) {
            NSRange     range = urlMatch.range;
            NSString    *text = [allString substringWithRange:range];
            [self addCustomLink:text forRange:range];
        }
    } while (0);
}

#pragma mark- 其他方法

- (void)autoAdjustHeight
{
    [self showAttributedString];
    CGSize size = [self sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    if([NSThread isMainThread])
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size.height);
        });
    }
}

+ (BOOL)containsCacheText:(NSString *)text parseType:(SYTextParseType)parseType font:(UIFont *)font otherKey:(NSString *)key
{
    BOOL            isBold = [font.fontName containsString:@"Medium"];
    int             fontKey = font.pointSize * 10 + isBold;
    NSString        *cacheKey = [NSString stringWithFormat:@"text_%ld_%ld_%d_%@", (unsigned long)text.hash, parseType, fontKey, key];
    M80CacheModel   *cacheModel = [cache objectForKey:cacheKey];
    
    if (cacheModel) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark- 内部方法

//目前只支持#ffffff格式的颜色
+ (UIColor *)colorWithHexString:(NSString*)hexString
{
    if (![hexString isKindOfClass:[NSString class]])
    {
        return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    }
    //去掉头尾空白
    hexString = [hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(hexString.length == 0)
    {
        return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
    }
    
    ///支持传 r,g,b 这种格式
    NSArray* rgbArray = [hexString componentsSeparatedByString:@","];
    if(rgbArray.count >= 3)
    {
        NSString *rString = rgbArray[0];
        NSString *gString = rgbArray[1];
        NSString *bString = rgbArray[2];
        
        int r, g, b;
        BOOL br = [[NSScanner scannerWithString:rString] scanInt:&r];
        BOOL bg = [[NSScanner scannerWithString:gString] scanInt:&g];
        BOOL bb = [[NSScanner scannerWithString:bString] scanInt:&b];
        
        float a = 1;
        if(rgbArray.count >= 4)
        {
            NSString *aString = rgbArray[3];
            [[NSScanner scannerWithString:aString] scanFloat:&a];
            ///对 alpha 的转化出错
            if(a>1 || a<0)
            {
                a = 1;
            }
        }
        
        if(br && bg && bb)
        {
            return [UIColor colorWithRed:( r / 255.0f) green:( g / 255.0f) blue:( b / 255.0f) alpha:a];
        }
        else
        {
            return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
        }
    }
    else
    {
        const char *s = [hexString cStringUsingEncoding:NSASCIIStringEncoding];
        if (*s == '#')
        {
            ++s;
        }
        unsigned long long value = (unsigned long long int) strtoll(s, nil, 16);
        int r, g, b, a;
        switch (strlen(s))
        {
            case 2:
            {
                // xx
                r = g = b = (int) value;
                a = 255;
                break;
            }
            case 3:
            {
                // RGB
                r = (int) ((value & 0xf00) >> 8);
                g = (int) ((value & 0x0f0) >> 4);
                b = (int) ((value & 0x00f) >> 0);
                r = r * 16 + r;
                g = g * 16 + g;
                b = b * 16 + b;
                a = 255;
                break;
            }
            case 6:
            {
                // RRGGBB
                r = (int) ((value & 0xff0000) >> 16);
                g = (int) ((value & 0x00ff00) >> 8);
                b = (int) ((value & 0x0000ff) >> 0);
                a = 255;
                break;
            }
            default:
            {
                // RRGGBBAA
                r = (int) ((value & 0xff000000) >> 24);
                g = (int) ((value & 0x00ff0000) >> 16);
                b = (int) ((value & 0x0000ff00) >> 8);
                a = (int) ((value & 0x000000ff) >> 0);
                break;
            }
        }
        return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
    }
}

///有 url 格式 强制搜索
- (BOOL)sy_containsLinkURL_ForceConvert:(NSString *)aString
{
    NSString *afterTrimString = [aString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (afterTrimString.length == 0)
    {
        return NO;
    }
    
    ///改用自己的url匹配
    NSString *regularStr = @"\\.[a-zA-Z]{2,4}";
    NSRegularExpression *urlRegex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSTextCheckingResult* result = [urlRegex firstMatchInString:aString options:NSMatchingReportCompletion range:NSMakeRange(0, aString.length)];
    if(result.range.length > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
