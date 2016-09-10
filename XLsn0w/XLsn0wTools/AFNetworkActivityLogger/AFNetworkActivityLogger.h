/*
 Add the following code to AppDelegate.m -application:didFinishLaunchingWithOptions::
 
 [[AFNetworkActivityLogger sharedLogger] startLogging];
 
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AFHTTPRequestLoggerLevel) {
  AFLoggerLevelOff,
  AFLoggerLevelDebug,
  AFLoggerLevelInfo,
  AFLoggerLevelWarn,
  AFLoggerLevelError,
  AFLoggerLevelFatal = AFLoggerLevelOff,
};

/**
 `AFNetworkActivityLogger` logs requests and responses made by AFNetworking, with an adjustable level of detail.
 
 Applications should enable the shared instance of `AFNetworkActivityLogger` in `AppDelegate -application:didFinishLaunchingWithOptions:`:

        [[AFNetworkActivityLogger sharedLogger] startLogging];
 
 `AFNetworkActivityLogger` listens for `AFNetworkingOperationDidStartNotification` and `AFNetworkingOperationDidFinishNotification` notifications, which are posted by AFNetworking as request operations are started and finish. For further customization of logging output, users are encouraged to implement desired functionality by listening for these notifications.
 */
@interface AFNetworkActivityLogger : NSObject

/**
 The level of logging detail. See "Logging Levels" for possible values. `AFLoggerLevelInfo` by default.
 */
@property (nonatomic, assign) AFHTTPRequestLoggerLevel level;

/**
 Omit requests which match the specified predicate, if provided. `nil` by default.
 
 @discussion Each notification has an associated `NSURLRequest`. To filter out request and response logging, such as all network activity made to a particular domain, this predicate can be set to match against the appropriate URL string pattern.
 */
@property (nonatomic, strong) NSPredicate *filterPredicate;

/**
 Returns the shared logger instance.
 */
+ (instancetype)sharedLogger;

/**
 Start logging requests and responses.
 */
- (void)startLogging;

/**
 Stop logging requests and responses.
 */
- (void)stopLogging;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Logging Levels

 The following constants specify the available logging levels for `AFNetworkActivityLogger`:

 enum {
 AFLoggerLevelOff,
 AFLoggerLevelDebug,
 AFLoggerLevelInfo,
 AFLoggerLevelWarn,
 AFLoggerLevelError,
 AFLoggerLevelFatal = AFLoggerLevelOff,
 }

 `AFLoggerLevelOff`
 Do not log requests or responses.

 `AFLoggerLevelDebug`
 Logs HTTP method, URL, header fields, & request body for requests, and status code, URL, header fields, response string, & elapsed time for responses.
 
 `AFLoggerLevelInfo`
 Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses.

 `AFLoggerLevelWarn`
 Logs HTTP method & URL for requests, and status code, URL, & elapsed time for responses, but only for failed requests.
 
 `AFLoggerLevelError`
 Equivalent to `AFLoggerLevelWarn`

 `AFLoggerLevelFatal`
 Equivalent to `AFLoggerLevelOff`
*/
