
#import <Foundation/Foundation.h>

/**
 Debug mode method for NSObject when using ARC.
 */
@interface NSObject (XLsn0wAddForARC)

/// Same as `retain`
- (instancetype)arcDebugRetain;

/// Same as `release`
- (oneway void)arcDebugRelease;

/// Same as `autorelease`
- (instancetype)arcDebugAutorelease;

/// Same as `retainCount`
- (NSUInteger)arcDebugRetainCount;

@end
