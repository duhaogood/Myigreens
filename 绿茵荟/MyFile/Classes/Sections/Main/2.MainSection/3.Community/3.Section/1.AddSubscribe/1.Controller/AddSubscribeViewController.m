//
//  AddSubscribeViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/29.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "AddSubscribeViewController.h"
#import "SharedManagerVC.h"
#import "SubscribeSearchVC.h"
@interface AddSubscribeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@end

@implementation AddSubscribeViewController
{
    int pageNo;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //搜索
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_search"] style:UIBarButtonItemStyleDone target:self action:@selector(submitSearch)];
    pageNo = 1;
    
    UITableView * tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 80;
    self.tableView = tableView;
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
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
    //头view
    {
        UIView * header_view = [UIView new];
        header_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:0 andWidth:375 andHeight:132];
        header_view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
//        tableView.tableHeaderView = header_view;
        UIView * bg_view = [UIView new];
        bg_view.frame = CGRectMake(0, 0, header_view.frame.size.width, header_view.frame.size.height-10);
        bg_view.backgroundColor = [UIColor whiteColor];
        [header_view addSubview:bg_view];
        //logo
        UIImageView * logo_icon = [UIImageView new];
        logo_icon.frame = CGRectMake(WIDTH/2-25, 22, 50, 50);
        logo_icon.image = [UIImage imageNamed:@"logo"];
        [header_view addSubview:logo_icon];
    }
    
    
    
}

//搜索事件
-(void)submitSearch{
    SubscribeSearchVC * search = [SubscribeSearchVC new];
    [self.navigationController pushViewController:search animated:true];
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
    if (indexPath.section == 0) {
        
        SharedManagerVC * share = [SharedManagerVC new];
        share.sharedDictionary = @{
                                   @"title":@"绿茵荟",
                                   @"img_url":@"https://image.baidu.com/search/detail?ct=503316480&z=0&ipn=false&word=头像%20动漫&step_word=&hs=2&pn=4&spn=0&di=192681110380&pi=0&rn=1&tn=baiduimagedetail&is=0%2C0&istype=2&ie=utf-8&oe=utf-8&in=&cl=2&lm=-1&st=-1&cs=1974473856%2C378835681&os=1772612900%2C1831627498&simid=3493092777%2C396414059&adpicid=0&lpn=0&ln=3950&fr=&fmq=1389861203899_R&fm=&ic=0&s=undefined&se=&sme=&tab=0&width=&height=&face=undefined&ist=&jit=&cg=head&bdtype=0&oriquery=头像&objurl=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201603%2F10%2F20160310125939_SArNP.jpeg&fromurl=ippr_z2C%24qAzdH3FAzdH3Fooo_z%26e3B17tpwg2_z%26e3Bv54AzdH3Fks52AzdH3F%3Ft1%3Dmdmn8cln8&gsm=0&rpstart=0&rpnum=0",
                                   @"shared_url":@"http://itunes.apple.com/app/id1238065310",
                                   };
        
        
        [share show];
        
        
        
    }else{
        bool isLogin = [MYTOOL isLogin];
        if (!isLogin) {
            //跳转至登录页
            LoginViewController * loginVC = [LoginViewController new];
            AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.window.rootViewController = loginVC;
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
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return self.member_array.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 122;
    }
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * memberDic = self.member_array[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
    if (indexPath.section == 0) {
        //logo
        UIImageView * logo_icon = [UIImageView new];
        logo_icon.frame = CGRectMake(WIDTH/2-25, 22, 50, 50);
        logo_icon.image = [UIImage imageNamed:@"logo"];
        logo_icon.layer.masksToBounds = true;
        logo_icon.layer.cornerRadius = 25;
        [cell addSubview:logo_icon];
        //文字
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(WIDTH/4, 81, WIDTH/2, 18);
        label.font = [UIFont systemFontOfSize:18];
        label.text = @"推荐绿茵荟给好友";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
        [cell addSubview:label];
        //右侧图标
        UIImageView * right_icon = [UIImageView new];
        right_icon.image = [UIImage imageNamed:@"arrow_right"];
        right_icon.frame = CGRectMake(WIDTH - 30, 61-15, 30, 30);
        [cell addSubview:right_icon];
    }else{
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
            name_label.font = [UIFont systemFontOfSize:16];
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
            //过滤换行
            signature = [signature stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
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
            btn.frame = CGRectMake(WIDTH-63-14, 25+3.5, 63, 23);
            btn.tag = [self.member_array[indexPath.row][@"memberId"] longValue];
            [btn addTarget:self action:@selector(subscribeOrNot:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            bool subscribeStatus = [self.member_array[indexPath.row][@"subscribeStatus"] boolValue];
            if (subscribeStatus) {
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_info_follow_pre"] forState:UIControlStateNormal];
                [btn setTitle:@"已订阅" forState:UIControlStateNormal];
                [btn setTitleColor:[MYTOOL RGBWithRed:113 green:157 blue:52 alpha:1] forState:UIControlStateNormal];
            }else{
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_info_follow_nor"] forState:UIControlStateNormal];
                [btn setTitle:@"订阅" forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
    
    return cell;
}
#pragma mark - 按钮事件
//订阅或取消
-(void)subscribeOrNot:(UIButton *)btn{
    NSInteger tag = btn.tag;
    for (NSDictionary * mem in self.member_array) {
        NSInteger memberId = [mem[@"memberId"] longValue];
        if (memberId == tag) {
            bool subscribeStatus = [mem[@"subscribeStatus"] boolValue];
            NSString * interfaceName = @"/community/modifySubscribe.intf";
            NSString * operate = @"";
            if (subscribeStatus) {
                operate = @"del";
            }else{
                operate = @"add";
            }
            NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
            NSString * byMemberId = mem[@"memberId"];
            NSDictionary * send_dic = @{
                                        @"operate":operate,
                                        @"memberId":memberId,
                                        @"byMemberId":byMemberId
                                        };
            if ([memberId intValue] == [byMemberId intValue]) {
                [SVProgressHUD showErrorWithStatus:@"就不要对自己操作啦" duration:2];
                return;
            }
            [MYTOOL netWorkingWithTitle:@"正在处理…"];
//            NSLog(@"send:%@",send_dic);
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
                pageNo = 1;
                [self loadDefaultData];
            }];
            break;
        }
    }
    
}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
//加载数据
-(void)loadDefaultData{
//    NSLog(@"刷新");
    NSString * interfaceName = @"/community/getTop10.intf";
    
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    [send_dic setValue:[NSString stringWithFormat:@"%d",pageNo] forKey:@"pageNo"];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    
//    NSLog(@"send:%@",send_dic);
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary * back_dic){
//                NSLog(@"back:%@",back_dic);
        bool flag = [back_dic[@"code"] boolValue];
        NSString * msg = back_dic[@"msg"];
        //        NSLog(@"%d--%@",flag,msg);
        if (!flag) {
            pageNo --;
            [SVProgressHUD showErrorWithStatus:msg duration:2];
            return;
        }
        NSArray * arr = back_dic[@"memberList"];
//        NSLog(@"count:%ld",arr.count);
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

#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}
@end
