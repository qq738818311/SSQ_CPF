//
//  ToolClass.h
//  ToolClass
//
//  Created by CPF on 16/4/5.
//  Copyright © 2016年 CPF. All rights reserved.
//

//创建单例的宏定义
#define singleton_interface(className) \
+ (className *)shared##className;

// @implementation
#define singleton_implementation(className) \
static className *_instance; \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
} \
+ (className *)shared##className \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [[self alloc] init]; \
}); \
return _instance; \
}

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
//RGB Color macro
#define UIColorFromRGB(rgbValue) UIColorFromRGBWithAlpha(rgbValue,1.0)
//RGB
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define DEBUGCOLOR(color) [UIColor color]

#define CELLIDENTIFIER(ClassName) NSStringFromClass([ClassName class])

/** 屏幕的宽度 */
#define WIDTH  [UIScreen mainScreen].bounds.size.width
/** 屏幕的高度 */
#define HEIGHT [UIScreen mainScreen].bounds.size.height

/** UserDefaults */
#define UserDefaults          [NSUserDefaults standardUserDefaults]
/** 通知中心 */
#define NotificationCenter    [NSNotificationCenter defaultCenter]

/** 设备信息 */
#define DEVICE_ID [UIDevice currentDevice].identifierForVendor.UUIDString
/** 版本信息 */
#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
/** App名字 */
#define APP_NAME [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] ? : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
/** BundleIdentifier */
#define BUNDLE_ID [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
/** 当前系统的版本 */
#define CURRENTDEVICE_SYSTEMVERSION [UIDevice currentDevice].systemVersion.floatValue

/** 工具类的实例 */
#define TOOL [ToolClass sharedToolClass]

#define kRequestTimeoutInterval 10                           //请求超时时间

#import <Foundation/Foundation.h>
#import <Availability.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "AFNetworking.h"

/************************************** 日历适配相关 *****************************************/

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#define NSGregorianCalendar         NSCalendarIdentifierGregorian
#define NSBuddhistCalendar          NSCalendarIdentifierBuddhist
#define NSChineseCalendar           NSCalendarIdentifierChinese
#define NSHebrewCalendar            NSCalendarIdentifierHebrew
#define NSIslamicCalendar           NSCalendarIdentifierIslamic
#define NSIslamicCivilCalendar      NSCalendarIdentifierIslamicCivil
#define NSJapaneseCalendar          NSCalendarIdentifierJapanese
#define NSRepublicOfChinaCalendar   NSCalendarIdentifierRepublicOfChina
#define NSPersianCalendar           NSCalendarIdentifierPersian
#define NSIndianCalendar            NSCalendarIdentifierIndian
#define NSISO8601Calendar           NSCalendarIdentifierISO8601
#else
#define NSGregorianCalendar         NSGregorianCalendar
#define NSBuddhistCalendar          NSBuddhistCalendar
#define NSChineseCalendar           NSChineseCalendar
#define NSHebrewCalendar            NSHebrewCalendar
#define NSIslamicCalendar           NSIslamicCalendar
#define NSIslamicCivilCalendar      NSIslamicCivilCalendar
#define NSJapaneseCalendar          NSJapaneseCalendar
#define NSRepublicOfChinaCalendar   NSRepublicOfChinaCalendar
#define NSPersianCalendar           NSPersianCalendar
#define NSIndianCalendar            NSIndianCalendar
#define NSISO8601Calendar           NSISO8601Calendar
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
#define NSEraCalendarUnit                   NSCalendarUnitEra
#define NSYearCalendarUnit                  NSCalendarUnitYear
#define NSMonthCalendarUnit                 NSCalendarUnitMonth
#define NSDayCalendarUnit                   NSCalendarUnitDay
#define NSHourCalendarUnit                  NSCalendarUnitHour
#define NSMinuteCalendarUnit                NSCalendarUnitMinute
#define NSSecondCalendarUnit                NSCalendarUnitSecond
#define NSWeekCalendarUnit                  kCFCalendarUnitWeek
#define NSWeekdayCalendarUnit               NSCalendarUnitWeekday
#define NSWeekdayOrdinalCalendarUnit        NSCalendarUnitWeekdayOrdinal
#define NSQuarterCalendarUnit               NSCalendarUnitQuarter
#define NSWeekOfMonthCalendarUnit           NSCalendarUnitWeekOfMonth
#define NSWeekOfYearCalendarUnit            NSCalendarUnitWeekOfYear
#define NSYearForWeekOfYearCalendarUnit     NSCalendarUnitYearForWeekOfYear
#define NSCalendarCalendarUnit              NSCalendarUnitCalendar
#define NSTimeZoneCalendarUnit              NSCalendarUnitTimeZone
#else
#define NSEraCalendarUnit                   NSEraCalendarUnit
#define NSYearCalendarUnit                  NSYearCalendarUnit
#define NSMonthCalendarUnit                 NSMonthCalendarUnit
#define NSDayCalendarUnit                   NSDayCalendarUnit
#define NSHourCalendarUnit                  NSHourCalendarUnit
#define NSMinuteCalendarUnit                NSMinuteCalendarUnit
#define NSSecondCalendarUnit                NSSecondCalendarUnit
#define NSWeekCalendarUnit                  NSWeekCalendarUnit
#define NSWeekdayCalendarUnit               NSWeekdayCalendarUnit
#define NSWeekdayOrdinalCalendarUnit        NSWeekdayOrdinalCalendarUnit
#define NSQuarterCalendarUnit               NSQuarterCalendarUnit
#define NSWeekOfMonthCalendarUnit           NSWeekOfMonthCalendarUnit
#define NSWeekOfYearCalendarUnit            NSWeekOfYearCalendarUnit
#define NSYearForWeekOfYearCalendarUnit     NSYearForWeekOfYearCalendarUnit
#define NSCalendarCalendarUnit              NSCalendarCalendarUnit
#define NSTimeZoneCalendarUnit              NSTimeZoneCalendarUnit
#endif

