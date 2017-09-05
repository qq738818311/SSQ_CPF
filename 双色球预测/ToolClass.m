//
//  ToolClass.m
//  ToolClass
//
//  Created by CPF on 16/4/5.
//  Revision on 17/8/4.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "ToolClass.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import "SDImageCache.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "FMDB.h"

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#pragma mark - ToolClassTimer

@interface TCTimer ()

@property (nonatomic, copy) tcd_inProgressBlock tcd_inProgress;
@property (nonatomic, copy) tcd_completionBlock tcd_completion;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation TCTimer

- (dispatch_source_t)timer
{
    if (!_timer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    }
    return _timer;
}

- (instancetype)initWithTimeCountDownWithCount:(NSTimeInterval)count perTime:(NSTimeInterval)perTime inProgress:(tcd_inProgressBlock)inProgress completion:(tcd_completionBlock)completion
{
    if (self = [super init]) {
        self.tcd_inProgress = inProgress;
        self.tcd_completion = completion;
        //倒计时函数
        __block int timeout = count; //倒计时时间
        dispatch_source_set_timer(self.timer,dispatch_walltime(NULL, 0), (perTime ? : 1.0)*NSEC_PER_SEC, 0); //每1秒执行
        dispatch_source_set_event_handler(self.timer, ^{
            if(timeout <= 0){ //倒计时结束，关闭
                dispatch_source_cancel(self.timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //这里可以替换成自己需要的
                    if (self.tcd_completion) self.tcd_completion();
                    [ToolClass cancelTimeCountDownWith:self];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //这里可以替换成自己需要的
                    if (self.tcd_inProgress) self.tcd_inProgress(timeout);
                    timeout--;
                });
            }
        });
        dispatch_resume(self.timer);
    }
    return self;
}

@end

NSString *const NetIsConnectedNotification = @"NetIsConnectedNotification";    //网络改变通知
NSString *const NetConnectStatu = @"NetConnectStatu";                          //网络连接状态
NSString *const NetIsConnected = @"NetIsConnected";                            //是否连接网络

// 请求方式
typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeGet,
    RequestTypePost,
    RequestTypeUpLoad
};

@interface ToolClass() <UIAlertViewDelegate, UIActionSheetDelegate>
{
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLable;
 
}
/** 检测网络对象 */
@property (nonatomic) Reachability *reachability;

@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, copy) void (^alertViewClickedButtonAtIndexBlock)(NSUInteger buttonIndex);

/** 储存倒计时TCTimer对象的数组 */
@property (nonatomic, strong) NSMutableArray *timers;

@end

@implementation ToolClass
singleton_implementation(ToolClass)

- (instancetype)init
{
    if (self = [super init]) {
        //请求数据缓存超时时间，默认为永远不超时
        self.cacheTime = 0;
    }
    return self;
}

- (BOOL)isConnectedNet
{
    if (!self.reachability) {
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable) {
            _isConnectedNet = YES;
        }else{
            _isConnectedNet = NO;
        }
    }
    return _isConnectedNet;
}

- (AFHTTPSessionManager *)afManager
{
    if (!_afManager) {
        _afManager = [AFHTTPSessionManager manager];
        _afManager.requestSerializer.timeoutInterval = kRequestTimeoutInterval;
        _afManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain",@"text/html",@"text/xml", nil];
        //设置不自动解析数据
        _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        /*****************************************************************************
         * 设置请求头:
         * [TOOL.afManager.requestSerializer setValue:@"" forHTTPHeaderField:@""]   
         * 统一扩展请求体:                                                            
         * TOOL.extensionRequestBody = @{@"":@""};
         *****************************************************************************
         ************* 注意!!! : 在程序入口、登录后、退出后这三个地方均需设置 ****************
         *****************************************************************************/
    }
    return _afManager;
}

- (FMDatabase *)db
{
    if (!_db) {
        
        //生成存放在沙盒中的数据库完整路径
        NSString *filename = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        filename = [filename stringByAppendingPathComponent:@"NetWorkCache"];
        BOOL isDir;
        BOOL exit =[[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:&isDir];
        if (!exit || !isDir) {
            [[NSFileManager defaultManager] createDirectoryAtPath:filename withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *dbName = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey],@".db"];
        filename = [filename stringByAppendingPathComponent:dbName];
        
        _db = [FMDatabase databaseWithPath:filename];
        if ([_db open]) {
            //判断是否存在
            BOOL res = [_db tableExists:@"HTTPData"];
            if (!res) {
                //创建表格
                BOOL result = [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS HTTPData (id integer PRIMARY KEY AUTOINCREMENT,url text NOT NULL,data blob NOT NULL,savetime date);"];
                if (result) {
                    NSLog(@"创建网络请求缓存表成功");
                }else{
                    NSLog(@"创建网络请求缓存表失败");
                }
            }
        }
        [_db close];
    }
    return _db;
}

- (NSMutableArray *)timers
{
    if (!_timers) {
        _timers = [NSMutableArray array];
    }
    return _timers;
}

#pragma mark - 本地储存相关

+ (id)objectForKey:(NSString *)defaultName
{
    return [UserDefaults objectForKey:defaultName];
}

+ (void)setObject:(id)value forKey:(NSString *)defaultName
{
    [UserDefaults setObject:value forKey:defaultName];
    [UserDefaults synchronize];
}

+ (BOOL)boolForKey:(NSString *)defaultName
{
    return [UserDefaults boolForKey:defaultName];
}

+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
    [UserDefaults setBool:value forKey:defaultName];
    [UserDefaults synchronize];
}

+ (void)removeObjectForKey:(NSString *)defaultName
{
    [UserDefaults removeObjectForKey:defaultName];
    [UserDefaults synchronize];
}

+ (void)setData:(NSData *)data forKey:(NSString *)defaultName
{
    [UserDefaults setValue:data forKey:defaultName];
    [UserDefaults synchronize];
}

+ (NSData *)dataForKey:(NSString *)defaultName
{
    return [UserDefaults valueForKey:defaultName];
}

/** 获取AppDelegate单例 */
+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

/** 返回默认Token */
+ (NSString *)tokenMD5WithUserId:(NSString *)userId youLife:(NSString *)youlife deviceId:(NSString *)deviceId
{
    //ea8f538c-fece-c6a84842-8a0df724
    /*
     userId 用户Id 默认token传空 @""
     youlife 与后台协商定义的字符串 "HEALTHAPP"
     deviceId 设备信息 deviceId=[UIDevice currentDevice].identifierForVendor.UUIDString;
     */
    NSString * str1 = [[self getMd5_32Bit_String:userId isUppercase:NO] substringToIndex:8];
    NSString * str2 = [[self getMd5_32Bit_String:youlife isUppercase:NO] substringToIndex:4];
    NSString * str3 = [[self getMd5_32Bit_String:deviceId isUppercase:NO] substringToIndex:8];
    NSString * str4 = [[self getMd5_32Bit_String:[NSString stringWithFormat:@"%llu",(long long)[[NSDate date] timeIntervalSince1970]] isUppercase:NO] substringToIndex:8];
    return [NSString stringWithFormat:@"%@-%@-%@-%@",str1,str2,str3,str4];
    
}

//遍历文件夹获得缓存文件夹大小，返回多少M
+ (float)folderSizeAtPath:(NSString*) folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        if ([fileAbsolutePath containsString:@"AutoNaviMapKitCache"]) {
            continue;
        }
        //        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        if ([manager fileExistsAtPath:fileAbsolutePath]){
            folderSize += [[manager attributesOfItemAtPath:fileAbsolutePath error:nil] fileSize];
        }
    }
    return folderSize/(1024.0*1024);
}

