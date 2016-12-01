//
//  FMDatabaseTool.h
//  HealthChat
//
//  Created by 曹鹏飞 on 15/12/1.
//  Copyright © 2015年 CPF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "FMDB.h"

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"

#define SQLTEXT_NSARRAY     @"TEXT,NSArray"
#define SQLTEXT_NSDICT      @"TEXT,NSDictionary"
#define SQLBLOB_UIIMAGE     @"BLOB,UIImage"

#define PrimaryKey  @"primary key"

@protocol FMDatabaseToolDelegate <NSObject>

@optional

/** 同步数据库数据和服务数据的代理方法 */
- (void)syncServerObjects:(NSArray *)serverObjects andDBObjects:(NSArray *)dbObjects;

@end

@interface FMDatabaseTool : NSObject

/************************************************************
 *  说明:
 *      主键为第一个Model声明的属性
 *      如果没有主键，则需要在Model声明中的第一个属性为"columnId"
 *      @property (nonatomic) NSInteger columnId;
 *      如果有不需要存储的字段
 *      需要声明该属性@"BELOW_IS_NOT_NEED_SAVE"
 *      @property (nonatomic, copy) NSString *BELOW_IS_NOT_NEED_SAVE;
 *      该属性以下声明的字段将都不会存数据库
 ************************************************************/

/** 数据库队列 */
@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;
/** 自定义DB储存位置与库名 */
@property (nonatomic, copy) NSString *dbPath;
/** 模型属性字段数组 */
@property (nonatomic, strong) NSArray *columeNames;
/** 模型属性类型数组 */
@property (nonatomic, strong) NSArray *columeTypes;
/** 主键在模型属性中的字段 */
@property (nonatomic, copy) NSString *primaryKeyStr;
/** 主键类型在sql中的字段 */
@property (nonatomic, copy) NSString *primarySQType;

/** 需要同步数据库操作时通过该代理方法去实现 */
@property (nonatomic, weak) id <FMDatabaseToolDelegate> delegate;

singleton_interface(FMDatabaseTool)

/** 数据库路径 */
+ (NSString *)dbPath;

/** 创建DB库 */
+ (BOOL)createTableWithTableName:(NSString *)tableName andModelClass:(Class)modelClass;

/** 保存单条数据 */
+ (BOOL)saveObjectToDB:(id)model withTableName:(NSString *)tableName;

/** 增加单条数据 */
- (BOOL)addObject:(id)model withTableName:(NSString *)tableName;

/** 更新单条数据 */
- (BOOL)updateObject:(id)model withTableName:(NSString *)tableName;

/** 删除单条数据 */
+ (BOOL)deleteObject:(id)model withTableName:(NSString *)tableName;

/** 批量保存数据(如果DB库没有就增加，如果有就更新) */
+ (BOOL)saveObjects:(NSArray *)array withTableName:(NSString *)tableName;

/** 批量增加数据 */
+ (BOOL)addObjects:(NSArray *)array withTableName:(NSString *)tableName;

/** 批量更新数据 */
+ (BOOL)updateObjects:(NSArray *)array withTableName:(NSString *)tableName;

/** 批量删除数据 */
+ (BOOL)deleteObjects:(NSArray *)array withTableName:(NSString *)tableName;

/** 查询全部数据 */
+ (NSArray *)findAllWithTableName:(NSString *)tableName andModelClass:(Class)modelClass;

/** 通过主键查询某条数据 */
+ (instancetype)findByFirstProperty:(id)firstProperty withTableName:(NSString *)tableName andModelClass:(Class)modelClass;

/** 通过条件查询某条数据 */
+ (instancetype)findFirstByCriteria:(NSString *)criteria withTableName:(NSString *)tableName andModelClass:(Class)modelClass;

/**
 *  通过条件查询数据（条件语句 例如:“WHERE account = '%@' COLLATE NOCASE(不区分大小写)”）
 *
 *  @param criteria   条件语句 例如:“WHERE account = '%@' COLLATE NOCASE(不区分大小写)”
 *  @param tableName  表名
 *  @param modelClass 模型的类
 *
 *  @return 返回条件查询出来的结果数据
 */
+ (NSArray *)findByCriteria:(NSString *)criteria WithTableName:(NSString *)tableName andModelClass:(Class)modelClass;

/** 通过条件删除数据 */
+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria withTableName:(NSString *)tableName andModelClass:(Class)modelClass;

/** 清空表 */
+ (BOOL)clearTableWithTableName:(NSString *)tableName andModelClass:(Class)modelClass;

@end
