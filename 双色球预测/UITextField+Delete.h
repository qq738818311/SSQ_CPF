//
//  UITextField+Delete.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/3.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WJTextFieldDelegate <UITextFieldDelegate>

@optional

- (void)textFieldDidDeleteBackward:(UITextField *)textField;

@end

@interface UITextField (Delete)

@property (nonatomic, weak) id<WJTextFieldDelegate> delegate;

@end

/**
 *  监听删除按钮
 *  object:UITextField
 */
extern NSString * const WJTextFieldDidDeleteBackwardNotification;
