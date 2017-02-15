//
//  WiningDetail.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/25.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "WiningDetail.h"

static dispatch_source_t timer;

@implementation WiningDetail

- (instancetype)init
{
    if (self = [super init]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"中奖信息"]];
    [self addSubview:titleImage];
    [titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(viewAdapter(0));
        make.left.equalTo(self);
        make.height.width.mas_equalTo(viewAdapter(70));
    }];
    
    UIView *contentBg = [UIView new];
    [self addSubview:contentBg];
    [contentBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleImage.mas_right).offset(viewAdapter(5));
        make.top.equalTo(self).offset(viewAdapter(10));
        make.bottom.equalTo(self).offset(viewAdapter(-10));
        make.right.equalTo(self).offset(viewAdapter(-10));
    }];
    contentBg.backgroundColor = UIColorFromRGBWithAlpha(0xffffff, 0.5);
    contentBg.layer.cornerRadius = viewAdapter(5);
    
    self.winingLabel =  [UILabel new];
    [contentBg addSubview:self.winingLabel];
    [self.winingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentBg).offset(viewAdapter(5));
        make.centerY.equalTo(contentBg).multipliedBy(1.0/2);
    }];
    self.winingLabel.text = @"未中奖😞😞:";
    self.winingLabel.font = [UIFont systemFontOfSize:viewAdapter(16)];
    
    self.conjectureLabel =  [UILabel new];
    [contentBg addSubview:self.conjectureLabel];
    [self.conjectureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentBg).offset(viewAdapter(5));
        make.centerY.equalTo(contentBg).multipliedBy(3.0/2);
    }];
    self.conjectureLabel.text = @"所有测中号码:";
//    self.conjectureLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
    self.conjectureLabel.font = [UIFont systemFontOfSize:viewAdapter(16)];

    self.winingBg = [UIView new];
    self.conjectureBg = [UIView new];
    [self addSubview:self.winingBg];
    [self addSubview:self.conjectureBg];
    [self.winingBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.winingLabel);
        make.left.equalTo(self.winingLabel.mas_right).offset(viewAdapter(5));
    }];
    [self.conjectureBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.conjectureLabel);
        make.left.equalTo(self.conjectureLabel.mas_right).offset(viewAdapter(5));
    }];
    
    UIView *lineView = [UIView new];
    [self addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(titleImage.mas_bottom).offset(viewAdapter(10));
        make.height.mas_equalTo(viewAdapter(1));
        make.bottom.equalTo(self);
    }];
    lineView.backgroundColor = [UIColor lightGrayColor];
}

- (void)setWiningDetailWithDictionary:(NSDictionary *)dict
{
    for (UIView *view in self.winingBg.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.conjectureBg.subviews) {
        [view removeFromSuperview];
    }
    [ToolClass cancelTimeCountDownWith:timer];

    if (dict) {
        
        [self.winingLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(viewAdapter(-12));
        }];
        
        self.winingLabel.textColor = [UIColor blackColor];
        /** @{@"sevenArray":sevenArray, @"allArray":allArray} */
        NSArray *sevenArray = dict[@"sevenArray"];
        NSArray *allArray = dict[@"allArray"];
        if (sevenArray.count >= 4) {
            self.winingLabel.text = @"已中奖😄😄:";
            timer = [ToolClass timeCountDownWithCount:1000 perTime:0.2 inProgress:^(int time) {
                self.winingLabel.textColor = RGBACOLOR(arc4random()%255, arc4random()%255, arc4random()%255, 1);
            } completion:^{
                self.winingLabel.textColor = [UIColor redColor];
            }];
        }else if (sevenArray.count > 0){
            self.winingLabel.text = @"未中奖😞😞:";
        }else{
            self.winingLabel.text = @"未中奖😟😟:";
            sevenArray = @[@"--"];
        }
        self.conjectureLabel.text = @"所有测中号码:";
        
        //是否中奖号码布局
        UIView *tempView = nil;
        for (int i = 0; i < sevenArray.count; i++) {
            UILabel *numberLabel = [UILabel new];
            numberLabel.backgroundColor = [UIColor redColor];
            numberLabel.layer.masksToBounds = YES;
            numberLabel.layer.cornerRadius = viewAdapter(21)/2;
            numberLabel.tag = 1000 + i;
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.font = [UIFont systemFontOfSize:viewAdapter(13)];
            [self.winingBg addSubview:numberLabel];
            [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.winingBg);
                make.width.height.mas_equalTo(viewAdapter(21));
                if (i == 0) {
                    make.left.equalTo(self.winingBg);
                }else{
                    make.left.equalTo(tempView.mas_right).offset(viewAdapter(5));
                }
                if (i == sevenArray.count -1) {
                    make.right.equalTo(self.winingBg).priorityLow();
                }
            }];
            numberLabel.text = sevenArray[i];
            tempView = numberLabel;
        }
        tempView = nil;
        for (int i = 0; i < allArray.count; i++) {
            UILabel *numberLabel = [UILabel new];
            numberLabel.backgroundColor = [UIColor redColor];
            numberLabel.layer.masksToBounds = YES;
            numberLabel.layer.cornerRadius = viewAdapter(21)/2;
            numberLabel.tag = 2000 + i;
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.font = [UIFont systemFontOfSize:viewAdapter(13)];
            [self.conjectureBg addSubview:numberLabel];
            [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.conjectureBg);
                make.width.height.mas_equalTo(viewAdapter(21));
                if (i == 0) {
                    make.left.equalTo(self.conjectureBg);
                }else{
                    make.left.equalTo(tempView.mas_right).offset(viewAdapter(5));
                }
                if (i == sevenArray.count -1) {
                    make.right.equalTo(self.conjectureBg).priorityLow();
                }
            }];
            numberLabel.text = allArray[i];
            tempView = numberLabel;
        }
    }else{
        self.winingLabel.text = @"未查询到上期开奖号码";
        self.conjectureLabel.text = @"";
        [self.winingLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(viewAdapter(0));
        }];
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
