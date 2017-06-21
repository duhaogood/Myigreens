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
{
    NSString * currentTitle;//要操作的类型
    BOOL isPop;//是否弹框提示
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.member_dic = DHTOOL.memberDic;
    //加载主界面
    [self loadMainView];
    isPop = false;
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
    NSArray * btn_state = @[@"weiboStatus",@"wechatStatus",@"qqStatus"];
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
        [btn addTarget:self action:@selector(swichBtn_callBack:) forControlEvents:UIControlEventValueChanged];
        btn.on = [self.member_dic[btn_state[i]] boolValue];
        [back_view addSubview:btn];
        [self.title_swich_dictionary setObject:btn forKey:title_array[i]];
    }
    
}
//swich开关回调
-(void)swichBtn_callBack:(UISwitch *)btn{
    for (NSString * key in self.title_swich_dictionary.allKeys) {
        UISwitch * s_btn = self.title_swich_dictionary[key];
        if ([s_btn isEqual:btn]) {
            if (btn.on) {
                [self startTieWithTitle:key];
            }else{
                [self cancelTieWithTitle:key andButton:btn];
            }
            return;
        }
    }
}

//第三方绑定入口
-(void)startTieWithTitle:(NSString *)title{
    isPop = true;
    //@"新浪微博",@"微信",@"QQ"
    if ([title isEqualToString:@"新浪微博"]) {
        [self getAuthWithUserInfoFromSina];
    }else if ([title isEqualToString:@"微信"]) {
        [self getAuthWithUserInfoFromWechat];
    }else {
        [self getAuthWithUserInfoFromQQ];
    }
}
//开始第三方绑定
-(void)bindTirdAPPWithTitle:(NSDictionary *)info{
    NSString * interface = @"/member/bindThirdApp.intf";
    
    NSMutableDictionary * send = [NSMutableDictionary new];
    [send setValue:MEMBERID forKey:@"memberId"];
    [send setValue:@"ios" forKey:@"terminal"];
    for (NSString * key in info.allKeys) {
        [send setValue:info[key] forKey:key];
    }
    NSString * app = info[@"app"];
    NSString * type = @"";
    //wechat 微信 ,qq QQ ,weibo 微博
    if ([app isEqualToString:@"wechat"]) {
        type = @"微信";
    }else if ([app isEqualToString:@"qq"]) {
        type = @"QQ";
    }else{
        type = @"微博";
    }
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@绑定成功",type] duration:1];
        [self getUserInfoAgagin];
    }];
}
//更新我的信息
-(void)updateMemberInfo{
    //获取我的信息
    NSString * interfaceName = @"/member/getMember.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getNoPopWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
        self.member_dic = back_dic[@"member"];
        DHTOOL.memberDic = self.member_dic;
        
    }];
}
//取消绑定
-(void)cancelTieWithTitle:(NSString *)title andButton:(UISwitch *)btn{
    
    //@"新浪微博",@"微信",@"QQ"
    //wechat 微信 ,qq QQ ,weibo 微博
    NSString * interface = @"/member/cancelBind.intf";
    NSString * key = @"";
    if ([title isEqualToString:@"新浪微博"]) {
        key = @"weibo";
    }else if ([title isEqualToString:@"微信"]) {
        key = @"wechat";
    }else{
        key = @"qq";
    }
    NSDictionary * send = @{
                            @"memberId":MEMBERID,
                            @"app":key
                            };
    if (!isPop){//直接取消，并不是打开后未安装而触发的取消
        isPop = false;
        [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
            if ([back_dic[@"code"] boolValue]) {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@取消成功",title] duration:1];
                //            [self updateMemberInfo];
            }else{
                btn.on = true;;
            }
        }];
    }
    
    
}
//微博授权
- (void)getAuthWithUserInfoFromSina{
    UISwitch * btn =  self.title_swich_dictionary[@"新浪微博"];
    if (![MYTOOL isInstallWB]) {
        [SVProgressHUD showErrorWithStatus:@"未安装微博" duration:2];
        btn.on = false;
        return;
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_Sina currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            btn.on = false;
            NSString * msg = error.userInfo[@"message"];
            if ([msg isEqualToString:@"Operation is cancel"]) {
                msg = @"取消绑定";
            }
            [SVProgressHUD showErrorWithStatus:msg duration:2];
        } else {
            UMSocialUserInfoResponse *resp = result;
            NSDictionary * info = @{
                                    @"app":@"weibo",
                                    @"openId":resp.uid
                                    };
            [self bindTirdAPPWithTitle:info];
        }
    }];
}
//qq授权
- (void)getAuthWithUserInfoFromQQ{
    UISwitch * btn =  self.title_swich_dictionary[@"QQ"];
    if (![MYTOOL isInstallQQ]) {
        [SVProgressHUD showErrorWithStatus:@"未安装QQ" duration:2];
        btn.on = false;
        return;
    }
    [UMSocialGlobal shareInstance].isClearCacheWhenGetUserInfo = false;
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_QQ currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            btn.on = false;
            NSString * msg = error.userInfo[@"message"];
            if ([msg isEqualToString:@"Operation is cancel"]) {
                msg = @"取消绑定";
            }
            [SVProgressHUD showErrorWithStatus:msg duration:2];
        } else {
            UMSocialUserInfoResponse *resp = result;
            
            // 授权信息
            NSDictionary * info = @{
                                    @"app":@"qq",
                                    @"openId":resp.openid
                                    };
            [self bindTirdAPPWithTitle:info];
//            NSLog(@"QQ accessToken: %@", resp.accessToken);
//            NSLog(@"QQ expiration: %@", resp.expiration);
//            
//            // 用户信息
//            NSLog(@"QQ name: %@", resp.name);
//            NSLog(@"QQ iconurl: %@", resp.iconurl);
//            NSLog(@"QQ gender: %@", resp.unionGender);
//            
//            // 第三方平台SDK源数据
//            NSLog(@"QQ originalResponse: %@", resp.originalResponse);
        }
    }];
}
//微信授权
- (void)getAuthWithUserInfoFromWechat{
    UISwitch * btn =  self.title_swich_dictionary[@"微信"];
    if (![MYTOOL isInstallWX]) {
        [SVProgressHUD showErrorWithStatus:@"未安装微信" duration:2];
        btn.on = false;
        return;
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            btn.on = false;
            NSString * msg = error.userInfo[@"message"];
            if ([msg isEqualToString:@"Operation is cancel"]) {
                msg = @"取消绑定";
            }
            switch (error.code) {
                case UMSocialPlatformErrorType_NotInstall:
                    msg = @"应用未安装";
                    break;
                case UMSocialPlatformErrorType_Cancel:
                    msg = @"您已取消分享";
                    break;
                default:
                    break;
            }
            [SVProgressHUD showErrorWithStatus:msg duration:2];
        } else {
            UMSocialUserInfoResponse *resp = result;
            NSDictionary * info = @{
                                    @"app":@"wechat",
                                    @"openId":resp.openid,
                                    @"unionId":resp.uid
                                    };
            [self bindTirdAPPWithTitle:info];
            
            
            //            NSLog(@"Wechat accessToken: %@", resp.accessToken);
//            NSLog(@"Wechat refreshToken: %@", resp.refreshToken);
//            NSLog(@"Wechat expiration: %@", resp.expiration);
//            
//            // 用户信息
//            NSLog(@"Wechat name: %@", resp.name);
//            NSLog(@"Wechat iconurl: %@", resp.iconurl);
//            NSLog(@"Wechat gender: %@", resp.unionGender);
//            
//            // 第三方平台SDK源数据
//            NSLog(@"Wechat originalResponse: %@", resp.originalResponse);
        }
    }];
}

#pragma mark - 重新网络获取个人信息数据刷新页面
-(void)getUserInfoAgagin{
    //获取我的信息
    NSString * interfaceName = @"/member/getMember.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getNoPopWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
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
    [self getUserInfoAgagin];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}

@end
