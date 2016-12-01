//
//  FMDatabaseTool.m
//  HealthChat
//
//  Created by 曹鹏飞 on 15/12/1.
//  Copyright © 2015年 CPF. All rights reserved.
//

#import "FMDatabaseTool.h"

@interface FMDatabaseTool ()

@property (nonatomic, retain) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) Class modelClass;             //需要创建表格的model

@end

@implementation FMDatabaseTool

singleton_implementation(FMDatabaseTool)

- (instancetype)init
{
    if (self=[super init]) {
//        _columeNames = [NSMutableArray array];
//        _columeTypes = [NSMutableArray array];
    }
    return self;
}

/** 操作数据库的队列 */
- (FMDatabaseQueue *)dbQueue
{
    if (_dbQueue == nil) {
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[FMDatabaseTool dbPath]];
    }
    return _dbQueue;
}

/** 获取模型所有属性名和类型数组,使数组有值后才能操作数据库 */
- (void)getColumeNamesAndTypes
{
    NSDictionary *dic = [self getModelAllProperties];
    self.columeNames = dic[@"name"];
    self.columeTypes = dic[@"type"];
}

/** 获取存放数据库的路径 */
+ (NSString *)dbPath
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    if (dbTool.dbPath) {
        return dbTool.dbPath;
    }
    // 生成存放在沙盒中的数据库完整路径
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *filemanage = [NSFileManager defaultManager];
    docsdir = [docsdir stringByAppendingPathComponent:@"USERDB"];
    BOOL isDir;
    BOOL exit =[filemanage fileExistsAtPath:docsdir isDirectory:&isDir];
    if (!exit || !isDir) {
        [filemanage createDirectoryAtPath:docsdir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbpath = [docsdir stringByAppendingPathComponent:@"user.db"];
    return dbpath;
}

/** 创建DB库 */
+ (BOOL)createTableWithTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabase *db = [FMDatabase databaseWithPath:[FMDatabaseTool dbPath]];
    if ([db open]) {
        NSLog(@"FMDatabaseToolLog:\n打开数据库成功,路径为:%@",[FMDatabaseTool dbPath]);
    }else{
        NSLog(@"FMDatabaseToolLog:\n打开数据库失败");
        return NO;
    }
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = modelClass;
    NSString *columeAndType = [dbTool getColumeAndTypeString];
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);",tableName,columeAndType];
    if ([db executeUpdate:sql]) {
        NSLog(@"FMDatabaseToolLog:\n创建表成功,表名为:%@",tableName);
//        [dbTool getColumeNamesAndTypes];
    }else{
        NSLog(@"FMDatabaseToolLog:\n创建表失败");
        return NO;
    }
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    NSDictionary *dict = [dbTool getModelAllProperties];
    NSArray *properties = [dict objectForKey:@"name"];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    //过滤数组
    NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    for (NSString *column in resultArray) {
        NSUInteger index = [properties indexOfObject:column];
        NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",tableName,fieldSql];
        if ([db executeUpdate:sql]) {
            NSLog(@"FMDatabaseToolLog:\n修改表中的字段成功,修改字段为:%@,类型为:%@",[fieldSql componentsSeparatedByString:@" "].firstObject, [fieldSql componentsSeparatedByString:@" "].lastObject);
//            [dbTool getColumeNamesAndTypes];
        }else{
            NSLog(@"FMDatabaseToolLog:\n修改表中的字段失败");
            return NO;
        }
    }
    [db close];
    return YES;
}

#pragma mark - 获取模型属性和类型的一些方法

