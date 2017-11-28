//
//  DBFunCollect.m
//  TXL
//
//  Created by Alonezzz on 2017/4/14.
//  Copyright © 2017年 浙江智旅信息有限公司. All rights reserved.
//

#import "DBFunCollect.h"

@implementation DBFunCollect


-(id)init
{
    if (self = [super init])
    {
        self.dbfileName = [NSString stringWithFormat:@"%@", [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingString:@"/155.sqlite"]];
        
    }
    return self;
}


- (NSMutableArray *)selectedTime:(NSString *)sql {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ([self OpenDB])
    {
        const char *sqlStatement =[sql cStringUsingEncoding:NSUTF8StringEncoding];
        sqlite3_stmt *statement = nil;
        
        if(sqlite3_prepare_v2(self.db, sqlStatement, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *str = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                [array addObject:str];
            }
        }else{
            NSLog(@"error");
            
        }
        sqlite3_finalize(statement);
    }
    return  array;
}



@end


