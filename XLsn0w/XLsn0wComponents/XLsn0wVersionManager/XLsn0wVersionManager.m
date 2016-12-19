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

#import "XLsn0wVersionManager.h"

#import "AFNetworking.h"

@interface XLsn0wVersionManager ()

@end

@implementation XLsn0wVersionManager

// 一定要先配置自己项目在商店的APPID,配置完最好在真机上运行才能看到完全效果哦!
+ (void)xlsn0w_updateVersionWithAppStoreID:(NSString *)appStoreID showInCurrentController:(UIViewController *)currentController {
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@",infoDic);
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    
    //3从网络获取appStore版本号
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@", appStoreID]]] returningResponse:nil error:nil];
    if (response == nil) {
        NSLog(@"你没有连接网络哦");
        return;
    }
    NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"hsUpdateAppError:%@",error);
        return;
    }
    //    NSLog(@"%@",appInfoDic);
    NSArray *array = appInfoDic[@"results"];
    
    if (array.count < 1) {
        NSLog(@"此APPID为未上架的APP或者查询不到");
        return;
    }
    
    NSDictionary *dic = array[0];
    NSString *appStoreVersion = dic[@"version"];
    //打印版本号
    NSLog(@"当前版本号:%@\n商店版本号:%@",currentVersion,appStoreVersion);
    //设置版本号
    currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (currentVersion.length==2) {
        currentVersion  = [currentVersion stringByAppendingString:@"0"];
    }else if (currentVersion.length==1){
        currentVersion  = [currentVersion stringByAppendingString:@"00"];
    }
    appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    if (appStoreVersion.length==2) {
        appStoreVersion  = [appStoreVersion stringByAppendingString:@"0"];
    }else if (appStoreVersion.length==1){
        appStoreVersion  = [appStoreVersion stringByAppendingString:@"00"];
    }
    
    //4当前版本号小于商店版本号,就更新
    if([currentVersion floatValue] < [appStoreVersion floatValue]) {
        UIAlertController *alercConteoller = [UIAlertController alertControllerWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",dic[@"version"]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //此处加入应用在app store的地址，方便用户去更新，一种实现方式如下
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appStoreID]];
            [[UIApplication sharedApplication] openURL:url];
        }];
        UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alercConteoller addAction:actionYes];
        [alercConteoller addAction:actionNo];
        [currentController presentViewController:alercConteoller animated:YES completion:nil];
    } else {
        NSLog(@"版本号好像比商店大噢!检测到不需要更新");
    }
    
}

//比较版本的方法，在这里我用的是Version来比较的
- (BOOL)compareVersionsFormAppStore:(NSString*)AppStoreVersion WithAppVersion:(NSString*)AppVersion {
    
    BOOL littleSunResult = false;
    
    NSMutableArray* a = (NSMutableArray*) [AppStoreVersion componentsSeparatedByString: @"."];
    NSMutableArray* b = (NSMutableArray*) [AppVersion componentsSeparatedByString: @"."];
    
    while (a.count < b.count) { [a addObject: @"0"]; }
    while (b.count < a.count) { [b addObject: @"0"]; }
    
    for (int j = 0; j<a.count; j++) {
        if ([[a objectAtIndex:j] integerValue] > [[b objectAtIndex:j] integerValue]) {
            littleSunResult = true;
            break;
        }else if([[a objectAtIndex:j] integerValue] < [[b objectAtIndex:j] integerValue]){
            littleSunResult = false;
            break;
        }else{
            littleSunResult = false;
        }
    }
    return littleSunResult;//true就是有新版本，false就是没有新版本
    
}

