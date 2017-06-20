//
//  TopTenViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/29.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "TopTenViewController.h"

@interface TopTenViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation TopTenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //上部背景
    UIView * bgView = [UIView new];
    bgView.frame = CGRectMake(0, 0, WIDTH, 60+64);
    bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bg"]];
    [self.view addSubview:bgView];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    UIButton * btn = [UIButton new];
    btn.frame = CGRectMake(0, 32, 30, 30);
    [btn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(popUpViewController) forControlEvents:UIControlEventTouchUpInside];
    //标题
    UILabel * label = [UILabel new];
    label.text = self.title;
    label.font = [UIFont systemFontOfSize:18];
    CGSize size = [MYTOOL getSizeWithLabel:label];
    label.textColor = [UIColor whiteColor];
    label.frame = CGRectMake(WIDTH/2-size.width/2, 42-size.height/2, size.width, size.height);
    [self.view addSubview:label];
    
    
    
    UITableView * tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 80;
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false,
    tableView.frame = CGRectMake(14, 25+64+12, WIDTH-28, HEIGHT - 64 - 25-12);
    [self.view addSubview:tableView];
    UIView * view = [UIView new];
    view.frame = CGRectMake(14, 25+64, WIDTH-28, 24);
    view.layer.masksToBounds = true;
    view.layer.cornerRadius = 12;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    
    NSLog(@"count:%ld",self.top_10_array.count);
}


#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
//    NSLog(@"%@",self.top_10_array[indexPath.row]);
//    bool isLogin = [MYTOOL isLogin];
//    if (!isLogin) {
//        [SVProgressHUD showErrorWithStatus:@"未登录无法查看" duration:2];
//        return;
//    }
    NSString * byMemberId = self.top_10_array[indexPath.row][@"memberId"];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    NSDictionary * send_dic = @{
                                @"memberId":memberId ? memberId : @"",
                                @"byMemberId":byMemberId
                                };
    if (memberId == nil) {
        send_dic = @{
                     @"byMemberId":byMemberId
                     };
    }
    
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getOtherUser.intf" andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
        SubscribeInfoViewController * subscribeInfo = [SubscribeInfoViewController new];
        subscribeInfo.member_dic = back_dic[@"member"];
        [self.navigationController pushViewController:subscribeInfo animated:true];
    }];
    
    /*
     ¬	接口地址：/community/getOtherUser.intf
     ¬	接口描述：获取其他用户
     ¬	输入参数：
     参数名称      参数含义     参数类型 是否必录
     byMemberId 当前登录人Id   数字        是
     memberId   会员id        数字        是

     */
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.top_10_array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSDictionary * user_dic = self.top_10_array[indexPath.row];
    //头像
    {
        UIImageView * user_icon = [UIImageView new];
        user_icon.frame = CGRectMake(20, tableView.rowHeight/2-25, 50, 50);
        user_icon.layer.masksToBounds = true;
        user_icon.layer.cornerRadius = 25;
        NSString * user_url = user_dic[@"headUrl"];
        if (!user_url) {
            user_url = @"http://img.woyaogexing.com/2017/02/28/d6e03fc50c7d3e13%21200x200.jpg";
        }
        [user_icon sd_setImageWithURL:[NSURL URLWithString:user_url] placeholderImage:[UIImage imageNamed:@"logo"]];
        [cell addSubview:user_icon];
    }
    //名字
    {
        UILabel * name_label = [UILabel new];
        name_label.frame = CGRectMake(83, tableView.rowHeight/2-9, WIDTH/2, 18);
        name_label.font = [UIFont systemFontOfSize:18];
        name_label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
        NSString * name = user_dic[@"nickName"];
        if (!name || name.length == 0) {
            name = @"匿名用户";
        }
        name_label.text = name;
        [cell addSubview:name_label];
    }
    
    
    //排名图标
    {
        UIImageView * difference_icon = [UIImageView new];
        difference_icon.frame = CGRectMake(WIDTH-50-20, tableView.rowHeight/2-15, 30, 30);
        NSString * icon_name = [NSString stringWithFormat:@"top%ld",indexPath.row+1];
        difference_icon.image = [UIImage imageNamed:icon_name];
        [cell addSubview:difference_icon];
    }
    return cell;
}
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self.navigationController setNavigationBarHidden:true animated:true];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    [self.navigationController setNavigationBarHidden:false animated:true];
}
@end
