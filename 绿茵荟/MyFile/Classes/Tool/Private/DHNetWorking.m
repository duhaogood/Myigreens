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
        [SVProgressHUD showErrorWithStatus:@"网络出错" duration:2];
//        NSLog(@"Error: %@", error);
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




@end
