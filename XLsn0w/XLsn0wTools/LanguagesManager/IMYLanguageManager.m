//
// Created by Ivan on 15/4/8.
//
//


#import "IMYLanguageManager.h"


@implementation IMYLanguageManager

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    NSString *value = [super localizedStringForKey:key value:comment];
    return value ?: key;
}


@end