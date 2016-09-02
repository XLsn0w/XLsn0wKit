//
//  SPHttp.m
//  SPHttp
//
//  Created by 换一换 on 16/3/7.
//  Copyright © 2016年 张洋. All rights reserved.
//

#import "SPHttp.h"
//#import "AFNetworking.h"
#import <AFNetworking.h>
#import "FMDB.h"



#define MCLog(...) NSLog(__VA_ARGS__)  //如果不需要打印数据, 注释nslog

/*!
 *  缓存的策略：(如果 cacheTime == 0，将永久缓存数据) 也就是缓存的时间 以 秒 为单位计算
 *  分钟 ： 60
 *  小时 ： 60 * 60
 *  一天 ： 60 * 60 * 24
 *  星期 ： 60 * 60 * 24 * 7
 *  一月 ： 60 * 60 * 24 * 30
 *  一年 ： 60 * 60 * 24 * 365
 *  永远 ： 0
 */

static NSInteger const cacheTime = 0;

// 缓存路径  缓存到Caches目录  统一做计算缓存大小，以及删除缓存操作
// NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
#define cachePath  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

// 请求方式
typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeGet,
    RequestTypePost,
    RequestTypeUpLoad
};



@implementation SPHttp

#pragma mark  -- Get请求 不缓存数据

