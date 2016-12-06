//
//  LastExpectView.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/25.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "LastExpectView.h"

#define SPACING_LastExpectView viewAdapter(10)//间距

@implementation LastExpectView

- (instancetype)init
{
    if (self = [super init]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
//    UIImageView *imageBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reand_bg_qingyan"]];
//    [self addSubview:imageBg];
//    [imageBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
//    imageBg.alpha = 0.7;
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_detail_note"]];
    [self addSubview:titleImage];
    [titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(viewAdapter(10));
        make.left.equalTo(self).offset(viewAdapter(20));
        make.width.height.mas_equalTo(viewAdapter(20));
    }];
    
    self.titleLable = [UILabel new];
    [self addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleImage);
        make.left.equalTo(titleImage.mas_right).offset(viewAdapter(5));
    }];
    self.titleLable.text = @"上期开奖号码:";
    self.titleLable.font = [UIFont systemFontOfSize:viewAdapter(16)];
    self.titleLable.textColor = [UIColor whiteColor];
    
    //上面的线
//    UIView *titleLineView = [UIView new];
//    [self.titleLable addSubview:titleLineView];
//    [titleLineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.top.equalTo(self.titleLable.mas_bottom).offset(viewAdapter(5));
//        make.height.mas_equalTo(viewAdapter(1));
//    }];
//    titleLineView.backgroundColor = [UIColor lightGrayColor];
    
    [self layoutIfNeeded];
    
    UIView *numberBg = [UIView new];
    [self addSubview:numberBg];
    [numberBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(viewAdapter(15));
        make.top.equalTo(self.titleLable.mas_bottom).offset(viewAdapter(5));
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(viewAdapter(-25));
    }];
    
    UIView *tempView = nil;
    for (int i = 0; i < 7; i++) {
        UILabel *numberLabel = [UILabel new];
        numberLabel.layer.masksToBounds = YES;
        numberLabel.layer.cornerRadius = viewAdapter(30)/2;
        numberLabel.layer.borderColor = i == 6 ? [UIColor blueColor].CGColor : [UIColor redColor].CGColor;
        numberLabel.layer.borderWidth = viewAdapter(1.5);
        numberLabel.tag = 1000 + i;
        numberLabel.textAlignment = NSTextAlignmentCenter;
        //红球白字
        numberLabel.backgroundColor = i == 6 ? [UIColor blueColor] : [UIColor redColor];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.font = [UIFont boldSystemFontOfSize:viewAdapter(17)];
        //红圈红字
//        numberLabel.textColor = i == 6 ? [UIColor blueColor] : [UIColor redColor];
//        numberLabel.font = [UIFont systemFontOfSize:viewAdapter(17)];
        [numberBg addSubview:numberLabel];
        [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(numberBg).offset(viewAdapter(5));
            make.width.height.mas_equalTo(viewAdapter(30));
            NSLog(@"ssssssssss:%f",(WIDTH - self.titleLable.bounds.origin.x - self.titleLable.bounds.size.width - viewAdapter(30) - viewAdapter(8) - SPACING_LastExpectView*6)/7);
            if (!tempView) {
                make.left.equalTo(numberBg).offset(SPACING_LastExpectView);
            }else{
                make.left.equalTo(tempView.mas_right).offset(SPACING_LastExpectView);
            }
            if (i == 6) {
                make.right.equalTo(numberBg).offset(-SPACING_LastExpectView);
                make.bottom.equalTo(numberBg.mas_bottom).offset(viewAdapter(-5)).priorityLow();
            }
        }];
        numberLabel.text = @"--";
        tempView = numberLabel;
    }
    
    //按钮的背景
    UIView *btnBg = [UIView new];
    [self addSubview:btnBg];
    [btnBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(viewAdapter(300));
        make.height.mas_equalTo(viewAdapter(35));
//        make.bottom.equalTo(numberBg.mas_top).offset(viewAdapter(0));
//        make.left.equalTo(numberBg.mas_right).offset(viewAdapter(3));
//        make.right.equalTo(self).offset(viewAdapter(-15));
        make.centerY.equalTo(self.mas_bottom);
        make.centerX.equalTo(self);
    }];
    btnBg.layer.cornerRadius = viewAdapter(35)/2;
    btnBg.backgroundColor = RGBACOLOR(253, 185, 17, 1);
    
    UIButton *startBtn = [UIButton new];
    [btnBg addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(btnBg);
//        make.width.mas_equalTo(viewAdapter(75));
        make.width.equalTo(btnBg).multipliedBy(2.0/3);
    }];
    startBtn.titleEdgeInsets = UIEdgeInsetsMake(0, viewAdapter(20), 0, 0);
    startBtn.titleLabel.font = [UIFont boldSystemFontOfSize:viewAdapter(15)];
    [startBtn setTitleColor:RGBACOLOR(78, 47, 34, 1) forState:UIControlStateNormal];
    
    [startBtn setTitle:@"开始" forState:UIControlStateNormal];
    [startBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [startBtn setTitle:@"停止" forState:UIControlStateSelected];
    [startBtn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
    
    UIView *lineView = [UIView new];
    [btnBg addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(startBtn.mas_right);
        make.width.mas_equalTo(viewAdapter(2));
        make.height.equalTo(btnBg).offset(viewAdapter(-10));
        make.centerY.equalTo(btnBg);
    }];
    lineView.backgroundColor = RGBACOLOR(241, 164, 16, 1);
    
    UIButton *saveBtn = [UIButton new];
    [btnBg addSubview:saveBtn];
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(btnBg);
        make.left.equalTo(lineView.mas_right);
    }];
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:RGBACOLOR(78, 47, 34, 1) forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:viewAdapter(15)];
}

- (void)setLastExpectViewWithText:(NSString *)text
{
    for (int i = 0; i < 7; i++) {
        UILabel *numberLabel = [self viewWithTag:1000 + i];
        if (i == 6 && [self.titleLable.text containsString:@"下期预测号码"]) {
            numberLabel.backgroundColor = [UIColor redColor];
            numberLabel.textColor = [UIColor whiteColor];
//            numberLabel.textColor = [UIColor redColor];
            numberLabel.layer.borderColor = [UIColor redColor].CGColor;
        }
        numberLabel.text = text ? [text substringWithRange:NSMakeRange(i*3, 2)] : @"--";
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
