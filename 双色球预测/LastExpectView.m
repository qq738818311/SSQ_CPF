//
//  LastExpectView.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/25.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "LastExpectView.h"

#define SPACING_LastExpectView viewAdapter(8)//间距

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
    self.titleLable = [UILabel new];
    [self addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(viewAdapter(0));
        make.left.equalTo(self);
    }];
    self.titleLable.text = @"上期开奖号码:";
    self.titleLable.font = [UIFont boldSystemFontOfSize:viewAdapter(17)];
    
    [self layoutIfNeeded];
    
    UIView *tempView = nil;
    for (int i = 0; i < 7; i++) {
        UILabel *numberLabel = [UILabel new];
        numberLabel.layer.masksToBounds = YES;
        numberLabel.layer.cornerRadius = ((WIDTH - self.titleLable.bounds.origin.x - self.titleLable.bounds.size.width - viewAdapter(30) - viewAdapter(8) - SPACING_LastExpectView*6)/7)/2;
        numberLabel.layer.borderColor = i == 6 ? [UIColor blueColor].CGColor : [UIColor redColor].CGColor;
        numberLabel.layer.borderWidth = viewAdapter(2);
        numberLabel.tag = 1000 + i;
        numberLabel.textAlignment = NSTextAlignmentCenter;
        //红球白字
//        numberLabel.backgroundColor = i == 6 ? [UIColor blueColor] : [UIColor redColor];
//        numberLabel.textColor = [UIColor whiteColor];
        //红圈红字
        numberLabel.textColor = i == 6 ? [UIColor blueColor] : [UIColor redColor];
        
        numberLabel.font = [UIFont boldSystemFontOfSize:viewAdapter(17)];
        [self addSubview:numberLabel];
        [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(viewAdapter(5));
            make.width.height.mas_equalTo((WIDTH - self.titleLable.bounds.origin.x - self.titleLable.bounds.size.width - viewAdapter(30) - viewAdapter(8) - SPACING_LastExpectView*6)/7);
            if (!tempView) {
                make.left.equalTo(self.titleLable.mas_right).offset(viewAdapter(8));
            }else{
                make.left.equalTo(tempView.mas_right).offset(SPACING_LastExpectView);
            }
            if (i == 6) {
                make.right.equalTo(self).priorityLow();
                make.bottom.equalTo(self.mas_bottom).offset(viewAdapter(-5)).priorityLow();
            }
        }];
        numberLabel.text = @"--";
        tempView = numberLabel;
    }
}

- (void)setLastExpectViewWithText:(NSString *)text
{
    for (int i = 0; i < 7; i++) {
        UILabel *numberLabel = [self viewWithTag:1000 + i];
        if (i == 6 && [self.titleLable.text isEqualToString:@"下期预测号码:"]) {
//            numberLabel.backgroundColor = [UIColor redColor];
            numberLabel.layer.borderColor = [UIColor redColor].CGColor;
            numberLabel.textColor = [UIColor redColor];
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
