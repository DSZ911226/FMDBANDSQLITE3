//
//  DSZDBHelper.h
//  ls
//
//  Created by zhilvmac on 2017/11/23.
//  Copyright © 2017年 浙江智旅信息有限公司. All rights reserved.
//

#import "FMDB.h"


@interface DSZDBHelper : NSObject
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;     // 数据库队列类

+ (DSZDBHelper *)shareInstance;

/**
 *  初始化数据库，这个方法初始化时需要执行一次，主要是数据库名，数据库表的创建 初始化赋值
 *
 *  @param secretKey 数据库加密密码    可为空
 *  @param dbName    数据库名         可为空
 *  @param tables    所有创建表的SQL语句
 */
- (void)initWithSecretKey:(NSString *)secretKey
                   dbName:(NSString *)dbName
                   tables:(NSArray *)tables;


- (BOOL) executeUpdate:(NSString *)sql;        // 执行sql语句

/*
 * 删除数据
 * @param name 表名 TableName
 * @param args where 以后的参数 例如:"ID=1"
 */
- (BOOL)delete4Table:(NSString *)name
            withArgs:(NSString *)where;

/*
 * 添加数据
 * @param name 表名 TableName
 * @param columns 所有字段名 例如:"Column1, Column2, Column3"
 * @param values 所有值  例如:"Value1, Value2, Value3" 这里的keys的个数跟value必须相同
 */
- (BOOL)insert4Table:(NSString *)name
             columns:(NSString *)columns
              values:(NSString *)values;


/*
 * 添加数据
 * @param name 表名 TableName
 * @param dic 所有的字段跟值，key为字段名，value位值
 */
- (BOOL)insert4Table:(NSString *)name
                 dic:(NSDictionary *)dic;


/*
 * 添加/更改 数据
 * @param name 表名 TableName
 * @param columns 所有字段名 例如:"Column1, Column2, Column3"
 * @param values 所有值  例如:"Value1, Value2, Value3" 这里的keys的个数跟value必须相同
 */
- (BOOL)replace4Table:(NSString *)name
              columns:(NSString *)columns
               values:(NSString *)values;

/*
 * 添加/更改 数据
 * @param name 表名 TableName
 * @param dic 所有的字段跟值，key为字段名，value位值
 */
- (BOOL)replace4Table:(NSString *)name
                  dic:(NSDictionary *)dic;

/*
 * 修改数据
 * @param name 表名 TableName
 * @param args 所有需要更改的值  例如:"NAME='张三', AGE=20"
 * @param where 更新条件
 */
- (BOOL)update4Table:(NSString *)name
            withArgs:(NSString *)args
               where:(NSString *)where;

/*
 * 查询数据 用完此方法记得对 FMResultSet 进行 close
 * @param name 表名 TableName
 * @param where 查询条件
 * @param order 排序字段
 * @param columns 需要查询的列名, 空则查询全部
 */
- (NSMutableArray *)query4Table:(NSString *)name
                           args:(NSString *)where
                          order:(NSString *)order
                        columns:(NSString *)columns;

/*
 * 查询表中元素的个数 ElementCount  （比较简单，只查询一个表内元素的个数）
 * @param name 表名 TableName
 */
- (NSInteger)query4TableElementCount:(NSString *)name;


/*
 * 查询数据 根据条件分组 groups分组条件
 * @param name 表名 TableName
 * @param where 查询条件
 * @param order 排序字段
 * @param groups 分组条件
 * @param columns 需要查询的列名, 空则查询全部
 */
- (NSMutableArray *)query4Table:(NSString *)name
                           args:(NSString *)where
                          order:(NSString *)order
                        columns:(NSString *)columns
                         groups:(NSString *)groups;





@end
