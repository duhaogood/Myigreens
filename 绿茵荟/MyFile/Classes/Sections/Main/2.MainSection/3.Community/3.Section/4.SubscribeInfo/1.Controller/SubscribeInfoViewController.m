//
//  SubscribeInfoViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/11.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SubscribeInfoViewController.h"

@interface SubscribeInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UILabel * bySubscribeLabel;//订阅者label
@property(nonatomic,strong)NSMutableArray * post_array;//帖子数组
@end

@implementation SubscribeInfoViewController
{
    int pageNo;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
//    NSLog(@"%@",self.member_dic);
    //加载帖子数据
    pageNo = 1;
    [self loadPostArray];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //表视图
    {
        UITableView * tableView = [UITableView new];
        self.tableView = tableView;
        tableView.frame = self.view.frame;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = (WIDTH-20)/3;
        //不显示分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        //解决tableView露白
        self.automaticallyAdjustsScrollViewInsets = false;
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
    //背景view
    UIView * back_view = [UIView new];
    float top = 0;
    back_view.frame = CGRectMake(0, 0, WIDTH, 480);
    self.tableView.tableHeaderView = back_view;
    //背景图
    UIImageView * back_imgV = [UIImageView new];
    {
        back_imgV.frame = [MYTOOL getRectWithIphone_six_X:0 andY:0 andWidth:375 andHeight:230];
        [back_view addSubview:back_imgV];
#warning 以后改
        back_imgV.image = [UIImage imageNamed:@"test_bg"];
    }
    //返回按钮
    {
        UIButton * back_btn = [UIButton new];
        back_btn.frame = CGRectMake(20, 25, 30, 30);
        [back_btn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [back_btn addTarget:self action:@selector(popUpViewController) forControlEvents:UIControlEventTouchUpInside];
        [back_view addSubview:back_btn];
        
    }
    //头像
    {
        UIImageView * user_icon = [UIImageView new];
        user_icon.frame = CGRectMake(WIDTH/2-40, back_imgV.frame.size.height-50, 80, 80);
#warning 头像暂时写死，以后改
        user_icon.image = [UIImage imageNamed:@"test_user"];
        user_icon.layer.masksToBounds = true;
        user_icon.layer.cornerRadius = 40;
        [back_view addSubview:user_icon];
        top = back_imgV.frame.size.height + 30+5;
    }
    //用户名字--nickName
    {
        UILabel * name_label = [UILabel new];
        name_label.frame = CGRectMake(WIDTH/4, top, WIDTH/2, 24);
        name_label.font = [UIFont systemFontOfSize:24];
        name_label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        [back_view addSubview:name_label];
        name_label.textAlignment = NSTextAlignmentCenter;
        NSString * name = self.member_dic[@"nickName"];
        if (!name || name.length == 0) {
            name = @"匿名用户";
        }
        name_label.text = name;
        top += 34-5;
    }
    //个人签名---signature
    {
        UILabel * signature_label = [UILabel new];
        NSString * signature = self.member_dic[@"signature"];
        if (!signature || signature.length == 0) {
            signature = @"匿名用户阿斯蒂芬里撒范德阿斯蒂芬范德萨范德萨萨里撒范德阿斯蒂芬范德萨范德萨萨";
        }
        signature_label.textAlignment = NSTextAlignmentCenter;
        signature_label.text = signature;
        signature_label.font = [UIFont systemFontOfSize:15];
        signature_label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:signature andFont:signature_label.font];
        int c = size.width/(WIDTH-20) < 1 ? 1 : (size.width/(WIDTH-20) == 1 ? 1 : (int)size.width/(WIDTH-20) + 1);
        if (c > 1) {
            signature_label.numberOfLines = 0;
        }
        signature_label.frame = CGRectMake(10, top, WIDTH-20, size.height*c);
        [back_view addSubview:signature_label];
        top += size.height*c + 10-5;
    }
    //城市
    {
        UIImageView * city_icon = [UIImageView new];
        city_icon.image = [UIImage imageNamed:@"icon_location"];
        [back_view addSubview:city_icon];
        UILabel * city_label = [UILabel new];
        city_label.text = @"江苏 南京";
        city_label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        city_label.font = [UIFont systemFontOfSize:12];
        [back_view addSubview:city_label];
        CGSize size = [MYTOOL getSizeWithString:city_label.text andFont:city_label.font];
        city_label.frame = CGRectMake(WIDTH/2 - (size.width-15)/2, top, size.width, 12);
        city_icon.frame = CGRectMake(WIDTH/2 - (size.width-15)/2 - 15, top-1, 15, 15);
        top += 25-5;
    }
    //订阅-subscribeCount    被订阅数bySubscribeCount
    {
        //分割线
        {
            UIView * space_view = [UIView new];
            space_view.frame = CGRectMake(WIDTH/2-0.5, top+3, 1, 10);
            [back_view addSubview:space_view];
            space_view.backgroundColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        }
        NSString * subscribeCount = [NSString stringWithFormat:@"%ld",[self.member_dic[@"subscribeCount"] longValue]];
        NSString * bySubscribeCount = [NSString stringWithFormat:@"%ld",[self.member_dic[@"subscribeMember"] longValue]];
        //订阅-subscribeCount
        {
            NSString * string = [NSString stringWithFormat:@"%@订阅",subscribeCount];
            UILabel * label = [UILabel new];
            label.text = string;
            label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
            label.font = [UIFont systemFontOfSize:15];
            CGSize size = [MYTOOL getSizeWithString:string andFont:label.font];
            label.frame = CGRectMake(WIDTH/2-size.width-10, top, size.width, 16);
            [back_view addSubview:label];
        }
        //被订阅数bySubscribeCount
        {
            NSString * string = [NSString stringWithFormat:@"%@订阅者",bySubscribeCount];
            UILabel * label = [UILabel new];
            label.text = string;
            label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
            label.font = [UIFont systemFontOfSize:15];
            label.frame = CGRectMake(WIDTH/2+10, top, WIDTH/2, 16);
            [back_view addSubview:label];
            self.bySubscribeLabel = label;
        }
        top += 26-5;
    }
    //订阅按钮
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(WIDTH/2-50, top, 100, 36);
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_info_follow_nor"
                                 ] forState:UIControlStateNormal];
        [btn setTitle:@"订阅" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [back_view addSubview:btn];
        top += 46;
        //subscribeStatus
        bool state = [self.member_dic[@"subscribeStatus"] boolValue];
        if (state) {
            [btn setTitle:@"已订阅" forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(subscribe_callBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    //他的发布   标题
    {
        UIImageView * imgV = [UIImageView new];
        imgV.frame = CGRectMake(WIDTH/2-72, top, 144, 42);
        imgV.image = [UIImage imageNamed:@"pic_info_frame"];
        [back_view addSubview:imgV];
        top += 47;
        //文字
        UILabel * label = [UILabel new];
        label.text = @"Ta的发布";
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(WIDTH/2-65, imgV.frame.origin.y + imgV.frame.size.height/2-9, 130, 18);
        label.font = [UIFont systemFontOfSize:18];
        [back_view addSubview:label];
        
        
    }
    back_view.frame = CGRectMake(0, 0, WIDTH, top);
    
}
#pragma mark - 用户点击事件
//订阅
-(void)subscribe_callBack:(UIButton *)btn{
    NSString * interface_name = @"/community/modifySubscribe.intf";
    NSString * operate = [btn.currentTitle isEqualToString:@"订阅"] ? @"add" : @"del";
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:self.member_dic[@"memberId"] forKey:@"byMemberId"];
    [send_dic setValue:operate forKey:@"operate"];
    [SVProgressHUD showWithStatus:@"请求中…" maskType:SVProgressHUDMaskTypeClear];
//    NSLog(@"send:%@",send_dic);
    [MYNETWORKING getWithInterfaceName:interface_name andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
        [self refreshView];
        if ([btn.currentTitle isEqualToString:@"订阅"]) {
            [btn setTitle:@"已订阅" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"订阅" forState:UIControlStateNormal];
        }
//        NSLog(@"%@",back_dic);
    }];
    
}
#pragma mark - 上拉、下拉刷新
-(void)headerRefresh{
    pageNo = 1;
    [self loadPostArray];
}
-(void)footerRefresh{
    pageNo ++;
    [self loadPostArray];
}
//加载帖子数据
-(void)loadPostArray{
    NSString * memberId = self.member_dic[@"memberId"];//[MYTOOL getProjectPropertyWithKey:@"memberId"];
    NSDictionary * send_dic = @{
                                @"memberId":memberId,
                                @"pageNo":[NSString stringWithFormat:@"%d",pageNo]
                                };
    NSString * interfaceName = @"/community/getMemberPost.intf";
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
        NSArray * array = back_dic[@"postList"];
//        NSLog(@"array:%@",array);
        if (array.count == 0) {
            pageNo --;
            return;
        }
        if (pageNo == 1) {
            self.post_array = [NSMutableArray arrayWithArray:array];
        }else{
            [self.post_array addObjectsFromArray:array];
        }
        [self.tableView reloadData];
//        NSLog(@"array:%ld",array.count);
    } andFailure:^(NSError *error_failure) {
        
    }];
    /*
     Ø接口地址：/community/getMemberPost.intf
     Ø接口描述：查看其它用户或者自己下面已经发布过的帖子
     Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     memberId	用户Id	数字	是
     pageNo	页数	数字	是
     */
}
//刷新界面
-(void)refreshView{
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:self.member_dic[@"memberId"] forKey:@"byMemberId"];
    [SVProgressHUD showWithStatus:@"刷新中" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getOtherUser.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        self.member_dic = back_dic[@"member"];
        NSString * bySubscribeCount = [NSString stringWithFormat:@"%ld",[self.member_dic[@"bySubscribeCount"] longValue]];
        NSString * string = [NSString stringWithFormat:@"%@订阅者",bySubscribeCount];
        self.bySubscribeLabel.text = string;
//        NSLog(@"刷新:%@",back_dic);
    }];
    
    
    
    
    
    
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rows = self.post_array.count/3;
    if (self.post_array.count - 3 * rows > 0) {
        return rows + 1;
    }
    return rows;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //图片
    {
        //3789794_135903129000_2.jpg
        for (int i = 0; i < 3; i ++) {
            if (i+indexPath.row*3 >= self.post_array.count) {
                continue;
            }
            UIImageView * imgV = [UIImageView new];
            imgV.frame = CGRectMake(10+(WIDTH-20)/3*i, 5, (WIDTH-20)/3-5, tableView.rowHeight-10);
            imgV.image = [UIImage imageNamed:@"3789794_135903129000_2.jpg"];
            //缩略图
            NSDictionary * post = self.post_array[i+indexPath.row*3];
            NSInteger postId = [post[@"postId"] longValue];
//            NSLog(@"post:%@",post);
            NSString * url_string = post[@"url"][0][@"smallUrl"];
            if (url_string) {
                [imgV sd_setImageWithURL:[NSURL URLWithString:url_string]];
            }
            imgV.tag = postId;
            imgV.layer.masksToBounds = true;
            imgV.layer.cornerRadius = 12;
            [cell addSubview:imgV];
            imgV.userInteractionEnabled = true;
            //添加点按击手势监听器
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPostInfo:)];
            //设置手势属性
            tapGesture.numberOfTapsRequired=1;//设置点按次数，默认为1，注意在iOS中很少用双击操作
            tapGesture.numberOfTouchesRequired=1;//点按的手指数
            [imgV addGestureRecognizer:tapGesture];
        }
    }
    return cell;
}
//查看帖子详情
-(void)showPostInfo:(UITapGestureRecognizer *)tap{
    UIView * view = tap.view;
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:[NSString stringWithFormat:@"%ld",view.tag] forKey:@"postId"];
    
    
    //开始请求
    [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        bool flag = [back_dic[@"code"] boolValue];
        if (flag) {
            [SVProgressHUD dismiss];
            PostInfoViewController * postVC = [PostInfoViewController new];
            postVC.title = @"帖子详情";
            postVC.post_dic = back_dic[@"post"];
            [self.navigationController pushViewController:postVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
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
    [self.navigationController setNavigationBarHidden:true];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    [self.navigationController setNavigationBarHidden:false];
}
@end
