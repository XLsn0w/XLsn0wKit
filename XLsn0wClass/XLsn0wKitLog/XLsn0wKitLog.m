
#import "XLsn0wKitLog.h"

static NSString *logString = @"";

@implementation XLsn0wKitLog

void ExtendNSLog(const char *file, int lineNumber, const char *functionName, NSString *format, ...) {
    va_list ap;
    
    va_start (ap, format);
    
    if (![format hasSuffix: @"\n"])
    {
        format = [format stringByAppendingString: @"\n"];
    }
    
    NSString *body = [[NSString alloc] initWithFormat:format
                                            arguments:ap];
    
    va_end (ap);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    fprintf(stderr, "(🎈%s🎈) (📍%s:%d📍) 📚%s📚", functionName, [fileName UTF8String], lineNumber, [body UTF8String]);
    
    if([logString isEqualToString:@""])
        logString = body;
    else
        logString = [NSString stringWithFormat:@"%@%@", logString, body];
}

+ (NSString *)logString {
    return logString;
}

+ (void)clearLog {
    logString = @"";
}

@end