//清除缓存
+ (void)clearCache:(NSString *)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            if ([absolutePath containsString:@"AutoNaviMapKitCache"]) {
                continue;
            }
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    TOOL.db = nil;
}

#pragma mark - 提示相关

/** 提示控件(默认显示时间为1.5秒，如果不传toView默认加到Window上) */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view
{
    [ToolClass showMBMessageTitle:text toView:view showTime:1.5];
}

/** 提示控件 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view showTime:(NSTimeInterval)second
{
    dispatch_async_get_main_queue_safe(^{
        [MBProgressHUD hideHUDForView:TOOL.hudView animated:YES];
        
        UIView *tempView = view ? : [ToolClass appDelegate].window;
        TOOL.hudView = tempView;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tempView animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"";
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = UIColorFromRGBWithAlpha(0x000000, 0.8);
        hud.detailsLabel.textColor = [UIColor whiteColor];
        hud.detailsLabel.text = [text isKindOfClass:NSClassFromString(@"NSString")] ? text : @"提示控件参数错误";
        hud.detailsLabel.font = [UIFont systemFontOfSize:14];
        hud.margin = 10;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:second];
    });
}

/** 提示控件带成功回调 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view completion:(void (^)())completionBlock
{
    [MBProgressHUD hideHUDForView:TOOL.hudView animated:YES];
    
    UIView *tempView = view ? : [ToolClass appDelegate].window;
    TOOL.hudView = tempView;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:tempView animated:YES];
    hud.detailsLabel.text = text ? : @"";
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = UIColorFromRGBWithAlpha(0x000000, 0.8);
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.font = [UIFont systemFontOfSize:14];
    hud.margin = 10;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        if (completionBlock) {
            completionBlock();
        }
    });
}

/** 显示MBHUD(默认延时1秒) */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view
{
    [ToolClass showMBConnectTitle:text toView:view afterDelay:1 isNeedUserInteraction:NO];
}

/** 延时显示MBHUD */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view afterDelay:(NSTimeInterval)delay isNeedUserInteraction:(BOOL)isNeed
{
    [MBProgressHUD hideHUDForView:TOOL.hudView animated:YES];
    
    UIView *tempView = view ? : [ToolClass appDelegate].window;
    TOOL.hudView = tempView;
    
    // 设置HUD的菊花为白色
    [UIActivityIndicatorView appearanceWhenContainedIn:[MBProgressHUD class], nil].color = [UIColor whiteColor];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:tempView];
    [tempView addSubview:hud];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.detailsLabel.text = @"";
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = UIColorFromRGBWithAlpha(0x000000, 0.8);
    hud.bezelView.layer.cornerRadius = 7;
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = text ? : @"";
    hud.margin = 13;
    hud.userInteractionEnabled = isNeed ? NO : YES;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud showAnimated:YES];
    });
}

/** 刷新MBHUD的文字 */
+ (void)reloadMBConnectTitle:(NSString *)text
{
    MBProgressHUD *processHud = [MBProgressHUD HUDForView:TOOL.hudView];
    dispatch_async_get_main_queue_safe(^{
        processHud.label.text = text;
    });
}

/** 结束MBHUD */
+ (void)hideMBConnect
{
    dispatch_async_get_main_queue_safe(^{
        [MBProgressHUD hideHUDForView:TOOL.hudView animated:YES];
    });
}

/** 结束MBHUD附带一句提示语 */
+ (void)hideMBConnectWithMessage:(NSString *)text
{
    dispatch_async_get_main_queue_safe(^{
        [MBProgressHUD hideHUDForView:TOOL.hudView animated:YES];
        if ([text isKindOfClass:[NSString class]]) {
            if (text.length > 0) {
                [self showMBMessageTitle:text toView:TOOL.hudView];
            }
        }
    });
}

