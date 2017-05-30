//
//  LaunchViewController.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/12/2.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "LaunchViewController.h"
#import "SaveModel.h"
#import "ViewController.h"
#import "LoginViewController.h"

TCTimer *tcd;

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"1242x2208"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
        
    [ToolClass showMBConnectTitle:@"" toView:self.view afterDelay:0 isNeedUserInteraction:NO];
    [ToolClass requestPOSTWithURL:NET_API parameters:nil isCache:NO success:^(id responseObject, NSString *msg) {
        NSArray *data = responseObject[@"data"];
        for (int i = 0; i < data.count; i++) {
            NSDictionary *dataDict = data[i];
            NSString *expect = dataDict[@"expect"];
            if (i == 0) {
                [ToolClass setObject:expect forKey:kLASTEXPECT];
            }
            SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:expect withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
            if (!model) {
                model = [SaveModel new];
                model.expect = dataDict[@"expect"];
                model.time = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
                model.number = dataDict[@"opencode"];
                [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
            }
        }
        [ToolClass hideMBConnect];
        [self setRootViewController];
    } failure:^(NSString *errorInfo, NSError *error) {
        [ToolClass hideMBConnect];
        if (![errorInfo containsString:@"-有缓存"]) {
            [self setRootViewController];
        }
    }];
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    tcd = [ToolClass timeCountDownWithCount:6 perTime:0.5 inProgress:^(int time) {
//        if (time%2) {
////            [self.nextExpectView setLastExpectViewWithText:[[@[@"--",@"--",@"--",@"--",@"--",@"--",@"--"] mutableCopy] componentsJoinedByString:@","]];
//        }else{
////            [self.nextExpectView setLastExpectViewWithText:[[@[@"  ",@"  ",@"  ",@"  ",@"  ",@"  ",@"  "] mutableCopy] componentsJoinedByString:@","]];
//        }
//    } completion:^{
//        tcd = [ToolClass timeCountDownWithCount:9999999 perTime:0.02 inProgress:^(int time) {
////            [self.nextExpectView setLastExpectViewWithText:[[OperationManager allNumbersChooesSevenNumberWithAllNumbers:dict[@"allArray"]] componentsJoinedByString:@","]];
//            //                    NSLog(@"ssssssssssss: 倒计时回调又给刷新预测号码了");
//        } completion:^{
//            
//        }];
//    }];
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [ToolClass cancelTimeCountDownWith:tcd];
//}

- (BOOL)isOverNineClock
{
    NSDate *nowDate = [NSDate date];
    NSString *todayWeek = [ToolClass getWeekDayFordate:nowDate];
    if ([todayWeek isEqualToString:@"周日"] || [todayWeek isEqualToString:@"周二"] || [todayWeek isEqualToString:@"周四"]) {
        return ([ToolClass stringFromDateWithFormat:@"HH" date:nowDate].intValue >= 21);
    }else{
        return NO;
    }
}

- (void)setRootViewController
{
    [ToolClass appDelegate].window.rootViewController = [ViewController new];
    return;
    if ([ToolClass objectForKey:kISLOGIN]) {
        [ToolClass appDelegate].window.rootViewController = [ViewController new];
    }else{
        [ToolClass appDelegate].window.rootViewController = [LoginViewController new];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
