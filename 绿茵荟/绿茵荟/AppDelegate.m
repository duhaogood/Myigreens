//
//  AppDelegate.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/22.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "AppDelegate.h"
#import "MainVC.h"
#import "StartViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import <UMSocialCore/UMSocialCore.h>

#define USHARE_DEMO_APPKEY @"591c60d2f5ade451b100046b"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MainVC * main = [MainVC new];
    StartViewController * start = [StartViewController new];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    if ([self isFirstStarThisApp]) {
        self.window.rootViewController = start;
    }else{
        self.window.rootViewController = main;
    }
    
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [NSThread sleepForTimeInterval:1];
    [main preferredStatusBarStyle];
    //    NSLog(@"memberId:%@",[MYTOOL getProjectPropertyWithKey:@"memberId"]);
    
    if (!SERVER_URL) {
//        [MYTOOL setProjectPropertyWithKey:@"server_url" andValue:@"http://myigreens.yemast.com:8081/api"];//正式
        [MYTOOL setProjectPropertyWithKey:@"server_url" andValue:@"http://yemast.com:8180/api"];//测试
    }
    //wxc3b31ac5cd6d9d5d
    //微信注册
    [WXApi registerApp:@"wxc3b31ac5cd6d9d5d" enableMTA:YES];//注册微信
    //    NSLog(@"启动");
    [[UMSocialManager defaultManager] openLog:YES];
    // 打开图片水印
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    [UMSocialGlobal shareInstance].isClearCacheWhenGetUserInfo = NO;
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_DEMO_APPKEY];
    
    [self configUSharePlatforms];
    
    return YES;
}
/**
 是不是第一次进入app
 
 @return 是否是第一次进入app
 */
-(BOOL)isFirstStarThisApp{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstStarThisApp"];
    
    return ![value boolValue];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
        if(url != nil && [[url host] isEqualToString:@"pay"]){//微信支付
            //        NSLog(@"微信支付");
            
            
            return [WXApi handleOpenURL:url delegate:self];
        }
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                //            NSLog(@"result = %@",resultDic);
                int resultStatus = [resultDic[@"resultStatus"] intValue];
                if (resultStatus == 9000) {
                    [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
                    MainVC * main = (MainVC *)self.window.rootViewController;
                    [main.selectedViewController.navigationController popToRootViewControllerAnimated:true];
                    main.selectedIndex = 3;
                }
            }];
            
            // 授权跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                // 解析 auth code
                NSString *result = resultDic[@"result"];
                NSString *authCode = nil;
                if (result.length>0) {
                    NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                    for (NSString *subResult in resultArr) {
                        if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                            authCode = [subResult substringFromIndex:10];
                            break;
                        }
                    }
                }
                NSLog(@"授权结果 authCode = %@", authCode?:@"");
            }];
        }
    }
    if ([url.host isEqualToString:@"Myigreens"]) {
        [self receiveWebRequestWithUrl:url];
    }
    return result;
    
}
#pragma mark - 第三方的跳转
//实现分享跳转页面
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"1url = %@   [url host] = %@",url,[url host]);
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        if(url != nil && [[url host] isEqualToString:@"pay"]){
            //微信支付
            NSLog(@"微信支付");
            return [WXApi handleOpenURL:url delegate:self];
        }
        else{
            //其他
            return YES;
        }
    }
    return result;
    
}
// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
    if (!result) {
        // 其他如支付等SDK的回调
        if(url != nil && [[url host] isEqualToString:@"pay"]){
            //微信支付
            return [WXApi handleOpenURL:url delegate:self];
        }
        if ([url.host isEqualToString:@"safepay"]) {
            // 支付跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result1 = %@",resultDic);
                int resultStatus = [resultDic[@"resultStatus"] intValue];
                if (resultStatus == 9000) {
                    [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
                    MainVC * main = (MainVC *)self.window.rootViewController;
                    [main.selectedViewController.navigationController popToRootViewControllerAnimated:true];
                    main.selectedIndex = 3;
                }
            }];
            
            // 授权跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
                //            NSLog(@"result2 = %@",resultDic);
                // 解析 auth code
                NSString *result = resultDic[@"result"];
                NSString *authCode = nil;
                if (result.length>0) {
                    NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                    for (NSString *subResult in resultArr) {
                        if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                            authCode = [subResult substringFromIndex:10];
                            break;
                        }
                    }
                }
                NSLog(@"授权结果 authCode = %@", authCode?:@"");
            }];
        }
        if ([url.host isEqualToString:@"Myigreens"]) {
            [self receiveWebRequestWithUrl:url];
        }
    }
    return result;
}
//收到web端的请求
-(void)receiveWebRequestWithUrl:(NSURL *)url{
    NSLog(@"url:%@",url);
}
//收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
- (void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[PayResp class]])
    {
        PayResp *response = (PayResp *)resp;
        
        //        NSLog(@"支付结果 %d===%@",response.errCode,response.errStr);
        
        switch (response.errCode) {
            case WXSuccess: {
                
                NSLog(@"支付成功");
                
                //...支付成功相应的处理，跳转界面等
                [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
                MainVC * main = (MainVC *)self.window.rootViewController;
                [main.selectedViewController.navigationController popToRootViewControllerAnimated:true];
                main.selectedIndex = 3;
                [SVProgressHUD showSuccessWithStatus:@"支付成功" duration:1];
                break;
            }
            case WXErrCodeUserCancel: {
                
                //                NSLog(@"用户取消支付");
                
                //...支付取消相应的处理
                [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
                MainVC * main = (MainVC *)self.window.rootViewController;
                [main.selectedViewController.navigationController popToRootViewControllerAnimated:true];
                main.selectedIndex = 3;
                [SVProgressHUD showErrorWithStatus:@"支付取消\n请从我的订单查看" duration:2];
                break;
            }
            default: {
                
                //                NSLog(@"支付失败");
                [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
                MainVC * main = (MainVC *)self.window.rootViewController;
                [main.selectedViewController.navigationController popToRootViewControllerAnimated:true];
                main.selectedIndex = 3;
                [SVProgressHUD showErrorWithStatus:@"支付失败\n请从我的订单查看" duration:2];
                //...做相应的处理，重新支付或删除支付
                
                break;
            }
        }
    }
    
}
- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxc3b31ac5cd6d9d5d" appSecret:@"49b4ea8503959c91daa7d26b88f02caf" redirectURL:@""];
    
    /* 设置分享到QQ互联的appID  - 未申请*/
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"101398535"/*设置QQ平台的appID*/  appSecret:@"c743dd692f0c004e9cfe0bbbf08ffeea" redirectURL:@""];
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1539877462"  appSecret:@"f0b045862b7e857439e600c28f689c23" redirectURL:@""];
    
}
@end
