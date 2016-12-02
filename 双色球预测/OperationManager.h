//
//  OperationManager.h
//  双色球预测
//
//  Created by Sifude_PF on 2016/10/28.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationManager : NSObject

+ (NSDictionary *)getResultWithArray:(NSArray *)numbArray;

/** 所有号码随机选7个 */
+ (NSMutableArray *)allNumbersChooesSevenNumberWithAllNumbers:(NSMutableArray *)allNumbers;
@end
