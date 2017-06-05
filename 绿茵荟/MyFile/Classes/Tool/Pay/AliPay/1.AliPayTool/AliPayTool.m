//
//  AliPayTool.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/4.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "AliPayTool.h"
#import "Order.h"
#import "RSADataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
@implementation AliPayTool



//支付
-(void)aliPayWithGoodsDictionary:(NSDictionary*)goodsDictionary{
//    NSLog(@"需要支付的商品信息:%@",goodsDictionary);
    NSInteger orderId = [goodsDictionary[@"orderId"] longValue];
    
    NSString * appID = APPID_ALIPAY;
    NSString * rsa2PrivateKey = RSA2_PRIMARY_KEY_ALIPAY;
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    // NOTE: app_id设置
    order.app_id = appID;
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    // NOTE: 支付版本
    order.version = @"1.0";
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = @"RSA2";
    
    //后台回调
    order.notify_url = [NSString stringWithFormat:@"%@%@",SERVER_URL,@"/shop/order/notifyAlipay.intf"];
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    NSString * body = goodsDictionary[@"goodsList"][0][@"goodsName"];
    NSString * subject = goodsDictionary[@"goodsList"][0][@"productName"];
//    NSLog(@"body:%@",body);
//    NSLog(@"subject:%@",subject);
//    NSLog(@"orderId:%ld",orderId);
    order.biz_content.body = body;
    order.biz_content.subject = subject;
    order.biz_content.out_trade_no = [NSString stringWithFormat:@"%ld",orderId]; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", [goodsDictionary[@"totalPrice"] floatValue]]; //商品价格
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
//    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:rsa2PrivateKey];
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:orderInfo withRSA2:YES];
    } else {
        signedString = [signer signString:orderInfo withRSA2:NO];
    }
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"alipayurlschemes";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    
    
    
    
}

@end
