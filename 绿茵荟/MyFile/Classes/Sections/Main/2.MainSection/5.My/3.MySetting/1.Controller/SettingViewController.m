//
//  SettingViewController.m
//  绿茵荟
//
//  Created by Mac on 17/3/31.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SettingViewController.h"
#import "MainVC.h"
@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSArray * view_data_array;
@property(nonatomic,strong)UITableView * tableView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.member_dic = DHTOOL.memberDic;
    //加载界面数据
    {
        self.view_data_array = @[
                                 @[//显示文字，是否可以跳转,跳转的viewcontroller类名字
                                     @[@"个人资料",@"1",@"PersonalMaterialViewController"],
                                     @[@"账号管理",@"1",@"AccountManagerViewController"],
                                     @[@"账号绑定",@"1",@"AccountTieViewController"],
                                     @[@"积分规则",@"1",@"ScoreRuleViewController"],
                                     @[@"认证规则",@"1",@"CertificationRulesViewController"]
                                     ],
                                 @[
                                     @[@"关于绿茵荟",@"1",@"AboutLYHViewController"],
                                     @[@"商务合作",@"1",@"BusinessCooperateViewController"],
                                     @[@"意见反馈",@"1",@"FeedbackViewController"],
                                     @[@"给我们评分",@"0",@"1"]
                                   ],
                                 @[
                                     @[@"清理缓存",@"0",@"1"],
                                     @[@"开启推送",@"0",@"1"]
                                     ],
                                 @[
                                     @[@"退出登录",@"0",@"0"]
                                     ]
                                 ];
    }
    //加载主界面
    [self loadMainView];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"服务器" style:UIBarButtonItemStyleDone target:self action:@selector(changeServerUrl)];
//    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    //tableView
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);//[MYTOOL getRectWithIphone_six_X:0 andY:0 andWidth:375 andHeight:667-64];
//    tableView.backgroundColor = [UIColor redColor];
    tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 60/667.0*HEIGHT;
    self.tableView = tableView;
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
}



#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    BOOL flag = [self.view_data_array[indexPath.section][indexPath.row][1] boolValue];
    if (flag) {
        NSString * vcClassName = self.view_data_array[indexPath.section][indexPath.row][2];
        Class class = NSClassFromString(vcClassName);
        UIViewController * vc = [class new];
        if ([vcClassName isEqualToString:@"PersonalMaterialViewController"]) {
            PersonalMaterialViewController * pmvc = (PersonalMaterialViewController*)vc;
            pmvc.member_dic = self.member_dic;
        }
        [vc setTitle:self.view_data_array[indexPath.section][indexPath.row][0]];
        vc.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
        if (vc) {
            [self.navigationController pushViewController:vc animated:true];
        }
    }else{
        NSString * title = self.view_data_array[indexPath.section][indexPath.row][0];
        if ([title isEqualToString:@"给我们评分"]) {
            NSString *str = [NSString stringWithFormat:
                             @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@&pageNumber=0&sortOrdering=2&mt=8",@"1238065310"]; //appID 解释如下
            bool flag = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]];
            if (flag) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            }else{
                [SVProgressHUD showErrorWithStatus:@"无法打开商店" duration:2];
            }
        }else if([title isEqualToString:@"清理缓存"]){
            CGFloat size =
                [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject]
                + [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject]
                + [self folderSizeAtPath:NSTemporaryDirectory()];
            NSString *message = size > 1 ? [NSString stringWithFormat:@"缓存%.2fM, 删除缓存", size] : [NSString stringWithFormat:@"缓存%.2fK, 删除缓存", size * 1024.0];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:(UIAlertControllerStyleAlert)];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                [self cleanCaches:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject];
                [self cleanCaches:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject];
                [self cleanCaches:NSTemporaryDirectory()];
                [self.tableView reloadData];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
            [alert addAction:action];
            [alert addAction:cancel];
            [self showDetailViewController:alert sender:nil];
        }else if([title isEqualToString:@"开启推送"]){
            
        }
        
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.view_data_array.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.view_data_array[section] count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSString * title = self.view_data_array[indexPath.section][indexPath.row][0];
    //除了最后一个是退出登录
    if (indexPath.section != 3) {
        //标题
        {
            UILabel * title_label = [UILabel new];
            title_label.frame = [MYTOOL getRectWithIphone_six_X:14 andY:25 andWidth:150 andHeight:17];
            title_label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            title_label.text = title;
            [cell addSubview:title_label];
        }
        //右侧图标
        {
            UIImageView * imgV = [UIImageView new];
            imgV.image = [UIImage imageNamed:@"arrow_right"];
            imgV.frame = CGRectMake(WIDTH-30, tableView.rowHeight/2-15, 30, 30);
            [cell addSubview:imgV];
        }
        //是否开启推送
        {
            if (indexPath.section == 2 && indexPath.row == 1) {
                UISwitch * switch_btn = [UISwitch new];
                switch_btn.frame = CGRectMake(WIDTH - 81, tableView.rowHeight/2-15.5, 51, 31);
//                NSLog(@"[%.2f,%.2f]",switch_btn.frame.size.width,switch_btn.frame.size.height);
                [cell addSubview:switch_btn];
                bool flag = false;//是否开启
                if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIUserNotificationTypeNone) {//关闭了
                    flag = false;
                }else{
                    flag = true;
                }
                switch_btn.on = flag;
                [switch_btn addTarget:self action:@selector(post_btn_callBack:) forControlEvents:UIControlEventValueChanged];
            }
        }
        //清理缓存
        {
            if ([title isEqualToString:@"清理缓存"]) {
                CGFloat size =
                [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject]
                + [self folderSizeAtPath:NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).lastObject]
                + [self folderSizeAtPath:NSTemporaryDirectory()];
                //显示缓存大小
                UILabel * cache_label = [UILabel new];
                cache_label.text = [NSString stringWithFormat:@"%.2fM",size];
                cache_label.textAlignment = NSTextAlignmentRight;
                cache_label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                cache_label.font = [UIFont systemFontOfSize:15];
                CGSize labelSize = [MYTOOL getSizeWithLabel:cache_label];
                
                cache_label.frame = CGRectMake(WIDTH-35-labelSize.width, tableView.rowHeight/2-8, labelSize.width, 16);
                [cell addSubview:cache_label];
            }
        }
        //分割线
        {
            if ([self.view_data_array[indexPath.section] count] - 1 != indexPath.row) {
                UIView * space_view = [UIView new];
                space_view.frame = CGRectMake(14, tableView.rowHeight-1,WIDTH-28, 1);
                space_view.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
                [cell addSubview:space_view];
            }
        }
    }else{
        //退出登录按钮
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(0, 0, WIDTH, tableView.rowHeight);
        [btn addTarget:self action:@selector(exitLogin) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [btn setTitle:@"退出登录" forState:UIControlStateNormal];
        [btn setTitleColor:[MYTOOL RGBWithRed:117 green:160 blue:52 alpha:1] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:17/667.0*HEIGHT];
    }
    
    return cell;
}
// 根据路径删除文件
- (void)cleanCaches:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        // 获取该路径下面的文件名
        NSArray *childrenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childrenFiles) {
            // 拼接路径
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            // 将文件删除
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
}
// 计算目录大小
- (CGFloat)folderSizeAtPath:(NSString *)path{
    // 利用NSFileManager实现对文件的管理
    NSFileManager *manager = [NSFileManager defaultManager];
    CGFloat size = 0;
    if ([manager fileExistsAtPath:path]) {
        // 获取该目录下的文件，计算其大小
        NSArray *childrenFile = [manager subpathsAtPath:path];
        for (NSString *fileName in childrenFile) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            size += [manager attributesOfItemAtPath:absolutePath error:nil].fileSize;
        }
        // 将大小转化为M
        return size / 1024.0 / 1024.0;
    }
    return 0;
}
//返回上一个界面
-(void)back{
    [self.navigationController popViewControllerAnimated:true];
}
//切换服务器
-(void)changeServerUrl{
    
#warning 以后删除
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请选择服务器!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    NSString * server = @"yemast.com:8180-测试";//
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:server style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [MYTOOL setProjectPropertyWithKey:@"server_url" andValue:@"http://yemast.com:8180/api"];
    }];
    NSString * server2 = @"http://yema.wicp.net/api-老王";
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:server2 style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [MYTOOL setProjectPropertyWithKey:@"server_url" andValue:@"http://yema.wicp.net/api"];
        
    }];
    //http://106.14.148.72:8081
    NSString * server3 = @"myigreens.yemast.com:8081-正式";
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:server3 style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [MYTOOL setProjectPropertyWithKey:@"server_url" andValue:@"http://myigreens.yemast.com:8081/api"];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    //    [self showDetailViewController:alert sender:nil];
    [self presentViewController:alert animated:YES completion:nil];
