//
//  AccountTieViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "AccountTieViewController.h"
#import <UMSocialCore/UMSocialCore.h>
@interface AccountTieViewController ()
@property(nonatomic,strong)NSMutableDictionary * title_swich_dictionary;//标题和开关
@end

@implementation AccountTieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.member_dic = DHTOOL.memberDic;
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //背景视图
    UIView * back_view = [UIView new];
    back_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:10 andWidth:375 andHeight:175];
    back_view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:back_view];
    //分割线
    float height = back_view.frame.size.height;
    for (int i = 0; i < 2; i ++) {
        UIView * space_view = [UIView new];
        space_view.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
        space_view.frame = CGRectMake(10, height/3 * (i + 1)-1, WIDTH-20, 1);
        [back_view addSubview:space_view];
    }
    //文字 & switch按钮
    NSArray * title_array = @[@"新浪微博",@"微信",@"QQ"];
    self.title_swich_dictionary = [NSMutableDictionary new];
    for (int i = 0; i < title_array.count; i ++) {
        //文字
        UILabel * title_label = [UILabel new];
        title_label.frame = CGRectMake(10, height/6 + height / 3 * i - 9, WIDTH/3, 18);
        title_label.text = title_array[i];
        [back_view addSubview:title_label];
        //按钮
        UISwitch * btn = [UISwitch new];
        btn.frame = CGRectMake(WIDTH - 70, height/6 + height / 3 * i - 15.5, 53, 31);
        btn.on = false;
        [btn addTarget:self action:@selector(swichBtn_callBack:) forControlEvents:UIControlEventValueChanged];
        [back_view addSubview:btn];
        [self.title_swich_dictionary setObject:btn forKey:title_array[i]];
    }
    
    
}
//swich开关回调
-(void)swichBtn_callBack:(UISwitch *)btn{
    for (NSString * key in self.title_swich_dictionary.allKeys) {
        UISwitch * s_btn = self.title_swich_dictionary[key];
        if ([s_btn isEqual:btn]) {
            NSLog(@"点击:%@,目前状态:%d",key,btn.on);
            if (btn.on) {
                [self startTieWithTitle:key];
            }else{
                [self cancelTieWithTitle:key];
            }
            return;
        }
    }
}
//第三方绑定
-(void)startTieWithTitle:(NSString *)title{
    //@"新浪微博",@"微信",@"QQ"
    if ([title isEqualToString:@"新浪微博"]) {
        [self getAuthWithUserInfoFromSina];
    }else if ([title isEqualToString:@"微信"]) {
        [self getAuthWithUserInfoFromWechat];
    }else {
        [self getAuthWithUserInfoFromQQ];
    }
    NSString * interface = @"/member/bindThirdApp.intf";
}
//取消绑定
-(void)cancelTieWithTitle:(NSString *)title{
    //@"新浪微博",@"微信",@"QQ"
    NSString * interface = @"/member/cancelBind.intf";
    
    NSDictionary * send = @{
                            @"memberId":MEMBERID,
                            @"app":@"",
                            @"terminal":@"ios"
                            };
    
    
}
//微博授权
- (void)getAuthWithUserInfoFromSina{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_Sina currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            UISwitch * btn =  self.title_swich_dictionary[@"新浪微博"];
            btn.on = false;
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"Sina uid: %@", resp.uid);
            NSLog(@"Sina accessToken: %@", resp.accessToken);
            NSLog(@"Sina refreshToken: %@", resp.refreshToken);
            NSLog(@"Sina expiration: %@", resp.expiration);
            
            // 用户信息
            NSLog(@"Sina name: %@", resp.name);
            NSLog(@"Sina iconurl: %@", resp.iconurl);
            NSLog(@"Sina gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSLog(@"Sina originalResponse: %@", resp.originalResponse);
        }
    }];
}
//qq授权
- (void)getAuthWithUserInfoFromQQ{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            UISwitch * btn =  self.title_swich_dictionary[@"QQ"];
            btn.on = false;
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"QQ uid: %@", resp.uid);
            NSLog(@"QQ openid: %@", resp.openid);
            NSLog(@"QQ accessToken: %@", resp.accessToken);
            NSLog(@"QQ expiration: %@", resp.expiration);
            
            // 用户信息
            NSLog(@"QQ name: %@", resp.name);
            NSLog(@"QQ iconurl: %@", resp.iconurl);
            NSLog(@"QQ gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSLog(@"QQ originalResponse: %@", resp.originalResponse);
        }
    }];
}
//微信授权
- (void)getAuthWithUserInfoFromWechat{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            UISwitch * btn =  self.title_swich_dictionary[@"微信"];
            btn.on = false;
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSLog(@"Wechat uid: %@", resp.uid);
            NSLog(@"Wechat openid: %@", resp.openid);
            NSLog(@"Wechat accessToken: %@", resp.accessToken);
            NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
            NSLog(@"Wechat expiration: %@", resp.expiration);
            
            // 用户信息
            NSLog(@"Wechat name: %@", resp.name);
            NSLog(@"Wechat iconurl: %@", resp.iconurl);
            NSLog(@"Wechat gender: %@", resp.unionGender);
            
            // 第三方平台SDK源数据
            NSLog(@"Wechat originalResponse: %@", resp.originalResponse);
        }
    }];
}
#pragma mark - 重新网络获取个人信息数据刷新页面
-(void)getUserInfoAgagin{
    //获取我的信息
    NSString * interfaceName = @"/member/getMember.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
        //        NSLog(@"back:%@",back_dic);
        self.member_dic = back_dic[@"member"];
        DHTOOL.memberDic = back_dic[@"member"];
        //3个状态
        bool qqStatus = [self.member_dic[@"qqStatus"] boolValue];
        bool wechatStatus = [self.member_dic[@"wechatStatus"] boolValue];
        bool weiboStatus = [self.member_dic[@"weiboStatus"] boolValue];
        UISwitch * qqSwitch = self.title_swich_dictionary[@"QQ"];
        UISwitch * wechatSwitch = self.title_swich_dictionary[@"微信"];
        UISwitch * weiboSwitch = self.title_swich_dictionary[@"新浪微博"];
        qqSwitch.on = qqStatus;
        wechatSwitch.on = wechatStatus;
        weiboSwitch.on = weiboStatus;
    }];
    
}

//返回上个界面
-(void)backToUpView{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}

@end
