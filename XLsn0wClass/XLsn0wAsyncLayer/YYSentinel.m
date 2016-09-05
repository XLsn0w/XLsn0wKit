
#import "YYSentinel.h"
#import <libkern/OSAtomic.h>

@implementation YYSentinel {
    int32_t _value;
}

- (int32_t)value {
    return _value;
}

- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

@end
