//
//  NewSubscribeViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/1.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "NewSubscribeViewController.h"
#import "PostInfoViewController.h"
@interface NewSubscribeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * subscribeArray;//收到的赞数组
@end

@implementation NewSubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //加载主界面
    [self loadMainView];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back_pop)];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    //tableView
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-64-10);
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        tableView.rowHeight = 106/667.0*HEIGHT;
        self.tableView = tableView;
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subscribeArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = self.subscribeArray[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
#warning 有问题
    //头像
    {
        UIImageView * user_icon = [UIImageView new];
        user_icon.frame = [MYTOOL getRectWithIphone_six_X:14 andY:12 andWidth:34 andHeight:34];
        user_icon.layer.masksToBounds = true;
        user_icon.layer.cornerRadius = user_icon.frame.size.width/2;
        [cell addSubview:user_icon];
        NSString * headUrl = dict[@"headUrl"];
        if (headUrl && headUrl.length) {
            [user_icon sd_setImageWithURL:[NSURL URLWithString:headUrl]];
        }else{
            user_icon.image = [UIImage imageNamed:@"logo"];
        }
    }
    
    //名字
    NSString * name = dict[@"nickName"];
    if (name == nil || name.length == 0) {
        name = @"匿名用户";
    }
    UILabel * name_label = [UILabel new];
    {
        name_label.font = [UIFont systemFontOfSize:15];
        name_label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:name andFont:[UIFont systemFontOfSize:15]];
        name_label.frame = CGRectMake(56/375.0*WIDTH, 28/667.0*HEIGHT-8, size.width, 16);
        name_label.text = name;
        [cell addSubview:name_label];
    }
    //是否订阅按钮
    {
        UIButton * sub_btn = [UIButton new];
        sub_btn.frame = CGRectMake(WIDTH-73, tableView.rowHeight/2-15.5, 63, 31);
        [sub_btn setBackgroundImage:[UIImage imageNamed:@"btn_follow_nor"] forState:UIControlStateNormal];
        
        [sub_btn setTitle:@"订阅" forState:UIControlStateNormal];
        [sub_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell addSubview:sub_btn];
        sub_btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [sub_btn addTarget:self action:@selector(sub_btn_callback:) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.row%2 == 1) {
            [sub_btn setBackgroundImage:[UIImage imageNamed:@"btn_green"] forState:UIControlStateNormal];
            [sub_btn setTitle:@"已订阅" forState:UIControlStateNormal];
            [sub_btn setTitleColor:[MYTOOL RGBWithRed:113 green:157 blue:52 alpha:1] forState:UIControlStateNormal];
        }
    }
    //个人签名
    {
        UILabel * content_label = [UILabel new];
        content_label.font = [UIFont systemFontOfSize:15/667.0*HEIGHT];
        content_label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        content_label.frame = [MYTOOL getRectWithIphone_six_X:57 andY:49 andWidth:300 andHeight:15];
        content_label.text = @"TA什么也没有留下";
        [cell addSubview:content_label];
    }
    return cell;
}
//订阅按钮回调
-(void)sub_btn_callback:(UIButton *)btn{
    [SVProgressHUD showSuccessWithStatus:btn.currentTitle duration:1];
}

//返回上个界面
-(void)back_pop{
    [self.navigationController popViewControllerAnimated:true];
}
//重新加载界面数据
-(void)reloadViewData{
    NSString * interfaceName = @"/member/newSubscriptions.intf";
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":MEMBERID} andSuccess:^(NSDictionary *back_dic) {
        self.subscribeArray = back_dic[@"subscriptionsList"];
        [self.tableView reloadData];
    }];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self reloadViewData];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}

@end