/** 显示一个AlertController */
+ (void)showAlertControllerWithPreferredStyle:(UIAlertControllerStyle)preferredStyle title:(NSString *)title message:(NSString *)message handlerBlock:(void (^)(NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION
{
    if (CURRENTDEVICE_SYSTEMVERSION >= 8.0) {
        NSInteger index = -1;
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
//        UIView *subView1 = alertController.view.subviews[0];
//        UIView *subView2 = subView1.subviews[0];
//        UIView *subView3 = subView2.subviews[0];
//        UIView *subView4 = subView3.subviews[0];
//        UIView *subView5 = subView4.subviews[0];
////        取title和message：
//        UILabel *title = subView5.subviews[0];
//        UILabel *message = subView5.subviews[1];
////        然后设置message内容居左：
//        message.textAlignment = NSTextAlignmentLeft;
        if (cancelButtonTitle) {
            index++;
            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                if (block) {
                    block(index);
                }
            }];
            [alertController addAction:cancelAction];
        }
        if (otherButtonTitles != nil) {
            id eachObject;
            va_list argumentList;
            if (otherButtonTitles) {
                index++;
                UIAlertAction * sendAction = [UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    if (block) {
                        block(index);
                    }
                }];
                [alertController addAction:sendAction];
                va_start(argumentList, otherButtonTitles);
                while ((eachObject = va_arg(argumentList, id))) {
                    index++;
                    UIAlertAction * otherButtonAction = [UIAlertAction actionWithTitle:eachObject style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        if (block) {
                            block(index);
                        }
                    }];
                    [alertController addAction:otherButtonAction];
                }
                va_end(argumentList);
            }
        }
        //异步获得主线程让其先显示出来
        dispatch_async_get_main_queue_safe(^{
            [[ToolClass getCurrentVC] presentViewController:alertController animated:YES completion:nil];
        });
    }else{
        if (preferredStyle == UIAlertControllerStyleAlert) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:TOOL cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
            if (otherButtonTitles != nil) {
                id eachObject;
                va_list argumentList;
                if (otherButtonTitles) {
                    [alertView addButtonWithTitle:otherButtonTitles];
                    va_start(argumentList, otherButtonTitles);
                    while ((eachObject = va_arg(argumentList, id))) {
                        [alertView addButtonWithTitle:eachObject];
                    }
                    va_end(argumentList);
                }
            }
            //异步获得主线程让其先显示出来
            dispatch_async_get_main_queue_safe(^{
                [alertView show];
            });
            TOOL.alertViewClickedButtonAtIndexBlock = block;
        }else{
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:TOOL cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
            if (otherButtonTitles != nil) {
                id eachObject;
                va_list argumentList;
                if (otherButtonTitles) {
                    [actionSheet addButtonWithTitle:otherButtonTitles];
                    va_start(argumentList, otherButtonTitles);
                    while ((eachObject = va_arg(argumentList, id))) {
                        [actionSheet addButtonWithTitle:eachObject];
                    }
                    va_end(argumentList);
                }
            }
            //异步获得主线程让其先显示出来
            dispatch_async_get_main_queue_safe(^{
                [actionSheet showInView:[ToolClass appDelegate].window.rootViewController.view];
            });
            TOOL.alertViewClickedButtonAtIndexBlock = block;
        }
    }
}

#pragma mark - 网络相关

/** 异步检测网络连接(AFNetworking)，放到程序入口处 */
+ (void)asyncReachabilityNetConnectWithAF
{
    AFNetworkReachabilityManager * afReachability = [AFNetworkReachabilityManager sharedManager];
    [afReachability startMonitoring];  //开启网络监视器；
    [afReachability setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:       //无网络
            {
                TOOL.connectStatu = @"无网络";
                TOOL.isConnectedNet = NO;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:   //WiFi连接
            {
                TOOL.connectStatu = @"WiFi连接";
                TOOL.isConnectedNet = YES;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:   //移动数据连接
            {
                TOOL.connectStatu = @"移动数据连接";
                TOOL.isConnectedNet = YES;
            }
                break;
            case AFNetworkReachabilityStatusUnknown:            //未知连接
            {
                TOOL.connectStatu = @"未知连接";
                TOOL.isConnectedNet = YES;
            }
                break;
                
            default:
            {
                TOOL.connectStatu = @"无网络";
                TOOL.isConnectedNet = NO;
            }
                break;
        }
        [NotificationCenter postNotificationName:NetIsConnectedNotification object:@{NetConnectStatu : TOOL.connectStatu , NetIsConnected : [NSString stringWithFormat:@"%@",TOOL.isConnectedNet ? @"YES" : @"NO"]}];
    }];
}

/** 同步检测网络连接(Reachability)，放到程序入口处，苹果官方推荐检测网络 */
+ (void)syncReachabilityNetConnectWithHostName:(NSString *)hostName
{
    [NotificationCenter addObserver:TOOL selector:@selector(reachabilityChanged:) name:@"kNetworkReachabilityChangedNotification" object:nil];
    if (hostName.length > 0) {
        TOOL.reachability = [Reachability reachabilityWithHostName:hostName];
    }else{
        TOOL.reachability = [Reachability reachabilityForInternetConnection];
    }
    //开启检测网络
    [TOOL.reachability startNotifier];
    NetworkStatus status = [TOOL.reachability currentReachabilityStatus];
    if (status != NotReachable) {
        TOOL.isConnectedNet = YES;
    }else{
        TOOL.isConnectedNet = NO;
    }
}

