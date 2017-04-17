//
//  CustomSlider.m
//  双色球预测
//
//  Created by Sifude_PF on 2017/4/11.
//  Copyright © 2017年 CPF. All rights reserved.
//

#import "CustomSlider.h"

@interface CustomSlider ()

//@property (nonatomic, strong) UIStepper *stepper;

@end

@implementation CustomSlider

- (UILabel *)blueLabel
{
    if (!_blueLabel) {
        _blueLabel = [UILabel new];
        _blueLabel.backgroundColor = [UIColor blueColor];
        _blueLabel.textColor = [UIColor whiteColor];
        _blueLabel.textAlignment = NSTextAlignmentCenter;
        _blueLabel.font = [UIFont systemFontOfSize:viewAdapter(25)];
        _blueLabel.layer.masksToBounds = YES;
        _blueLabel.layer.cornerRadius = ((WIDTH - viewAdapter(10)*10)/7)/2;
    }
    return _blueLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.subviews.count == 3 && ![self.blueLabel.superview.superview isEqual:self]) {
        UIView *tempView = self.subviews.lastObject;
        tempView.frame = CGRectMake(tempView.frame.origin.x, tempView.frame.origin.y, ((WIDTH - viewAdapter(10)*10)/7), ((WIDTH - viewAdapter(10)*10)/7));
        self.blueLabel.text = kTwoBitString([@((int)self.value) stringValue]);
        [tempView addSubview:self.blueLabel];
        [self.blueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(tempView);
            make.height.width.mas_equalTo((WIDTH - viewAdapter(10)*10)/7);
        }];
    }
}

//- (instancetype)init
//{
//    if (self = [super init]) {
//        [self createUI];
//    }
//    return self;
//}
//
//- (void)createUI
//{
//    self.stepper = [[UIStepper alloc] init];
//    self.stepper.minimumValue = 1;//下限
//    self.stepper.maximumValue = 16;//上限
//    self.stepper.stepValue = 1;
//    [self.stepper addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
//    
////    self.slider = [[UISlider alloc] init];
//    self.minimumValue = 1;//下限
//    self.maximumValue = 16;//上限
//    [self addTarget:self action:@selector(stepperValueChanged:) forControlEvents:UIControlEventValueChanged];
//}
//
//- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
//{
//    [super addTarget:target action:action forControlEvents:controlEvents];
//    
//}
//
//- (void)stepperValueChanged:(id)control
//{
//    if ([control isKindOfClass:[UIStepper class]]) {
//        UIStepper *stepper = (UIStepper *)control;
//        self.value = stepper.value;
//    }else if ([control isKindOfClass:[UISlider class]]){
//        UISlider *slider = (UISlider *)control;
//        self.stepper.value = slider.value;
//    }
//}

@end
