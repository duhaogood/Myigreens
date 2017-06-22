//
//  MyReaderVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/18.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "MyReaderVC.h"
#import "SubscribeInfoViewController.h"

@interface MyReaderVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * member_array;

@end

@implementation MyReaderVC
{
    int pageNo;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = false;
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    pageNo = 1;
    
    UITableView * tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 80;
    self.tableView = tableView;
    tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT - 74);
    [self.view addSubview:tableView];
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self headerRefresh];
        // 结束刷新
        [tableView.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self footerRefresh];
        [tableView.mj_footer endRefreshing];
    }];
}
#pragma mark - 上拉、下拉刷新
-(void)headerRefresh{
    pageNo = 1;
    [self loadDefaultData];
}
-(void)footerRefresh{
    pageNo ++;
    [self loadDefaultData];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    bool isLogin = [MYTOOL isLogin];
    if (!isLogin) {
        [SVProgressHUD showErrorWithStatus:@"未登录无法查看" duration:2];
        return;
    }
    NSString * byMemberId = self.member_array[indexPath.row][@"memberId"];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    NSDictionary * send_dic = @{
                                @"memberId":memberId,
                                @"byMemberId":byMemberId
                                };
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getOtherUser.intf" andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
        SubscribeInfoViewController * subscribeInfo = [SubscribeInfoViewController new];
        subscribeInfo.member_dic = back_dic[@"member"];
        [self.navigationController pushViewController:subscribeInfo animated:true];
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.member_array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * memberDic = self.member_array[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
    //头像
    {
        UIImageView * user_icon = [UIImageView new];
        user_icon.image = [UIImage imageNamed:@"logo"];
        NSString * headUrl = memberDic[@"headUrl"];
        if (headUrl && headUrl.length) {
            [user_icon sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
        }
        user_icon.frame = CGRectMake(14, 14, 50, 50);
        user_icon.layer.masksToBounds = true;
        user_icon.layer.cornerRadius = 25;
        [cell addSubview:user_icon];
    }
    //名字
    {
        UILabel * name_label = [UILabel new];
        name_label.frame = CGRectMake(76, 22, WIDTH/2, 16);
        name_label.font = [UIFont titleFontOfSize:16];
        name_label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
        NSString * nickName = memberDic[@"nickName"];
        if (!nickName || nickName.length == 0) {
            nickName = @"匿名用户";
        }
        name_label.text = nickName;
        [cell addSubview:name_label];
    }
    //个性签名  76  width-85
    {
        UILabel * label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12];
        NSString * signature = self.member_array[indexPath.row][@"signature"];
        if (!signature || signature.length == 0) {
            signature = @"他什么也没留下";
        }
//                    signature = @"反对撒放大镜看拉萨附近看到拉萨肌肤抵抗力撒娇疯狂的拉萨肌肤都可撒";
        label.text = signature;
        label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        [cell addSubview:label];
        CGSize size = [MYTOOL getSizeWithString:signature andFont:label.font];
        int c = size.width/(WIDTH-76-85) < 1 ? 1 : (size.width/(WIDTH-76-85) == 1 ? 1 : (int)size.width/(WIDTH-76-85) + 1);
        if (c > 1) {
            label.numberOfLines = 0;
            if (c > 2) {
                c = 2;
            }
        }
        label.frame = CGRectMake(75, 45, WIDTH-76-85, size.height*c);
    }
    //订阅按钮
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(WIDTH-63-14, 25, 63, 30);
        btn.tag = [self.member_array[indexPath.row][@"memberId"] longValue];
        [btn addTarget:self action:@selector(subscribeOrNot:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:btn];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_info_follow_pre"] forState:UIControlStateNormal];
        [btn setTitle:@"已订阅" forState:UIControlStateNormal];
        [btn setTitleColor:[MYTOOL RGBWithRed:113 green:157 blue:52 alpha:1] forState:UIControlStateNormal];
        bool subscribe = [self.member_array[indexPath.row][@"subscribe"] boolValue];
        btn.enabled = subscribe;
    }
    
    return cell;
}
#pragma mark - 按钮事件
//订阅或取消
-(void)subscribeOrNot:(UIButton *)btn{
    NSInteger tag = btn.tag;
    [MYTOOL netWorkingWithTitle:@"取消订阅"];
    for ( int i = 0;i < self.member_array.count;i ++) {
        NSDictionary * mem = self.member_array[i];
        NSInteger memberId = [mem[@"memberId"] longValue];
        if (memberId == tag) {
            NSString * interfaceName = @"/community/modifySubscribe.intf";
            NSString * operate = @"del";
            NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
            NSString * byMemberId = mem[@"memberId"];
            NSDictionary * send_dic = @{
                                        @"operate":operate,
                                        @"memberId":memberId,
                                        @"byMemberId":byMemberId
                                        };
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
                [SVProgressHUD showSuccessWithStatus:@"取消成功" duration:1];
                [self.member_array removeObjectAtIndex:i];
                [self.tableView reloadData];
            }];
            break;
        }
    }
    
    
}
//加载数据
-(void)loadDefaultData{
    //    NSLog(@"刷新");
    NSString * interfaceName = @"/member/getSubscribe.intf";
    
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    [send_dic setValue:[NSString stringWithFormat:@"%d",pageNo] forKey:@"pageNo"];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];//
        [send_dic setValue:memberId forKey:@"byMemberId"];//byMemberId
    }
    [send_dic setValue:@"2" forKey:@"type"];//
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary * back_dic){
        NSLog(@"back:%@",back_dic);
        bool flag = [back_dic[@"code"] boolValue];
        NSString * msg = back_dic[@"msg"];
        //        NSLog(@"%d--%@",flag,msg);
        if (!flag) {
            pageNo --;
            [SVProgressHUD showErrorWithStatus:msg duration:2];
            return;
        }
        NSArray * arr = back_dic[@"memberList"];
        //成功--如果页数=1，重置数组，如果页数>1，数据加上去
        if (pageNo > 1) {
            
            if (arr.count > 0) {
                [self.member_array addObjectsFromArray:arr];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
            
        }else{
            self.member_array = [NSMutableArray arrayWithArray:arr];
        }
        [self.tableView reloadData];
        
        //NSLog(@"back:%@",back_dic);
        //        NSLog(@"msg:%@",back_dic[@"msg"]);
    }andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.member_array removeAllObjects];
            [self.tableView reloadData];
        }else{
            pageNo --;
        }
    }];
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
    [self headerRefresh];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}
@end
