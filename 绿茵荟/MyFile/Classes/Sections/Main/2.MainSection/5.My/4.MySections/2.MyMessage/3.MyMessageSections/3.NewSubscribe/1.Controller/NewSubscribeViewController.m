//
//  NewSubscribeViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/1.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "NewSubscribeViewController.h"
#import "PostInfoViewController.h"
#import "SubscribeInfoViewController.h"

@interface NewSubscribeViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * subscribeArray;//收到的赞数组
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@end

@implementation NewSubscribeViewController
{
    int pageNo;
}
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
        //不显示分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = 76/667.0*HEIGHT;
        self.tableView = tableView;
        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            pageNo = 1;
            [self reloadViewData];
            // 结束刷新
            [tableView.mj_header endRefreshing];
        }];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        tableView.mj_header.automaticallyChangeAlpha = YES;
        
        // 上拉刷新
        tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            pageNo ++;
            [self reloadViewData];
            [tableView.mj_footer endRefreshing];
        }];
        //覆盖一个没有数据时显示的view
        //@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
        {
            UIView * view = [UIView new];
            view.frame = tableView.bounds;
            self.noDateView = view;
            view.hidden = true;
            [tableView addSubview:view];
            view.backgroundColor = [MYTOOL RGBWithRed:240 green:240 blue:240 alpha:1];
            //没有数据提示
            {
                UILabel * label = [UILabel new];
                label.text = @"暂无订阅信息";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = MYCOLOR_46_42_42;
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(0, 10, WIDTH, 20);
                [view addSubview:label];
            }
        }
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSDictionary * subscribeDic = self.subscribeArray[indexPath.row];
    //消息状态置为已读
    bool flag = [subscribeDic[@"readType"] boolValue];
    if (!flag) {
        //将未读信息设成已读
        NSInteger flowId = [subscribeDic[@"flowId"] longValue];
        NSString * interfaceName = @"/member/readMessage.intf";
        NSDictionary * sendDic = @{
                                   @"flowId":[NSString stringWithFormat:@"%ld",flowId]
                                   };
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
            [self reloadViewData];
            
            NSString * byMemberId = subscribeDic[@"byMemberId"];
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
            
            
            
        }];
    }else{
        NSString * byMemberId = subscribeDic[@"byMemberId"];
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
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subscribeArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = self.subscribeArray[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
    //头像
    UIImageView * user_icon = [UIImageView new];
    {
        
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
        //是否已读
        {
            bool readType = [dict[@"readType"] boolValue];
            if (!readType) {
                UIView * view = [UIView new];
                view.backgroundColor = [UIColor redColor];
                view.frame = CGRectMake(5, user_icon.frame.origin.y+user_icon.frame.size.height/2-2, 4, 4);
                view.layer.masksToBounds = true;
                view.layer.cornerRadius = 2;
                [cell addSubview:view];
            }
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
        name_label.frame = CGRectMake(56/375.0*WIDTH, user_icon.frame.origin.y + user_icon.frame.size.height/2-size.height/2, size.width, 16);
        name_label.text = name;
        [cell addSubview:name_label];
    }
    //时间
    NSString * time = dict[@"releaseTime"];
    {
        UILabel * time_label = [UILabel new];
        time_label.font = [UIFont systemFontOfSize:12];
        time_label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:time andFont:time_label.font];
        time_label.frame = CGRectMake(WIDTH - size.width - 10, name_label.frame.origin.y+name_label.frame.size.height-12, size.width, 12);
        time_label.text = time;
        [cell addSubview:time_label];
    }
    //消息内容
    {
        UILabel * content_label = [UILabel new];
        content_label.font = [UIFont systemFontOfSize:15/667.0*HEIGHT];
        content_label.text = dict[@"comment"];;
        content_label.textColor = [MYTOOL RGBWithRed:112 green:112 blue:112 alpha:1];
        content_label.frame = [MYTOOL getRectWithIphone_six_X:56 andY:48 andWidth:270 andHeight:15];
        [cell addSubview:content_label];
    }
    //分割线
    {
        UIView * space_view = [UIView new];
        space_view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
        space_view.frame = CGRectMake(10, tableView.rowHeight - 2, WIDTH-20, 2);
        [cell addSubview:space_view];
    }
    return cell;
}

//返回上个界面
-(void)back_pop{
    [self.navigationController popViewControllerAnimated:true];
}
//重新加载界面数据
-(void)reloadViewData{
    NSString * interfaceName = @"/member/newSubscriptions.intf";
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":MEMBERID,@"pageNo":@(pageNo)} andSuccess:^(NSDictionary *back_dic) {
        NSArray * arr = back_dic[@"subscriptionsList"];
//        NSLog(@"arr:%@",arr);
        if (pageNo > 1) {
            if (arr.count > 0) {
                [self.subscribeArray addObjectsFromArray:arr];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
        }else{
            self.subscribeArray = [NSMutableArray arrayWithArray:arr];
        }
        if (self.subscribeArray.count > 0) {
            self.noDateView.hidden = true;
        }else{
            self.noDateView.hidden = false;
        }
        [self.tableView reloadData];
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.subscribeArray removeAllObjects];
            self.noDateView.hidden = false;
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
    pageNo = 1;
    [self reloadViewData];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}

@end
