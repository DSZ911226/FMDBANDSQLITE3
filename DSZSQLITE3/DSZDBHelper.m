//
//  DSZDBHelper.h
//  ls
//
//  Created by zhilvmac on 2017/11/23.
//  Copyright © 2017年 浙江智旅信息有限公司. All rights reserved.
//

#import "DSZDBHelper.h"

static NSString *kDBSecretKey;  // 数据库安全密码
static NSString *kDBName;       // 数据库名称

@interface DSZDBHelper ()

@property (nonatomic, strong) NSMutableArray *tables;
@property (nonatomic, strong) FMDatabase *db;               // 数据库类


@end

@implementation DSZDBHelper


+ (DSZDBHelper *)shareInstance
{
    static DSZDBHelper *sharedManager = nil;
    static dispatch_once_t onceDBToken;
    dispatch_once(&onceDBToken, ^{
        sharedManager = [[DSZDBHelper alloc]init];
    });
    
    return sharedManager;
}

- (void)dealloc
{
    [self.db close];
    self.dbQueue = nil;
    self.db = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initDB];
    }
    return self;
}

#pragma mark - getting/setting

- (FMDatabase *)db
{
    if (!_db) {
        _db = [FMDatabase databaseWithPath:[self getDBFilePath]];
    }
    
    return _db;
}

- (FMDatabaseQueue *)dbQueue
{
    if (!_dbQueue) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self getDBFilePath]];
    }
    
    return _dbQueue;
}

- (NSMutableArray *)tables {
    if (!_tables) {
        _tables = [NSMutableArray arrayWithCapacity:1];
    }
    return _tables;
}


#pragma mark - 自定义方法

- (void)initWithSecretKey:(NSString *)secretKey
                   dbName:(NSString *)dbName
                   tables:(NSArray *)tables {
    
    kDBSecretKey = secretKey;
    kDBName = dbName;
    
    if (tables.count > 0) {
        [self.tables addObjectsFromArray:tables];
    }
}


- (NSString *)dbSecretKey {
    if (kDBSecretKey.length == 0) {
        kDBSecretKey = @"secretkey";
    }
    return kDBSecretKey;
}

- (NSString *)dbName {
    if (kDBName.length == 0) {
        kDBName = @"name";
    }
    
    return kDBName;
}

- (NSString *)dbSecretName {
    if (kDBName.length == 0) {
        kDBName = @"name";
    }
    
    NSString *secretName = [NSString stringWithFormat:@"%@", @"155.sqlite"];
    return secretName;
}

/*
 * 得到加密数据库路径
 */
- (NSString *)getDBFilePath {
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:[self dbSecretName]];
    
    return dbPath;
}

/*
 * 得到明文数据库路径
 */
- (NSString *)getPlaintextDBFilePath {
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:[self dbName]];
    
    return dbPath;
}