/** 同步检测网络 */
- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = notification.object;
//    NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:        {
            self.connectStatu = @"无网络";
            self.isConnectedNet = NO;
            break;
        }
        case ReachableViaWWAN:        {
            self.connectStatu = @"移动数据连接";
            self.isConnectedNet = YES;
            break;
        }
        case ReachableViaWiFi:        {
            self.connectStatu = @"WiFi连接";
            self.isConnectedNet = YES;
            break;
        }
    }
    [NotificationCenter postNotificationName:NetIsConnectedNotification object:@{NetConnectStatu : self.connectStatu , NetIsConnected : [NSString stringWithFormat:@"%@",self.isConnectedNet ? @"YES" : @"NO"]}];
}

/** 将请求网址和请求体拼接起来作为缓存的key */
- (NSString *)cacheUrlStringWithUrlStr:(NSString *)urlStr parameters:(NSDictionary *)parameters
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
        NSString *finalValue = [[NSString stringWithFormat:@"%@",obj] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *part =[NSString stringWithFormat:@"%@=%@", finalKey, finalValue];
        [parts addObject:part];
    }];
    NSString *queryString = [parts componentsJoinedByString:@"&"];
    queryString = queryString.length > 0 ? queryString : @"";
    NSString *pathStr = [NSString stringWithFormat:@"%@?%@",urlStr,queryString];
    return pathStr;
}

/** 缓存数据 */
- (void)saveData:(NSData *)data url:(NSString *)url
{
    [self.db open];
    FMResultSet * rs = [self.db executeQuery:@"SELECT * FROM HTTPData  WHERE url = ?",url];
    if ([rs next]) {
        BOOL res = [self.db executeUpdate:@"UPDATE HTTPData SET data = ?,savetime = ? WHERE url = ?",data,[NSDate date],url];
        NSLog(@"[%@]%@", url, res ? @"数据更新成功" : @"数据更新失败");
    }else{
        BOOL res = [self.db executeUpdate:@"INSERT INTO HTTPData(url,data,savetime) VALUES (?,?,?);",url,data,[NSDate date]];
        NSLog(@"[%@]%@", url, res ? @"数据插入成功" : @"数据插入失败");
    }
    [self.db close];
}

/** 通过请求地址和参数加载缓存数据 */
- (NSData *)cachedDataWithCacheUrl:(NSString *)cacheUrl
{
    NSData * data = [[NSData alloc] init];
    [self.db open];
    FMResultSet *resultSet = nil;
    resultSet = [self.db executeQuery:@"SELECT * FROM HTTPData WHERE url = ?",cacheUrl];
    //遍历查询结果
    while (resultSet.next) {
        NSDate * time = [resultSet dateForColumn:@"savetime"];
        NSTimeInterval timeInterVale = - [time timeIntervalSinceNow];
        if (timeInterVale > self.cacheTime && self.cacheTime != 0) {
//            [self.db executeQuery:@"DELETE FROM HTTPData WHERE url = ?",cacheUrl];
            if ([self.db executeQuery:@"DELETE FROM HTTPData WHERE url = ?",cacheUrl]) {
                NSLog(@"删除过期缓存数据成功");
            }else{
                NSLog(@"删除过期缓存数据失败");
            }
//            NSLog(@"缓存的数据过期了");
        }else{
            data = [resultSet objectForColumnName:@"data"];
        }
    }
    return data;
}

/** 解析数据 */
- (id)objectWithJSONData:(NSData *)jsonData
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        return nil;
    }else{
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            return [NSDictionary dictionaryWithDictionary:jsonObject];
        }else if ([jsonObject isKindOfClass:[NSDictionary class]]){
            return [NSArray arrayWithArray:jsonObject];
        }else if (jsonData.length > 0){
            return [UIImage imageWithData:jsonData];
        }else{
            return nil;
        }
    }
}

