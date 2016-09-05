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

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...);

@interface XLsn0wKitLog : NSObject

/*! XLsn0wKitLog 仅在调试模式 */
#ifdef DEBUG
#define XLsn0wKitLog(args ...) ExtendNSLog(__FILE__, __LINE__, __PRETTY_FUNCTION__, args);
#define XLsn0wKitLogString [SDLog logString]
#define XLsn0wKitLogClear [SDLog clearLog]
#else
#define XLsn0wKitLog(args ...)
#define XLsn0wKitLogString
#define XLsn0wKitLogClear
#endif

/**
*  清除日志字符串.
*/
+ (void)clearLog;

/**
 *  获取日志字符串.
 */
+ (NSString *)logString;

@end
