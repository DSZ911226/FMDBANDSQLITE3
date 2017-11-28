//
//  ViewController.m
//  DSZSQLITE3
//
//  Created by zhilvmac on 2017/11/28.
//  Copyright © 2017年 zjwist. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import "DSZDBHelper.h"
#import "DBFunCollect.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self getNetWork];//下载库
//    [self fmdbTest];//数据库测试  --fmdb
    [self dbTest];//数据库测试
}
-(void)getNetWork{
    NSInteger state = 0;
    NSString *filepath = [NSString stringWithFormat:@"%@/%@.sqlite", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0],@"155"];
    NSLog(@"%@",filepath);
    NSString *url = @"https://y1api.4yankj.cn/LSSet/SyncDataDB";
    //    NSString *url = @"https://y1api.4yankj.cn/home/test";
    switch (state) {
        case 0:
        {
            AFHTTPSessionManager *managerA = [AFHTTPSessionManager manager];
            managerA.responseSerializer = [AFHTTPResponseSerializer serializer];
            managerA.requestSerializer = [AFHTTPRequestSerializer serializer];
            managerA.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/octet-stream",@"application/stream", nil];
            [self addHeader:managerA];
            [managerA GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSData *data = responseObject;
                [data writeToFile:filepath atomically:YES];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"f");
            }];
        }
            break;
        case 1:
        {
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            [self addHeader:manager];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            
            NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                return [NSURL fileURLWithPath:filepath];
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                NSLog(@"%@",filepath);
            }];
            [download resume];
        }
            break;
        case 2:
        {
            AFHTTPSessionManager *managerA = [AFHTTPSessionManager manager];
            [self addHeader:managerA];
            [managerA GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"s");
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"f");
            }];
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
        default:
            break;
    }
}
- (void)addHeader:(AFHTTPSessionManager *)managerD {
    NSDictionary *headerFieldValueDictionary = @{@"authorization":@"e497be13-23d2-4250-8ff1-57d3e057bb27",@"lsVersion":[NSString stringWithFormat:@"IOS_%@",[[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"]]};
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [managerD.requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
}


- (void)fmdbTest {
    NSMutableArray *array = [[DSZDBHelper shareInstance] query4Table:@"synctime" args:nil order:nil columns:@"lasttime"];
    NSLog(@"%@",array);
    
}


- (void)dbTest {
    DBFunCollect *db = [DBFunCollect new];
    NSMutableArray *arr = [db selectedTime:@"select * from synctime"];
    NSLog(@"%@",arr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
