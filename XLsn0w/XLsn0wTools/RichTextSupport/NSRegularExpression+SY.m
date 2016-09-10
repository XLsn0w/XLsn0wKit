//
// Created by Ivan on 14-9-9.
//
//


#import <MacTypes.h>
#import "NSRegularExpression+SY.h"


static NSString *urlExpressionString = @"([[Hh][Tt][Tt][Pp]|[Hh][Tt][Tt][Pp][Ss]:\\/\\/]*)(([0-9]{1,3}\\.){3}[0-9]{1,3}|([0-9a-zA-Z_!~*\\'()-]+\\.)*([0-9a-zA-Z-]*)\\.(aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mn|mn|mo|mp|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|nom|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ra|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw|arpa))(\\/[0-9a-zA-Z\\.\\?\\@\\&\\=\\#\\%\\_\\:\\$]*)*";

@implementation NSRegularExpression (SY)
+ (NSRegularExpression *)URLExpression
{
    static NSRegularExpression *urlExpression;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlExpression = [NSRegularExpression regularExpressionWithPattern:urlExpressionString options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return urlExpression;
}

+ (NSRegularExpression *)keywordExpression
{
    static dispatch_once_t onceToken;
    static NSRegularExpression *regularExpression = nil;
    dispatch_once(&onceToken, ^{
        regularExpression = [NSRegularExpression regularExpressionWithPattern:@"(?<=<em>)[\\w\\W]*?(?=</em>)" options:0 error:nil];
    });
    return regularExpression;
}

@end