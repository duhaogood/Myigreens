//
//  DHNetWorking.h
//  绿茵荟
//
//  Created by Mac on 17/3/28.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHNetWorking : NSObject
/**
 *  获取单例网络工具类对象
 *
 *  @return 工具对象
 */
+(instancetype)sharedDHNetWorking;



-(void)getWithInterfaceName:(NSString *)interfaceName andDictionary:(NSDictionary *)send_dic andSuccess:(void(^)(NSDictionary * back_dic)) back_block;

-(void)getWithInterfaceName:(NSString *)interfaceName andDictionary:(NSDictionary *)send_dic andSuccess:(void (^)(NSDictionary * back_dic))back_block andFailure:(void(^)(NSError * error_failure)) failure;

/**
 获取用户购物车商品数量

 @param back_block @{@"count":@"0"}
 */
-(void)getNumberOfShoppingCartCallback:(void (^)(NSDictionary * backDict))back_block;

@end
