//
//  SaveModel.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/11/18.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveModel : NSObject

@property (nonatomic, copy) NSString *expect;//期数
@property (nonatomic, copy) NSString *time;//开奖时间
@property (nonatomic, copy) NSString *number;//号码
@property (nonatomic, copy) NSString *nextNumber;//下期预测号码

@end
