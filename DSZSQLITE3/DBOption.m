//
//  DBOption.m
//  addresslist
//
//  Created by 庄 严 on 14-8-5.
//  Copyright (c) 2014年 浙江省旅游信息中心. All rights reserved.
//

#import "DBOption.h"

@implementation DBOption

- (void)dealloc
{
    sqlite3_close(_db);
    _db = nil;
}

-(BOOL)OpenDB
{
    BOOL success = NO;
    if(sqlite3_open([self.dbfileName UTF8String], &_db) == SQLITE_OK)
    {
        success = YES;
    }
    else
    {
        success = NO;
    }
    return success;
}

@end
