//
//  MainVC.m
//  绿茵荟
//
//  Created by Mac on 17/3/13.
//  Copyright © 2017年 江苏野马软件. All rights reserved.
//

#import "MainVC.h"
#import "SpecialVC.h"
#import "WallpaperVC.h"
#import "CommunityVC.h"
#import "StoreVC.h"
#import "MyVC.h"
#import "JPUSHService.h"
@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化tabbarItem
    [self initTabbarItem];
    NSLog(@"memberId:%@",[MYTOOL getProjectPropertyWithKey:@"memberId"]);

    self.delegate = self;
    
    //5秒后执行
    [self performSelector:@selector(isUploadPushIdOrNor) withObject:nil afterDelay:5];
    UILabel * label = [UILabel new];
    label.font = [UIFont systemFontOfSize:15];
    NSLog(@"name:%@",label.font.fontName);
    
}
//是否上传
-(void)isUploadPushIdOrNor{
    if ([JPUSHService registrationID] && [MYTOOL isLogin]) {
        [self uploadPushId:[JPUSHService registrationID]];
    }
}

//上传pushid
-(void)uploadPushId:(NSString *)pushId{
    NSString * interface = @"/member/updatePushId.intf";
    NSDictionary * send = @{
                            @"memberId":MEMBERID,
                            @"pushId":pushId
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        
    }];
}

//初始化tabbarItem
-(void)initTabbarItem{
    //改变tabbar选中及未选中的字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[DHTOOL RGBWithRed:46 green:42 blue:42 alpha:1]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[DHTOOL RGBWithRed:113 green:157 blue:52 alpha:1]} forState:UIControlStateSelected];
    //改变字体大小
    
    //字体 ,UIFontDescriptorTextStyleAttribute:[UIFont systemFontOfSize:12]
    
    UIColor * titleColor = [UIColor whiteColor];
    NSDictionary * dictColor = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName:titleColor
                                 };
    UINavigationController * nc1 = [[UINavigationController alloc]initWithRootViewController:[SpecialVC new]];
    //修改navigationbar背景色
    nc1.navigationBar.translucent = NO;
    //修改title字体颜色及大小
    nc1.navigationBar.titleTextAttributes = dictColor;
    nc1.title = @"专题";
    nc1.tabBarItem.image = [UIImage imageNamed:@"tab_-subject_nor.png"];
    nc1.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_-subject_sel.png"];
    
    [nc1.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
    
    WallpaperVC * vc2 = [WallpaperVC new];
    vc2.title = @"壁纸";
    UINavigationController * nc2 = [[UINavigationController alloc]initWithRootViewController:vc2];
    //修改navigationbar背景色
    nc2.navigationBar.translucent = NO;
    //修改title字体颜色及大小
    nc2.navigationBar.titleTextAttributes = dictColor;
    nc2.title = @"壁纸";
    nc2.tabBarItem.image = [UIImage imageNamed:@"tab_picture_nor.png"];
    nc2.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_picture_sel.png"];
    [nc2.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    CommunityVC * vc3 = [CommunityVC new];
    UINavigationController * nc3 = [[UINavigationController alloc]initWithRootViewController:vc3];
    //修改navigationbar背景色
    nc3.navigationBar.translucent = NO;
    //修改title字体颜色及大小
    nc3.navigationBar.titleTextAttributes = dictColor;
    nc3.title = @"社区";
    nc3.tabBarItem.image = [UIImage imageNamed:@"tab_chat_nor.png"];
    nc3.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_chat_sel.png"];
    UIImageView * nav_bg_view3 = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, WIDTH, 64)];
    nav_bg_view3.image = [UIImage imageNamed:@"nav_bg"];
    [nc3.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
    StoreVC * vc4 = [StoreVC new];
//    vc4.title = @"商城";
    UINavigationController * nc4 = [[UINavigationController alloc]initWithRootViewController:vc4];
    //修改navigationbar背景色
    nc4.navigationBar.translucent = NO;
    //修改title字体颜色及大小
    nc4.navigationBar.titleTextAttributes = dictColor;
    nc4.title = @"商城";
    nc4.tabBarItem.image = [UIImage imageNamed:@"tab_shop_nor.png"];
    nc4.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_shop_sel.png"];
    [nc4.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
    MyVC * myVC = [MyVC new];
    UINavigationController * nc5 = [[UINavigationController alloc]initWithRootViewController:myVC];
    //修改navigationbar背景色
    nc5.navigationBar.translucent = NO;
    //修改title字体颜色及大小
    nc5.navigationBar.titleTextAttributes = dictColor;
    nc5.title = @"我的";
    nc5.tabBarItem.image = [UIImage imageNamed:@"tab_user_nor.png"];
    nc5.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_user_sel.png"];
    [nc5.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    
    //    [self addChildViewController:nc1];
    [self addChildViewController:nc2];
    [self addChildViewController:nc3];
    [self addChildViewController:nc4];
    [self addChildViewController:nc5];
    
    
}
//控制tabBar是否可以跳转
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    NSString * title = viewController.title;
    if ([title isEqualToString:@"我的"]) {//跳转 我的 界面
        //[SVProgressHUD showSuccessWithStatus:@"欢迎来到我的界面"duration:1];
        if (![MYTOOL isLogin]) {
            //跳转至登录页
            LoginViewController * loginVC = [LoginViewController new];
            UINavigationController * nc = self.childViewControllers[self.selectedIndex];
            [nc pushViewController:loginVC animated:true];
            return false;
        }
        return true;
    }
    return YES;
}


@end
