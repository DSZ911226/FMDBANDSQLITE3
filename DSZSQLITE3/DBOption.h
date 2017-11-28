//
//  TXLDBOperate.h
//  addresslist
//
//  Created by 庄 严 on 14-8-5.
//  Copyright (c) 2014年 浙江省旅游信息中心. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DBOption : NSObject

-(BOOL)OpenDB;

@property (nonatomic) sqlite3 *db;
@property (nonatomic,copy) NSString *dbfileName;


@end