#define APP_URL @"http://itunes.apple.com/cn/lookup?id=1093039842"
- (void)checkWithAppVersion:(NSString*)AppVersion showInCurrentController:(UIViewController *)currentController {
    //检测更新
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [mgr POST:APP_URL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
        /*responseObject是个字典{}，有两个key
         
         KEYresultCount = 1//表示搜到一个符合你要求的APP
         results =（）//这是个只有一个元素的数组，里面都是app信息，那一个元素就是一个字典。里面有各种key。其中有 trackName （名称）trackViewUrl = （下载地址）version （可显示的版本号）等等
         */
        
        //具体实现为
        NSArray *arr = [responseObject objectForKey:@"results"];
        NSDictionary *dic = [arr firstObject];
        NSString *versionStr = [dic objectForKey:@"version"];
        NSString *trackViewUrl = [dic objectForKey:@"trackViewUrl"];
        NSString *releaseNotes = [dic objectForKey:@"releaseNotes"];//更新日志
        
        
        //NSString* buile = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString*) kCFBundleVersionKey];build号
        NSString* thisVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        
        if ([self compareVersionsFormAppStore:versionStr WithAppVersion:thisVersion]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"发现新版本:%@",versionStr] message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction  = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了取消");
            }];
            
            UIAlertAction *OKAction  = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击了知道了");
                NSURL * url = [NSURL URLWithString:trackViewUrl];//itunesURL = trackViewUrl的内容
                [[UIApplication sharedApplication] openURL:url];
            }];
            [alertVC addAction:cancelAction];
            [alertVC addAction:OKAction];
            [currentController presentViewController:alertVC animated:YES completion:nil];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"");
        
    }];
}


/*
 * 需要加上/cn
 * itunes.apple.com/cn/lookup?id=你的appid
 */
/**
 *  版本更新
 *
 *  @param appid              该app的id (在itunes connect中获取)
 *  @param isShowReleaseNotes 是否显示版本注释
 *  @param controller         要显示的controller
 */
+ (void)updateVersionForAppID:(NSString *)appid
          isShowReleaseNotes:(BOOL)isShowReleaseNotes
              showController:(UIViewController *)controller {
    // 获取网络状态
    NSString *status = [self getNetWorkStatus];
    NSLog(@"%@", status);
    
    // 只有当网络为WiFi 和 4G 的情况下 提醒更新
    if ([status isEqualToString:@"WIFI"] || [status isEqualToString:@"4G"]) {
        
        [self getVersionForAppID:appid isShowReleaseNotes:isShowReleaseNotes showController:controller];
    }
}

#pragma mark - 获取版本信息
+ (void)getVersionForAppID:(NSString *)appid
       isShowReleaseNotes:(BOOL)isShowReleaseNotes
           showController:(UIViewController *)controller {
    
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@", appid];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableArray *arr = [responseObject objectForKey:@"results"];
        NSDictionary   *dic = arr[0];
        
        // 获取 appstore 信息
        NSString *newVersion   = [dic objectForKey:@"version"];      // 版本号
        NSString *newURL       = [dic objectForKey:@"trackViewUrl"]; // 程序地址
        NSString *releaseNotes = [dic objectForKey:@"releaseNotes"]; // 版本注释
        
        // 本地版本号
        NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        // 版本号比较
        if (![newVersion isEqualToString:localVersion]) {// 有版本更新
            
            NSString *message = nil;
            
            if (isShowReleaseNotes == YES) {
                message = releaseNotes;
            }else{
                message = @"赶快更新吧，第一时间体验新功能！";
            }
            
            UIAlertController *alertV = [UIAlertController alertControllerWithTitle:@"有新版本了！" message:message preferredStyle:(UIAlertControllerStyleAlert)];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 跳转到url
                if (newURL != nil) {
                    NSURL *url=[NSURL URLWithString:newURL];
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            //修改按钮颜色
            [cancelAction setValue:[UIColor brownColor] forKey:@"titleTextColor"];
            
            [alertV addAction:cancelAction];
            [alertV addAction:okAction];
            [controller presentViewController:alertV animated:YES completion:nil];
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - 获取当前网络状态
+(NSString *)getNetWorkStatus{
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    
    NSString *status = [[NSString alloc] init];
    
    int netType = 0;
    //获取到网络返回码
    for (id child in children) {
        
        if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            
            //获取到状态栏
            netType = [[child valueForKeyPath:@"dataNetworkType"]intValue];
            
            switch (netType) {
                case 0:
                    status = @"无网络";
                    break;
                    
                case 1:
                    status = @"2G";
                    break;
                    
                case 2:
                    status = @"3G";
                    break;
                    
                case 3:
                    status = @"4G";
                    break;
                    
                case 5:
                {
                    status = @"WIFI";
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    //根据状态选择
    return status;
}

@end
