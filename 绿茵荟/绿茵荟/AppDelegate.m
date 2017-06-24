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
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#import "MyOrderVC.h"
#import "GoodsInfoViewController.h"
#import "PostInfoViewController.h"
#import <PgySDK/PgyManager.h>
#import <PgyUpdate/PgyUpdateManager.h>
#import "CheckUpdateVC.h"
// iOS10注册APNs所需头 件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max 
#import <UserNotifications/UserNotifications.h>
#endif

#define USHARE_DEMO_APPKEY @"591c60d2f5ade451b100046b"

static NSString *appKey = @"19286ff90c8abb86842087a2";
static NSString *channel = @"62b8468f1f54251e179cf0fa";
static BOOL isProduction = true;

@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CheckUpdateVC * update = [CheckUpdateVC new];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = update;
    [self.window makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [NSThread sleepForTimeInterval:1];
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
    
    //极光推送注册
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加 定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel apsForProduction:isProduction];
    if (launchOptions) {
        NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //这个判断是在程序没有运行的情况下收到通知，点击通知跳转页面
        if (remoteNotification) {
//            NSLog(@"推送消息==== %@",remoteNotification);
//            [self goToMssageViewControllerWith:remoteNotification];
        }
    }
    UIApplication *app = [UIApplication sharedApplication];
    
    // 应用程序右上角数字
    app.applicationIconBadgeNumber = 0;
    
    
    //蒲公英
    //启动基本SDK
    [[PgyManager sharedPgyManager] startManagerWithAppId:@"5f7de76ffc45dc469fa27a5d81a6ce54"];
    //启动更新检查SDK
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"5f7de76ffc45dc469fa27a5d81a6ce54"];
    
    
    return YES;
}
-(void)goToMssageViewControllerWith:(NSDictionary *)remoteNotification{
    NSArray * receiveArray = (NSArray *)[MYTOOL getDictionaryWithJsonString:remoteNotification[@"ExtraData"]];
    NSDictionary * receiveDic = receiveArray[0];
    int contentType = [receiveDic[@"contentType"] intValue];
    NSString * contentId = receiveDic[@"contentId"];
    if (contentId == nil || contentId.length == 0) {
        return;
    }
    if (contentType == 1) {//商品
        //网络获取商品详情
        NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
        NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
        if (cityId == nil ) {
            cityId = @"320300";
        }
        NSDictionary * sendDict = @{
                                    @"goodsId":contentId,
                                    @"cityId":cityId
                                    };
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
            GoodsInfoViewController * info = [GoodsInfoViewController new];
            info.goodsInfoDictionary = back_dic[@"goods"];
            MainVC * main = (MainVC *)self.window.rootViewController;
            main.selectedIndex = 2;
            UINavigationController * nc = main.childViewControllers[2];
            [nc pushViewController:info animated:true];
        }];
    }else if (contentType == 2) {//帖子
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
        if (memberId) {
            [send_dic setValue:memberId forKey:@"memberId"];
        }
        [send_dic setValue:contentId forKey:@"postId"];
        
        
        //开始请求
        [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
        [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            bool flag = [back_dic[@"code"] boolValue];
            if (flag) {
                [SVProgressHUD dismiss];
                PostInfoViewController * postVC = [PostInfoViewController new];
                postVC.title = @"帖子详情";
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
                postVC.post_dic = dict;
                MainVC * main = (MainVC *)self.window.rootViewController;
                main.selectedIndex = 1;
                UINavigationController * nc = main.childViewControllers[1];
                [nc pushViewController:postVC animated:true];
            }else{
                [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
            }
        }];
    }
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_APP_ENTER_FOREGROUND object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_APP_BECOME_ACTIVE object:nil userInfo:nil];
    
    
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
                    [self paySuccess];
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
//支付成功后
-(void)paySuccess{
    [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_SUCCESS object:nil];
    MainVC * main = (MainVC *)self.window.rootViewController;
    main.selectedIndex = 3;
    
    UINavigationController * nc = main.childViewControllers[3];
    [nc popToRootViewControllerAnimated:true];
    MyOrderVC * order = [MyOrderVC new];
    order.title = @"我的订单";
    [nc pushViewController:order animated:true];
    
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
                    [self paySuccess];
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
                [self paySuccess];
                break;
            }
            case WXErrCodeUserCancel: {
                
                //                NSLog(@"用户取消支付");
                
                //...支付取消相应的处理
                [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_PAY_CANCEL object:nil];
//                MainVC * main = (MainVC *)self.window.rootViewController;
//                [main.selectedViewController.navigationController popToRootViewControllerAnimated:true];
//                main.selectedIndex = 3;
//                [SVProgressHUD showErrorWithStatus:@"支付取消\n请从我的订单查看" duration:2];
                break;
            }
            default: {
                
                //                NSLog(@"支付失败");
                [self paySuccess];
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
#pragma mark- JPUSHRegisterDelegate
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]
        ]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执 这个 法,选择 是否提醒 户,有Badge、Sound、Alert三种类型可以选择设置
}
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    [self goToMssageViewControllerWith:userInfo];
    completionHandler(); // 系统要求执 这个 法
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    if (application.applicationState == UIApplicationStateActive) {
        //这里写APP正在运行时，推送过来消息的处理
        [self goToMssageViewControllerWith:userInfo];
    } else if (application.applicationState == UIApplicationStateInactive ) {
        //APP在后台运行，推送过来消息的处理
        [self goToMssageViewControllerWith:userInfo];
    } else if (application.applicationState == UIApplicationStateBackground) {
        //APP没有运行，推送过来消息的处理
        [self goToMssageViewControllerWith:userInfo];
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}
@end