+(void)getRequestUrlStr:(NSString *)urlStr success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [[self alloc] requestWithUrl:urlStr withDic:nil requestType:RequestTypeGet isCache:NO imageKey:nil withData:nil upLoadProgress:^(float progress) {
        
    } success:^(NSDictionary *requestDic, NSString *msg) {
        success(requestDic,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

#pragma mark -- Get请求  缓存数据
+(void)getRequestCacheUrlStr:(NSString *)urlStr success:(SuccessBlock)success failure:(FailureBlock)failure{
    [[self alloc] requestWithUrl:urlStr withDic:nil requestType:RequestTypeGet isCache:YES imageKey:nil withData:nil upLoadProgress:^(float progress) {
        
    } success:^(NSDictionary *requestDic, NSString *msg) {
        success(requestDic,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}


#pragma mark -- Post请求 不缓存
+(void)postRequestUrlStr:(NSString *)urlStr withDic:(NSDictionary *)parameters success:(SuccessBlock)success failure:(FailureBlock)failure{
    [[self alloc] requestWithUrl:urlStr withDic:parameters requestType:RequestTypePost isCache:NO imageKey:nil withData:nil upLoadProgress:^(float progress) {
        
    } success:^(NSDictionary *requestDic, NSString *msg) {
        success(requestDic,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

#pragma mark -- Post请求 缓存
+(void)postREquestCacheUrlStr:(NSString *)urlStr withDic:(NSDictionary *)parameters success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [[self alloc] requestWithUrl:urlStr withDic:parameters requestType:RequestTypePost isCache:YES imageKey:nil withData:nil upLoadProgress:^(float progress) {
        
    } success:^(NSDictionary *requestDic, NSString *msg) {
        success(requestDic,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

#pragma mark -- 上传单个文件
+(void)upLoadDataWithUrlStr:(NSString *)urlStr withDic:(NSDictionary *)parameters imageKey:(NSString *)attach withData:(NSData *)data upLoadProgress:(loadProgress)loadProgress success:(SuccessBlock)success failure:(FailureBlock)failure
{
    [[self alloc] requestWithUrl:urlStr withDic:parameters requestType:RequestTypeUpLoad  isCache:NO imageKey:attach withData:data upLoadProgress:^(float progress) {
        loadProgress(progress);
    } success:^(NSDictionary *requestDic, NSString *msg) {
        success(requestDic,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}
#pragma mark -- 网络请求统一处理
-(void)requestWithUrl:(NSString *)url withDic:(NSDictionary *)parameters requestType:(RequestType)requestType  isCache:(BOOL)isCache imageKey:(NSString *)attach withData:(NSData *)data upLoadProgress:(loadProgress)loadProgress success:(SuccessBlock)success failure:(FailureBlock)failure
{
    
    //处理中文和空格问题
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * cacheUrl = [self urlDictToStringWithUrlStr:url WithDict:parameters];
    
    MCLog(@"\n\n 网址 \n\n      %@    \n\n 网址 \n\n",cacheUrl);
    
   //判断数据库中是否有数据
    NSData *cacheData;
    
    if (isCache) {
        cacheData = [self cachedDataWithUrl:cacheUrl];
        if (cacheData.length != 0) {
            [self returnDataWithRequestData:cacheData Success:^(NSDictionary *requestDic, NSString *msg) {
                MCLog(@"缓存数据\n\n    %@    \n\n",requestDic);
                success(requestDic,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        }
    }
    
    //进行网络检查
    
    if (![self requestBeforeJudgeConnect]) {
        failure(@"没有网络");
        MCLog(@"\n\n----%@------\n\n",@"没有网络");
        return;
    }
    
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    session.requestSerializer.timeoutInterval =  10;
    
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //get请求
    if (requestType == RequestTypeGet) {
        [session GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"%@",downloadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self dealWithResponseObject:responseObject cacheUrl:cacheUrl cacheData:cacheData isCache:isCache success:^(NSDictionary *requestDic, NSString *msg) {
                success(responseObject,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(@"出现问题了");
        }];
       
    }
    
    //post请求
    if (requestType == RequestTypePost) {
       
        [session POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self dealWithResponseObject:responseObject cacheUrl:cacheUrl cacheData:cacheData isCache:isCache success:^(NSDictionary *requestDic, NSString *msg) {
                success(responseObject,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(@"出现问题了");
        }];
    }
    
    
    if (requestType == RequestTypeUpLoad) {
       [session POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
           NSTimeInterval timeInterVal = [[NSDate date] timeIntervalSince1970];
           NSString * fileName = [NSString stringWithFormat:@"%@.png",@(timeInterVal)];
           [formData appendPartWithFileData:data name:attach fileName:fileName mimeType:@"image/png"];
       } progress:^(NSProgress * _Nonnull uploadProgress) {
           
           
           loadProgress((float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
           
           
       } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
           
          [self dealWithResponseObject:responseObject cacheUrl:cacheUrl cacheData:cacheData isCache:isCache success:^(NSDictionary *requestDic, NSString *msg) {
              success(requestDic,msg);
          } failure:^(NSString *errorInfo) {
              failure(errorInfo);
          }];
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           failure(@"出现错误了");
           MCLog(@"上传文件发生错误\n\n    %@  \n\n",error);
       }];
        
        
        
      
    }
    
    
    
    
    
    
}




#pragma mark  统一处理请求到的数据
-(void)dealWithResponseObject:(NSData *)responseData cacheUrl:(NSString *)cacheUrl cacheData:(NSData *)cacheData isCache:(BOOL)isCache success:(SuccessBlock)success failure :(FailureBlock)failure
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    
    
    NSString * dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    dataString = [self deleteSpecialCodeWithStr:dataString];
    NSData *requestData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (isCache) {
        [self saveData:requestData url:cacheUrl];
    }
    if (!isCache || ![cacheData isEqual:requestData]) {
        [self returnDataWithRequestData:requestData Success:^(NSDictionary *requestDic, NSString *msg) {
            MCLog(@"网络数据\n\n   %@   \n\n",requestDic);
        } failure:^(NSString *errorInfo) {
            failure(errorInfo);
        }];
    }
    
    
}


/**
 *  拼接post请求的网址
 *
 *  @param urlStr     基础网址
 *  @param parameters 拼接参数
 *
 *  @return 拼接完成的网址
 */
-(NSString *)urlDictToStringWithUrlStr:(NSString *)urlStr WithDict:(NSDictionary *)parameters
{
    if (!parameters) {
        return urlStr;
    }
    
    
    NSMutableArray *parts = [NSMutableArray array];
    //enumerateKeysAndObjectsUsingBlock会遍历dictionary并把里面所有的key和value一组一组的展示给你，每组都会执行这个block 这其实就是传递一个block到另一个方法，在这个例子里它会带着特定参数被反复调用，直到找到一个ENOUGH的key，然后就会通过重新赋值那个BOOL *stop来停止运行，停止遍历同时停止调用block
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //接收key
        NSString *finalKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //接收值
        NSString *finalValue = [obj stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        
        NSString *part =[NSString stringWithFormat:@"%@=%@",finalKey,finalValue];
        
        [parts addObject:part];
        
    }];
    
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    
    queryString = queryString ? [NSString stringWithFormat:@"?%@",queryString] : @"";
    
    NSString *pathStr = [NSString stringWithFormat:@"%@?%@",urlStr,queryString];
    
    return pathStr;
    
    
    
}


#pragma mark --根据返回的数据进行统一的格式处理  ----requestData 网络或者是缓存的数据----
- (void)returnDataWithRequestData:(NSData *)requestData Success:(SuccessBlock)success failure:(FailureBlock)failure{
    id myResult = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableContainers error:nil];
    
    
   //判断是否为字典
    if ([myResult isKindOfClass:[NSDictionary  class]]) {
        NSDictionary *  requestDic = (NSDictionary *)myResult;
        
   //根据返回的接口内容来变
        NSString * succ = requestDic[@"status"];
        if ([succ isEqualToString:@"success"]) {
            success(requestDic[@"result"],requestDic[@"msg"]);
        }else{
            failure(requestDic[@"msg"]);
        }
        
    }
    
}



#pragma mark -- 数据库示例
static FMDatabase *_db;
+(void)initialize
{
    //获取版本号
    NSString * bundleName = [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey];
  
    NSString *dbName = [NSString stringWithFormat:@"%@%@",bundleName,@".sqlite"];
    NSString *filename = [cachePath stringByAppendingPathComponent:dbName];
    
    _db = [FMDatabase databaseWithPath:filename];
    
    if ([_db open]) {
        //判断是否存在
        BOOL res = [_db tableExists:@"SPData"];
        if (!res) {
          //创建表格
            BOOL result = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS SPData (id integer PRIMARY KEY AUTOINCREMENT,url text NOT NULL,data blob NOT NULL,savetime date);"];
            MCLog(@"\n\n---%@---\n\n",result?@"成功创表":@"创表失败");
            
            
        }
    }
    [_db close];
    
    
}




#pragma mark -- 通过请求参数去数据库中加载对应数据
-(NSData *)cachedDataWithUrl:(NSString *)url
{
    NSLog(@"通过参加载数据");
    NSData * data = [[NSData alloc] init];
    [_db open];
    FMResultSet *resultSet = nil;
    
    resultSet = [_db executeQuery:@"select * from SPData where url = ?",url];
    
    //便利查询结果
    while (resultSet.next) {
        NSDate * time = [resultSet dateForColumn:@"savetime"];
        NSTimeInterval timeInterVale = - [time timeIntervalSinceNow];
        if (timeInterVale > cacheTime && cacheTime != 0) {
            MCLog(@"\n\n   缓存的数据过期了   \n\n");
            
        }else
        {
            data = [resultSet objectForColumnName:@"data"];
        }
        
    }
    
    return data;
}

#pragma mark -- 缓存数据到数据库中
-(void)saveData:(NSData *)data url:(NSString *)url
{
    NSLog(@"缓存数据");
    [_db open];
    FMResultSet * rs = [_db executeQuery:@"select * from SPData  where url = ?",url];
    if ([rs next]) {
        BOOL res = [_db executeUpdate:@"update SPData set data = ?,savetime = ? where url = ?",data,[NSDate date],url];
        MCLog(@"\n\n%@    %@\n\n",url,res?@"数据更新成功":@"数据更新失败");
        
    }else
    {
        BOOL res = [_db executeUpdate:@"INSERT INTO SPData(url,data,savetime) VALUES (?,?,?);",url,data,[NSDate date]];
        MCLog(@"\n\n%@       %@\n\n",url,res?@"数据插入成功":@"数据插入失败");
    }
    
    [_db close];
}
#pragma mark ---   计算一共缓存的数据的大小
+ (NSString *)cacheSize{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *subpaths = [mgr subpathsAtPath:cachePath];
    long long ttotalSize = 0;
    for (NSString *subpath in subpaths) {
        NSString *fullpath = [cachePath stringByAppendingPathComponent:subpath];
        BOOL dir = NO;
        [mgr fileExistsAtPath:fullpath isDirectory:&dir];
        if (dir == NO) {// 文件
            ttotalSize += [[mgr attributesOfItemAtPath:fullpath error:nil][NSFileSize] longLongValue];
        }
    }//  M
    ttotalSize = ttotalSize/1024;
    return ttotalSize<1024?[NSString stringWithFormat:@"%lld KB",ttotalSize]:[NSString stringWithFormat:@"%.2lld MB",ttotalSize/1024];
}
/**
 *  获取文件大小
 */
+ (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}
#pragma mark ---   清空缓存的数据
+(void)deleateCahce
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:cachePath error:nil];
}
#pragma mark  网络判断
-(BOOL)requestBeforeJudgeConnect
{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable  =(isReachable && !needsConnection) ? YES : NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible =isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    });
    return isNetworkEnable;
}

#pragma mark -- 处理json格式的字符串中的换行符、回车符
- (NSString *)deleteSpecialCodeWithStr:(NSString *)str {
    NSString *string = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    return string;
}
@end