/** 获取模型属性和类型的字符串 */
- (NSString *)getColumeAndTypeString
{
    NSMutableString* pars = [NSMutableString string];
    NSDictionary *dict = [self getModelAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    for (int i=0; i< proNames.count; i++) {
        NSString *proType = [proTypes objectAtIndex:i];
        if ([proType isEqualToString:SQLTEXT_NSARRAY] || [proType isEqualToString:SQLTEXT_NSDICT]) {//字典或者数组
            proType = SQLTEXT;
        }else if ([proType isEqualToString:SQLBLOB_UIIMAGE]){//图片对象
            proType = SQLBLOB;
        }
        [pars appendFormat:@"%@ %@",[proNames objectAtIndex:i],proType];
        if(i+1 != proNames.count) {
            [pars appendString:@","];
        }
    }
    return pars;
}

/** 获取模型类的所有属性 */
- (NSDictionary *)getModelPropertys
{
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(self.modelClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //不需要创建的字段，需要声明该属性@"BELOW_IS_NOT_NEED_SAVE"
        if ([propertyName isEqualToString:@"BELOW_IS_NOT_NEED_SAVE"]) {
            break;
        }
        [proNames addObject:propertyName];
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         */
        if ([propertyType hasPrefix:@"T@"]) {//对象类型
            if ([propertyType containsString:@"Array"]) {//数组
                [proTypes addObject:SQLTEXT_NSARRAY];
            }else if([propertyType containsString:@"Dictionary"]){//字典
                [proTypes addObject:SQLTEXT_NSDICT];
            }else if([propertyType containsString:@"NSData"]){//Data对象
                [proTypes addObject:SQLBLOB];
            }else if([propertyType containsString:@"UIImage"]){//图片对象
                [proTypes addObject:SQLBLOB_UIIMAGE];
            }else{//默认为字符串对象
                [proTypes addObject:SQLTEXT];
            }
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            [proTypes addObject:SQLINTEGER];
        } else {
            [proTypes addObject:SQLREAL];
        }
    }
    free(properties);
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

/** 获取所有属性字典，包含主键(模型第一个属性为主键) */
- (NSDictionary *)getModelAllProperties
{
    NSDictionary *dict = [self getModelPropertys];
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObjectsFromArray:dict[@"name"]];
    [proTypes addObjectsFromArray:dict[@"type"]];
    self.primaryKeyStr = proNames.firstObject;
    NSString *tempString = proTypes.firstObject;
    self.primarySQType = [NSString stringWithFormat:@"%@ %@",tempString,PrimaryKey];
//    self.primarySQType = tempString;
    [proTypes replaceObjectAtIndex:0 withObject:self.primarySQType];
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

#pragma mark - 操作数据库的方法

- (BOOL)isTableOK:(NSString *)tableName
{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([resultSet next]) {
            // just print out what we've got in a number of formats.
            NSInteger count = [resultSet intForColumn:@"count"];
            NSLog(@"isTableOK %ld", (long)count);
            res = count == 0 ? NO : YES;
        }
    }];
    return res;
}

/** 保存单条数据 */
+ (BOOL)saveObjectToDB:(id)model withTableName:(NSString *)tableName
{
    if (!model) return NO;
    
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = [model class];
//    [dbTool getColumeNamesAndTypes];
//    [dbTool getModelAllProperties];
    //创建表
    [FMDatabaseTool createTableWithTableName:tableName andModelClass:[model class]];
    
    id tempModel = [FMDatabaseTool findByFirstProperty:[NSString stringWithFormat:@"%@",[model valueForKey:dbTool.primaryKeyStr]] withTableName:tableName andModelClass:[model class]];
    if (tempModel) {
        return [dbTool updateObject:model withTableName:tableName];
    }
    return [dbTool addObject:model withTableName:tableName];
}

/** 增加单条数据 */
- (BOOL)addObject:(id)model withTableName:(NSString *)tableName
{
    if (!model) return NO;

    self.modelClass = [model class];
    [self getColumeNamesAndTypes];
    if (!(self.columeNames.count > 0) || !(self.columeTypes.count > 0)) {
        return NO;
    }
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    for (int i = 0; i < self.columeNames.count; i++) {
        NSString *proname = [self.columeNames objectAtIndex:i];
        if ([proname isEqualToString:@"columnId"]) {
            continue;
        }
        [keyString appendFormat:@"%@,", proname];
        [valueString appendString:@"?,"];
        id value = [model valueForKey:proname];
        
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {//将数组或字典转为JOSN串
            NSError *err = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&err];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            value = jsonStr;
        }else if ([value isKindOfClass:[UIImage class]]){//将Image转换为Data
            value = UIImageJPEGRepresentation(value, 1.0);
        }
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
    __weak typeof(self) weakSelf = self;
    __block BOOL res = NO;
    [weakSelf.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        if ([self.primaryKeyStr isEqualToString:@"columnId"] && [self.primarySQType isEqualToString:[NSString stringWithFormat:@"%@ %@",SQLINTEGER, PrimaryKey]]) {
            NSLog(@"db.lastInsertRowId == %lld",db.lastInsertRowId);
            [model setValue:res ? [NSString stringWithFormat:@"%lld",db.lastInsertRowId] : @"0" forKey:self.primaryKeyStr];
        }
        NSLog(@"FMDatabaseToolLog:\n表名为:%@,增加主键为:%@=%@,单条数据%@", tableName, self.primaryKeyStr, [model valueForKey:self.primaryKeyStr], res ? @"成功" : @"失败");
    }];
    return res;
}

