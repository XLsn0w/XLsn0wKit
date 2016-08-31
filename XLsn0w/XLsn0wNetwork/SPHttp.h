//
//  SPHttp.h
//  SPHttp
//
//  Created by 换一换 on 16/3/7.
//  Copyright © 2016年 张洋. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSDictionary * requestDic, NSString * msg);
typedef void (^FailureBlock)(NSString *errorInfo);
typedef void (^loadProgress)(float progress);

@interface SPHttp : NSObject

/**
 *  Get请求 不对数据进行缓存
 *
 *  @param urlStr  url
 *  @param success 成功的回调
 *  @param failure 失败的回调
 */


+(void)getRequestUrlStr:(NSString *)urlStr success:(SuccessBlock)success failure:(FailureBlock)failure;


/**
 *  Get请求 对数据进行缓存
 *
 *  @param urlStr  url
 *  @param success 成功的回调
 *  @param failure 失败的回调
 */


+(void)getRequestCacheUrlStr:(NSString *)urlStr success:(SuccessBlock)success failure:(FailureBlock)failuer;



/**
 *  Post请求 不对数据进行缓存
 *
 *  @param urlStr     url
 *  @param parameters post参数
 *  @param success    成功的回调
 *  @param failure    失败的回调
 */
+(void)postRequestUrlStr:(NSString *)urlStr withDic:(NSDictionary *)parameters success:(SuccessBlock )success failure:(FailureBlock)failure;


/**
 *  Post请求 对数据进行缓存
 *
 *  @param urlStr     url
 *  @param parameters post参数
 *  @param success    成功的回调
 *  @param failure    失败的回调
 */

+(void)postREquestCacheUrlStr:(NSString *)urlStr withDic:(NSDictionary *)parameters success:(SuccessBlock )success failure:(FailureBlock)failure;

/**
 *  上传单个文件
 *
 *  @param urlStr       服务器地址
 *  @param parameters   参数
 *  @param attach       上传的key
 *  @param data         上传的问价
 *  @param loadProgress 上传的进度
 *  @param success      成功的回调
 *  @param failure      失败的回调
 */
+(void)upLoadDataWithUrlStr:(NSString *)urlStr withDic:(NSDictionary *)parameters imageKey:(NSString *)attach withData:(NSData *)data upLoadProgress:(loadProgress)loadProgress success:(SuccessBlock)success failure:(FailureBlock)failure;


#pragma mark --- 
#pragma mark --- 计算一共缓存的数据的大小
+(NSString *)cacheSize;


#pragma mark ---
#pragma mark --- 清空缓存的数据
+(void)deleateCahce;

/**
 *  获取文件大小
 *
 *  @param path 本地数据
 *
 *  @return 文件大小
 */
+(unsigned long long)fileSizeForPath:(NSString *)path;


@end
