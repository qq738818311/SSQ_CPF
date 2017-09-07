//
//  ToolClass+Xml.m
//  双色球预测
//
//  Created by Sifude_PF on 2017/9/7.
//  Copyright © 2017年 CPF. All rights reserved.
//

#import "ToolClass+Xml.h"
#import "XMLDictionary.h"

@implementation ToolClass (Xml)

+ (void)load
{
    [super load];
    //控制台输出中文的方法
    [self jr_swizzleMethod:@selector(objectWithJSONData:) withMethod:@selector(my_objectWithJSONData:) error:nil];
}

/** 解析数据 */
- (id)my_objectWithJSONData:(NSData *)jsonData
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    if (error) {
        NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLData:jsonData];
        if (xmlDict) {
            return xmlDict;
        }else{
            return nil;
        }
    }else{
        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
            return [NSDictionary dictionaryWithDictionary:jsonObject];
        }else if ([jsonObject isKindOfClass:[NSDictionary class]]){
            return [NSArray arrayWithArray:jsonObject];
        }else if (jsonData.length > 0){
            return [UIImage imageWithData:jsonData];
        }else{
            return nil;
        }
    }
}

@end