/** 更新单条数据 */
- (BOOL)updateObject:(id)model withTableName:(NSString *)tableName
{
    if (!model) return NO;

    self.modelClass = [model class];
    [self getColumeNamesAndTypes];
    if (!(self.columeNames.count > 0) || !(self.columeTypes.count > 0)) {
        return NO;
    }
    __weak typeof(self) weakSelf = self;
    __block BOOL res = NO;
    [weakSelf.dbQueue inDatabase:^(FMDatabase *db) {
        id primaryValue = [model valueForKey:weakSelf.primaryKeyStr];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updateValues = [NSMutableArray  array];
        for (int i = 0; i < weakSelf.columeNames.count; i++) {
            NSString *proname = [weakSelf.columeNames objectAtIndex:i];
            [keyString appendFormat:@" %@=?,", proname];
            id value = [model valueForKey:proname];
            
            if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {//将数组或字典转为JOSN串
                NSError *err = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&err];
                NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                value = jsonStr;
            }else if ([value isKindOfClass:[UIImage class]]){//将Image转换为Data
                value = UIImageJPEGRepresentation(value, 1.0);
            }
            if (!value) {
                value = @"";
            }
            [updateValues addObject:value];
        }
        //删除最后那个逗号
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, weakSelf.primaryKeyStr];
        [updateValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        NSLog(@"FMDatabaseToolLog:\n表名为:%@,更新主键为:%@=%@,单条数据%@", tableName, self.primaryKeyStr, [model valueForKey:self.primaryKeyStr], res ? @"成功" : @"失败");
    }];
    return res;
}

/** 删除单条数据 */
+ (BOOL)deleteObject:(id)model withTableName:(NSString *)tableName
{
    if (!model) return NO;

    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    //如果没有表格直接return
    if (![dbTool isTableOK:tableName]) return NO;
    
    dbTool.modelClass = [model class];
//    [dbTool getColumeNamesAndTypes];
    [dbTool getModelAllProperties];
    
    __block BOOL res = NO;
    [dbTool.dbQueue inDatabase:^(FMDatabase *db) {
        id primaryValue = [model valueForKey:dbTool.primaryKeyStr];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,dbTool.primaryKeyStr];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        NSLog(@"FMDatabaseToolLog:\n表名为:%@,删除主键为:%@=%@,单条数据%@", tableName, dbTool.primaryKeyStr, [model valueForKey:dbTool.primaryKeyStr], res ? @"成功" : @"失败");
    }];
    return res;
}

/** 批量保存数据(如果DB库没有就增加，如果有就更新) */
+ (BOOL)saveObjects:(NSArray *)array withTableName:(NSString *)tableName
{
    if (!(array.count > 0)) return NO;
    
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = [array.firstObject class];
//    [dbTool getColumeNamesAndTypes];
//    [dbTool getModelAllProperties];
    //创建表
    [FMDatabaseTool createTableWithTableName:tableName andModelClass:[array.firstObject class]];

    NSArray *dbObjects = [FMDatabaseTool findAllWithTableName:tableName andModelClass:dbTool.modelClass];
    NSMutableArray *addArray = [NSMutableArray array];
    NSMutableArray *updateArray = [NSMutableArray array];
    
    for (int i = 0; i < array.count; i++) {
        id model = array[i];
        id primaryValue = [model valueForKey:dbTool.primaryKeyStr];
        for (int j = 0; j < dbObjects.count; j++) {
            id dbModel = dbObjects[j];
            id dbPrimaryValue = [dbModel valueForKey:dbTool.primaryKeyStr];
            if ([[NSString stringWithFormat:@"%@",primaryValue] isEqualToString:[NSString stringWithFormat:@"%@",dbPrimaryValue]]) {
                [updateArray addObject:model];
                break;
            }
        }
    }
    [addArray addObjectsFromArray:array];
    [addArray removeObjectsInArray:updateArray];
    
    if (dbTool.delegate) {
        [dbTool.delegate syncServerObjects:array andDBObjects:dbObjects];
    }
    
    BOOL add = YES;
    if (addArray.count > 0) {
        add = [FMDatabaseTool addObjects:addArray withTableName:tableName];
    }
    BOOL update = YES;
    if (updateArray.count > 0) {
        update = [FMDatabaseTool updateObjects:updateArray withTableName:tableName];
    }
    
    return (update && add);
}

