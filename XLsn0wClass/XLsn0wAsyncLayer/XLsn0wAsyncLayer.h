/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/
/**
 *  iOS 异步绘制与显示的工具类
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#if __has_include(<XLsn0wAsyncLayer/YYAsyncLayer.h>)
FOUNDATION_EXPORT double YYAsyncLayerVersionNumber;
FOUNDATION_EXPORT const unsigned char YYAsyncLayerVersionString[];
#import <XLsn0wAsyncLayer/YYSentinel.h>
#import <XLsn0wAsyncLayer/YYTransaction.h>
#else
#import "YYSentinel.h"
#import "YYTransaction.h"
#endif

@class YYAsyncLayerDisplayTask;

NS_ASSUME_NONNULL_BEGIN

/**
 The YYAsyncLayer class is a subclass of CALayer used for render contents asynchronously.
 
 @discussion When the layer need update it's contents, it will ask the delegate 
 for a async display task to render the contents in a background queue.
 */
@interface XLsn0wAsyncLayer : CALayer
/// Whether the render code is executed in background. Default is YES.

@property BOOL displaysAsynchronously;
@end


/**
 The YYAsyncLayer's delegate protocol. The delegate of the YYAsyncLayer (typically a UIView)
 must implements the method in this protocol.
 */
@protocol YYAsyncLayerDelegate <NSObject>
@required
/// This method is called to return a new display task when the layer's contents need update.
- (YYAsyncLayerDisplayTask *)newAsyncDisplayTask;
@end


/**
 A display task used by YYAsyncLayer to render the contents in background queue.
 */
@interface YYAsyncLayerDisplayTask : NSObject

/**
 This block will be called before the asynchronous drawing begins.
 It will be called on the main thread.
 
 @param layer  The layer.
 */
@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);

/**
 This block is called to draw the layer's contents.
 
 @discussion This block may be called on main thread or background thread,
 so is should be thread-safe.
 
 @param context      A new bitmap content created by layer.
 @param size         The content size (typically same as layer's bound size).
 @param isCancelled  If this block returns `YES`, the method should cancel the
 drawing process and return as quickly as possible.
 */
@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

/**
 This block will be called after the asynchronous drawing finished.
 It will be called on the main thread.
 
 @param layer  The layer.
 @param finished  If the draw process is cancelled, it's `NO`, otherwise it's `YES`;
 */
@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