- (void)initDB {
    if (![self.db open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //  数据库进行加密
    [self.db setKey:[self dbSecretKey]];
    
}


/*
 * 创建DB文件
 */
- (void)createDBFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *dbPath = [self getDBFilePath];
    if(![manager fileExistsAtPath:dbPath]) {
        [manager createFileAtPath:dbPath contents:nil attributes:nil];
    }
}

- (BOOL)deleteTable:(NSString *)tableName {
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE [%@]", tableName];
    [self.db executeUpdate:sql];
    
    return YES;
}

#pragma mark - 增删改查方法封装

- (BOOL)executeUpdate:(NSString *)sql {
    __block BOOL isSuccess = NO;
    
    if (sql.length == 0) {
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        isSuccess = [db2 executeUpdate:sql];
        
        if ([db2 hadError])
        {
            NSLog(@"数据库执行 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
    }];
    return isSuccess;
}
- (BOOL) executeTransactionUpdate:(NSArray *)sqls {
    __block BOOL isSuccess = NO;
    
    if (sqls.count == 0) {
        return isSuccess;
    }
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        [db2 beginTransaction];
        for (NSString *sql in sqls) {
            [db2 executeUpdate:sql];
        }
        if ([db2 hadError])
        {
            NSLog(@"数据库执行 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        isSuccess = [db2 commit];
    }];
    return isSuccess;
}
- (BOOL)insert4Table:(NSString *)name
             columns:(NSString *)columns
              values:(NSString *)values {
    __block BOOL isSuccess = NO;
    
    if (name.length == 0 || columns.length == 0 || values.length == 0) {
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", name, columns, values];
        
        isSuccess = [db2 executeUpdate:sql];
        
        if ([db2 hadError]) {
            NSLog(@"数据库添加 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
    }];
    return isSuccess;
}

- (BOOL)insert4Table:(NSString *)name
                 dic:(NSDictionary *)dic {
    __block BOOL isSuccess = NO;
    
    if (name.length == 0 ||  dic.count == 0) {
        NSLog(@"参数为空...");
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        NSArray *columnArray = [dic allKeys];
        NSString *columns = [columnArray componentsJoinedByString:@","];
        
        NSArray *valueArray = [dic allValues];
        NSString *values = [valueArray componentsJoinedByString:@","];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", name, columns, values];
        
        NSLog(@"SQL ===== %@", sql);
        isSuccess = [db2 executeUpdate:sql];
        
        if ([db2 hadError])
        {
            NSLog(@"数据库添加 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        NSLog(@"数据 添加 [%@]", isSuccess ? @"成功" : @"失败");
    }];
    
    return isSuccess;
}


- (BOOL)replace4Table:(NSString *)name
              columns:(NSString *)columns
               values:(NSString *)values {
    __block BOOL isSuccess = NO;
    
    if (name.length == 0 || columns.length == 0 || values.length == 0) {
        NSLog(@"参数为空...");
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)", name, columns, values];
        
        NSLog(@"SQL ===== %@", sql);
        isSuccess = [db2 executeUpdate:sql];
        
        if ([db2 hadError])
        {
            NSLog(@"数据库添加 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        NSLog(@"数据 添加 [%@]", isSuccess ? @"成功" : @"失败");
    }];
    return isSuccess;
}


- (BOOL)replace4Table:(NSString *)name
                  dic:(NSDictionary *)dic {
    __block BOOL isSuccess = NO;
    
    if (name.length == 0 ||  dic.count == 0) {
        NSLog(@"参数为空...");
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        NSArray *columnArray = [dic allKeys];
        NSString *columns = [columnArray componentsJoinedByString:@","];
        
        NSArray *valueArray = [dic allValues];
        NSString *values = [valueArray componentsJoinedByString:@","];
        
        NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)", name, columns, values];
        
        NSLog(@"SQL ===== %@", sql);
        isSuccess = [db2 executeUpdate:sql];
        
        if ([db2 hadError])
        {
            NSLog(@"更新数据库 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        NSLog(@"数据 更新 [%@]", isSuccess ? @"成功" : @"失败");
    }];
    
    
    return isSuccess;
}


- (BOOL)delete4Table:(NSString *)name
            withArgs:(NSString *)where {
    __block BOOL isSuccess = NO;
    
    if (name.length == 0) {
        NSLog(@"参数为空...");
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        NSString *sql = @"";
        if (where.length != 0) {
            sql = [NSString stringWithFormat:@"DELETE FROM [%@] WHERE %@", name, where];
        } else {
            sql = [NSString stringWithFormat:@"DELETE FROM %@", name];
        }
        
        NSLog(@"SQL ===== %@", sql);
        isSuccess = [db2 executeUpdate:sql];
        
        if ([db2 hadError]) {
            NSLog(@"数据库删除 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        NSLog(@"数据 删除 [%@]", isSuccess ? @"成功" : @"失败");
    }];
    
    return isSuccess;
}

- (BOOL)update4Table:(NSString *)name
            withArgs:(NSString *)args
               where:(NSString *)where {
    __block BOOL isSuccess = NO;
    
    if (name.length == 0 || args.length == 0) {
        NSLog(@"参数为空...");
        return isSuccess;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE [%@] SET %@", name, args];
        
        if (where.length > 0) {
            [sql appendFormat:@" WHERE %@ ", where];
        }
        
        NSLog(@"SQL ===== %@", sql);
        isSuccess = [db2 executeUpdate:sql];
        if ([db2 hadError]) {
            NSLog(@"数据库更新 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        NSLog(@"数据 更新 [%@]", isSuccess ? @"成功" : @"失败");
    }];
    
    return isSuccess;
}

- (NSMutableArray *)query4Table:(NSString *)name
                           args:(NSString *)where
                          order:(NSString *)order
                        columns:(NSString *)columns {
    
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    
    if (name.length == 0) {
        NSLog(@"参数为空...");
        return array;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        NSMutableString *column = [NSMutableString stringWithCapacity:1];
        
        if (columns.length == 0) {
            [column appendString:@"*"];
        } else {
            [column appendString:columns];
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ ",column, name];
        
        if (where.length > 0) {
            [sql appendFormat:@" WHERE %@ ",where];
        }
        
        if (order.length > 0) {
            [sql appendFormat:@" ORDER BY %@ ", order];
        }
        
        NSLog(@"SQL ===== %@", sql);
        FMResultSet *rs = [db2 executeQuery:sql];
        if ([db2 hadError]) {
            array = nil;
            NSLog(@"数据库查询 错误 %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        while ([rs next]) {
            NSDictionary *dic = [rs resultDictionary];
            [array addObject:dic];
        }
        [rs close];
    }];
    
    return array;
}

/*
 * 查询表中元素的个数 ElementCount
 * 查询数据 用完此方法记得对 FMResultSet 进行 close
 * @param name 表名 TableName
 */
- (NSInteger)query4TableElementCount:(NSString *)name {
    
    __block NSInteger allCount = 0;
    
    if (name.length == 0) {
        NSLog(@"参数为空...");
        return allCount;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        
        NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) from %@" ,name];
        FMResultSet *rs = [db2 executeQuery:sql];
        if ([db2 hadError]) {
            NSLog(@"Err %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        if ([rs next]) {
            allCount = [rs intForColumnIndex:0];
        }
        [rs close];
        NSLog(@"allCount ==== %ld", (long)allCount);
        
    }];
    
    return allCount;
}

//  分组
- (NSMutableArray *)query4Table:(NSString *)name
                           args:(NSString *)where
                          order:(NSString *)order
                        columns:(NSString *)columns
                         groups:(NSString *)groups {
    
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    if (name.length == 0) {
        NSLog(@"参数为空...");
        return array;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db2) {
        
        NSMutableString *column = [NSMutableString stringWithCapacity:1];
        
        if (columns.length == 0) {
            [column appendString:@"*"];
        } else {
            [column appendString:columns];
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"SELECT %@ FROM %@ ",column, name];
        
        if (where.length > 0) {
            [sql appendFormat:@" WHERE %@ ",where];
        }
        
        if (groups.length > 0) {
            [sql appendFormat:@" GROUP BY %@ ", groups];
        }
        
        if (order.length > 0) {
            [sql appendFormat:@" ORDER BY %@ ", order];
        }
        
        FMResultSet *rs = [db2 executeQuery:sql];
        if ([db2 hadError]) {
            NSLog(@"Err %d: %@", [db2 lastErrorCode], [db2 lastErrorMessage]);
        }
        
        while([rs next]) {
            NSDictionary *dic = [rs resultDictionary];
            [array addObject:dic];
        }
        
        [rs close];
        
    }];
    
    return array;
}


@end
