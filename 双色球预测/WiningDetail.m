//
//  WiningDetail.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/25.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "WiningDetail.h"

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
    UILabel *titleLabel = [UILabel new];
    [self addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(viewAdapter(5));
        make.centerX.equalTo(self);
    }];
    titleLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
    titleLabel.text = @"===⭐️中奖信息⭐️===";//
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.winingLabel =  [UILabel new];
    [self addSubview:self.winingLabel];
    [self.winingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(viewAdapter(10));
        make.top.equalTo(titleLabel.mas_bottom).offset(viewAdapter(5));
    }];
    self.winingLabel.text = @"未中奖😞:07";
    self.winingLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
    
    self.conjectureLabel =  [UILabel new];
    [self addSubview:self.conjectureLabel];
    [self.conjectureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(viewAdapter(10));
        make.top.equalTo(self.winingLabel.mas_bottom).offset(viewAdapter(5));
        make.bottom.equalTo(self).offset(viewAdapter(-10));
    }];
    self.conjectureLabel.text = @"所有测中号码为:07,24";
    self.conjectureLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:viewAdapter(17)];
}

- (void)setWiningDetailWithDictionary:(NSDictionary *)dict
{
    if (dict) {
        /** @{@"sevenArray":sevenArray, @"allArray":allArray} */
        NSArray *sevenArray = dict[@"sevenArray"];
        NSArray *allArray = dict[@"allArray"];
        if (sevenArray.count > 4) {
            self.winingLabel.text = [NSString stringWithFormat:@"已中奖😄😄:%@", [sevenArray componentsJoinedByString:@","]];
        }else if (sevenArray.count > 0){
            self.winingLabel.text = [NSString stringWithFormat:@"未中奖😞😞:%@", [sevenArray componentsJoinedByString:@","]];
        }else{
            self.winingLabel.text = @"未中奖😟😟:暂无买中号码";
        }
        self.conjectureLabel.text = [NSString stringWithFormat:@"所有测中号码为:%@", [allArray componentsJoinedByString:@","]];
    }else{
        self.winingLabel.text = @"未查询到上期开奖号码";
        self.conjectureLabel.text = @"";
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
