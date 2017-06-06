//
//  SubscribeSearchVC.m
//  绿茵荟
//
//  Created by mac on 2017/6/4.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "SubscribeSearchVC.h"

@interface SubscribeSearchVC ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * data_array;
@property(nonatomic,strong)UISearchBar * searchBar;
@end

@implementation SubscribeSearchVC
{
    int pageNo;//分页数
    NSString * currentSearchString;//当前搜索关键字
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左按钮取消
    [self.navigationItem setHidesBackButton:true];
    //右按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(submitCancelBtn)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    //tableView
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        tableView.rowHeight = 80;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            pageNo = 1;
            if (currentSearchString == nil || currentSearchString.length == 0) {
                // 结束刷新
                [tableView.mj_header endRefreshing];
                return;
            }
            [self getCellData];
            // 结束刷新
            [tableView.mj_header endRefreshing];
        }];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        tableView.mj_header.automaticallyChangeAlpha = YES;
        // 上拉刷新
        tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            if (currentSearchString == nil || currentSearchString.length == 0) {
                // 结束刷新
                [tableView.mj_footer endRefreshing];
                return;
            }
            pageNo ++;
            [self getCellData];
            [tableView.mj_footer endRefreshing];
        }];
    }
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data_array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * memberDic = self.data_array[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
    //头像-向哲
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
        NSString * signature = memberDic[@"signature"];
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
        btn.frame = CGRectMake(WIDTH-63-14, 25, 63, 30);
        btn.tag = indexPath.row;
        [btn addTarget:self action:@selector(subscribeOrNot:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        bool subscribeStatus = [memberDic[@"subscribeStatus"] boolValue];
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
    //分割线
    {
        if (indexPath.row < self.data_array.count - 1) {
            UIView * space = [UIView new];
            space.frame = CGRectMake(14, tableView.rowHeight-1, WIDTH-28, 1);
            space.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
            [cell addSubview:space];
        }
    }

    return cell;
}
//订阅或取消-向哲
-(void)subscribeOrNot:(UIButton *)btn{
    NSInteger tag = btn.tag;
    NSDictionary * mem = self.data_array[tag];
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
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
        pageNo = 1;
        [self getCellData];
    }];
    
    
}
#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString * searchString = searchBar.text;
    currentSearchString = searchString;
    pageNo = 1;
    [self getCellData];
    [searchBar resignFirstResponder];
}
#pragma mark - 取消按钮
-(void)submitCancelBtn{
    [self.navigationController popViewControllerAnimated:true];
}

//加载数据
-(void)getCellData{
    NSString * interface = @"/community/getTop10.intf";
    NSDictionary * send = @{
                            @"memberId":MEMBERID,
                            @"content":currentSearchString,
                            @"pageNo":@(pageNo)
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        bool flag = [back_dic[@"code"] boolValue];
        NSString * msg = back_dic[@"msg"];
        if (!flag) {
            pageNo --;
            [SVProgressHUD showErrorWithStatus:msg duration:2];
            return;
        }
        NSArray * arr = back_dic[@"memberList"];
        //成功--如果页数=1，重置数组，如果页数>1，数据加上去
        if (pageNo > 1) {
            
            if (arr.count > 0) {
                [self.data_array addObjectsFromArray:arr];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
            
        }else{
            self.data_array = [NSMutableArray arrayWithArray:back_dic[@"memberList"]];
        }
        [self.tableView reloadData];
    }];
    
    /*
     Ø接口地址：/community/getTop10.intf
     Ø接口描述：获取top10和订阅推荐用户
     39.40.40.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     pageNo	页数	数字	是
     content	搜索内容	字符串	否
     */
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    //搜索框
    UISearchBar * searchBar = [[UISearchBar alloc]init];
    searchBar.delegate = self;
    self.searchBar = searchBar;
    searchBar.tag = 123123;
    searchBar.frame = CGRectMake(0.05*WIDTH, 14, WIDTH*0.75, 14.5);
    [self.navigationController.navigationBar addSubview:searchBar];
    searchBar.placeholder = @"搜索用户昵称";
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    [self.searchBar removeFromSuperview];
}
@end
