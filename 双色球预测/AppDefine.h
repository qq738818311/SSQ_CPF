//
//  AppDefine.h
//  ChildrenApp
//
//  Created by 曹鹏飞 on 16/6/3.
//  Copyright © 2016年 Sifude. All rights reserved.
//

#ifndef AppDefine_h
#define AppDefine_h

#ifdef __OPTIMIZE__
# define NSLog(...) {}
#else
//#define FuncFileName [[NSString stringWithUTF8String:__FILE__] lastPathComponent]
//#define NSLog(fmt, ...) NSLog(@"===NSLog===\n%@ line_%d: \n" fmt"", FuncFileName, __LINE__, ##__VA_ARGS__);
//一个很高级的 NSLog
#define NSLog(format, ...) do {      \
fprintf(stderr,  "---------------------完美分割线---开始--------------------\n<%s : %d> %s\n" ,                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr,  "---------------------完美分割线---结束--------------------\n" );          \
} while ( 0 )

#endif

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define IOS8 [UIDevice currentDevice].systemVersion.integerValue > 7

#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)

/** 屏幕适配 */
#define viewAdapter(f)  f*WIDTH/414

#define WeakObj(o) __weak typeof(o) o##Weak = o;
#define StrongObj(o) __strong typeof(o) o = o##Weak;

//是否是空字符串
//#define kIsEmptyString(s) (s == nil || [s isKindOfClass:[NSNull class]] || ([s isKindOfClass:[NSString class]] && s.length == 0))
#define kIsString(s) (s.length > 0)

#define kTwoBitString(str) str.length >= 2 ? str : [NSString stringWithFormat:@"0%@",str]

//本地储存的Key
#define kLastNumber         @"lastNumber"   //上期号码
#define kISLOGIN            @"isLogin"      //是否登录

//通知的Key
#define kSCNOTIFICATION_UPLOADHEADIMAGERESULT   @"uploadHeadImageResult"//上传头像的结果

//本地储存表名
#define SCUPLOADIMAGE_TABELNAME [NSString stringWithFormat:@"upload_image_%@",[ToolClass objectForKey:kSCCHILD_ID]]

#endif /* AppDefine_h */