#warning 以上
}
//开启关闭推送
-(void)post_btn_callBack:(UISwitch *)switch_btn{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        NSURL *url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}
//更新推送状态
-(void)updatePushState{
    NSString * interfaceName = @"/member/updateMember.intf";
    bool flag = false;//是否开启
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIUserNotificationTypeNone) {//关闭了
        flag = false;
    }else{
        flag = true;
    }
    NSDictionary * sendDic = @{
                               @"pushStatus":flag ? @"1" :@"0",
                               @"memberId":MEMBERID
                               };
    
    [SVProgressHUD showWithStatus:@"更新中" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        //更新成功
//        for (NSString * key in back_dic.allKeys) {
//            NSLog(@"%@:%@",key,back_dic[key]);
//        }
    }];
}
//获取最新推送状态
-(void)getNewPushState{
    //获取用户中心的存档
    bool pushState = [[DHTOOL getProjectPropertyWithKey:@"push_state"] boolValue];
    //获取现在的推送状态
    bool currentPushState = false;
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIUserNotificationTypeNone) {//关闭了
        currentPushState = false;
    }else{
        currentPushState = true;
    }
    //如果不相同
    if (currentPushState != pushState) {
        //存入用户中心
        [DHTOOL setProjectPropertyWithKey:@"push_state" andValue:currentPushState ? @"1" : @"0"];
        //告知服务器
        [self updatePushState];
    }
    
    //刷新按钮状态
    [self.tableView reloadData];
    
}
//退出登录按钮
-(void)exitLogin{
    
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"退出登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * aa_sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [MYTOOL setProjectPropertyWithKey:@"user_tel" andValue:nil];
        [MYTOOL setProjectPropertyWithKey:@"isLogin" andValue:nil];
        [MYTOOL setProjectPropertyWithKey:@"memberId" andValue:nil];
        [SVProgressHUD showSuccessWithStatus:@"退出成功了" duration:1];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        LoginViewController * login = [LoginViewController new];
        login.fromExitLogin = true;
        delegate.window.rootViewController = login;
    }];
    UIAlertAction * aa_cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:aa_sure];
    [ac addAction:aa_cancel];
    [self presentViewController:ac animated:true completion:nil];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getNewPushState];
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(getNewPushState) name:NOTIFICATION_APP_BECOME_ACTIVE object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_APP_BECOME_ACTIVE object:nil];
}

@end