@class MBProgressHUD;

extern NSString *const NetIsConnectedNotification;          //网络改变通知
extern NSString *const NetConnectStatu;                     //网络连接状态
extern NSString *const NetIsConnected;                      //是否连接网络

typedef void (^successBlock)(id responseObject, NSString *msg);     //请求成功回调block
typedef void (^failureBlock)(NSString *errorInfo, NSError *error);  //请求失败回调block
typedef void (^loadProgressBlock)(float progress);                  //请求中回调block

/************************************************************
 *  说明:
 *      需要集成的框架
 *      pod 'AFNetworking', '~> 3.1.0'
 *      pod 'FMDB', '~> 2.6.2’
 *      pod 'Masonry', '~> 1.0.2'
 *      pod 'IQKeyboardManager', '~> 4.0.1’
 *      pod 'SDWebImage', '~> 3.8.2'
 *      pod 'MBProgressHUD', '~> 1.0.0'
 *      pod 'Reachability', '~> 3.2'
 ************************************************************/

@interface ToolClass : NSObject
{
    
}

@property (nonatomic, strong) UIView *hudView;               //承载Hud的View

@property (nonatomic, copy) NSString *connectStatu;          //网络连接类型
@property (nonatomic, assign) BOOL isConnectedNet;           //是否有网络

@property (nonatomic, strong) AFHTTPSessionManager *afManager;
/** 扩展请求体 */
@property (nonatomic, strong) NSDictionary *extensionRequestBody;

/**!
 *  默认为 0:永远
 *  缓存的策略：(如果 cacheTime == 0，将永久缓存数据) 也就是缓存的时间 以 秒 为单位计算
 *  分钟 ： 60
 *  小时 ： 60 * 60
 *  一天 ： 60 * 60 * 24
 *  星期 ： 60 * 60 * 24 * 7
 *  一月 ： 60 * 60 * 24 * 30
 *  一年 ： 60 * 60 * 24 * 365
 *  永远 ： 0
 */
@property (nonatomic, assign) NSInteger cacheTime;

//宏定义创建单例
singleton_interface(ToolClass)

#pragma mark - 本地储存相关

