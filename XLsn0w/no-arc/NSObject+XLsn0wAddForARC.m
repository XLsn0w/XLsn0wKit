
#import "NSObject+XLsn0wAddForARC.h"

@interface NSObject_AddForARC : NSObject

@end

@implementation NSObject_AddForARC

@end

#if __has_feature(objc_arc)
#error This file must be compiled without ARC. Specify the -fno-objc-arc flag to this file.
#endif

@implementation NSObject (XLsn0wAddForARC)

- (instancetype)arcDebugRetain {
    return [self retain];
}

- (oneway void)arcDebugRelease {
    [self release];
}

- (instancetype)arcDebugAutorelease {
    return [self autorelease];
}

- (NSUInteger)arcDebugRetainCount {
    return [self retainCount];
}

@end
