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
    [ToolClass requestPOSTWithURL:@"http://f.apiplus.cn/ssq-1.json" parameters:nil isCache:NO success:^(id responseObject, NSString *msg) {
        NSArray *data = responseObject[@"data"];
        NSDictionary *dataDict = data.firstObject;
        NSString *expect = dataDict[@"expect"];
//        NSString *dateStr = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
        SaveModel *model = (SaveModel *)[FMDatabaseTool findByFirstProperty:expect withTableName:NSStringFromClass([SaveModel class]) andModelClass:[SaveModel class]];
        if (!model) {
            model = [SaveModel new];
            model.time = [NSString stringWithFormat:@"%@(%@)", [dataDict[@"opentime"] componentsSeparatedByString:@" "].firstObject, [ToolClass getWeekDayFordate:[ToolClass dateFromTimeInterval:[dataDict[@"opentimestamp"] doubleValue]]]];
            model.number = dataDict[@"opencode"];
            model.expect = dataDict[@"expect"];
            [FMDatabaseTool saveObjectToDB:model withTableName:NSStringFromClass([SaveModel class])];
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

- (void)setRootViewController
{
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
