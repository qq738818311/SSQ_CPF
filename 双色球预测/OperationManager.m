//
//  OperationManager.m
//  双色球预测
//
//  Created by Sifude_PF on 2016/10/28.
//  Copyright © 2016年 CPF. All rights reserved.
//

#import "OperationManager.h"

@implementation OperationManager

//    //例一
//    [self exampleOneWithNumArray:@[@01,@07,@10,@22,@32,@33]];
//    //例二
//    [self exampleTwoWithNumArray:@[@14,@16,@27,@28,@30,@33]];
//    //例三
//    [self exampleThreeWithNumArray:@[@9,@13,@14,@21,@30,@33]];
//    //例四
//    [self exampleFourWithNumArray:@[@1,@2,@18,@22,@29,@32]];

/*
 替数就是隔５期， 如：１与６，２与７、３与８、４与９、５与０。["jun.he十位密码对应法"的学术叫法]
 补数，就是和１０数，如：１与９、２与８ ３与７、４与６。
 减数就是和５数， 如：１与４、２与３、６与９、７与８。
 邻数，就本身±数，如５的邻数６与４。同尾数，个位相同数，如：８与１８、２８。
 */
/*******************************************************************************
 *  0-10 0-20 0-30   * 1-11 1-21 1-31   * 2-12 2-22 2-32   * 3-13 3-23 3-33    *
 *  4-14 4-24        * 5-15 5-25        * 6-16 6-26        * 7-17 7-27         *
 *  8-18 8-28        * 9-19 9-29        * 10-20 10-30      * 11-1 11-21 11-31  *
 *  12-2 12-22 12-32 * 13-3 13-23 13-33 * 14-4 14-24       * 15-5 15-25        *
 *  16-6 16-26       * 17-7 17-27       * 18-8 18-28       * 19-9 19-29        *
 *  20-10 20-30      * 21-1 21-11 21-31 * 22-2 22-12 22-32 * 23-3 23-13 23-33  *
 *  24-4 24-14       * 25-5 25-15       * 26-6 26-16       * 27-7 27-17        *
 *  28-8 28-18       * 29-9 29-19       * 30-10 30-20      * 31-1 31-11 31-21  *
 *  32-2 32-12 32-22 * 33-3 33-13 33-23                                        *
 *******************************************************************************/

