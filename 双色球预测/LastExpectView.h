//
//  LastExpectView.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/25.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastExpectView : UIView

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UIView *btnBg;//按钮的背景
@property (nonatomic, strong) UIButton *startBtn;//开始按钮
@property (nonatomic, strong) UIView *lineView;//竖线
@property (nonatomic, strong) UIButton *saveBtn;//保存按钮
@property (nonatomic, strong) UIView *btnBgLineView;//按钮下面的线

@property (nonatomic) BOOL buttonEnabled;

@property (nonatomic, copy) void (^buttonClick)(UIButton *button, NSInteger index);
- (void)setButtonClick:(void (^)(UIButton *button, NSInteger index))buttonClick;

- (void)setLastExpectViewWithText:(NSString *)text;

@end