/** 处理请求到的数据 */
- (void)dealResponseObject:(NSData *)responseData Url:(NSString *)url cacheData:(NSData *)cacheData isCache:(BOOL)isCache success:(successBlock)success
{
    dispatch_async_get_main_queue_safe(^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    
    NSString *dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    if (dataString.length > 0 && ![dataString isEqualToString:@" "]) {
        responseData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (isCache) {//缓存模式
        //保存数据
        [self saveData:responseData url:url];
    }
    
    if (success) {
        if (![responseData isEqual:cacheData]) {
            success([self objectWithJSONData:responseData], @"网络数据");
        }else{
            success([self objectWithJSONData:cacheData], @"缓存数据");
        }
    }
}

/** 统一处理网络请求 */
- (NSURLSessionDataTask *)requestWithURL:(NSString *)url parameters:(NSDictionary *)parameters requestType:(RequestType)requestType isCache:(BOOL)isCache fileData:(NSData *)data attachName:(NSString *)attach fileName:(NSString *)fileName mimeType:(NSString *)mimeType upLoadProgress:(loadProgressBlock)loadProgress success:(successBlock)success failure:(failureBlock)failure
{
    NSMutableDictionary *dict = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    //处理如果有统一扩展的请求Body
    if (self.extensionRequestBody) {
        [dict setValuesForKeysWithDictionary:self.extensionRequestBody];
    }
    NSString * cacheUrl = [self cacheUrlStringWithUrlStr:url parameters:dict];
    
    NSData *cacheData;
    id jsonObj;
    if (isCache) {//判断数据库中是否有数据
        cacheData = [self cachedDataWithCacheUrl:cacheUrl];
        jsonObj = [self objectWithJSONData:cacheData];
    }
    //进行网络检查
    if (self.isConnectedNet) {
        if (requestType == RequestTypeGet) {//GET请求
            self.afManager.requestSerializer.timeoutInterval = kRequestTimeoutInterval;
            return [self.afManager GET:url parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
//                NSLog(@"GET-downloadProgress == %@",downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"请求地址:[%@]\n参数:[%@]",url, dict);
                if ([responseObject isKindOfClass:NSClassFromString(@"_NSZeroData")]) {
                    if (cacheData.length > 0 && jsonObj) {//如果请求错误&&有缓存展示缓存
                        if (success) success(jsonObj,@"Error:GET请求返回数据错误");
                        if (failure) failure(@"GET请求返回数据错误-有缓存", nil);
                    }else{
                        if (failure) failure(@"GET请求返回数据错误-无缓存", nil);
                    }
                }else{
                    [self dealResponseObject:responseObject Url:cacheUrl cacheData:cacheData isCache:isCache success:^(id  _Nullable responseObject, NSString *msg) {
                        if (success) success(responseObject, [NSString stringWithFormat:@"GET请求-%@",msg]);
                    }];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Error:GET请求错误-%@", error);
                if (cacheData.length > 0 && jsonObj) {//如果请求错误&&有缓存展示缓存
                    if (success) success(jsonObj,@"Error:GET请求错误");
                    if (failure) failure(@"GET请求错误-有缓存", error);
                }else{
                    if (failure) failure(@"GET请求错误-无缓存", error);
                }
            }];
        } else if (requestType == RequestTypePost) {//POST请求
            self.afManager.requestSerializer.timeoutInterval = kRequestTimeoutInterval;
            return [self.afManager POST:url parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
//                NSLog(@"POST-uploadProgress == %@",uploadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"请求地址:[%@]\n参数:[%@]",url, dict);
                if ([responseObject isKindOfClass:NSClassFromString(@"_NSZeroData")]) {
                    if (cacheData.length > 0 && jsonObj) {//如果请求错误&&有缓存展示缓存
                        if (success) success(jsonObj,@"Error:POST请求返回数据错误");
                        if (failure) failure(@"POST请求返回数据错误-有缓存", nil);
                    }else{
                        if (failure) failure(@"POST请求返回数据错误-无缓存", nil);
                    }
                }else{
                    [self dealResponseObject:responseObject Url:cacheUrl cacheData:cacheData isCache:isCache success:^(id  _Nullable responseObject, NSString *msg) {
                        if (success) success(responseObject, [NSString stringWithFormat:@"POST请求-%@",msg]);
                    }];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Error:POST请求错误-%@", error);
                if (cacheData.length > 0 && jsonObj) {//如果请求错误&&有缓存展示缓存
                    if (success) success(jsonObj,@"Error:POST请求错误");
                    if (failure) failure(@"POST请求错误-有缓存", error);
                }else{
                    if (failure) failure(@"POST请求错误-无缓存", error);
                }
            }];
        } else if (requestType == RequestTypeUpLoad) {
            self.afManager.requestSerializer.timeoutInterval = 60;
            return [self.afManager POST:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:data name:attach fileName:fileName mimeType:mimeType];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                NSLog(@"上传文件-uploadProgress == %f",(float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
                loadProgress((float)uploadProgress.completedUnitCount/(float)uploadProgress.totalUnitCount);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"请求地址:[%@]\n参数:[%@]",url, dict);
                if ([responseObject isKindOfClass:NSClassFromString(@"_NSZeroData")]) {
                    if (cacheData.length > 0 && jsonObj) {//如果请求错误&&有缓存展示缓存
                        if (success) success(jsonObj,@"Error:上传文件返回数据错误");
                        if (failure) failure(@"上传文件返回数据错误-有缓存", nil);
                    }else{
                        if (failure) failure(@"上传文件返回数据错误-无缓存", nil);
                    }
                }else{
                    [self dealResponseObject:responseObject Url:cacheUrl cacheData:cacheData isCache:isCache success:^(id  _Nullable responseObject, NSString *msg) {
                        if (success) success(responseObject, [NSString stringWithFormat:@"上传文件-%@",msg]);
                    }];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Error:上传文件出现错误-%@", error);
                if (cacheData.length > 0 && jsonObj) {//如果请求错误&&有缓存展示缓存
                    if (success) success(jsonObj,@"Error:上传文件出现错误");
                    if (failure) failure(@"上传文件出现错误-有缓存", error);
                }else{
                    if (failure) failure(@"上传文件出现错误-无缓存", error);
                }
            }];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (cacheData.length > 0 && jsonObj) {//如果有网络，参数错误&&有缓存展示缓存
                    if (success) success(jsonObj,@"Error:参数错误");
                    if (failure) failure(@"参数错误-有缓存", nil);
                }else{
                    if (failure) failure(@"参数错误-无缓存", nil);
                }
            });
            return nil;
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (cacheData.length > 0 && jsonObj) {//如果无网络&&有缓存展示缓存
                if (success) success(jsonObj,@"Error:无网络");
                if (failure) failure(@"无网络-有缓存", nil);
            }else{
                if (failure) failure(@"无网络-无缓存", nil);
            }
        });
        return nil;
    }
}

/** GET请求 */
+ (NSURLSessionDataTask *)requestGETWithURL:(NSString *)url parameters:(NSDictionary *)parameters isCache:(BOOL)isCache success:(successBlock)success failure:(failureBlock)failure
{
    return [TOOL requestWithURL:url parameters:parameters requestType:RequestTypeGet isCache:isCache fileData:nil attachName:nil fileName:nil mimeType:nil upLoadProgress:nil success:^(id responseObject, NSString *msg) {
        if (success) {
            success(responseObject, msg);
        }
    } failure:^(NSString *errorInfo, NSError *error) {
        if (failure) {
            failure(errorInfo, error);
        }
    }];
}

/** POST请求 */
+ (NSURLSessionDataTask *)requestPOSTWithURL:(NSString *)url parameters:(NSDictionary *)parameters isCache:(BOOL)isCache success:(successBlock)success failure:(failureBlock)failure
{
    return [TOOL requestWithURL:url parameters:parameters requestType:RequestTypePost isCache:isCache fileData:nil attachName:nil fileName:nil mimeType:nil upLoadProgress:nil success:^(id responseObject, NSString *msg) {
        if (success) {
            NSLog(@"响应数据：\n%@", responseObject);
            success(responseObject, msg);
        }
    } failure:^(NSString *errorInfo, NSError *error) {
        if (failure) {
            failure(errorInfo, error);
        }
    }];
}

