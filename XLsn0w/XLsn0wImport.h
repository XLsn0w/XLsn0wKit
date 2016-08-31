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
#import <Foundation/Foundation.h>

#if __has_include(<XLsn0wKit/XLsn0wKit.h>)

FOUNDATION_EXPORT double YYKitVersionNumber;
FOUNDATION_EXPORT const unsigned char YYKitVersionString[];

#import <XLsn0wKitMacro.h>

#import <NSObject+YYAdd.h>
#import <NSObject+YYAddForKVO.h>
#import <NSObject+XLsn0wAddForARC.h>
#import <NSString+YYAdd.h>
#import <NSNumber+YYAdd.h>
#import <NSData+YYAdd.h>
#import <NSArray+YYAdd.h>
#import <NSDictionary+YYAdd.h>
#import <NSDate+YYAdd.h>
#import <NSNotificationCenter+YYAdd.h>
#import <NSKeyedUnarchiver+YYAdd.h>
#import <NSTimer+YYAdd.h>
#import <NSBundle+YYAdd.h>
#import <NSThread+XLsn0wAdd.h>

#import <UIColor+YYAdd.h>
#import <UIImage+YYAdd.h>
#import <UIControl+YYAdd.h>
#import <UIBarButtonItem+YYAdd.h>
#import <UIGestureRecognizer+YYAdd.h>
#import <UIView+YYAdd.h>
#import <UIScrollView+YYAdd.h>
#import <UITableView+YYAdd.h>
#import <UITextField+YYAdd.h>
#import <UIScreen+YYAdd.h>
#import <UIDevice+YYAdd.h>
#import <UIApplication+YYAdd.h>
#import <UIFont+YYAdd.h>
#import <UIBezierPath+YYAdd.h>

#import <CALayer+YYAdd.h>
#import <YYCGUtilities.h>

#import <NSObject+YYModel.h>
#import <YYClassInfo.h>

#import <XLsn0wCache.h>
#import <XLsn0wMemoryCache.h>
#import <XLsn0wDiskCache.h>
#import <YYKVStorage.h>

#import <YYImage.h>
#import <YYFrameImage.h>
#import <YYSpriteSheetImage.h>
#import <YYAnimatedImageView.h>
#import <YYImageCoder.h>
#import <YYImageCache.h>
#import <YYWebImageOperation.h>
#import <YYWebImageManager.h>
#import <UIImageView+YYWebImage.h>
#import <UIButton+YYWebImage.h>
#import <MKAnnotationView+YYWebImage.h>
#import <CALayer+YYWebImage.h>

#import <YYLabel.h>
#import <YYTextView.h>
#import <YYTextAttribute.h>
#import <YYTextArchiver.h>
#import <YYTextParser.h>
#import <YYTextUtilities.h>
#import <YYTextRunDelegate.h>
#import <YYTextRubyAnnotation.h>
#import <NSAttributedString+YYText.h>
#import <NSParagraphStyle+YYText.h>
#import <UIPasteboard+YYText.h>
#import <YYTextLayout.h>
#import <YYTextLine.h>
#import <YYTextInput.h>
#import <YYTextDebugOption.h>
#import <YYTextContainerView.h>
#import <YYTextSelectionView.h>
#import <YYTextMagnifier.h>
#import <YYTextEffectWindow.h>
#import <YYTextKeyboardManager.h>

#import <YYReachability.h>
#import <YYGestureRecognizer.h>
#import <YYFileHash.h>
#import <YYKeychain.h>
#import <YYWeakProxy.h>
#import <YYTimer.h>
#import <YYTransaction.h>
#import <YYAsyncLayer.h>
#import <YYSentinel.h>
#import <YYDispatchQueuePool.h>
#import <YYThreadSafeArray.h>
#import <YYThreadSafeDictionary.h>

#else

#import "YYKitMacro.h"
#import "NSObject+YYAdd.h"
#import "NSObject+YYAddForKVO.h"
#import "NSObject+YYAddForARC.h"
#import "NSString+YYAdd.h"
#import "NSNumber+YYAdd.h"
#import "NSData+YYAdd.h"
#import "NSArray+YYAdd.h"
#import "NSDictionary+YYAdd.h"
#import "NSDate+YYAdd.h"
#import "NSNotificationCenter+YYAdd.h"
#import "NSKeyedUnarchiver+YYAdd.h"
#import "NSTimer+YYAdd.h"
#import "NSBundle+YYAdd.h"
#import "NSThread+YYAdd.h"

#import "UIColor+YYAdd.h"
#import "UIImage+YYAdd.h"
#import "UIControl+YYAdd.h"
#import "UIBarButtonItem+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "UIView+YYAdd.h"
#import "UIScrollView+YYAdd.h"
#import "UITableView+YYAdd.h"
#import "UITextField+YYAdd.h"
#import "UIScreen+YYAdd.h"
#import "UIDevice+YYAdd.h"
#import "UIApplication+YYAdd.h"
#import "UIFont+YYAdd.h"
#import "UIBezierPath+YYAdd.h"

#import "CALayer+YYAdd.h"
#import "YYCGUtilities.h"

#import "NSObject+YYModel.h"
#import "YYClassInfo.h"

#import "YYCache.h"
#import "YYMemoryCache.h"
#import "YYDiskCache.h"
#import "YYKVStorage.h"

#import "YYImage.h"
#import "YYFrameImage.h"
#import "YYSpriteSheetImage.h"
#import "YYAnimatedImageView.h"
#import "YYImageCoder.h"
#import "YYImageCache.h"
#import "YYWebImageOperation.h"
#import "YYWebImageManager.h"
#import "UIImageView+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "MKAnnotationView+YYWebImage.h"
#import "CALayer+YYWebImage.h"

#import "YYLabel.h"
#import "YYTextView.h"
#import "YYTextAttribute.h"
#import "YYTextArchiver.h"
#import "YYTextParser.h"
#import "YYTextUtilities.h"
#import "YYTextRunDelegate.h"
#import "YYTextRubyAnnotation.h"
#import "NSAttributedString+YYText.h"
#import "NSParagraphStyle+YYText.h"
#import "UIPasteboard+YYText.h"
#import "YYTextLayout.h"
#import "YYTextLine.h"
#import "YYTextInput.h"
#import "YYTextDebugOption.h"
#import "YYTextContainerView.h"
#import "YYTextSelectionView.h"
#import "YYTextMagnifier.h"
#import "YYTextEffectWindow.h"
#import "YYTextKeyboardManager.h"

#import "YYReachability.h"
#import "YYGestureRecognizer.h"
#import "YYFileHash.h"
#import "YYKeychain.h"
#import "YYWeakProxy.h"
#import "YYTimer.h"
#import "YYTransaction.h"
#import "YYAsyncLayer.h"
#import "YYSentinel.h"
#import "YYDispatchQueuePool.h"
#import "YYThreadSafeArray.h"
#import "YYThreadSafeDictionary.h"

#endif
