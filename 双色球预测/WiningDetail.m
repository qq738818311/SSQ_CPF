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
//    UILabel *titleLabel = [UILabel new];
//    [self addSubview:titleLabel];
//    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(viewAdapter(5));
//        make.centerY.equalTo(self);
//    }];
//    titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
////    titleLabel.text = @"===⭐️中奖信息⭐️===";//
//    titleLabel.text = @"⭐️中信⭐️\n⭐️奖息⭐️";//
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.numberOfLines = 0;
//    titleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    titleLabel.layer.borderWidth = viewAdapter(1);
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"中奖信息"]];
    [self addSubview:titleImage];
    [titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.centerY.equalTo(self);
        make.height.width.mas_equalTo(viewAdapter(70));
    }];
    
    self.winingLabel =  [UILabel new];
    [self addSubview:self.winingLabel];
    [self.winingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleImage.mas_right);
        make.centerY.equalTo(self).offset(viewAdapter(-12));
    }];
    self.winingLabel.text = @"未中奖😞😞:";
    self.winingLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
    
    self.conjectureLabel =  [UILabel new];
    [self addSubview:self.conjectureLabel];
    [self.conjectureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleImage.mas_right);
        make.centerY.equalTo(self).offset(viewAdapter(18));
        make.bottom.equalTo(self).offset(viewAdapter(-10)).priorityLow();
    }];
    self.conjectureLabel.text = @"所有测中号码:";
    self.conjectureLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
    
    self.winingBg = [UIView new];
    self.conjectureBg = [UIView new];
    [self addSubview:self.winingBg];
    [self addSubview:self.conjectureBg];
    [self.winingBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.winingLabel);
        make.left.equalTo(self.winingLabel.mas_right);
    }];
    [self.conjectureBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.conjectureLabel);
        make.left.equalTo(self.conjectureLabel.mas_right);
    }];
}

- (void)setWiningDetailWithDictionary:(NSDictionary *)dict
{
    for (UIView *view in self.winingBg.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.conjectureBg.subviews) {
        [view removeFromSuperview];
    }
    if (dict) {
        
        [self.winingLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self).offset(viewAdapter(-12));
        }];
        
        [ToolClass cancelTimeCountDownWith:timer];
        self.winingLabel.textColor = [UIColor blackColor];
        /** @{@"sevenArray":sevenArray, @"allArray":allArray} */
        NSArray *sevenArray = dict[@"sevenArray"];
        NSArray *allArray = dict[@"allArray"];
        if (sevenArray.count > 4) {
//            self.winingLabel.text = [NSString stringWithFormat:@"已中奖😄😄:%@", [sevenArray componentsJoinedByString:@","]];
            self.winingLabel.text = @"已中奖😄😄:";
            timer = [ToolClass timeCountDownWithCount:1000 perTime:0.2 inProgress:^(int time) {
                self.winingLabel.textColor = RGBACOLOR(arc4random()%255, arc4random()%255, arc4random()%255, 1);
            } completion:^{
                self.winingLabel.textColor = [UIColor redColor];
            }];
        }else if (sevenArray.count > 0){
//            self.winingLabel.text = [NSString stringWithFormat:@"未中奖😞😞:%@", [sevenArray componentsJoinedByString:@","]];
            self.winingLabel.text = @"未中奖😞😞:";
        }else{
            self.winingLabel.text = @"未中奖😟😟:暂无买中号码";
        }
//        self.conjectureLabel.text = [NSString stringWithFormat:@"所有测中号码为:%@", [allArray componentsJoinedByString:@","]];
        self.conjectureLabel.text = @"所有测中号码:";
        
        //是否中奖号码布局
        UIView *tempView = nil;
        for (int i = 0; i < sevenArray.count; i++) {
            UILabel *numberLabel = [UILabel new];
            numberLabel.backgroundColor = [UIColor redColor];
            numberLabel.layer.masksToBounds = YES;
            numberLabel.layer.cornerRadius = viewAdapter(22)/2;
            numberLabel.tag = 1000 + i;
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.font = [UIFont systemFontOfSize:viewAdapter(13)];
            [self.winingBg addSubview:numberLabel];
            [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.winingBg);
                make.width.height.mas_equalTo(viewAdapter(22));
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
            numberLabel.layer.cornerRadius = viewAdapter(22)/2;
            numberLabel.tag = 2000 + i;
            numberLabel.textAlignment = NSTextAlignmentCenter;
            numberLabel.textColor = [UIColor whiteColor];
            numberLabel.font = [UIFont systemFontOfSize:viewAdapter(13)];
            [self.conjectureBg addSubview:numberLabel];
            [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(self.conjectureBg);
                make.width.height.mas_equalTo(viewAdapter(22));
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
