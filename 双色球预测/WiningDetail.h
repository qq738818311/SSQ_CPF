//
//  WiningDetail.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/25.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WiningDetail : UIView

@property (nonatomic, strong) UILabel *winingLabel;//是否中奖
@property (nonatomic, strong) UILabel *conjectureLabel;//所用测中号码

- (void)setWiningDetailWithDictionary:(NSDictionary *)dict;

@end
