//
//  BottomBar.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/12/6.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "BottomBar.h"

@implementation BottomBar

- (instancetype)init
{
    if (self = [super init]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self layoutIfNeeded];
    //上一期
    UIButton *upButton = [UIButton new];
    [self addSubview:upButton];
    [upButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self.mas_left).offset(WIDTH/2/2/2);
    }];
    [self setButtonWithButton:upButton title:@"上一期" tag:2000 imageName:@"bottom_bar_last_btn"];
    //下一期
    UIButton *downButton = [UIButton new];
    [self addSubview:downButton];
    [downButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self).offset(-WIDTH/2/2/2);
    }];
    [self setButtonWithButton:downButton title:@"下一期" tag:2001 imageName:@"bottom_bar_next_btn"];
    //刷新
    UIButton *refreshBtn = [UIButton new];
    [self addSubview:refreshBtn];
    [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(WIDTH/2/2/2);
        make.centerY.equalTo(self);
    }];
    [self setButtonWithButton:refreshBtn title:@"刷新" tag:2002 imageName:@"bottom_bar_refresh"];
    //设置
    UIButton *settingBtn = [UIButton new];
    [self addSubview:settingBtn];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_right).offset(-WIDTH/2/2/2);
        make.centerY.equalTo(self);
    }];
    [self setButtonWithButton:settingBtn title:@"设置" tag:2003 imageName:@"bottom_bar_setting"];
}

- (void)setButtonWithButton:(UIButton *)button title:(NSString *)title tag:(NSInteger)tag imageName:(NSString *)imageName
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitleColor:RGBACOLOR(18, 109, 255, 1) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(13)];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick:(UIButton *)button
{
    if (self.buttonClick) {
        self.buttonClick(button, button.tag - 2000);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [self initButton:(UIButton *)view];
        }
    }
}

- (void)initButton:(UIButton *)btn
{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, viewAdapter(-5), 0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.titleLabel.bounds.size.height, 0.0, 0.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
