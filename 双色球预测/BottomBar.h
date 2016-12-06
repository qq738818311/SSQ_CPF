//
//  BottomBar.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/12/6.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomBar : UIView

@property (nonatomic, copy) void (^buttonClick)(UIButton *button, NSInteger index);
- (void)setButtonClick:(void (^)(UIButton *button, NSInteger index))buttonClick;

@end