/** 上传单个文件 */
+ (NSURLSessionDataTask *)upLoadDataWithUrlStr:(NSString *)urlStr parameters:(NSDictionary *)parameters fileData:(NSData *)data attachName:(NSString *)attach fileName:(NSString *)fileName mimeType:(NSString *)mimeType upLoadProgress:(loadProgressBlock)loadProgress success:(successBlock)success failure:(failureBlock)failure
{
    return [TOOL requestWithURL:urlStr parameters:parameters requestType:RequestTypeUpLoad isCache:NO fileData:data attachName:attach fileName:fileName mimeType:mimeType upLoadProgress:^(float progress) {
        if (loadProgress) {
            loadProgress(progress);
        }
    } success:^(id responseObject, NSString *msg) {
        if (success) {
            success(responseObject, msg);
        }
    } failure:^(NSString *errorInfo, NSError *error) {
        if (failure) {
            failure(errorInfo, error);
        }
    }];
}

/** 获取网络缓存的大小(返回单位'M') */
+ (CGFloat)getNetWorkCacheSize
{
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"NetWorkCache"];
    return [ToolClass folderSizeAtPath:filename];
}

/** 清除网络缓存 */
+ (void)clearNetWorkCache
{
    NSString *filename = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"NetWorkCache"];
    [ToolClass clearCache:filename];
    TOOL.db = nil;
}

/** 获取本机IP地址（传入参数是否是IPV4） */
+ (NSString *)getIPAddress:(BOOL)isIPv4
{
    NSArray *searchArray = isIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop){
        address = addresses[key];
        if(address) *stop = YES;
    }];
    return address ? address : @"0.0.0.0";
}

/** 获取IP地址集 */
+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    //     The dictionary keys have the form "interface" "/" "ipv4 or ipv6"
    
    return [addresses count] ? addresses : nil;
}

#pragma mark - 时间相关

/** 时间格式化为字符串(format:yyyy-MM-dd HH:mm:ss) */
+ (NSString *)stringFromDateWithFormat:(NSString *)format date:(NSDate *)date
{
    NSDateFormatter * dateFormat =[[NSDateFormatter alloc] init];
    dateFormat.dateFormat = format;
    NSString *dateStr = [dateFormat stringFromDate:date];
    return dateStr;
}

/** 当前时间格式化为字符串(format:yyyy-MM-dd HH:mm:ss) */
+ (NSString *)stringFromNowDateFormat:(NSString *)format
{
    return [ToolClass stringFromDateWithFormat:format date:[NSDate date]];
}

/** 时间戳格式化为字符串(format:yyyy-MM-dd HH:mm:ss) */
+ (NSString *)stringFromTimeIntervalWithFormat:(NSString *)format timeInterval:(NSTimeInterval)timeInterval
{
    return [ToolClass stringFromDateWithFormat:format date:[ToolClass dateFromTimeInterval:timeInterval]];
}

/** 获取传入时间的时间戳 */
+ (NSTimeInterval)timeIntervalFromDate:(NSDate *)date
{
    return date.timeIntervalSince1970;
}

/** 获取当前时间的时间戳 */
+ (NSTimeInterval)timeIntervalFromNowDate
{
    return [ToolClass timeIntervalFromDate:[NSDate date]];
}

/** 获取传入时间毫秒级的时间戳 */
+ (long long)milliSecondTimeIntervalFromDate:(NSDate *)date
{
    long long result = [ToolClass timeIntervalFromDate:date]* (long long)1000;
    return result;
}

/** 获取当前时间毫秒级的时间戳 */
+ (long long)milliSecondTimeIntervalFromNowDate
{
    return [ToolClass milliSecondTimeIntervalFromDate:[NSDate date]];
}

/** 时间戳转时间对象 */
+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    return date;
}

/** 毫秒级的时间戳转时间对象 */
+ (NSDate *)dateFromMilliSecondTimeInterval:(long long)milliSecondTimeInterval
{
    return [ToolClass dateFromTimeInterval:milliSecondTimeInterval/1000];
}

/** 时间字符串转时间对象(format:yyyy-MM-dd HH:mm:ss) */
+ (NSDate *)dateFromDateString:(NSString *)dateString format:(NSString *)format
{
    return [ToolClass dateFromTimeInterval:[ToolClass timeIntervalFromDateString:dateString format:format]];
}

/** 时间字符串转时间戳(format:yyyy-MM-dd HH:mm:ss) */
+ (NSTimeInterval)timeIntervalFromDateString:(NSString *)dateStr format:(NSString *)format
{
    NSDateFormatter * dateFormat =[[NSDateFormatter alloc] init];
    dateFormat.dateFormat = format;
    NSDate *date = [dateFormat dateFromString:dateStr];
    return [ToolClass timeIntervalFromDate:date];
}

/** 根据时间对象获取星期几 */
+ (NSString *)getWeekDayFordate:(NSDate *)date
{
    NSArray *weekday = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    NSString *weekStr = [weekday objectAtIndex:components.weekday];
    return weekStr;
}

#pragma mark - UI相关

/** 隐藏TableView多余的线 */
+ (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView * view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

/** 获取当前屏幕显示的viewcontroller */
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    UIViewController *appRootVC = window.rootViewController;
    if (appRootVC.presentedViewController) {
        result = appRootVC.presentedViewController;
    }else{
        if (window.windowLevel != UIWindowLevelNormal) {
            NSArray *windows = [[UIApplication sharedApplication] windows];
            for(UIWindow * tmpWin in windows) {
                if (tmpWin.windowLevel == UIWindowLevelNormal) {
                    window = tmpWin;
                    break;
                }
            }
        }
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]){
            result = nextResponder;
        }else{
            result = window.rootViewController;
        }
    }
    return result;
}

