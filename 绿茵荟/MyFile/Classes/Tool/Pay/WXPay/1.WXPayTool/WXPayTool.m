//
//  WXPayTool.m
//  绿茵荟
//
//  Created by Mac on 17/5/12.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "WXPayTool.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "lhSharePay.h"
@implementation WXPayTool

//支付
-(void)wxPayWithGoodsDictionary:(NSDictionary*)goodsDictionary{
    
    //payDic和orderDic请求实例
    NSDictionary * payDic = @{
                              @"api_key":@"jiangsuxuzhoulvyinyuanyilvyinhui",
                              @"app_id":@"wxc3b31ac5cd6d9d5d",
                              @"app_secret":@"49b4ea8503959c91daa7d26b88f02caf",
                              @"mch_id":@"1468640402",
                              @"notify_url":[NSString stringWithFormat:@"%@%@",SERVER_URL,@"/shop/order/returnPayStatus.intf"]
                              };
    NSString * price = goodsDictionary[@"totalPrice"];
    price = [NSString stringWithFormat:@"%.2f",price.doubleValue*100];
    NSString * subject = goodsDictionary[@"goodsList"][0][@"goodsName"];
    if ([goodsDictionary[@"goodsList"] count] > 1) {
        subject = [NSString stringWithFormat:@"%@……等",subject];
    }
    NSDictionary * orderDic = @{
                                @"enable":@"1",
                                @"id":@"df2b38795ccd40cea71c2e859aec7e5c",
                                @"money":price,
                                @"orderCode":goodsDictionary[@"orderId"],
                                @"rechargeRule_id":@"1",
                                @"remark":@"",
                                @"status":@"",
                                @"successTime":@"",
                                @"time":@"1436766784625",
                                @"users_id":@"a38d4da064054e99840efdd91280ee35",
                                @"way":@"2",
                                @"productName":subject,
                                @"productDescription":subject};
    
    //下单成功，调用微信支付
    [[lhSharePay sharePay]wxPayWithPayDic:payDic OrderDic:orderDic];
}




@end
