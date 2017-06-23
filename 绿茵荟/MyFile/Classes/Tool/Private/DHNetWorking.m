//
//  DHNetWorking.m
//  绿茵荟
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "DHNetWorking.h"
#import "AFNetworking.h"
static id instance;
@implementation DHNetWorking
+(instancetype)sharedDHNetWorking{
    if (!instance) {
        instance = [[self alloc]init];
    }
    return instance;
}
+(instancetype)alloc{
    if (!instance) {
        instance = [[super alloc]init];
    }
    return instance;
}
-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)getNumberOfShoppingCartCallback:(void (^)(NSDictionary *))back_block{
    NSString * interfaceName = @"/shop/cart/getCount.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    NSDictionary * sendDic = nil;
    if (memberId) {
        sendDic = @{@"memberId":memberId};
        [self getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
            NSInteger number = [back_dic[@"count"] longValue];
            NSDictionary * dic = @{@"count":[NSString stringWithFormat:@"%ld",number]};
            back_block(dic);
        } andFailure:^(NSError *error_failure) {
            NSDictionary * dic = @{@"count":@"0"};
            back_block(dic);
        }];
    }else{
        NSDictionary * dic = @{@"count":@"0"};
        back_block(dic);
    }
    
    
}
// 字典转json字符串方法

-(NSString *)getJsonWithDictionary:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

-(void)getWithInterfaceName:(NSString *)interfaceName andDictionary:(NSDictionary *)send_dic andSuccess:(void (^)(NSDictionary * back_dic))back_block{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",SERVER_URL,interfaceName];
    [manager GET:urlString parameters:send_dic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        if (![[responseObject valueForKey:@"code"] boolValue]) {
            [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"] duration:1];
        }else{
            back_block(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSMutableDictionary * call = [NSMutableDictionary new];
//        if (interfaceName) {
//            [call setValue:interfaceName forKey:@"interface"];
//        }
//        if (send_dic) {
//            [call setValue:[self getJsonWithDictionary:send_dic] forKey:@"send"];
//        }
//        if (error) {
//            [call setValue:[NSString stringWithFormat:@"%@",error] forKey:@"error"];
//        }
//        if (MEMBERID) {
//            [call setValue:MEMBERID forKey:@"memberId"];
//        }
//        [self netCallBack:call];
        
        [SVProgressHUD showErrorWithStatus:@"网络出错" duration:2];
    }];
}
-(void)getWithInterfaceName:(NSString *)interfaceName andDictionary:(NSDictionary *)send_dic andSuccess:(void (^)(NSDictionary * back_dic))back_block andFailure:(void(^)(NSError * error_failure)) failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",SERVER_URL,interfaceName];
    [manager GET:urlString parameters:send_dic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        if (![[responseObject valueForKey:@"code"] boolValue]) {
            [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"] duration:2];
        }else{
            back_block(responseObject);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(error);
//        NSLog(@"error:%@",error);
        [SVProgressHUD showErrorWithStatus:@"网络出错" duration:2];
    }];
}
-(void)getNoPopWithInterfaceName:(NSString *)interfaceName andDictionary:(NSDictionary *)send_dic andSuccess:(void (^)(NSDictionary * back_dic))back_block{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",SERVER_URL,interfaceName];
    [manager GET:urlString parameters:send_dic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (![[responseObject valueForKey:@"code"] boolValue]) {
            [SVProgressHUD showErrorWithStatus:[responseObject valueForKey:@"msg"] duration:1];
        }else{
            back_block(responseObject);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络出错" duration:2];
    }];
}
-(void)getDataWithErroeWithInterfaceName:(NSString *)interfaceName andDictionary:(NSDictionary *)send_dic andSuccess:(void (^)(NSDictionary * back_dic))back_block{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",SERVER_URL,interfaceName];
    [manager GET:urlString parameters:send_dic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        back_block(responseObject);
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"网络出错" duration:2];
    }];
}
//网络错误回调
-(void)netCallBack:(NSDictionary *)send{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    NSString * urlString = @"http://222.190.120.106:8099/health_center/callback.app";
    [manager GET:urlString parameters:send progress:nil success:^(NSURLSessionTask *task, id responseObject) {
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
    }];
}

@end