#pragma mark - 其它

/** 注册IQKeyboard，在程序入口处调用 */
+ (void)registerIQKeyboard
{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    // enable控制整个功能是否启用。
    manager.enable = YES;
    // 控制点击背景是否收起键盘。
    manager.shouldResignOnTouchOutside = YES;
    // 控制键盘上的工具条文字颜色是否用户自定义。
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    // 控制是否显示键盘上的工具条。
    manager.enableAutoToolbar = NO;
}

/** 倒计时(Count:执行总次数 perTime:每几秒执行一次 inProgress:倒计时中回调(time:第几次) completion:完成回调) */
+ (TCTimer *)timeCountDownWithCount:(NSTimeInterval)count perTime:(NSTimeInterval)perTime inProgress:(tcd_inProgressBlock)inProgress completion:(tcd_completionBlock)completion
{
    TCTimer *timer = [[TCTimer alloc] initWithTimeCountDownWithCount:count perTime:perTime inProgress:inProgress completion:completion];
    [TOOL.timers addObject:timer];
    return timer;
}

/** 手动结束倒计时 */
+ (void)cancelTimeCountDownWith:(TCTimer *)tcTimer
{
    if ([TOOL.timers containsObject:tcTimer]) {
        if (tcTimer.timer) {
            dispatch_source_cancel(tcTimer.timer);
//            tcTimer.timer = nil;
            tcTimer.tcd_inProgress = nil;
            tcTimer.tcd_completion = nil;
            [TOOL.timers removeObject:tcTimer];
        }
    }
}

/** 图片转字符串 */
+ (NSString *)UIImageToBase64Str:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

/** 字符串转图片 */
+ (UIImage *)Base64StrToUIImage:(NSString *)encodedImageStr
{
//    NSData *decodedImageData = [[NSData alloc] initWithBase64Encoding:encodedImageStr];
    if (encodedImageStr.length > 0) {
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:encodedImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        return decodedImage;
    }else{
        return nil;
    }
}

/** 获取摄像头授权(未授权自动提示) */
+ (void)requestAccessCameraSuccess:(void(^)())success failure:(void(^)())failure
{
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined) {//第一次
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                dispatch_async_get_main_queue_safe(^{
                    if (success) {
                        success();
                    }
                });
            }else {
                dispatch_async_get_main_queue_safe(^{
                    if (failure) {
                        failure();
                    }
                });
            }
        }];
    }else{
        if(!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)){
            [ToolClass showAlertControllerWithPreferredStyle:UIAlertControllerStyleAlert title:@"未获得授权使用相机" message:[NSString stringWithFormat:@"请在\"设置中\"-\"%@\"-\"位置\"中打开",APP_NAME] handlerBlock:^(NSUInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"prefs:root=%@",BUNDLE_ID]]];
                }
            } cancelButtonTitle:@"设置" otherButtonTitles:@"好", nil];
            if (failure) {
                failure();
            }
        }else{
            if (success) {
                success();
            }
        }
    }
}

/** 32位MD5加密方式 */
+ (NSString *)getMd5_32Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase
{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [result appendFormat:@"%02x", digest[i]];
    }
    if (isUppercase) {
        return [result uppercaseString];
    }else{
        return result;
    }
}

//16位MD5加密方式
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase
{
    //提取32位MD5散列的中间16位
    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString isUppercase:NO];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8];//即9～25位
    
    if (isUppercase) {
        return   [result uppercaseString];
    }else{
        return result;
    }
}

#pragma mark - UIAlertViewDelegate, UIActionSheetDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertViewClickedButtonAtIndexBlock) {
        self.alertViewClickedButtonAtIndexBlock (buttonIndex);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alertViewClickedButtonAtIndexBlock) {
        self.alertViewClickedButtonAtIndexBlock (buttonIndex);
    }
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.frame = CGRectMake((WIDTH - 120) / 2, (HEIGHT - 90) / 2, 120, 90);
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
        
        _HUDLable = [[UILabel alloc] init];
        _HUDLable.frame = CGRectMake(0,40, 120, 50);
        _HUDLable.textAlignment = NSTextAlignmentCenter;
        _HUDLable.text = @"正在处理...";
        _HUDLable.font = [UIFont systemFontOfSize:15];
        _HUDLable.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLable];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    
    // if over time, dismiss HUD automatic
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideProgressHUD];
    });
}

- (void)hideProgressHUD {
    if (_progressHUD) {
        [_HUDIndicatorView stopAnimating];
        [_progressHUD removeFromSuperview];
    }
}

@end

/********************************* 以下为设置控制台输出中文代码 ***********************************/
#pragma mark - 以下为设置控制台输出中文代码

#if DEBUG

#if TARGET_OS_IPHONE
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-class.h>
#endif

#define SetNSErrorFor(FUNC, ERROR_VAR, FORMAT,...)	\
if (ERROR_VAR) {	\
NSString *errStr = [NSString stringWithFormat:@"%s: " FORMAT,FUNC,##__VA_ARGS__]; \
*ERROR_VAR = [NSError errorWithDomain:@"NSCocoaErrorDomain" \
code:-1	\
userInfo:[NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey]]; \
}
#define SetNSError(ERROR_VAR, FORMAT,...) SetNSErrorFor(__func__, ERROR_VAR, FORMAT, ##__VA_ARGS__)

#if OBJC_API_VERSION >= 2
#define GetClass(obj)	object_getClass(obj)
#else
#define GetClass(obj)	(obj ? obj->isa : Nil)
#endif

@implementation NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_ {
#if OBJC_API_VERSION >= 2
    Method origMethod = class_getInstanceMethod(self, origSel_);
    if (!origMethod) {
#if TARGET_OS_IPHONE
        SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self class]);
#else
        SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
#endif
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel_);
    if (!altMethod) {
#if TARGET_OS_IPHONE
        SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self class]);
