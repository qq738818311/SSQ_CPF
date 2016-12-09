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
    NSArray *titleArray = @[@"上一期", @"下一期", @"刷新", @"设置"];
    NSArray *imageNameArray = @[@"bottom_bar_last_btn", @"bottom_bar_next_btn", @"bottom_bar_refresh", @"bottom_bar_setting"];
    
    UIView *tempView = nil;
    for (int i = 0; i < 4; i++) {
        UIButton *button = [self createButtonWithTitle:titleArray[i] tag:2000 + i imageName:imageNameArray[i]];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(viewAdapter(5));
            make.bottom.equalTo(self).offset(viewAdapter(-5));
            make.width.mas_equalTo((WIDTH - viewAdapter(20)*5)/4);
            if (!tempView) {
                make.left.equalTo(self).offset(viewAdapter(20));
            }else{
                make.left.equalTo(tempView.mas_right).offset(viewAdapter(20));
            }
            if (i == 5) {
                make.right.equalTo(self).offset(viewAdapter(-20)).priorityLow();
            }
        }];
        tempView = button;
    }
    self.backgroundColor = UIColorFromRGBWithAlpha(0xffffff, 0.5);
}

- (UIButton *)createButtonWithTitle:(NSString *)title tag:(NSInteger)tag imageName:(NSString *)imageName
{
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitleColor:RGBACOLOR(18, 109, 255, 1) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(13)];
    button.tag = tag;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
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
            UIButton *button = (UIButton *)view;
            [self initButton:button];
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