+ (NSDictionary *)getResultWithArray:(NSArray *)numbArray
{
    NSMutableArray *allNumbs = [NSMutableArray new];
    NSArray *exampleArray1 = [self exampleOneWithNumArray:numbArray];
    NSArray *exampleArray2 = [self exampleTwoWithNumArray:numbArray];
    NSArray *exampleArray3 = [self exampleThreeWithNumArray:numbArray];
    NSArray *exampleArray4 = [self exampleFourWithNumArray:numbArray];
    [allNumbs addObjectsFromArray:exampleArray1];
    [allNumbs addObjectsFromArray:exampleArray2];
    [allNumbs addObjectsFromArray:exampleArray3];
    [allNumbs addObjectsFromArray:exampleArray4];
    
    //    allNumbs = [allNumbs valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    NSMutableArray *dateMutablearray = [NSMutableArray new];
    for (int i = 0; i < allNumbs.count; i++) {
        NSString *string = allNumbs[i];
        NSMutableArray *tempArray = [NSMutableArray new];
        [tempArray addObject:string];
        for (int j = i+1; j < allNumbs.count; j ++) {
            NSString *jstring = allNumbs[j];
            if([string isEqualToString:jstring]){
                [tempArray addObject:jstring];
                [allNumbs removeObjectAtIndex:j];
                j -= 1;
            }
        }
        [dateMutablearray addObject:tempArray];
    }
    NSArray *array = [dateMutablearray sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        if (obj1.count > obj2.count) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    NSMutableArray *dictArray = [NSMutableArray new];
    for (NSArray *tempArr in array) {
        if (![(NSString *)tempArr.firstObject containsString:@"未知"]) {
            NSDictionary *dict = @{tempArr.firstObject:[NSString stringWithFormat:@"%lu",(unsigned long)tempArr.count]};
            [dictArray addObject:dict];
        }
    }
    //所有号码随机选7
    NSMutableArray *allCSevenArray = [NSMutableArray new];
    for (NSDictionary *dict in dictArray) {
        [allCSevenArray addObject:[dict allKeys].firstObject];
    }
    //7个号码
    NSMutableArray *sevenArray = [NSMutableArray new];
    //出现次数最多的
//    if (dictArray.count > 7) {
//        for (int i = 0; i < 7; i++) {
//            [sevenArray addObject:[(NSDictionary *)dictArray[i] allKeys].firstObject];
//        }
//    }
//    [sevenArray sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
//        if (obj1.intValue < obj2.intValue) {
//            return(NSComparisonResult)NSOrderedAscending;
//        }else {
//            return(NSComparisonResult)NSOrderedDescending;
//        }
//    }];
    
    //随机选择
    sevenArray = [self allNumbersChooesSevenNumberWithAllNumbers:allCSevenArray];
    
//    NSMutableString *sevenStr = [NSMutableString new];
//    for (int i = 0; i < sevenArray.count; i++) {
//        NSString *str = sevenArray[i];
//        if (i == sevenArray.count - 1) {
//            [sevenStr appendString:kTwoBitString(str)];
//        }else{
//            [sevenStr appendFormat:@"%@,",kTwoBitString(str)];
//        }
//    }
    NSMutableArray *allArray = [NSMutableArray new];
    NSMutableArray *dictArr = [NSMutableArray new];
    
    for (int i = 0; i < dictArray.count; i++) {
        NSDictionary *dic = (NSDictionary *)dictArray[i];
        NSString *key = [dic allKeys].firstObject;
        [allArray addObject:key];
        NSString *tempStr = @"";
        if (i == dictArray.count - 1) {
            tempStr = [NSString stringWithFormat:@"%@-%@。", kTwoBitString(key), dic[key]];
//            [dictString appendFormat:@"%@-%@。", kTwoBitString(key), dic[key]];
        }else if (i == 6){
            tempStr = [NSString stringWithFormat:@"%@-%@;\n", kTwoBitString(key), dic[key]];
//            [dictString appendFormat:@"%@-%@;\n", kTwoBitString(key), dic[key]];
        }else{
            tempStr = [NSString stringWithFormat:@"%@-%@,", kTwoBitString(key), dic[key]];
//            [dictString appendFormat:@"%@-%@,", kTwoBitString(key), dic[key]];
        }
        [dictArr addObject:tempStr];
    }
    [allArray sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.intValue < obj2.intValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
//    NSMutableString *allStr = [NSMutableString new];
//    for (int i = 0; i < allArray.count; i++) {
//        NSString *str = allArray[i];
//        if (i == allArray.count - 1) {
//            [allStr appendString:kTwoBitString(str)];
//        }else{
//            [allStr appendFormat:@"%@,",kTwoBitString(str)];
//        }
//    }
    
    NSString *resultStr = [NSString stringWithFormat:@"========================\n例一：%@\n例二：%@\n例三：%@\n例四：%@\n=========7个号码=========\n= %@ =\n========================\n共%lu个号码：%@\n出现次数：%@", [exampleArray1 componentsJoinedByString:@","], [exampleArray2 componentsJoinedByString:@","], [exampleArray3 componentsJoinedByString:@","], [exampleArray4 componentsJoinedByString:@","], [sevenArray componentsJoinedByString:@","], (unsigned long)allArray.count, [allArray componentsJoinedByString:@","], [dictArr componentsJoinedByString:@""]];
    NSLog(@"%@", resultStr);
    return @{@"example1":exampleArray1, @"example2":exampleArray2, @"example3":exampleArray3, @"example4":exampleArray4, @"sevenArray":sevenArray, @"allArrayCount":@(allArray.count).stringValue, @"allArray":allArray, @"dictArr":dictArr};
}

+ (NSArray *)towBitFormatWithArray:(NSArray *)array
{
    NSMutableArray *mArray = [array mutableCopy];
    for (int i = 0; i < mArray.count; i++) {
        NSString *str = array[i];
        if (str.length < 2) {
            [mArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"0%@",str]];
        }
    }
    return mArray;
}

/** 所有号码随机选7个 */
+ (NSMutableArray *)allNumbersChooesSevenNumberWithAllNumbers:(NSMutableArray *)allNumbers
{
    NSMutableArray *allNumbersCopy = [allNumbers mutableCopy];
    NSMutableArray *sevenArray = [NSMutableArray new];
    if (allNumbersCopy.count > 7) {
        for (int i = 0; i < 7; i++) {
            NSString *str = allNumbersCopy[arc4random()%allNumbersCopy.count];
            [sevenArray addObject:str];
            [allNumbersCopy removeObject:str];
        }
    }
    [sevenArray sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.intValue < obj2.intValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return sevenArray;
}

//例一
+ (NSArray *)exampleOneWithNumArray:(NSArray *)numArray
{
    NSMutableArray *resultArr = [NSMutableArray new];
    NSString *str1 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[0] intValue]];
    NSString *str2 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[3] intValue]];
    //第１位是０１，第４位是２２。第６位与第１位差数为：３３－０１＝３２，取２。第６位与第４位差数为：３３－２２＝１１，取１。２的同尾数２２，２的邻数为１，取０１。１的替数为６，取同尾数１６。１的邻数为０，取同尾数１０，１的减数为４，取同尾数２４。１的补数为９，取０９。 ２２、０１、１６、１０、２４、０９为下期中奖红号的预测号。０４００９期中奖红号是０１、０９、１０、１６、２２、２４（全部测中）
    //1 第６位与第４位差数为：３３－２２＝１１，取１
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        if (![gewei isEqualToString:@"0"]) {
            [resultArr addObject:gewei];
        }else{//调整
            //            [resultArr addObject:@"未知"];
            [resultArr addObject:str2];
        }
    }else{//调整
        //        [resultArr addObject:@"未知"];
        [resultArr addObject:str2];
    }
    //2 第６位与第１位差数为：３３－０１＝３２，取２,２的同尾数２２(2-12 2-22 2-32)
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSArray *array = [self tongweishu:gewei];
        if (array.count == 3) {
            [resultArr addObject:array[1]];
        }else{//调整
            //            [resultArr addObject:@"未知"];
            if (array.count == 2) {
                [resultArr addObject:array[1]];
            }else{
                [resultArr addObject:@"未知"];
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //3 第６位与第１位差数为：３３－０１＝３２，取２。２的邻数为１，取０１。１的替数为６，取同尾数１６(6-16 6-26)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSArray *lingshus = [self linshu:gewei];
        if (lingshus.count == 2) {
            NSString *linshu = lingshus[0];
            NSString *tishu = [self tishu:linshu];
            if (![tishu isEqualToString:@"未知"]) {
                NSArray *tongweishus = [self tongweishu:tishu];
                if (tongweishus.count == 2) {
                    [resultArr addObject:tongweishus[0]];
                }else{//调整
                    //                    [resultArr addObject:@"未知"];
                    [resultArr addObject:tongweishus[0]];
                }
            }else{
                [resultArr addObject:@"未知"];
            }
        }else{//调整
            //            [resultArr addObject:@"未知"];
            NSString *tempStr2 = lingshus.firstObject;
            NSString *tempStr3 = [self tishu:tempStr2];
            if (![tempStr3 isEqualToString:@"未知"]) {
                NSArray *tongweishus = [self tongweishu:tempStr3];
                if (tongweishus.count == 2) {
                    [resultArr addObject:tongweishus[0]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }else{
                [resultArr addObject:@"未知"];
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //4 第６位与第４位差数为：３３－２２＝１１，取１。１的邻数为０，取同尾数１０(0-10 0-20 0-30)
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        NSArray *linshus = [self linshu:gewei];
        if (linshus.count == 2) {
            NSString *linshu = linshus[0];
            NSArray *tongweishus = [self tongweishu:linshu];
            if (tongweishus.count == 3) {
                [resultArr addObject:tongweishus[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus[0]];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSString *linshu = linshus[0];
            NSArray *tongweishus = [self tongweishu:linshu];
            if (tongweishus.count == 3) {
                [resultArr addObject:tongweishus[0]];
            }else{
                [resultArr addObject:@"未知"];
            }
        }
    }else{//调整
        //[resultArr addObject:@"未知"];
        NSArray *linshus = [self linshu:str2];
        if (linshus.count == 2) {
            NSString *linshu = linshus[0];
            NSArray *tongweishus = [self tongweishu:linshu];
            if (tongweishus.count == 3) {
                [resultArr addObject:tongweishus[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus[0]];
            }
        }else{
            [resultArr addObject:@"未知"];
        }
    }
    //5 第６位与第４位差数为：３３－２２＝１１，取１。１的减数为４，取同尾数２４(4-14 4-24)。
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        NSString *jianshu = [self jianshu:gewei];
        if (![jianshu isEqualToString:@"未知"]) {
            NSArray *tongweishus = [self tongweishu:jianshu];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[1]];
            }else{//调整
                //                [resultArr addObject:@"未知"];
                if (tongweishus.count == 3) {
                    [resultArr addObject:tongweishus[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishus = [self tongweishu:gewei];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[1]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                if (tongweishus.count == 3) {
                    [resultArr addObject:tongweishus[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }
    }else{//调整
        //[resultArr addObject:@"未知"];
        NSString *jianshu = [self jianshu:str2];
        if (![jianshu isEqualToString:@"未知"]) {
            NSArray *tongweishus = [self tongweishu:jianshu];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[1]];
            }else{//调整
//                [resultArr addObject:@"未知"];
                if (tongweishus.count == 3) {
                    [resultArr addObject:tongweishus[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }else{//调整
//            [resultArr addObject:@"未知"];
            NSArray *tongweishus = [self tongweishu:str2];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[1]];
            }else{
                [resultArr addObject:@"未知"];
            }
        }
    }
    //6 第６位与第４位差数为：３３－２２＝１１，取１。１的补数为９，取０９。
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            [resultArr addObject:bushu];
        }else{//调整
            //[resultArr addObject:@"未知"];
            if (![gewei isEqualToString:@"0"]) {
                [resultArr addObject:gewei];
            }else{
                [resultArr addObject:str2];
            }
        }
    }else{//调整
        //[resultArr addObject:@"未知"];
        NSString *bushu = [self bushu:str2];
        if (![bushu isEqualToString:@"未知"]) {
            [resultArr addObject:bushu];
        }else{//调整
            //[resultArr addObject:@"未知"];
            [resultArr addObject:str2];
        }
    }
    
    NSMutableString *beforeSort = [NSMutableString new];
    for (int i = 0; i < resultArr.count; i++) {
        NSString *str = resultArr[i];
        if (i == resultArr.count - 1) {
            [beforeSort appendString:kTwoBitString(str)];
        }else{
            [beforeSort appendFormat:@"%@,",kTwoBitString(str)];
        }
    }
    NSLog(@"例一:%@",beforeSort);
    
    [resultArr sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.intValue < obj2.intValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return [self towBitFormatWithArray:resultArr];
}

//例二
+ (NSArray *)exampleTwoWithNumArray:(NSArray *)numArray
{
    NSMutableArray *resultArr = [NSMutableArray new];
    NSString *str1 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[0] intValue]];
    NSString *str2 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[3] intValue]];
    //"双色球"０４０８３期中奖红号为：１４、１６、２７、２８、３０、３３，第６位是３３，第１位是１４，第４位是２８。第６位红号与第１位红号差数为３３－１４＝１９，取个位９。第６位红号与第４位红号差数为３３－２８＝０５，取个位５，９的邻数为８，取０８。９的替数为４，取０４，９的补数为１，取０１与同尾数１１、２１。５的同尾数取２５。 ０８、０４、０１、１１、２１、２５为下期中奖红号的预测号。０４０８４期中奖红号是０１、０４、０８、１１、２１、２５（全部测中）。
    
    //1 第６位红号与第１位红号差数为３３－１４＝１９，取个位９。９的邻数为８，取０８。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSArray *lingshus = [self linshu:gewei];
        if (lingshus.count == 2) {
            NSString *linshu = lingshus[0];
            if (![linshu isEqualToString:@"0"]) {
                [resultArr addObject:lingshus[0]];
            }else{//调整
                //                [resultArr addObject:@"未知"];
                [resultArr addObject:lingshus[1]];
            }
        }else{//调整
            //            [resultArr addObject:@"未知"];
            [resultArr addObject:lingshus.firstObject];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //2 第６位红号与第１位红号差数为３３－１４＝１９，取个位９。９的替数为４，取０４
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *tishu = [self tishu:gewei];
        if (![tishu isEqualToString:@"0"]) {
            [resultArr addObject:tishu];
        }else{//调整
//            [resultArr addObject:@"未知"];
            [resultArr addObject:gewei];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //3 第６位红号与第１位红号差数为３３－１４＝１９，取个位９。９的补数为１，取０１
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            [resultArr addObject:bushu];
        }else{//调整
//            [resultArr addObject:@"未知"];
            [resultArr addObject:gewei.intValue == 0 ? str1 : gewei];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //4 第６位红号与第１位红号差数为３３－１４＝１９，取个位９。９的补数为１，取０１,与同尾数１１(1-11 1-21 1-31)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            NSArray *tongweishu = [self tongweishu:bushu];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[0]];
            }else{//调整
                //                [resultArr addObject:@"未知"];
                [resultArr addObject:tongweishu[0]];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishu = [self tongweishu:gewei];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishu[0]];
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //5 第６位红号与第１位红号差数为３３－１４＝１９，取个位９。９的补数为１，取０１,与同尾数２１(1-11 1-21 1-31)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            NSArray *tongweishu = [self tongweishu:bushu];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[1]];
            }else{//调整
                //                [resultArr addObject:@"未知"];
                if (tongweishu.count == 2) {
                    [resultArr addObject:tongweishu[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishu = [self tongweishu:gewei];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[1]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                if (tongweishu.count == 2) {
                    [resultArr addObject:tongweishu[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //6 第６位红号与第４位红号差数为３３－２８＝０５，取个位５，５的同尾数取２５(5-15 5-25)。
    if (str2.length == 1) {
        NSString *gewei = str2;
        NSArray *tongweishu = [self tongweishu:gewei];
        if (tongweishu.count == 2) {
            [resultArr addObject:tongweishu[1]];
        }else{//调整
//            [resultArr addObject:@"未知"];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[1]];
            }else{
                [resultArr addObject:@"未知"];
            }
        }
    }else{//调整
        //        [resultArr addObject:@"未知"];
        NSString *gewei = [str2 substringFromIndex:1];
        NSArray *tongweishu = [self tongweishu:gewei];
        if (tongweishu.count == 2) {
            [resultArr addObject:tongweishu[1]];
        }else{//调整
            //            [resultArr addObject:@"未知"];
            [resultArr addObject:tongweishu[1]];
        }
    }
    
    NSMutableString *beforeSort = [NSMutableString new];
    for (int i = 0; i < resultArr.count; i++) {
        NSString *str = resultArr[i];
        if (i == resultArr.count - 1) {
            [beforeSort appendString:kTwoBitString(str)];
        }else{
            [beforeSort appendFormat:@"%@,",kTwoBitString(str)];
        }
    }
    NSLog(@"例二:%@",beforeSort);
    
    [resultArr sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.intValue < obj2.intValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return [self towBitFormatWithArray:resultArr];
}

//例三
+ (NSArray *)exampleThreeWithNumArray:(NSArray *)numArray
{
    NSMutableArray *resultArr = [NSMutableArray new];
    NSString *str1 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[0] intValue]];
    NSString *str2 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[3] intValue]];
    //"双色球"０４０９１期中奖红号为：０９、１３、１４、２１、３０、３３。 ０４０９１期中奖红号是第６位是３３。第１位是０９，第４位是２１，第６位红号与第１位红号差数为３３－０９＝２４，取个位４。 ３３－２１＝１２，取个位２，４的本身取０４，４的减数是１，取０１与同尾数３１，２的减数是３，取同尾数１３。２的补数是８，取０８与同尾数２８。 ０４、０１、３１、１３、０８、２８为下期中奖红号的预测号。 ０４０９２期中奖红号是０１、０４、０８、１３、２８、３１。（全部测中）
    
    //1 第６位红号与第１位红号差数为３３－０９＝２４，取个位４。４的本身取０４。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        if (![gewei isEqualToString:@"0"]) {
            [resultArr addObject:gewei];
        }else{
            [resultArr addObject:str1];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //2 第６位红号与第１位红号差数为３３－０９＝２４，取个位４。４的减数是１，取０１。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *jianshu = [self jianshu:gewei];
        if (![jianshu isEqualToString:@"未知"]) {
            [resultArr addObject:jianshu];
        }else{//调整
            //[resultArr addObject:@"未知"];
            [resultArr addObject:gewei.intValue == 0 ? str1 : gewei];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //3 第６位红号与第１位红号差数为３３－０９＝２４，取个位４。４的减数是１，取０１与同尾数３１(1-11 1-21 1-31)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *jianshu = [self jianshu:gewei];
        if (![jianshu isEqualToString:@"未知"]) {
            NSArray *tongweishus = [self tongweishu:jianshu];
            if (tongweishus.count == 3) {
                [resultArr addObject:tongweishus[2]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus.lastObject];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishus = [self tongweishu:gewei];
            if (tongweishus.count == 3) {
                [resultArr addObject:tongweishus[2]];
            }else{//调整
                //                [resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus.lastObject];
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //4 第６位红号与第４位红号差数为３３－２１＝１２，取个位２。２的减数是３，取同尾数１３(3-13 3-23 3-33)。
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        NSString *jianshu = [self jianshu:gewei];
        if (![jianshu isEqualToString:@"未知"]) {
            NSArray *tongweishu = [self tongweishu:jianshu];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishu[0]];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishu = [self tongweishu:gewei];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishu[0]];
            }
        }
    }else{//调整
        //[resultArr addObject:@"未知"];
        NSString *jianshu = [self jianshu:str2];
        if (![jianshu isEqualToString:@"未知"]) {
            NSArray *tongweishu = [self tongweishu:jianshu];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishu[0]];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishu = [self tongweishu:str2];
            if (tongweishu.count == 3) {
                [resultArr addObject:tongweishu[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishu[0]];
            }
        }
    }
    //5 第６位红号与第４位红号差数为３３－２１＝１２，取个位２。２的补数是８，取０８。
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            [resultArr addObject:bushu];
        }else{//调整
            //[resultArr addObject:@"未知"];
            if (![gewei isEqualToString:@"0"]) {
                [resultArr addObject:gewei];
            }else{
                [resultArr addObject:str2];
            }
        }
    }else{//调整
        //[resultArr addObject:@"未知"];
        NSString *bushu = [self bushu:str2];
        if (![bushu isEqualToString:@"未知"]) {
            [resultArr addObject:bushu];
        }else{//调整
            //[resultArr addObject:@"未知"];
            [resultArr addObject:str2];
        }
    }
    //6 第６位红号与第４位红号差数为３３－２１＝１２，取个位２。２的补数是８，同尾数２８(8-18 8-28)。
    if (str2.length == 2) {
        NSString *gewei = [str2 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            NSArray *tongweishu = [self tongweishu:bushu];
            if (tongweishu.count == 2) {
                [resultArr addObject:tongweishu[1]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                if (tongweishu.count == 3) {
                    [resultArr addObject:tongweishu[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishu = [self tongweishu:gewei];
            if (tongweishu.count == 2) {
                [resultArr addObject:tongweishu[1]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                if (tongweishu.count == 3) {
                    [resultArr addObject:tongweishu[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }
    }else{//调整
        //        [resultArr addObject:@"未知"];
        NSString *bushu = [self bushu:str2];
        if (![bushu isEqualToString:@"未知"]) {
            NSArray *tongweishu = [self tongweishu:bushu];
            if (tongweishu.count == 2) {
                [resultArr addObject:tongweishu[1]];
            }else{//调整
                //                [resultArr addObject:@"未知"];
                if (tongweishu.count == 3) {
                    [resultArr addObject:tongweishu[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishu = [self tongweishu:str2];
            if (tongweishu.count == 2) {
                [resultArr addObject:tongweishu[1]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                if (tongweishu.count == 3) {
                    [resultArr addObject:tongweishu[1]];
                }else{
                    [resultArr addObject:@"未知"];
                }
            }
        }
    }
    
    NSMutableString *beforeSort = [NSMutableString new];
    for (int i = 0; i < resultArr.count; i++) {
        NSString *str = resultArr[i];
        if (i == resultArr.count - 1) {
            [beforeSort appendString:kTwoBitString(str)];
        }else{
            [beforeSort appendFormat:@"%@,",kTwoBitString(str)];
        }
    }
    NSLog(@"例三:%@",beforeSort);
    
    [resultArr sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.intValue < obj2.intValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return [self towBitFormatWithArray:resultArr];
}

//例四
+ (NSArray *)exampleFourWithNumArray:(NSArray *)numArray
{
    NSMutableArray *resultArr = [NSMutableArray new];
    NSString *str1 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[0] intValue]];
    NSString *str2 = [NSString stringWithFormat:@"%d",[numArray[5] intValue] - [numArray[3] intValue]];
    /*
     2006年26期奖号：[01 02 18 22 29 32]
     32-01=31
     32-22=10
     01替数 06 取本身06 取同尾16 06邻数07 取同尾数：27
     01补数 09 取邻数08
     01减数 04 取同尾14
     10的邻数取11 27期中奖号是:06 08 11 14 16 27 (全部测中)
     */
    
    //1 第６位红号与第１位红号差数为32-01=31。取个位1。01替数 06 取本身06。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *tishu = [self tishu:gewei];
        if (![tishu isEqualToString:@"未知"]) {
            if ((![tishu isEqualToString:@"0"])) {
                [resultArr addObject:tishu];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:gewei];
            }
        }else{
            [resultArr addObject:@"未知"];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //2 第６位红号与第１位红号差数为32-01=31。取个位1。01替数 06 取同尾16(6-16 6-26)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *tishu = [self tishu:gewei];
        if (![tishu isEqualToString:@"未知"]) {
            NSArray *tongweishus = [self tongweishu:tishu];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[0]];
            }else{//调整
//                [resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus[0]];
            }
        }else{
            [resultArr addObject:@"未知"];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //3 第６位红号与第１位红号差数为32-01=31。取个位1。01替数 06 06邻数07 取同尾数：27(7-17 7-27)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *tishu = [self tishu:gewei];
        if (![tishu isEqualToString:@"未知"]) {
            NSArray *linshus = [self linshu:tishu];
            if (linshus.count == 2) {
                NSString *linshu = linshus[1];
                NSArray *tongweishus = [self tongweishu:linshu];
                if (tongweishus.count == 2) {
                    [resultArr addObject:tongweishus[1]];
                }else{//调整
//                    [resultArr addObject:@"未知"];
                    if (tongweishus.count == 3) {
                        [resultArr addObject:tongweishus[1]];
                    }else{
                        [resultArr addObject:@"未知"];
                    }
                }
            }else{//调整
                //[resultArr addObject:@"未知"];
                NSString *linshu = linshus[0];
                NSArray *tongweishus = [self tongweishu:linshu];
                if (tongweishus.count == 2) {
                    [resultArr addObject:tongweishus[1]];
                }else{//调整
                    //[resultArr addObject:@"未知"];
                    if (tongweishus.count == 3) {
                        [resultArr addObject:tongweishus[1]];
                    }else{
                        [resultArr addObject:@"未知"];
                    }
                }
            }
        }else{
            [resultArr addObject:@"未知"];
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //4 第６位红号与第１位红号差数为32-01=31。取个位1。01补数 09 取邻数08。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *bushu = [self bushu:gewei];
        if (![bushu isEqualToString:@"未知"]) {
            NSArray *linshus = [self linshu:bushu];
            if (linshus.count == 2) {
                NSString *linshu = linshus[0];
                if (![linshu isEqualToString:@"0"]) {
                    [resultArr addObject:linshus[0]];
                }else{//调整
                    //[resultArr addObject:@"未知"];
                    [resultArr addObject:linshus[1]];
                }
            }else{
                [resultArr addObject:@"未知"];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *linshus = [self linshu:gewei];
            if (linshus.count == 2) {
                NSString *linshu = linshus[0];
                if (![linshu isEqualToString:@"0"]) {
                    [resultArr addObject:linshus[0]];
                }else{//调整
                    //[resultArr addObject:@"未知"];
                    [resultArr addObject:linshus[1]];
                }
            }else{//调整
                //[resultArr addObject:@"未知"];
                NSString *linshu = linshus[0];
                if (![linshu isEqualToString:@"0"]) {
                    [resultArr addObject:linshus[0]];
                }else{//调整
                    //[resultArr addObject:@"未知"];
                    [resultArr addObject:linshus[1]];
                }
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //5 第６位红号与第１位红号差数为32-01=31。取个位1。01减数 04 取同尾14(4-14 4-24)。
    if (str1.length == 2) {
        NSString *gewei = [str1 substringFromIndex:1];
        NSString *jianshu = [self jianshu:gewei];
        if (![jianshu isEqualToString:@"未知"]) {
            NSArray *tongweishus = [self tongweishu:jianshu];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus[0]];
            }
        }else{//调整
            //[resultArr addObject:@"未知"];
            NSArray *tongweishus = [self tongweishu:gewei];
            if (tongweishus.count == 2) {
                [resultArr addObject:tongweishus[0]];
            }else{//调整
                //[resultArr addObject:@"未知"];
                [resultArr addObject:tongweishus[0]];
            }
        }
    }else{
        [resultArr addObject:@"未知"];
    }
    //6 第６位红号与第4位红号差数为32-22=10。10的邻数取11。
    if (str2.length == 2) {
        NSArray *linshus = [self linshu:str2];
        if (linshus.count == 2) {
            [resultArr addObject:linshus[1]];
        }else{
            [resultArr addObject:@"未知"];
        }
    }else{//调整
        //        [resultArr addObject:@"未知"];
        NSArray *linshus = [self linshu:str2];
        if (linshus.count == 2) {
            [resultArr addObject:linshus[1]];
        }else{
            [resultArr addObject:@"未知"];
        }
    }
    
    NSMutableString *beforeSort = [NSMutableString new];
    for (int i = 0; i < resultArr.count; i++) {
        NSString *str = resultArr[i];
        if (i == resultArr.count - 1) {
            [beforeSort appendString:kTwoBitString(str)];
        }else{
            [beforeSort appendFormat:@"%@,",kTwoBitString(str)];
        }
    }
    NSLog(@"例四:%@",beforeSort);
    
    [resultArr sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (obj1.intValue < obj2.intValue) {
            return(NSComparisonResult)NSOrderedAscending;
        }else {
            return(NSComparisonResult)NSOrderedDescending;
        }
    }];
    return [self towBitFormatWithArray:resultArr];
}

//替数就是隔５期， 如：１与６，２与７、３与８、４与９、５与０。["jun.he十位密码对应法"的学术叫法]
+ (NSString *)tishu:(NSString *)str
{
    int a = str.intValue;
    if (a == 1) {
        return @"6";
    }else if (a == 2){
        return @"7";
    }else if (a == 3){
        return @"8";
    }else if (a == 4){
        return @"9";
    }else if (a == 6){
        return @"1";
    }else if (a == 7){
        return @"2";
    }else if (a == 8){
        return @"3";
    }else if (a == 9){
        return @"4";
    }else if (a == 0){
        return @"5";
    }else if (a == 5){
        return @"0";
    }else{
        return @"未知";
    }
}

//补数，就是和１０数，如：１与９、２与８ ３与７、４与６
+ (NSString *)bushu:(NSString *)str
{
    int a = str.intValue;
    if (a == 1) {
        return @"9";
    }else if (a == 2){
        return @"8";
    }else if (a == 3){
        return @"7";
    }else if (a == 4){
        return @"6";
    }else if (a == 6){
        return @"4";
    }else if (a == 7){
        return @"3";
    }else if (a == 8){
        return @"2";
    }else if (a == 9){
        return @"1";
    }else{
        return @"未知";
    }
}

//减数就是和５数， 如：１与４、２与３、６与９、７与８。
+ (NSString *)jianshu:(NSString *)str
{
    int a = str.intValue;
    if (a == 1) {
        return @"4";
    }else if (a == 2){
        return @"3";
    }else if (a == 3){
        return @"2";
    }else if (a == 4){
        return @"1";
    }else if (a == 6){
        return @"9";
    }else if (a == 7){
        return @"8";
    }else if (a == 8){
        return @"7";
    }else if (a == 9){
        return @"6";
    }else{
        return @"未知";
    }
}

//相邻数
+ (NSArray *)linshu:(NSString *)str
{
    NSMutableArray *array = [NSMutableArray new];
    int a = str.intValue;
    if (a == 0) {
        [array addObject:@"1"];
    }else if (a == 1){
        [array addObject:@"0"];
        [array addObject:@"2"];
    }else if (a == 33){
        [array addObject:@"32"];
    }else{
        [array addObject:[NSString stringWithFormat:@"%d",a - 1]];
        [array addObject:[NSString stringWithFormat:@"%d",a + 1]];
    }
    return array;
}

//同尾数
+ (NSArray *)tongweishu:(NSString *)str
{
    NSMutableArray *array = [NSMutableArray new];
    if (str.length == 2) {
        int a = str.intValue;
        int b = [[str substringFromIndex:1] intValue];
        if (a >= 30) {
            if (b == 0) {
                [array addObject:[NSString stringWithFormat:@"1%d",b]];
                [array addObject:[NSString stringWithFormat:@"2%d",b]];
            }else{
                [array addObject:[NSString stringWithFormat:@"%d",b]];
                [array addObject:[NSString stringWithFormat:@"1%d",b]];
                [array addObject:[NSString stringWithFormat:@"2%d",b]];
            }
        }else if (a >= 20){
            if (b == 0) {
                [array addObject:[NSString stringWithFormat:@"1%d",b]];
                [array addObject:[NSString stringWithFormat:@"3%d",b]];
            }else if (b <= 3){
                [array addObject:[NSString stringWithFormat:@"%d",b]];
                [array addObject:[NSString stringWithFormat:@"1%d",b]];
                [array addObject:[NSString stringWithFormat:@"3%d",b]];
            }else{
                [array addObject:[NSString stringWithFormat:@"%d",b]];
                [array addObject:[NSString stringWithFormat:@"1%d",b]];
            }
        }else if (a >= 10){
            if (b == 0) {
                [array addObject:[NSString stringWithFormat:@"2%d",b]];
                [array addObject:[NSString stringWithFormat:@"3%d",b]];
            }else if (b <= 3){
                [array addObject:[NSString stringWithFormat:@"%d",b]];
                [array addObject:[NSString stringWithFormat:@"2%d",b]];
                [array addObject:[NSString stringWithFormat:@"3%d",b]];
            }else{
                [array addObject:[NSString stringWithFormat:@"%d",b]];
                [array addObject:[NSString stringWithFormat:@"2%d",b]];
            }
        }
    }else{
        int b = str.intValue;
        if (b == 0) {
            [array addObject:[NSString stringWithFormat:@"1%d",b]];
            [array addObject:[NSString stringWithFormat:@"2%d",b]];
            [array addObject:[NSString stringWithFormat:@"3%d",b]];
        }else if (b <= 3){
            [array addObject:[NSString stringWithFormat:@"1%d",b]];
            [array addObject:[NSString stringWithFormat:@"2%d",b]];
            [array addObject:[NSString stringWithFormat:@"3%d",b]];
        }else{
            [array addObject:[NSString stringWithFormat:@"1%d",b]];
            [array addObject:[NSString stringWithFormat:@"2%d",b]];
        }
    }
    return array;
}

@end