/** 批量增加数据 */
+ (BOOL)addObjects:(NSArray *)array withTableName:(NSString *)tableName
{
    if (!(array.count > 0)) return NO;

    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = [array.firstObject class];
    [dbTool getColumeNamesAndTypes];
    if (!(dbTool.columeNames.count > 0) || !(dbTool.columeTypes.count > 0)) {
        return NO;
    }
    __block BOOL res = YES;
    // 如果要支持事务
    [dbTool.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        int index = 0;
        for (id model in array) {
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray  array];
            for (int i = 0; i < dbTool.columeNames.count; i++) {
                NSString *proname = [dbTool.columeNames objectAtIndex:i];
                if ([proname isEqualToString:@"columnId"]) {
                    continue;
                }
                [keyString appendFormat:@"%@,", proname];
                [valueString appendString:@"?,"];
                id value = [model valueForKey:proname];
                
                if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {//将数组或字典转为JOSN串
                    NSError *err = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    value = jsonStr;
                }else if ([value isKindOfClass:[UIImage class]]){//将Image转换为Data
                    value = UIImageJPEGRepresentation(value, 1.0);
                }
                if (!value) {
                    value = @"";
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            if ([dbTool.primaryKeyStr isEqualToString:@"columnId"] && [dbTool.primarySQType isEqualToString:[NSString stringWithFormat:@"%@ %@",SQLINTEGER, PrimaryKey]]) {
                NSLog(@"db.lastInsertRowId == %lld",db.lastInsertRowId);
                [model setValue:flag ? [NSString stringWithFormat:@"%lld",db.lastInsertRowId] : @"0" forKey:dbTool.primaryKeyStr];
            }
            index++;
            NSLog(@"FMDatabaseToolLog:\n表名为:%@,批量增加第%d条数据%@", tableName, index, flag ? @"成功" : @"失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 批量更新数据 */
+ (BOOL)updateObjects:(NSArray *)array withTableName:(NSString *)tableName
{
    if (!(array.count > 0)) return NO;

    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = [array.firstObject class];
    [dbTool getColumeNamesAndTypes];
    if (!(dbTool.columeNames.count > 0) || !(dbTool.columeTypes.count > 0)) {
        return NO;
    }
    __block BOOL res = YES;
    // 如果要支持事务
    [dbTool.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        int index = 0;
        for (id model in array) {
            id primaryValue = [model valueForKey:dbTool.primaryKeyStr];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return;
            }
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray  array];
            for (int i = 0; i < dbTool.columeNames.count; i++) {
                NSString *proname = [dbTool.columeNames objectAtIndex:i];
                [keyString appendFormat:@" %@=?,", proname];
                id value = [model valueForKey:proname];
                
                if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {//将数组或字典转为JOSN串
                    NSError *err = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&err];
                    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    value = jsonStr;
                }else if ([value isKindOfClass:[UIImage class]]){//将Image转换为Data
                    value = UIImageJPEGRepresentation(value, 1.0);
                }
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
            }
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?;", tableName, keyString, dbTool.primaryKeyStr];
            [updateValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            index++;
            NSLog(@"FMDatabaseToolLog:\n表名为:%@,批量更新第%d条数据%@", tableName, index, flag ? @"成功" : @"失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 批量删除数据 */
+ (BOOL)deleteObjects:(NSArray *)array withTableName:(NSString *)tableName
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    //如果没有表格直接return
    if (![dbTool isTableOK:tableName]) return NO;
    
    dbTool.modelClass = [array.firstObject class];
//    [dbTool getColumeNamesAndTypes];
    [dbTool getModelAllProperties];

    __block BOOL res = YES;
    // 如果要支持事务
    [dbTool.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        int index = 0;
        for (id model in array) {
            id primaryValue = [model valueForKey:dbTool.primaryKeyStr];
            if (!primaryValue || primaryValue <= 0) {
                return ;
            }
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,dbTool.primaryKeyStr];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            index++;
            NSLog(@"FMDatabaseToolLog:\n表名为:%@,批量删除第%d条数据%@", tableName, index, flag ? @"成功" : @"失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

/** 查询全部数据 */
+ (NSArray *)findAllWithTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    //如果没有表格直接return
    if (![dbTool isTableOK:tableName]) return nil;
    
    dbTool.modelClass = modelClass;
    [dbTool getColumeNamesAndTypes];
    if (!(dbTool.columeNames.count > 0) || !(dbTool.columeTypes.count > 0)) {
        return nil;
    }
    NSMutableArray *users = [NSMutableArray array];
    [dbTool.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            id model = [[dbTool.modelClass alloc] init];
            for (int i=0; i< dbTool.columeNames.count; i++) {
                NSString *columeName = [dbTool.columeNames objectAtIndex:i];
                NSString *columeType = [dbTool.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {//字符串
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                }else if ([columeType isEqualToString:SQLTEXT_NSARRAY] || [columeType isEqualToString:SQLTEXT_NSDICT]){//数组或者字典
                    NSString *jsonString = [resultSet stringForColumn:columeName];
                    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err;
                    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                    [model setValue:result forKey:columeName];
                }else if ([columeType isEqualToString:SQLBLOB]){//Data数据
                    [model setValue:[resultSet dataForColumn:columeName] forKey:columeName];
                }else if ([columeType isEqualToString:SQLBLOB_UIIMAGE]){//图片对象
                    [model setValue:[UIImage imageWithData:[resultSet dataForColumn:columeName]] forKey:columeName];
                }else{//数字
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    return users;
}

/** 通过主键查询某条数据 */
+ (instancetype)findByFirstProperty:(id)firstProperty withTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = modelClass;
//    [dbTool getColumeNamesAndTypes];
    [dbTool getModelAllProperties];

    NSString *condition = [NSString stringWithFormat:@"WHERE %@='%@'",dbTool.primaryKeyStr,firstProperty];
    return [FMDatabaseTool findFirstByCriteria:condition withTableName:tableName andModelClass:modelClass];
}

/** 通过条件查询某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria withTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    dbTool.modelClass = modelClass;
//    [dbTool getColumeNamesAndTypes];

    NSArray *results = [FMDatabaseTool findByCriteria:criteria WithTableName:tableName andModelClass:modelClass];
    if (results.count < 1) {
        return nil;
    }
    return results.firstObject;
}

/** 通过条件查询数据 */
+ (NSArray *)findByCriteria:(NSString *)criteria WithTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    //如果没有表格直接return
    if (![dbTool isTableOK:tableName]) return nil;
    
    dbTool.modelClass = modelClass;
    [dbTool getColumeNamesAndTypes];
    if (!(dbTool.columeNames.count > 0) || !(dbTool.columeTypes.count > 0)) {
        return nil;
    }

    NSMutableArray *users = [NSMutableArray array];
    [dbTool.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,criteria];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            id model = [[dbTool.modelClass alloc] init];
            for (int i = 0; i < dbTool.columeNames.count; i++) {
                NSString *columeName = [dbTool.columeNames objectAtIndex:i];
                NSString *columeType = [dbTool.columeTypes objectAtIndex:i];
                if ([columeType containsString:SQLTEXT]) {//字符串
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                }else if ([columeType isEqualToString:SQLTEXT_NSARRAY] || [columeType isEqualToString:SQLTEXT_NSDICT]){//数组或者字典
                    NSString *jsonString = [resultSet stringForColumn:columeName];
                    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    NSError *err;
                    id result = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                    [model setValue:result forKey:columeName];
                }else if ([columeType isEqualToString:SQLBLOB]){//Data数据
                    [model setValue:[resultSet dataForColumn:columeName] forKey:columeName];
                }else if ([columeType isEqualToString:SQLBLOB_UIIMAGE]){//图片对象
                    [model setValue:[UIImage imageWithData:[resultSet dataForColumn:columeName]] forKey:columeName];
                }else{//数字
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    return users;
}

/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria withTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    //如果没有表格直接return
    if (![dbTool isTableOK:tableName]) return NO;
    
    dbTool.modelClass = modelClass;
//    [dbTool getColumeNamesAndTypes];

    __block BOOL res = NO;
    [dbTool.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ",tableName,criteria];
        res = [db executeUpdate:sql];
        NSLog(@"FMDatabaseToolLog:\n表名为:%@,通过条件:%@,删除数据%@", tableName, criteria, res ? @"成功" : @"失败");
    }];
    return res;
}

/** 清空表 */
+ (BOOL)clearTableWithTableName:(NSString *)tableName andModelClass:(Class)modelClass
{
    FMDatabaseTool *dbTool = [FMDatabaseTool sharedFMDatabaseTool];
    //如果没有表格直接return
    if (![dbTool isTableOK:tableName]) return NO;
    
    dbTool.modelClass = modelClass;
//    [dbTool getColumeNamesAndTypes];

    __block BOOL res = NO;
    [dbTool.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        NSLog(@"FMDatabaseToolLog:\n表名为:%@,清空%@", tableName, res ? @"成功" : @"失败");
    }];
    return res;
}


@end
