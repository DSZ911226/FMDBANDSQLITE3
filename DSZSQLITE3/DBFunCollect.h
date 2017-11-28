//
//  DBFunCollect.h
//  TXL
//
//  Created by Alonezzz on 2017/4/14.
//  Copyright © 2017年 浙江智旅信息有限公司. All rights reserved.
//

#import "DBOption.h"




@interface DBFunCollect : DBOption
@property(nonatomic,assign)BOOL isFirst;

//areacode 数据库
-(NSMutableArray *)selectedTime:(NSString *)sql;
@end