/**
 *  UserDefaults从本地取对象
 *
 *  @param defaultName 取的名字Key
 *
 *  @return 返回本地名字Key所对应的对象的值
 */
+ (id)objectForKey:(NSString *)defaultName;

/**
 *  UserDefaults存本地的对象
 *
 *  @param value       要存本地的对象的值
 *  @param defaultName 存的名字Key
 */
+ (void)setObject:(id)value forKey:(NSString *)defaultName;

/**
 *  UserDefaults从本地取BOOL值
 *
 *  @param defaultName 取的名字Key
 *
 *  @return 返回本地名字Key所对应的BOOL值
 */
+ (BOOL)boolForKey:(NSString *)defaultName;

/**
 *  UserDefaults存本地BOOL值
 *
 *  @param value       要存本地的BOOL值
 *  @param defaultName 存的名字Key
 */
+ (void)setBool:(BOOL)value forKey:(NSString *)defaultName;

/** UserDefaults通过key删除一个对象 */
+ (void)removeObjectForKey:(NSString *)defaultName;

/**
 *  UserDefaults存本地Data数据
 *
 *  @param data        要存本地的Data数据
 *  @param defaultName 存的名字Key
 */
+ (void)setData:(NSData *)data forKey:(NSString *)defaultName;

/**
 *  UserDefaults从本地取Data数据
 *
 *  @param defaultName 取的名字Key
 *
 *  @return 返回本地名字Key所对应的Data数据
 */
+ (NSData *)dataForKey:(NSString *)defaultName;

/**
 *  返回Token
 *
 *  @param userId   用户id
 *  @param youlife  与后台协商定义的字段
 *  @param deviceId 设备信息
 *
 *  @return 返回一个Token字串
 */
+(NSString *)tokenMD5WithUserId:(NSString *)userId youLife:(NSString *)youlife deviceId:(NSString *)deviceId;

/**
 *  计算缓存大小
 *
 *  @param folderPath 传入文件夹位置
 *
 *  @return 返回缓存大小单位为M
 */
+ (float)folderSizeAtPath:(NSString *)folderPath;

/**
 *  通过文件夹位置来清理缓存
 *
 *  @param path 文件夹位置
 */
+ (void)clearCache:(NSString *)path;

#pragma mark - 提示相关

/**
 *  提示控件(默认显示时间为1.5秒，如果不传toView默认加到Window上)
 *
 *  @param text 显示的文字
 *  @param view 承载的控件(如果不传toView默认加到Window上)
 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view;

/**
 *  提示控件(如果不传toView默认加到Window上)
 *
 *  @param text   显示的文字
 *  @param view   承载的控件(如果不传toView默认加到Window上)
 *  @param second 显示时间
 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view showTime:(NSTimeInterval)second;

/**
 *  提示控件带成功回调(默认显示时间为1.5秒，如果不传toView默认加到Window上)
 *
 *  @param text            显示的文字
 *  @param view            承载的控件(如果不传toView默认加到Window上)
 *  @param completionBlock 成功回调
 */
+ (void)showMBMessageTitle:(NSString *)text toView:(UIView *)view completion:(void (^)())completionBlock;

/**
 *  显示MBHUD
 *
 *  @param text 需要显示的文字
 */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view;

/**
 *  延时显示MBHUD(单位:(秒)0为立即显示)
 *
 *  @param text  显示的文字
 *  @param view  显示的控件
 *  @param delay 延时的时间(秒)
 */
+ (void)showMBConnectTitle:(NSString *)text toView:(UIView *)view afterDelay:(NSTimeInterval)delay isNeedUserInteraction:(BOOL)isNeed;

/**
 *  刷新MBHUD的文字
 *
 *  @param text 刷新时显示的文字
 */
+ (void)reloadMBConnectTitle:(NSString *)text;

/**
 *  结束MBHUD
 */
+ (void)hideMBConnect;

/**
 *  显示一个AlertController
 *
 *  @param preferredStyle    显示方式
 *  @param title             标题
 *  @param message           信息
 *  @param block             点击事件的回调Block
 *  @param cancelButtonTitle 取消按钮的标题
 *  @param otherButtonTitles 其它按钮的标题
 */
