//
//  AccountManagerViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "ChangeTelViewController.h"
@interface AccountManagerViewController ()
@property(nonatomic,strong)UILabel * tel_label;//手机号码
@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //背景视图
    UIView * back_view = [UIView new];
    back_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:10 andWidth:375 andHeight:59];
    back_view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:back_view];
    //手机号标题
    UILabel * title_label = [UILabel new];
    title_label.frame = CGRectMake(10, back_view.frame.size.height/2-9, 60, 18);
    title_label.text = @"手机号";
    title_label.font = [UIFont systemFontOfSize:18];
    title_label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
    [back_view addSubview:title_label];
    //手机号label
    UILabel * tel_label = [UILabel new];
    tel_label.frame = CGRectMake(80, back_view.frame.size.height/2-8, 176, 16);
    tel_label.font = [UIFont systemFontOfSize:15];
    tel_label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
    [back_view addSubview:tel_label];
    self.tel_label = tel_label;
    [self refresh_tel_label];
    //更换手机按钮
    UIButton * btn = [UIButton new];
    [btn setTitle:@"更换手机号" forState:UIControlStateNormal];
    [btn setTitleColor:[MYTOOL RGBWithRed:117 green:160 blue:52 alpha:1] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(changeTelBtn_callBack) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(WIDTH-112, back_view.frame.size.height/2-8, 100, 16);
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [back_view addSubview:btn];
    
}


//更换手机号码
-(void)changeTelBtn_callBack{
    ChangeTelViewController * changeVC = [ChangeTelViewController new];
    changeVC.title = @"修改手机号";
    changeVC.delegate = self;
    [self.navigationController pushViewController:changeVC animated:true];
}
//刷新手机号码
-(void)refresh_tel_label{
    //获取我的信息
    NSString * interfaceName = @"/member/getMember.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
        MYTOOL.memberDic = back_dic[@"member"];
        NSString * tel = MYTOOL.memberDic[@"mobile"];
        if (!tel) {
            return;
        }
        self.tel_label.text = tel;
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