#else
        SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
#endif
        return NO;
    }
    
    class_addMethod(self,
                    origSel_,
                    class_getMethodImplementation(self, origSel_),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel_,
                    class_getMethodImplementation(self, altSel_),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, origSel_), class_getInstanceMethod(self, altSel_));
    return YES;
#else
    //	Scan for non-inherited methods.
    Method directOriginalMethod = NULL, directAlternateMethod = NULL;
    
    void *iterator = NULL;
    struct objc_method_list *mlist = class_nextMethodList(self, &iterator);
    while (mlist) {
        int method_index = 0;
        for (; method_index < mlist->method_count; method_index++) {
            if (mlist->method_list[method_index].method_name == origSel_) {
                assert(!directOriginalMethod);
                directOriginalMethod = &mlist->method_list[method_index];
            }
            if (mlist->method_list[method_index].method_name == altSel_) {
                assert(!directAlternateMethod);
                directAlternateMethod = &mlist->method_list[method_index];
            }
        }
        mlist = class_nextMethodList(self, &iterator);
    }
    
    //	If either method is inherited, copy it up to the target class to make it non-inherited.
    if (!directOriginalMethod || !directAlternateMethod) {
        Method inheritedOriginalMethod = NULL, inheritedAlternateMethod = NULL;
        if (!directOriginalMethod) {
            inheritedOriginalMethod = class_getInstanceMethod(self, origSel_);
            if (!inheritedOriginalMethod) {
                SetNSError(error_, @"original method %@ not found for class %@", NSStringFromSelector(origSel_), [self className]);
                return NO;
            }
        }
        if (!directAlternateMethod) {
            inheritedAlternateMethod = class_getInstanceMethod(self, altSel_);
            if (!inheritedAlternateMethod) {
                SetNSError(error_, @"alternate method %@ not found for class %@", NSStringFromSelector(altSel_), [self className]);
                return NO;
            }
        }
        
        int hoisted_method_count = !directOriginalMethod && !directAlternateMethod ? 2 : 1;
        struct objc_method_list *hoisted_method_list = malloc(sizeof(struct objc_method_list) + (sizeof(struct objc_method)*(hoisted_method_count-1)));
        hoisted_method_list->obsolete = NULL;	// soothe valgrind - apparently ObjC runtime accesses this value and it shows as uninitialized in valgrind
        hoisted_method_list->method_count = hoisted_method_count;
        Method hoisted_method = hoisted_method_list->method_list;
        
        if (!directOriginalMethod) {
            bcopy(inheritedOriginalMethod, hoisted_method, sizeof(struct objc_method));
            directOriginalMethod = hoisted_method++;
        }
        if (!directAlternateMethod) {
            bcopy(inheritedAlternateMethod, hoisted_method, sizeof(struct objc_method));
            directAlternateMethod = hoisted_method;
        }
        class_addMethods(self, hoisted_method_list);
    }
    
    //	Swizzle.
    IMP temp = directOriginalMethod->method_imp;
    directOriginalMethod->method_imp = directAlternateMethod->method_imp;
    directAlternateMethod->method_imp = temp;
    
    return YES;
#endif
}

+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_ {
    return [GetClass((id)self) jr_swizzleMethod:origSel_ withMethod:altSel_ error:error_];
}

@end

@implementation NSDictionary (Unicode)

+ (void)load
{
    [super load];
    //控制台输出中文的方法
    [self jr_swizzleMethod:@selector(description) withMethod:@selector(my_description) error:nil];
}

- (NSString*)my_description {
    NSString *desc = [self my_description];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

@end

@implementation NSArray (Unicode)

- (NSString*)my_description {
    NSString *desc = [self my_description];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    
    return desc;
}

@end

@implementation NSDictionary (Log)
- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *string = [NSMutableString string];
    
    // 开头有个{
    [string appendString:self.allKeys.count ? @"{\n" : @"{"];
    
    // 遍历所有的键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [string appendFormat:@"\t\"%@\"", key];
        [string appendString:@": "];
        if ([obj isKindOfClass:[NSString class]]) {
            [string appendFormat:@"\"%@\",\n", obj];
        }else{
            [string appendFormat:@"%@,\n", obj];
        }
    }];
    
    // 结尾有个}
    [string appendString:@"}"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return [string stringByReplacingOccurrencesOfString:@"<null>" withString:@"null"];
}
@end

@implementation NSArray (Log)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *string = [NSMutableString string];
    
    // 开头有个[
    [string appendString:self.count ? @"[\n" : @"["];
    
    // 遍历所有的元素
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [string appendFormat:@"\t\"%@\",\n", obj];
        }else{
            [string appendFormat:@"\t%@,\n", obj];
        }
    }];
    
    // 结尾有个]
    [string appendString:@"]"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}

@end

#endif

/************************************ 以下为字符串类别代码 **************************************/

@implementation NSString (Contains)

#ifdef __IPHONE_7_0
- (BOOL)containsString:(NSString *)aString {
    //    if (IS_BLANK_STRING(aString)) {
    //        return NO;
    //    }
    if ([self rangeOfString:aString].location != NSNotFound) {
        return YES;
    }
    return NO;
}
#endif

@end

/*************************************** 以下为C代码 ******************************************/

/** 异步获得安全主线程 */
void dispatch_async_get_main_queue_safe(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/** 同步获得安全主线程 */
void dispatch_sync_get_main_queue_safe(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }else{
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/*********************************** 以下为UIImage类别代码 *************************************/

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

