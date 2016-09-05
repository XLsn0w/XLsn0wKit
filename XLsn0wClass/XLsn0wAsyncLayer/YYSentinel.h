
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 YYSentinel is a thread safe incrementing counter. 
 It may be used in some multi-threaded situation.
 */
@interface YYSentinel : NSObject

/// Returns the current value of the counter.
@property (readonly) int32_t value;

/// Increase the value atomically.
/// @return The new value.
- (int32_t)increase;

@end

NS_ASSUME_NONNULL_END
