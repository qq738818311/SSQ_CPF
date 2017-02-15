//
//  LoginViewController.m
//  双色球预测
//
//  Created by Sifude_PF on 2017/1/11.
//  Copyright © 2017年 CPF. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"

@interface LoginViewController ()

@property (nonatomic, strong) UITextField *accountTF;
@property (nonatomic, strong) UITextField *passwordTF;

@end

@implementation LoginViewController

#define TITLE_TEXTFIELD_WIDTH viewAdapter(85)

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1242x2208"]];
    [self.view addSubview:imageBg];
    [imageBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UILabel *tiltleLabel = [UILabel new];
    [self.view addSubview:tiltleLabel];
    [tiltleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(viewAdapter(85));
        make.centerX.equalTo(self.view);
    }];
    tiltleLabel.text = @"双色球预测";
    tiltleLabel.textColor = [UIColor whiteColor];
    tiltleLabel.font = [UIFont systemFontOfSize:viewAdapter(35)];
    
    //账号
    self.accountTF = [UITextField new];
    [self.view addSubview:self.accountTF];
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tiltleLabel.mas_bottom).offset(viewAdapter(65));
        make.left.equalTo(self.view).offset(viewAdapter(50));
        make.right.equalTo(self.view).offset(viewAdapter(-50));
        make.height.mas_equalTo(viewAdapter(30));
    }];
    self.accountTF.textColor = [UIColor whiteColor];
    NSAttributedString *accountAttributedStr = [[NSAttributedString alloc] initWithString:@"请输入您的邮箱" attributes:@{NSForegroundColorAttributeName : RGBACOLOR(174, 175, 174, 1)}];
    self.accountTF.attributedPlaceholder = accountAttributedStr;
    
    UILabel *accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TITLE_TEXTFIELD_WIDTH, viewAdapter(30))];
    accountLabel.text = @"  账号";
    accountLabel.textColor = [UIColor whiteColor];
    accountLabel.font = [UIFont boldSystemFontOfSize:viewAdapter(17)];
    self.accountTF.leftView = accountLabel;
    self.accountTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *accountLine = [UIView new];
    [self.accountTF addSubview:accountLine];
    [accountLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.accountTF);
        make.top.equalTo(self.accountTF.mas_bottom).offset(viewAdapter(5));
        make.height.mas_equalTo(viewAdapter(1));
    }];
    accountLine.backgroundColor = [UIColor lightGrayColor];
    
    //密码
    self.passwordTF = [UITextField new];
    [self.view addSubview:self.passwordTF];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountLine.mas_bottom).offset(viewAdapter(10));
        make.left.equalTo(self.view).offset(viewAdapter(50));
        make.right.equalTo(self.view).offset(viewAdapter(-50));
        make.height.mas_equalTo(viewAdapter(30));
    }];
    self.passwordTF.textColor = [UIColor whiteColor];
    NSAttributedString *passwordAttributedStr = [[NSAttributedString alloc] initWithString:@"请输入您的密码" attributes:@{NSForegroundColorAttributeName : RGBACOLOR(174, 175, 174, 1)}];
    self.passwordTF.attributedPlaceholder = passwordAttributedStr;
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TITLE_TEXTFIELD_WIDTH, viewAdapter(30))];
    passwordLabel.text = @"  密码";
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.font = [UIFont boldSystemFontOfSize:viewAdapter(17)];
    self.passwordTF.leftView = passwordLabel;
    self.passwordTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *passwordLine = [UIView new];
    [self.passwordTF addSubview:passwordLine];
    [passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.passwordTF);
        make.top.equalTo(self.passwordTF.mas_bottom).offset(viewAdapter(5));
        make.height.mas_equalTo(viewAdapter(1));
    }];
    passwordLine.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *loginBtn = [UIButton new];
    [self.view addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(passwordLine).offset(viewAdapter(35));
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(viewAdapter(65));
        make.right.equalTo(self.view).offset(viewAdapter(-65));
        make.height.mas_equalTo(viewAdapter(45));
    }];
    [loginBtn setBackgroundImage:[UIImage imageWithColor:RGBACOLOR(253, 185, 17, 1)] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = viewAdapter(5);
    loginBtn.layer.borderColor = UIColorFromRGB(0xba8402).CGColor;
    loginBtn.layer.borderWidth = viewAdapter(1);
    
    UIButton *backBtn = [UIButton new];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view);
        make.width.height.mas_equalTo(viewAdapter(50));
    }];
    [backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backBtnClick:(UIButton *)button
{
    [ToolClass appDelegate].window.rootViewController = [ViewController new];
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
