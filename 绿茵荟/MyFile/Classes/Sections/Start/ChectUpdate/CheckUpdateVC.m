//
//  CheckUpdateVC.m
//  绿茵荟
//
//  Created by mac on 2017/6/24.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "CheckUpdateVC.h"
#import "MainVC.h"
#import "StartViewController.h"
#import "AFNetworking.h"
@interface CheckUpdateVC ()

@end


#define MY_APP_ID @"1238065310"//应用对应appid-开票:1178537125====绿茵荟-1238065310
@implementation CheckUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    UIImageView * imgV = [UIImageView new];
    imgV.frame = self.view.bounds;
    [self.view addSubview:imgV];
    imgV.image = [UIImage imageNamed:@"LaunchImg"];
    [self getStoreVersion];
}
//获取商店版本号
-(void)getStoreVersion{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/javascript", nil];
    NSString * urlString = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",MY_APP_ID];
    [manager POST:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        int resultCount = [responseObject[@"resultCount"] intValue];
        if (resultCount == 0) {
            [self goNextVC];
            return;
        }
        NSDictionary * result = responseObject[@"results"][0];
        //更新内容
        NSString * releaseNotes = result[@"releaseNotes"];
        //版本号
        NSString * version = result[@"version"];
        if (!version) {
            [self goNextVC];
            return;
        }
        if (!releaseNotes) {
            [self goNextVC];
            return;
        }
        NSDictionary * storeVersion = @{
                                        @"version":version,
                                        @"releaseNotes":releaseNotes
                                        };
        [self compareVersionAndStoreVersionWithDictionary:storeVersion];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [self goNextVC];
    }];
}
//解析商店返回的信息
-(void)compareVersionAndStoreVersionWithDictionary:(NSDictionary *)storeDictionary{
    //更新内容
    NSString * releaseNotes = storeDictionary[@"releaseNotes"];
    //商店版本号
    NSString * storeVersion = storeDictionary[@"version"];
    NSLog(@"商店版本:%@",storeVersion);
    NSLog(@"更新内容:%@",releaseNotes);
    //分割版本号
    NSArray * storeVersionArray = [storeVersion componentsSeparatedByString:@"."];
    if (storeVersionArray.count == 0) {
        [self goNextVC];
        return;
    }
    //版本号
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray * appVersionArray = [appVersion componentsSeparatedByString:@"."];
    /*强制更新*/
    {
        //商店版本号第一个数字
        int storeVersionFirstNum = [storeVersionArray[0] intValue];
        //程序版本号第一个数字
        int appVersionFirstNum = [appVersionArray[0] intValue];
        
        if (storeVersionFirstNum > appVersionFirstNum) {
            //强制更新
            [self mustUpdateWithNote:releaseNotes];
            return;
        }
    }
    /*建议更新-比对第二个数字*/
    {
        //商店版本号第二个数字
        int storeVersionSecondNum = [storeVersionArray[1] intValue];
        //程序版本号第二个数字
        int appVersionSecondNum = [appVersionArray[1] intValue];
        if (storeVersionSecondNum > appVersionSecondNum) {
            //提示更新
            [self proposeUpdateWithNote:releaseNotes];
            return;
        }
    }
    /*建议更新-比对第三个数字*/
    {
        if (storeVersionArray.count < 3 || appVersionArray.count < 3) {
            [self goNextVC];
            return;
        }
        //商店版本号第三个数字
        int storeVersionThirdNum = [storeVersionArray[2] intValue];
        //程序版本号第三个数字
        int appVersionThirdNum = [appVersionArray[2] intValue];
        if (storeVersionThirdNum > appVersionThirdNum) {
            //提示更新
            [self proposeUpdateWithNote:releaseNotes];
            return;
        }
    }
}
//强制更新
-(void)mustUpdateWithNote:(NSString *)releaseNotes{
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"检测到有新版本" message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * urlString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8",MY_APP_ID];
        NSURL * url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }];
    [ac addAction:sure];
    [self presentViewController:ac animated:true completion:nil];
}
//提示更新
-(void)proposeUpdateWithNote:(NSString *)releaseNotes{
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"检测到有新版本" message:releaseNotes preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * sure = [UIAlertAction actionWithTitle:@"升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * urlString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%@?mt=8",MY_APP_ID];
        NSURL * url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self goNextVC];
    }];
    [ac addAction:sure];
    [ac addAction:cancel];
    [self presentViewController:ac animated:true completion:nil];
}
//不用更新
-(void)goNextVC{
    MainVC * main = [MainVC new];
    [main preferredStatusBarStyle];
    StartViewController * start = [StartViewController new];
    AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([self isFirstStarThisApp]) {
        delegate.window.rootViewController = start;
    }else{
        delegate.window.rootViewController = main;
    }
}
/**
 是不是第一次进入app
 
 @return 是否是第一次进入app
 */
-(BOOL)isFirstStarThisApp{
    NSString * value = [[NSUserDefaults standardUserDefaults] valueForKey:@"isFirstStarThisApp"];
    
    return ![value boolValue];
}
//程序进入前台

-(void)viewWillAppear:(BOOL)animated{
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(getStoreVersion) name:NOTIFICATION_APP_ENTER_FOREGROUND object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_APP_ENTER_FOREGROUND object:nil];
}
@end
