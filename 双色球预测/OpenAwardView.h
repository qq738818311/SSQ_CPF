//
//  OpenAwardView.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/24.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveModel.h"

@interface OpenAwardView : UIView

@property (nonatomic, strong) UILabel *expectLabel;
@property (nonatomic, strong) UILabel *timeLabel;

- (void)setOpenAwardViewWithModel:(SaveModel *)model;

@end