+ (void)showAlertControllerWithPreferredStyle:(UIAlertControllerStyle)preferredStyle title:(NSString *)title message:(NSString *)message handlerBlock:(void (^)(NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *  获取AppDelegate单例
 *
 *  @return 返回AppDelegate单例
 */
+ (AppDelegate *)appDelegate;

#pragma mark - 网络相关

/**
 *  异步检测网络连接(AFNetworking)，放到程序入口处
 */
+ (void)asyncReachabilityNetConnectWithAF;

/**
 *  同步检测网络连接(Reachability)(hostName：需要ping的地址)，放到程序入口处
 *
 *  @param hostName 需要ping的地址
 */
+ (void)syncReachabilityNetConnectWithHostName:(NSString *)hostName;

/**
 *  网络请求，GET
 *
 *  @param url        请求地址
 *  @param parameters 请求参数
 *  @param isCache    是否缓存
 *  @param success    成功回调Block
 *  @param failure    失败回调Block
 *
 *  @return 请求任务NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)requestGETWithURL:(NSString *)url parameters:(NSDictionary *)parameters isCache:(BOOL)isCache success:(successBlock)success failure:(failureBlock)failure;

/**
 *  网络请求，POST
 *
 *  @param url        请求地址
 *  @param parameters 请求参数
 *  @param isCache    是否缓存
 *  @param success    成功回调Block
 *  @param failure    失败回调Block
 *
 *  @return 请求任务NSURLSessionDataTask对象
 */
+ (NSURLSessionDataTask *)requestPOSTWithURL:(NSString *)url parameters:(NSDictionary *)parameters isCache:(BOOL)isCache success:(successBlock)success failure:(failureBlock)failure;

/** 上传单个文件 */
+ (NSURLSessionDataTask *)upLoadDataWithUrlStr:(NSString *)urlStr parameters:(NSDictionary *)parameters fileData:(NSData *)data attachName:(NSString *)attach fileName:(NSString *)fileName mimeType:(NSString *)mimeType upLoadProgress:(loadProgressBlock)loadProgress success:(successBlock)success failure:(failureBlock)failure;

/**
 *  获取网络缓存的大小(返回单位'M')
 *
 *  @return 网络缓存的大小
 */
+ (CGFloat)getNetWorkCacheSize;

/**
 *  清除网络缓存
 */
+ (void)clearNetWorkCache;

/**
 *  获取IP地址
 *
 *  @param isIPv4 是否为IPV4
 *
 *  @return IP地址字符串
 */
+ (NSString *)getIPAddress:(BOOL)isIPv4;

#pragma mark - 时间相关

/**
 *  时间格式化为字符串(format:YYYY-MM-DD HH:mm:ss)
 *
 *  @param format YYYY-MM-DD HH:mm:ss
 *  @param date   时间
 *
 *  @return 格式化后的时间字符串
 */
+ (NSString *)stringFromDateWithFormat:(NSString *)format date:(NSDate *)date;

/**
 *  当前时间格式化为字符串(format:YYYY-MM-DD HH:mm:ss)
 *
 *  @param format YYYY-MM-DD HH:mm:ss
 *
 *  @return 当前时间格式化后的字符串
 */
+ (NSString *)stringFromNowDateFormat:(NSString *)format;

/**
 *  获取传入时间的时间戳
 *
 *  @param date 传入的时间对象
 *
 *  @return 返回时间戳
 */
+ (NSTimeInterval)timeIntervalFromDate:(NSDate *)date;

/**
 *  获取当前时间的时间戳
 *
 *  @return 返回当前时间的时间戳
 */
+ (NSTimeInterval)timeIntervalFromNowDate;

/**
 *  获取传入时间毫秒级的时间戳
 *
 *  @param date 传入的时间对象
 *
 *  @return 返回毫秒级的时间戳
 */
+ (long long)milliSecondTimeIntervalFromDate:(NSDate *)date;

/**
 *  获取当前时间毫秒级的时间戳
 *
 *  @return 返回当前时间毫秒级的时间戳
 */
+ (long long)milliSecondTimeIntervalFromNowDate;

/** 时间戳转时间对象 */
+ (NSDate *)dateFromTimeInterval:(NSTimeInterval)timeInterval;

/** 毫秒级的时间戳转时间对象 */
+ (NSDate *)dateFromMilliSecondTimeInterval:(long long)milliSecondTimeInterval;

/** 时间字符串转时间对象(format:yyyy-MM-dd HH:mm:ss) */
+ (NSDate *)dateFromDateString:(NSString *)dateString format:(NSString *)format;

/** 时间字符串转时间戳(format:yyyy-MM-dd HH:mm:ss) */
+ (NSTimeInterval)timeIntervalFromDateString:(NSString *)dateStr format:(NSString *)format;

/** 根据时间对象获取星期几 */
+ (NSString *)getWeekDayFordate:(NSDate *)date;

#pragma mark - UI相关

/**
 *  隐藏TableView多余的线(如果设了FooterView就不要用该方法)
 *
 *  @param tableView 传入的TableView
 */
+ (void)setExtraCellLineHidden:(UITableView *)tableView;

/**
 *  获取当前屏幕显示的ViewController(如果有present出来的VC优先显示)
 *
 *  @return 当前屏幕显示的ViewController
 */
+ (UIViewController *)getCurrentVC;

#pragma mark - 其它

/**
 *  注册IQKeyboard，在程序入口处调用
 */
+ (void)registerIQKeyboard;

/**
 *  倒计时(Count:执行总次数 perTime:每几秒执行一次 inProgress:倒计时中回调(time:第几次) completion:完成回调)
 *
 *  @param count           执行总次数
 *  @param perTime         每几秒执行一次
 *  @param inProgressBlock 倒计时中回调(time:第几次)
 *  @param completionBlock 完成回调
 */
+ (dispatch_source_t)timeCountDownWithCount:(NSTimeInterval)count perTime:(NSTimeInterval)perTime inProgress:(void (^)(int time))inProgressBlock completion:(void (^)())completionBlock;

/**
 *  手动结束倒计时
 *
 *  @param timer 开启倒计时时创建的dispatch_source_t对象
 */
+ (void)cancelTimeCountDownWith:(dispatch_source_t)timer;

/**
 *  图片转字符串
 *
 *  @param image UIImage对象
 *
 *  @return 图片的字符串
 */
+ (NSString *)UIImageToBase64Str:(UIImage *)image;

/**
 *  字符串转图片
 *
 *  @param encodedImageStr 图片的字符串
 *
 *  @return UIImage对象
 */
+ (UIImage *)Base64StrToUIImage:(NSString *)encodedImageStr;

/**
 *  获取摄像头授权(未授权自动提示)
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
+ (void)requestAccessCameraSuccess:(void(^)())success failure:(void(^)())failure;

/**
 *  16位MD5加密方式
 *
 *  @param srcString   需要加密的字符串
 *  @param isUppercase 是否是大写
 *
 *  @return 加密后的16位MD5字符串
 */
+ (NSString *)getMd5_16Bit_String:(NSString *)srcString isUppercase:(BOOL)isUppercase;

- (void)showProgressHUD;
- (void)hideProgressHUD;

@end

/********************************* 以下为设置控制台输出中文代码 ***********************************/
#pragma mark - 以下为设置控制台输出中文代码

@interface NSObject (JRSwizzle)

+ (BOOL)jr_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError**)error_;
+ (BOOL)jr_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError**)error_;

@end

@interface NSDictionary (Unicode)

- (NSString*)my_description;

@end

@interface NSArray (Unicode)

- (NSString*)my_description;

@end

/************************************ 以下为字符串类别代码 **************************************/

@interface NSString (Contains)

#ifdef __IPHONE_7_0
- (BOOL)containsString:(NSString *)aString;
#endif

@end

/*************************************** 以下为C代码 ******************************************/

#ifdef __BLOCKS__

/** 异步获得安全主线程 */
void dispatch_async_get_main_queue_safe(dispatch_block_t block);

/** 同步获得安全主线程 */
void dispatch_sync_get_main_queue_safe(dispatch_block_t block);

#endif
