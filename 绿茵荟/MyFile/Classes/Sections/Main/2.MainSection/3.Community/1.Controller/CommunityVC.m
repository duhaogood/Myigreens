//
//  CommunityVC.m
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "CommunityVC.h"
#import "SelectView.h"
#import "CircleView.h"
#import "AddSubscribeViewController.h"
#import "TopTenViewController.h"
#import "SubmitPostViewController.h"
#import "SDCycleScrollView.h"
#import "TextBannerVC.h"
#import "GoodsInfoViewController.h"
#import "GoodsBannerVC.h"
@interface CommunityVC ()<UITableViewDataSource,UITableViewDelegate,SDCycleScrollViewDelegate>
@property(nonatomic,strong)NSMutableDictionary * btn_location_dic;
@property(nonatomic,strong)UIImageView * imgV_downOfBtn;
@property(nonatomic,strong)NSMutableDictionary * data_select_dictionary;//显示数据
@property(nonatomic,strong)UIView * view_downOfImageView_circleView;
@property(nonatomic,strong)UIView * navigation_titleView;//navigationbar中间view
@property(nonatomic,strong)NSMutableArray * data_array;//显示的数组
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UITextField * assist_tf;//辅助文本框，不显示
@property(nonatomic,strong)NSArray * bannerArray;//banner数组
@property(nonatomic,strong)UIButton * firstBtn;//精选按钮
@property(nonatomic,strong)UIView * noDateView;//订阅没有数据时显示
@end

@implementation CommunityVC
{
    UIButton * current_btn;//目前显示的按钮
    UIView * current_view;//目前显示的view
    NSDictionary * circle_image_title_dictionary;//文字对应UIImageView及图标名字
    NSString * current_title_circle_img_title;//圈子中目前标题 0 - 6
    NSString * current_circle_lower_value;//圈子中按钮获取数据的根据
    UIView * down_img_circle_view;//圈子中下册视图
    NSArray * circle_imgTitle_array;//圈子下图标标题
    NSArray * circle_imgUrl_array;//圈子下图标url
    NSArray * circle_img_title_value_array;//圈子下图标、标题、value数组
    int pageNo;//数据分页数
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.donotUpdate = false;
    self.assist_tf = [UITextField new];
    self.assist_tf.frame = CGRectMake(0, -1000, 10, 10);
    [self.view addSubview:self.assist_tf];
    self.view.backgroundColor = [UIColor whiteColor];
    //加载主页面
    [self loadMainView];
    //加载默认数据
    pageNo = 1;
    
    SelectView * select_view = [[SelectView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64) andDataDictionary:nil andDelegate:self withBannerArray:self.bannerArray];
    //[self.view addSubview:select_view];
    [self.view insertSubview:select_view atIndex:0];
    current_view = select_view;
    select_view.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self headerRefresh];
        // 结束刷新
        [select_view.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    select_view.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    select_view.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self footerRefresh];
        [select_view.mj_footer endRefreshing];
    }];
    self.tableView = select_view;
    [self loadDefaultData];
    [self loadBannerData];
}
//加载主页面
-(void)loadMainView{
    //发帖按钮
    UIButton * submitPostBtn = [UIButton new];
    [submitPostBtn setImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
    submitPostBtn.frame = CGRectMake(WIDTH-80, HEIGHT-49-150, 60, 60);
    [self.view insertSubview:submitPostBtn atIndex:9999];
    [submitPostBtn addTarget:self action:@selector(submitPostBtnBack) forControlEvents:UIControlEventTouchUpInside];
    //中间view
    
    UIView * center_view = [UIView new];
    self.navigation_titleView = center_view;
    center_view.frame = CGRectMake(WIDTH/4, 0, WIDTH/2, 44);
    //    center_view.backgroundColor = [UIColor greenColor];
    [self.navigationController.navigationBar addSubview:center_view];
    self.btn_location_dic = [NSMutableDictionary new];
    //3个按钮  ,44 ,高度30,宽度50
    //精选
    UIButton * select_btn = [UIButton new];
    select_btn.frame = CGRectMake(center_view.frame.size.width/6-25, 6, 50, 30);
    [select_btn setTitle:@"精选" forState:UIControlStateNormal];
    self.firstBtn = select_btn;
    select_btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [center_view addSubview:select_btn];
    current_btn = select_btn;
    [self.btn_location_dic setValue:[NSString stringWithFormat:@"%.2f",select_btn.frame.size.width/2-18+center_view.frame.size.width/6-25] forKey:@"精选"];
    [select_btn addTarget:self action:@selector(submitCenterBtn:) forControlEvents:UIControlEventTouchUpInside];
    //按钮下方白条
    UIImageView * whiteImgV = [UIImageView new];
    whiteImgV.frame = CGRectMake(select_btn.frame.size.width/2-18+center_view.frame.size.width/6-25, 41, 36, 3);
    whiteImgV.image = [UIImage imageNamed:@"banner_dot_nor"];
    [center_view addSubview:whiteImgV];
    self.imgV_downOfBtn = whiteImgV;
    //圈子
    UIButton * circle_btn = [UIButton new];
    circle_btn.frame = CGRectMake(center_view.frame.size.width/2-25, 6, 50, 30);
    [circle_btn setTitle:@"圈子" forState:UIControlStateNormal];
    [center_view addSubview:circle_btn];
    circle_btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.btn_location_dic setValue:[NSString stringWithFormat:@"%.2f",center_view.frame.size.width/2-18] forKey:@"圈子"];
    [circle_btn addTarget:self action:@selector(submitCenterBtn:) forControlEvents:UIControlEventTouchUpInside];
    //订阅
    UIButton * subscribe_btn = [UIButton new];
    subscribe_btn.frame = CGRectMake(center_view.frame.size.width/6*5-25, 6, 50, 30);
    [subscribe_btn setTitle:@"订阅" forState:UIControlStateNormal];
    [center_view addSubview:subscribe_btn];
    subscribe_btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.btn_location_dic setValue:[NSString stringWithFormat:@"%.2f",subscribe_btn.frame.origin.x+subscribe_btn.frame.size.width/2-18] forKey:@"订阅"];
    [subscribe_btn addTarget:self action:@selector(submitCenterBtn:) forControlEvents:UIControlEventTouchUpInside];
    
}
//加载圈子下选择view
-(void)loadViewOfCircle:(UIView *)mainView{
    //上部按钮及文字
    {
        UIScrollView * view = [UIScrollView new];
        view.frame = CGRectMake(0, 0, WIDTH, 55);
        [mainView addSubview:view];
        view.contentSize =  CGSizeMake(WIDTH*circle_img_title_value_array.count/5.7, 0);
        
        circle_image_title_dictionary = [NSMutableDictionary new];
        for (int i = 0; i < circle_img_title_value_array.count; i ++) {
            //按钮
            UIButton * btn = [UIButton new];
            [btn setTitle:circle_img_title_value_array[i][@"label"] forState:UIControlStateNormal];
            [btn setTitleColor:[MYTOOL RGBWithRed:92 green:92 blue:92 alpha:1] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            float btn_width = view.contentSize.width/circle_img_title_value_array.count;
            btn.frame = CGRectMake(btn_width*i, 15, btn_width, 20);
            btn.tag = i;
            [btn addTarget:self action:@selector(submitCircleTitleBtn:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
            NSDictionary * dic = @{
                                   @"btn":btn,
                                   @"icon":circle_img_title_value_array[i][@"url"],
                                   @"value":circle_img_title_value_array[i][@"value"]
                                   };
            [circle_image_title_dictionary setValue:dic forKey:btn.currentTitle];
        }
        // 83 131 40
        float center_x = (view.contentSize.width/circle_img_title_value_array.count)/2;
        UIView * down_view = [UIView new];
        down_view.backgroundColor = [DHTOOL RGBWithRed:83 green:131 blue:40 alpha:1];
        down_view.frame = CGRectMake(center_x - 15, 40, 30, 4);
        [view addSubview:down_view];
        self.view_downOfImageView_circleView = down_view;
        current_title_circle_img_title = circle_imgTitle_array[0];
        current_circle_lower_value = circle_img_title_value_array[0][@"value"];
        
    }
    //中间分割线
    UIView * space_view_mid = [UIView new];
    space_view_mid.backgroundColor = [DHTOOL RGBWithRed:227 green:227 blue:227 alpha:1];
    space_view_mid.frame = CGRectMake(0, 45, WIDTH, 10);
    [mainView addSubview:space_view_mid];
    
    //加载下部视图
    [self loadCircleViewWithCurrent_title_circle_img:current_title_circle_img_title  withDirection:2];
    
}
//根据current_title_circle_img 加载下部视图 1右   0左 2下
-(void)loadCircleViewWithCurrent_title_circle_img:(NSString *)current_title_circle_img  withDirection:(int)direction{
    [down_img_circle_view removeFromSuperview];
    UITableView * down_view = [UITableView new];
    down_view.dataSource = self;
    down_view.delegate = self;
    down_view.rowHeight = HEIGHT/2.5;
    down_img_circle_view = down_view;
    down_view.frame = CGRectMake(direction ? -WIDTH : WIDTH, 55, WIDTH, HEIGHT - 55-64-49);
    [current_view addSubview:down_view];
    down_view.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self headerRefresh];
        // 结束刷新
        [down_view.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    down_view.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    down_view.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self footerRefresh];
        [down_view.mj_footer endRefreshing];
    }];
    self.tableView = down_view;
    //覆盖一个没有数据时显示的view
    {
        UIView * view = [UIView new];
        view.frame = down_view.bounds;
        self.noDateView = view;
        view.hidden = true;
        [down_view addSubview:view];
        view.backgroundColor = [MYTOOL RGBWithRed:240 green:240 blue:240 alpha:1];
        //没有数据提示
        {
            UILabel * label = [UILabel new];
            label.text = @"暂无此类型的帖子数据";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = MYCOLOR_46_42_42;
            label.font = [UIFont systemFontOfSize:15];
            label.frame = CGRectMake(0, 10, WIDTH, 20);
            [view addSubview:label];
        }
    }
    //加载数据
    [self loadDefaultData];
    
    if (direction == 2) {
        down_view.frame = CGRectMake(0 , -HEIGHT, WIDTH, HEIGHT - 55-64-49);
    }
    down_view.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        down_view.alpha = 1;
        down_view.frame = CGRectMake(0, 55, WIDTH, HEIGHT - 55-64-49);
    }];
    
}
//圈子文字按钮回调
-(void)submitCircleTitleBtn:(UIButton *)btn{
    NSLog(@"%@",btn.currentTitle);
    NSString * title = btn.currentTitle;
    if ([current_title_circle_img_title isEqualToString:title]) {
        return;
    }
    NSInteger index1 = [circle_imgTitle_array indexOfObject:current_title_circle_img_title];
    NSInteger index2 = [circle_imgTitle_array indexOfObject:title];
    current_title_circle_img_title = title;
    pageNo = 1;
    //    NSLog(@"点击了--%@,图片名字:%@",title,circle_image_title_dictionary[current_title_circle_img_title][@"icon"]);
    float center_x = btn.frame.origin.x + btn.frame.size.width/2;
    [UIView animateWithDuration:0.3 animations:^{
        self.view_downOfImageView_circleView.frame = CGRectMake(center_x - 15, self.view_downOfImageView_circleView.frame.origin.y, _view_downOfImageView_circleView.frame.size.width, _view_downOfImageView_circleView.frame.size.height);
    }];
    [self loadCircleViewWithCurrent_title_circle_img:current_title_circle_img_title withDirection:index1>index2?0:1];
}
#pragma mark - 圈子图片按钮回调
-(void)submitCircleImageView:(UITapGestureRecognizer *)tap{
    UIImageView * imgV = (UIImageView *)tap.view;
    if (!imgV) {
        return;
    }
    NSString * title = @"";
    for (NSString * key in circle_image_title_dictionary.allKeys) {
        UIImageView * iv = circle_image_title_dictionary[key][@"imgV"];
        if ([iv isEqual:imgV]) {
            title = key;
            break;
        }
    }
    if ([current_title_circle_img_title isEqualToString:title]) {
        return;
    }
    NSInteger index1 = [circle_imgTitle_array indexOfObject:current_title_circle_img_title];
    NSInteger index2 = [circle_imgTitle_array indexOfObject:title];
    current_title_circle_img_title = title;
    pageNo = 1;
//    NSLog(@"点击了--%@,图片名字:%@",title,circle_image_title_dictionary[current_title_circle_img_title][@"icon"]);
    float center_x = imgV.frame.origin.x + imgV.frame.size.width/2;
    [UIView animateWithDuration:0.3 animations:^{
        self.view_downOfImageView_circleView.frame = CGRectMake(center_x - 30, 65, 60, 4);
    }];
    [self loadCircleViewWithCurrent_title_circle_img:current_title_circle_img_title withDirection:index1>index2?0:1];
    
}
#pragma mark - BarButtonItem 回调
//左按钮
-(void)addOfNavigationBar{
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        loginVC.delegate = self;
        loginVC.donotUpdate = self.donotUpdate;
        [self.navigationController pushViewController:loginVC animated:true];
        return;
    }
#warning 接口可能不对
    NSString * interfaceName = @"/community/getTop10.intf";
    [SVProgressHUD showWithStatus:@"获取订阅" maskType:SVProgressHUDMaskTypeClear];
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:@"1" forKey:@"pageNo"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        bool flag = [back_dic[@"code"] boolValue];
        NSArray * array = back_dic[@"memberList"];
        if (flag) {
            AddSubscribeViewController * addVC = [AddSubscribeViewController new];
            addVC.title = @"添加订阅";
            addVC.member_array = [NSMutableArray new];
            [addVC.member_array addObjectsFromArray:array];
            [self.navigationController pushViewController:addVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
        }
    }];
    
}
//右按钮
-(void)topOfNavigationBar{
    NSString * interfaceName = @"/community/getTop10.intf";
    [SVProgressHUD showWithStatus:@"获取top10…" maskType:SVProgressHUDMaskTypeClear];
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
   
    [send_dic setValue:@"1" forKey:@"pageNo"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        bool flag = [back_dic[@"code"] boolValue];
        NSArray * array = back_dic[@"memberList"];
        if (flag) {
            [SVProgressHUD dismiss];
            TopTenViewController * topVC = [TopTenViewController new];
            topVC.title = @"本周排行TOP10";
            topVC.top_10_array = array;
            [self.navigationController pushViewController:topVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
        }
    }];
    /*
     7.10本周TOP10和订阅推荐用户
     Ø接口地址：/community/getTop10.intf
     Ø接口描述：获取top10和订阅推荐用户
     37.38.38.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     pageNo	页数	数字	是
     content	搜索内容	字符串	否
     */
    
}
#pragma mark - 中间3个按钮回调 精选、圈子、订阅
-(void)submitCenterBtn:(UIButton *)btn{
    if ([btn isEqual:current_btn]) {
        return;
    }
    pageNo = 1;
    current_btn = btn;
    //按钮标签文字
    NSString * title = btn.currentTitle;
    float left = [self.btn_location_dic[title] floatValue];
    //跳转动画
    [UIView animateWithDuration:0.3 animations:^{
        self.imgV_downOfBtn.frame = CGRectMake(left, 41, 36, 3);
    }];
    [current_view removeFromSuperview];
    if ([title isEqualToString:@"精选"]) {
        SelectView * select_view = [[SelectView alloc]initWithFrame:CGRectMake(0, 10, WIDTH, HEIGHT-64-49-10) andDataDictionary:nil andDelegate:self withBannerArray:self.bannerArray];
        //[self.view addSubview:select_view];
        [self.view insertSubview:select_view atIndex:0];
        current_view = select_view;
        select_view.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self headerRefresh];
            // 结束刷新
            [select_view.mj_header endRefreshing];
        }];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        select_view.mj_header.automaticallyChangeAlpha = YES;
        
        // 上拉刷新
        select_view.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self footerRefresh];
            [select_view.mj_footer endRefreshing];
        }];
        //覆盖一个没有数据时显示的view
        {
            UIView * view = [UIView new];
            view.frame = select_view.bounds;
            self.noDateView = view;
            view.hidden = true;
            [select_view addSubview:view];
            view.backgroundColor = [MYTOOL RGBWithRed:240 green:240 blue:240 alpha:1];
            //没有数据提示
            {
                UILabel * label = [UILabel new];
                label.text = @"暂无此类型的帖子数据";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = MYCOLOR_46_42_42;
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(0, 10, WIDTH, 20);
                [view addSubview:label];
            }
        }
        self.tableView = select_view;
        [self loadDefaultData];
    }else if ([title isEqualToString:@"圈子"]) {
        UIView * circle_view = [UIView new];
        circle_view.frame = self.view.bounds;
        //[self.view addSubview:circle_view];
        [self.view insertSubview:circle_view atIndex:0];
        current_view = circle_view;
        
        
        [self loadViewOfCircle:circle_view];
        
        
    }else{//订阅
        if (![MYTOOL isLogin]) {
            [self submitCenterBtn:self.firstBtn];
            //跳转至登录页
            LoginViewController * loginVC = [LoginViewController new];
            loginVC.delegate = self;
            loginVC.donotUpdate = self.donotUpdate;
            [self.navigationController pushViewController:loginVC animated:true];
            return ;
        }
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 10-HEIGHT, WIDTH, HEIGHT - 74 - 49);
        [UIView animateWithDuration:0.3 animations:^{
            tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT - 74 - 49);
        }];
        tableView.dataSource = self;
        tableView.delegate = self;
        current_view = tableView;
        [self.view insertSubview:tableView atIndex:0];
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
        self.tableView = tableView;
        [self loadDefaultData];
        //覆盖一个没有数据时显示的view
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
                label.text = @"暂无此类型的帖子数据";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = MYCOLOR_46_42_42;
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(0, 10, WIDTH, 20);
                [view addSubview:label];
            }
        }
    }
    
    
}
#pragma mark - 上拉、下拉刷新
-(void)headerRefresh{
    pageNo = 1;
    [self getCircleTypeArray];
    [self loadDefaultData];
}
-(void)footerRefresh{
    pageNo ++;
    [self loadDefaultData];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * post_dic = self.data_array[indexPath.row];
    //NSLog(@"%@",post_dic);
    //获取帖子信息
    /*参数
     memberId	会员id
     postId	帖子id
     */
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:post_dic[@"postId"] forKey:@"postId"];
    
    
    //开始请求
    [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        bool flag = [back_dic[@"code"] boolValue];
        if (flag) {
            [SVProgressHUD dismiss];
            PostInfoViewController * postVC = [PostInfoViewController new];
            postVC.title = @"帖子详情";
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
            [dict setValue:post_dic[@"postId"] forKey:@"postId"];
            postVC.post_dic = dict;
            postVC.delegate = self;
            [self.navigationController pushViewController:postVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
        }
    }];
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data_array.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * title = current_btn.currentTitle;
    NSDictionary * data_dic = self.data_array[indexPath.row];
    //精选
    if ([title isEqualToString:@"精选"]) {
        //间距
        float space_y = [MYTOOL getHeightWithIphone_six:15];
        float height = space_y * 2 + 40;
        //简介
        {
            NSString * content = data_dic[@"content"];//内容
            if (content == nil || content.length == 0) {
                content = @"这家伙什么也没留下…";
            }
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
            label.text = content;
            CGSize size = [MYTOOL getSizeWithLabel:label];
            UILabel * label2 = [UILabel new];
            label2.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
            label2.text = @"哈哈好";
            CGSize size2 = [MYTOOL getSizeWithLabel:label2];
            int row = size.width / (WIDTH -60-10);
            if (size.width > (WIDTH -60-10)*row) {
                row ++;
            }
            if (row > 2) {
                row = 2;
            }
            height += space_y + size2.height * row;
        }
        //图片 150-180
        {
            float width_img = (WIDTH - 65 - 30)/2;
            float height_img = width_img / 150 *180;
            height += height_img + space_y;
        }
        height += 30;
        return height;
    }else if([title isEqualToString:@"圈子"]){
        return 225;
    }else{
        return 383;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * data_dic = self.data_array[indexPath.row];
//    NSLog(@"%ld-----%@",indexPath.row,data_dic);

    NSString * releaseTime = data_dic[@"releaseTime"];//距离当前的发布时间
    NSString * content = data_dic[@"content"];//内容
    if (content == nil || content.length == 0) {
        content = @"这家伙什么也没留下…";
    }
    NSString * commentCount = [NSString stringWithFormat:@"%ld",[data_dic[@"commentCount"] longValue]];//评论数量
    NSString * praiseCount = [NSString stringWithFormat:@"%ld",[data_dic[@"praiseCount"] longValue]];//赞的数量
    NSString * headUrl = data_dic[@"member"][@"headUrl"];//用户头像连接
    NSString * post_memberId = [NSString stringWithFormat:@"%ld",[data_dic[@"member"][@"memberId"]longValue]];//用户id
    NSString * nickName = data_dic[@"member"][@"nickName"];//用户昵称
    NSString * signature = data_dic[@"member"][@"signature"];//个性签名
    
    if (signature == nil || signature.length == 0) {
        signature = @"这家伙什么也没留下…阿萨德";
    }
    NSArray * image_array = data_dic[@"url"];//帖子图片数组
    NSInteger postId = [data_dic[@"postId"] longValue];
    
    bool praiseStatus = [data_dic[@"praiseStatus"] boolValue];//状态
    //间距
    float space_y = [MYTOOL getHeightWithIphone_six:15];
    //圈子
    UITableViewCell * cell = [UITableViewCell new];
    if ([current_btn.currentTitle isEqualToString:@"精选"]) {
        float top = 0;
        //头像
        {
            float user_width = 40;
            UIImageView * userImgView = [UIImageView new];
            userImgView.frame = CGRectMake(10, space_y, user_width, user_width);
        
            //        userImgView.backgroundColor = [UIColor greenColor];
            [cell addSubview:userImgView];
            userImgView.layer.masksToBounds = true;
            userImgView.layer.cornerRadius = user_width/2;
            
            [userImgView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
            //添加点击事件
            userImgView.userInteractionEnabled = true;
            userImgView.tag = indexPath.row;
            [userImgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUserImage:)];
            tapGesture.numberOfTapsRequired=1;
            [userImgView addGestureRecognizer:tapGesture];
        }
        //名字
        {
            UILabel * label = [UILabel new];
            label.text = nickName;
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
            label.frame = CGRectMake(60,space_y+10 , WIDTH - 75, 20);
            [cell addSubview:label];
            top = space_y * 2 + 40;
        }
        //简介
        {
            UILabel * tv = [UILabel new];
            tv.text = content;
            tv.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
            tv.userInteractionEnabled = NO;
            tv.textColor = [MYTOOL RGBWithRed:79 green:79 blue:79 alpha:1];
            CGSize size = [MYTOOL getSizeWithLabel:tv];
            int row = size.width / (WIDTH -60-10);
            if (size.width > (WIDTH -60-10)*row) {
                row ++;
            }
            if (row > 1) {
                tv.numberOfLines = 0;
            }
            if (row > 2) {
                row = 2;
                //过滤换行
                NSString * string = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
                NSString * text = @"";
                for(int i = 0; i < string.length ; i ++){
                    text = [string substringToIndex:i];
                    tv.text = text;
                    size = [MYTOOL getSizeWithLabel:tv];
                    if (size.width >= (WIDTH -60-10) * 1.8) {
//                        NSLog(@"text:%@",text);
                        break;
                    }
                }
            }
            tv.frame = CGRectMake(60, top, WIDTH -60-10, size.height*row);
            [cell addSubview:tv];
            top += size.height*row + space_y;
        }
        //图片
        {
            float width_img = (WIDTH - 65 - 30)/2;
            float height_img = width_img / 150 *180;
            if (image_array.count == 1) {
                UIImageView * iv1 = [UIImageView new];
                iv1.contentMode = UIViewContentModeScaleAspectFill;
                iv1.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [iv1 setContentScaleFactor:[[UIScreen mainScreen] scale]];
                iv1.frame = CGRectMake(65,top, width_img, height_img);
                iv1.layer.masksToBounds = true;
//                iv1.layer.cornerRadius = 10;
                [iv1 sd_setImageWithURL:[NSURL URLWithString:image_array[0][@"normalUrl"]] placeholderImage:[UIImage imageNamed:@"bg"]];
                [cell addSubview:iv1];
            }else{
                //1
                UIImageView * iv1 = [UIImageView new];
                iv1.contentMode = UIViewContentModeScaleAspectFill;
                iv1.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [iv1 setContentScaleFactor:[[UIScreen mainScreen] scale]];
                iv1.frame = CGRectMake(65,top , width_img, height_img);
                iv1.layer.masksToBounds = true;
//                iv1.layer.cornerRadius = 10;
                [iv1 sd_setImageWithURL:[NSURL URLWithString:image_array[0][@"normalUrl"]] placeholderImage:[UIImage imageNamed:@"bg"]];
                [cell addSubview:iv1];
                //2
                UIImageView * iv2 = [UIImageView new];
                iv2.contentMode = UIViewContentModeScaleAspectFill;
                iv2.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [iv2 setContentScaleFactor:[[UIScreen mainScreen] scale]];
                iv2.frame = CGRectMake(65 + iv1.frame.size.width+10,top , width_img, height_img);
                iv2.layer.masksToBounds = true;
//                iv2.layer.cornerRadius = 10;
                [iv2 sd_setImageWithURL:[NSURL URLWithString:image_array[1][@"normalUrl"]] placeholderImage:[UIImage imageNamed:@"Icon60"]];
                [cell addSubview:iv2];
            }
            top += height_img + space_y;
        }
        
        //下边小图标及数字
        {
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"icon_praise"] forState:UIControlStateNormal];
            if (praiseStatus) {
                [btn setImage:[UIImage imageNamed:@"icon_praise_press"] forState:UIControlStateNormal];
            }
            btn.frame = CGRectMake(WIDTH/2-30, top, 30, 30);
            [btn addTarget:self action:@selector(praise_callBack:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = postId * 10 + [data_dic[@"praiseStatus"] intValue];
            [cell addSubview:btn];
            
            {
                //数字
                UILabel * num_label1 = [UILabel new];
                num_label1.text = praiseCount;
                num_label1.frame = CGRectMake(WIDTH/2, top+5, WIDTH/6, 20);
                num_label1.font = [UIFont systemFontOfSize:12];
                [cell addSubview:num_label1];
                
                //下边小图标  icon_message
                UIImageView * icon2 = [UIImageView new];
                icon2.image = [UIImage imageNamed:@"icon_message"];
                icon2.frame = CGRectMake((WIDTH-10-35-25 - WIDTH/2)/2+WIDTH/2-15, top, 30, 30);
                [cell addSubview:icon2];
                //绑定监听
                [icon2 setUserInteractionEnabled:YES];
                icon2.tag = postId * 10 + 2;
                UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
                tapGesture2.numberOfTapsRequired=1;
                [icon2 addGestureRecognizer:tapGesture2];
                
                //数字
                UILabel * num_label2 = [UILabel new];
                num_label2.text = commentCount;
                num_label2.frame = CGRectMake((WIDTH-10-35-25 - WIDTH/2)/2+WIDTH/2+30-15, top+4, WIDTH/6-20, 20);
                num_label2.font = [UIFont systemFontOfSize:12];
                [cell addSubview:num_label2];
                
                //下边小图标  icon_message
                UIImageView * icon3 = [UIImageView new];
                icon3.image = [UIImage imageNamed:@"icon_share"];
                icon3.frame = CGRectMake(WIDTH-10-35-25, top, 30, 30);
                [cell addSubview:icon3];
                //绑定监听
                [icon3 setUserInteractionEnabled:YES];
                icon3.tag = postId * 10 + 3;
                UITapGestureRecognizer * tapGesture3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
                tapGesture3.numberOfTapsRequired=1;
                [icon3 addGestureRecognizer:tapGesture3];
                
                //数字
                UILabel * num_label3 = [UILabel new];
                num_label3.text = @"分享";
                num_label3.frame = CGRectMake(WIDTH-10-35, top+5, 40, 20);
                num_label3.font = [UIFont systemFontOfSize:12];
                [cell addSubview:num_label3];
            }
            top += 30;
        }
        //分割线
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [DHTOOL RGBWithRed:227 green:227 blue:227 alpha:1];
        spaceView.frame = CGRectMake(20, top-1, WIDTH-40, 1);
        [cell addSubview:spaceView];
    }else if ([current_btn.currentTitle isEqualToString:@"圈子"]) {
        tableView.rowHeight = 225;
        //图片
        {
            UIImageView * iv1 = [UIImageView new];
            iv1.contentMode = UIViewContentModeScaleAspectFill;
            iv1.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [iv1 setContentScaleFactor:[[UIScreen mainScreen] scale]];
            iv1.frame = CGRectMake(10,10 , WIDTH - 20, 169);
            iv1.layer.masksToBounds = true;
//            iv1.layer.cornerRadius = 10;
            [iv1 sd_setImageWithURL:[NSURL URLWithString:image_array[0][@"normalUrl"]] placeholderImage:[UIImage imageNamed:@"bg"]];
            [cell addSubview:iv1];
            
        }

        //头像
        {
            float user_width = 40;
            UIImageView * userImgView = [UIImageView new];
            userImgView.frame = CGRectMake(WIDTH/2-20, 35, user_width, user_width);
            [cell addSubview:userImgView];
            userImgView.layer.masksToBounds = true;
            userImgView.layer.cornerRadius = user_width/2;
            [userImgView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
            
            //添加点击事件
            userImgView.userInteractionEnabled = true;
            userImgView.tag = indexPath.row;
            [userImgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUserImage:)];
            tapGesture.numberOfTapsRequired=1;
            [userImgView addGestureRecognizer:tapGesture];
        }
        //名字
        {
            UILabel * label = [UILabel new];
            label.text = nickName;
            label.font = [UIFont systemFontOfSize:24];
            label.textColor = [UIColor whiteColor];
            label.frame = CGRectMake(WIDTH/4, 79, WIDTH/2, 24);
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            [cell addSubview:label];
        }
        //简介
        {
            UILabel * tv = [UILabel new];
            tv.text = signature;
            tv.font = [UIFont systemFontOfSize:15];
            tv.textColor = [UIColor whiteColor];
            tv.frame = CGRectMake(10, 105, WIDTH - 20, 20);
            [cell addSubview:tv];
            tv.backgroundColor = [UIColor clearColor];
            tv.textAlignment = NSTextAlignmentCenter;
        }
        //时间
        {
            UILabel * label = [UILabel new];
            label.text = releaseTime;
            label.textColor = [UIColor whiteColor];
            label.frame = CGRectMake(WIDTH/4, 125, WIDTH/2, 20);
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12];
            [cell addSubview:label];
        }
        //下边小图标及数字
        {
            float top = 194-7;
            //两条分割线
            {
                UIView * space_view_1 = [UIView new];
                space_view_1.frame = CGRectMake(10+(WIDTH-20)/3, 198, 1, 10);
                space_view_1.backgroundColor = [MYTOOL RGBWithRed:112 green:112 blue:112 alpha:1];
                [cell addSubview:space_view_1];
                UIView * space_view_2 = [UIView new];
                space_view_2.frame = CGRectMake(10+(WIDTH-20)/3*2, 198, 1, 10);
                space_view_2.backgroundColor = [MYTOOL RGBWithRed:112 green:112 blue:112 alpha:1];
                [cell addSubview:space_view_2];
            }
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"icon_praise"] forState:UIControlStateNormal];
            if (praiseStatus) {
                [btn setImage:[UIImage imageNamed:@"icon_praise_press"] forState:UIControlStateNormal];
            }
            btn.frame = CGRectMake(WIDTH/6-30, top, 30, 30);
            [btn addTarget:self action:@selector(praise_callBack:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = postId * 10 + [data_dic[@"praiseStatus"] intValue];
            [cell addSubview:btn];
            {
            //数字
            UILabel * num_label1 = [UILabel new];
            num_label1.text = praiseCount;
            num_label1.frame = CGRectMake(WIDTH/6, top+5, WIDTH/6, 20);
            num_label1.font = [UIFont systemFontOfSize:12];
            [cell addSubview:num_label1];
//            num_label1.backgroundColor = [UIColor greenColor];
            //下边小图标  icon_message
            UIImageView * icon2 = [UIImageView new];
            icon2.image = [UIImage imageNamed:@"icon_message"];
            icon2.frame = CGRectMake(WIDTH/2-30, top, 30, 30);
            [cell addSubview:icon2];
            //绑定监听
            [icon2 setUserInteractionEnabled:YES];
            icon2.tag = postId * 10 + 2;
            UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
            tapGesture2.numberOfTapsRequired=1;
            [icon2 addGestureRecognizer:tapGesture2];
            
            //数字
            UILabel * num_label2 = [UILabel new];
            num_label2.text = commentCount;
            num_label2.frame = CGRectMake(WIDTH/2, top+5, WIDTH/6, 20);
            num_label2.font = [UIFont systemFontOfSize:12];
            [cell addSubview:num_label2];
//            num_label2.backgroundColor = [UIColor greenColor];
            
            //下边小图标  icon_message
            UIImageView * icon3 = [UIImageView new];
            icon3.image = [UIImage imageNamed:@"icon_share"];
            icon3.frame = CGRectMake(WIDTH*5/6-30, top, 30, 30);
            [cell addSubview:icon3];
            //绑定监听
            [icon3 setUserInteractionEnabled:YES];
            icon3.tag = postId * 10 + 3;
            UITapGestureRecognizer * tapGesture3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
            tapGesture3.numberOfTapsRequired=1;
            [icon3 addGestureRecognizer:tapGesture3];
            
            //数字
            UILabel * num_label3 = [UILabel new];
            num_label3.text = @"分享";
            num_label3.frame = CGRectMake(WIDTH*5/6, top+5, 40, 20);
            num_label3.font = [UIFont systemFontOfSize:12];
            [cell addSubview:num_label3];
            }
        }
        //分割线
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [DHTOOL RGBWithRed:227 green:227 blue:227 alpha:1];
        spaceView.frame = CGRectMake(20, tableView.rowHeight-1, WIDTH-40, 1);
        [cell addSubview:spaceView];
    }else{//订阅
        tableView.rowHeight = 383;
        float left = 0;
        //用户头像
        {
            UIImageView * userImgView = [UIImageView new];
            userImgView.frame = CGRectMake(14, 19, 41, 41);
            [userImgView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
            [cell addSubview:userImgView];
            userImgView.layer.masksToBounds = true;
            userImgView.layer.cornerRadius = 20;
            //添加点击事件
            userImgView.userInteractionEnabled = true;
            userImgView.tag = indexPath.row;
            [userImgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickUserImage:)];
            tapGesture.numberOfTapsRequired=1;
            [userImgView addGestureRecognizer:tapGesture];
        }
        //用户名字
        {
            UILabel * label = [UILabel new];
            label.text = nickName;
            label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
            label.font = [UIFont systemFontOfSize:16];
            CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
            label.frame = CGRectMake(61, 21, size.width, 18);
            [cell addSubview:label];
            left = 61+size.width+10;
        }
        //时间
        {
            UILabel * label = [UILabel new];
            label.text = releaseTime;
            label.font = [UIFont systemFontOfSize:12];
            CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
            label.frame = CGRectMake(left, 25, size.width, 12);
            label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
            [cell addSubview:label];
        }
        //右侧图标-icon_reportReporticon_report
        {
            UIImageView * right_icon = [UIImageView new];
            right_icon.frame = CGRectMake(WIDTH-38, 12, 33, 33);
            right_icon.image = [UIImage imageNamed:@"icon_reportReporticon_report"];
            [cell addSubview:right_icon];
            right_icon.tag = indexPath.row;
            [right_icon setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reportBtnCallBack:)];
            tapGesture.numberOfTapsRequired=1;
            [right_icon addGestureRecognizer:tapGesture];
            
        }
        //个性签名
        float top = 0;
        {
            UILabel * label = [UILabel new];
            //过滤换行
            signature = [signature stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            label.text = signature;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
            CGSize size = [MYTOOL getSizeWithString:signature andFont:label.font];
            int c = size.width/(WIDTH-71) < 1 ? 1 : (size.width/(WIDTH-71) == 1 ? 1 : (int)size.width/(WIDTH-71) + 1);
            if (c > 1) {
                label.numberOfLines = 0;
                c = 2;
            }
            label.frame = CGRectMake(61, 45, WIDTH-71, size.height*c);
            [cell addSubview:label];
            top = 45 + size.height*c + 10;
        }
        //内容
        {
            UILabel * label = [UILabel new];
            //过滤换行
            NSString * string = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
            label.text = string;
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = [MYTOOL RGBWithRed:79 green:79 blue:79 alpha:1];
            CGSize size = [MYTOOL getSizeWithString:string andFont:label.font];
            float width = WIDTH-71;
            int c = size.width/width < 1 ? 1 : (size.width/width == 1 ? 1 : (int)size.width/width + 1);
            if (c > 1) {
                label.numberOfLines = 0;
                if (c > 2) {
                    c = 2;
                    //过滤换行
                    string = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
                    NSString * text = @"";
                    for(int i = 0; i < string.length ; i ++){
                        text = [string substringToIndex:i];
                        label.text = text;
                        size = [MYTOOL getSizeWithLabel:label];
                        if (size.width >= (WIDTH -60-10) * 1.8) {
                            //                        NSLog(@"text:%@",text);
                            break;
                        }
                    }
                }
            }
            label.frame = CGRectMake(61, top, WIDTH-71, size.height*c);
            [cell addSubview:label];
            top += label.frame.size.height + 10;
        }
        //图片
        {
            NSArray * url_array = data_dic[@"url"];
            float height = tableView.rowHeight - top - 46;
//            NSLog(@"图片数组个数:%ld",url_array.count);
            if (url_array.count == 1) {
                UIImageView * img = [UIImageView new];
                img.contentMode = UIViewContentModeScaleAspectFill;
                img.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [img setContentScaleFactor:[[UIScreen mainScreen] scale]];
                img.image = [UIImage imageNamed:@"test_bg"];
                img.frame = CGRectMake(61, top, WIDTH-61-20, height);
                [img sd_setImageWithURL:[NSURL URLWithString:url_array[0][@"smallUrl"]] placeholderImage:[UIImage imageNamed:@"test_bg"]];
                img.layer.masksToBounds = true;
//                img.layer.cornerRadius = 12;
                [cell addSubview:img];
            }else if (url_array.count >= 2) {
                float width = (WIDTH-61-20)/2;
                //第一张图片
                UIImageView * img = [UIImageView new];
                img.contentMode = UIViewContentModeScaleAspectFill;
                img.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [img setContentScaleFactor:[[UIScreen mainScreen] scale]];
                img.frame = CGRectMake(61, top, width, height);
                [img sd_setImageWithURL:[NSURL URLWithString:url_array[0][@"smallUrl"]] placeholderImage:[UIImage imageNamed:@"test_bg"]];
                img.layer.masksToBounds = true;
//                img.layer.cornerRadius = 12;
                [cell addSubview:img];
                //第二张图片
                UIImageView * img2 = [UIImageView new];
                img2.contentMode = UIViewContentModeScaleAspectFill;
                img2.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [img2 setContentScaleFactor:[[UIScreen mainScreen] scale]];
                img2.frame = CGRectMake(61+width+5, top, width, height);
                [img2 sd_setImageWithURL:[NSURL URLWithString:url_array[1][@"smallUrl"]] placeholderImage:[UIImage imageNamed:@"9252150_170958052001_2.jpg"]];
                img2.layer.masksToBounds = true;
//                img2.layer.cornerRadius = 12;
                [cell addSubview:img2];
            }
            top += height;
        }
        //下册小图标
        {
            float y_center = (tableView.rowHeight - top) / 2 + top;
            //点赞
            {
                UIButton * btn = [UIButton new];
                [btn setImage:[UIImage imageNamed:@"icon_praise"] forState:UIControlStateNormal];
                if (praiseStatus) {
                    [btn setImage:[UIImage imageNamed:@"icon_praise_press"] forState:UIControlStateNormal];
                }
                btn.frame = CGRectMake(WIDTH/2-30, y_center-15, 30, 30);
                [btn addTarget:self action:@selector(praise_callBack:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = postId * 10 + [data_dic[@"praiseStatus"] intValue];
                [cell addSubview:btn];
                
                //数字
                UILabel * num_label1 = [UILabel new];
                num_label1.text = praiseCount;
                num_label1.frame = CGRectMake(WIDTH/2, y_center-8, WIDTH/6, 16);
                num_label1.font = [UIFont systemFontOfSize:15];
                [cell addSubview:num_label1];
            }
            //消息
            {
                //下边小图标  icon_message
                UIImageView * icon2 = [UIImageView new];
                icon2.image = [UIImage imageNamed:@"icon_message"];
                icon2.frame = CGRectMake((WIDTH-10-35-25 - WIDTH/2)/2+WIDTH/2-15, y_center-15, 30, 30);
                [cell addSubview:icon2];
                //绑定监听
                [icon2 setUserInteractionEnabled:YES];
                icon2.tag = postId * 10 + 2;
                UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
                tapGesture2.numberOfTapsRequired=1;
                [icon2 addGestureRecognizer:tapGesture2];
                
                //数字
                UILabel * num_label2 = [UILabel new];
                num_label2.text = commentCount;
                num_label2.frame = CGRectMake((WIDTH-10-35-25 - WIDTH/2)/2+WIDTH/2+30-15, y_center- 8, WIDTH/6-20, 16);
                num_label2.font = [UIFont systemFontOfSize:15];
                [cell addSubview:num_label2];
            }
            //分享
            {
                //下边小图标  icon_message
                UIImageView * icon3 = [UIImageView new];
                icon3.image = [UIImage imageNamed:@"icon_share"];
                icon3.frame = CGRectMake(WIDTH-10-35-25, y_center-15, 30, 30);
                [cell addSubview:icon3];
                //绑定监听
                [icon3 setUserInteractionEnabled:YES];
                icon3.tag = postId * 10 + 3;
                UITapGestureRecognizer * tapGesture3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
                tapGesture3.numberOfTapsRequired=1;
                [icon3 addGestureRecognizer:tapGesture3];
                
                //数字
                UILabel * num_label3 = [UILabel new];
                num_label3.text = @"分享";
                num_label3.frame = CGRectMake(WIDTH-10-25, y_center- 6, 40, 12);
                num_label3.font = [UIFont systemFontOfSize:12];
                [cell addSubview:num_label3];
            }
        }
        
        
    }
    
    
    
    
    return cell;
}
//点击用户头像跳转
-(void)clickUserImage:(UITapGestureRecognizer *)tap{
    NSDictionary * postInfo = self.data_array[tap.view.tag];
    NSString * byMemberId = postInfo[@"member"][@"memberId"];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    NSDictionary * send_dic = @{
                                @"byMemberId":byMemberId
                                };
    if (memberId == nil) {
        send_dic = @{
                     @"memberId":byMemberId,
                     @"byMemberId":byMemberId
                     };
    }else{
        send_dic = @{
                     @"memberId":memberId,
                     @"byMemberId":byMemberId
                     };
    }
    
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getOtherUser.intf" andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
        SubscribeInfoViewController * subscribeInfo = [SubscribeInfoViewController new];
        NSDictionary * memberInfo = back_dic[@"member"];
        if (memberInfo == nil || memberInfo.allKeys.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"查询失败" duration:2];
            return;
        }else{
            subscribeInfo.member_dic = memberInfo;
        }
        [self.navigationController pushViewController:subscribeInfo animated:true];
    }];
}
//举报帖子入口
-(void)reportBtnCallBack:(UITapGestureRecognizer *)tap{
    if (![MYTOOL isLogin]) {
        [SVProgressHUD showErrorWithStatus:@"请先登录" duration:2];
        LoginViewController * login = [LoginViewController new];
        [self.navigationController pushViewController:login animated:true];
        return;
    }
    //    NSLog(@"帖子:%@",self.post_dic);
    int myMemberId = [MEMBERID intValue];
    NSDictionary * postDict = self.data_array[tap.view.tag];
    NSInteger memberId = [postDict[@"member"][@"memberId"] longValue];
    if (myMemberId == memberId) {//自己帖子，删除
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要删除此帖？" preferredStyle:(UIAlertControllerStyleActionSheet)];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定删除" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            [SVProgressHUD showWithStatus:@"删除中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
            
            NSInteger postCommentId = [postDict[@"postId"] longValue];
            NSString * interfaceName = @"/community/delPost.intf";
            [SVProgressHUD showWithStatus:@"正在删除" maskType:SVProgressHUDMaskTypeClear];
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"postId":[NSString stringWithFormat:@"%ld",postCommentId]} andSuccess:^(NSDictionary *back_dic) {
                //            NSLog(@"back:%@",back_dic);
                [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
                [self updateData];
            }];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:action];
        [alert addAction:cancel];
        [self showDetailViewController:alert sender:nil];
        
        
        
    }else{//别人帖子，举报
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要举报此帖？" preferredStyle:(UIAlertControllerStyleActionSheet)];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定举报" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            [SVProgressHUD showWithStatus:@"举报中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
            //拼接上传参数
            NSMutableDictionary * send_dic = [NSMutableDictionary new];
            NSInteger postId = [postDict[@"postId"] longValue];
            [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
            [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
            //开始上传
            [MYNETWORKING getWithInterfaceName:@"/community/postInform.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
                //            NSLog(@"back:%@",back_dic);
                [SVProgressHUD showSuccessWithStatus:@"举报成功" duration:1];
            }];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:action];
        [alert addAction:cancel];
        [self showDetailViewController:alert sender:nil];
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
}
#pragma mark - cell 中小图标回调 点赞、回复、分享
-(void)callback_cellForSelectView:(UITapGestureRecognizer *)tap{
    UIImageView * imgV = (UIImageView *)tap.view;
    if (!imgV) {
        return;
    }
    NSInteger tag = imgV.tag;
    //帖子id
    NSInteger postId = tag / 10;
    if (tag % 10 == 1) {//点赞
        
    }else if(tag % 10 == 2) {//回复
        [self reply_callBack:postId];
    }else if(tag % 10 == 3) {//分享
        //找出帖子和点击分享相同的数据
        NSDictionary * dictionary = nil;
        for (NSDictionary * post_dic in self.data_array) {
            NSInteger array_postId = [post_dic[@"postId"] longValue];
            if (array_postId == postId) {
                dictionary = post_dic;
                break;
            }
        }
        [self share_callBack:dictionary];
    }
}
#pragma mark - cell中点击事件
//点赞事件
-(void)praise_callBack:(UIButton *)btn{
    NSInteger postId = btn.tag / 10;
    bool praiseStatus = btn.tag % 10;
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        loginVC.delegate = self;
        loginVC.donotUpdate = self.donotUpdate;
        [self.navigationController pushViewController:loginVC animated:true];
        return;
    }
    if (praiseStatus) {//取消
        [SVProgressHUD showWithStatus:@"取消中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/delPostPraise.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            pageNo = 1;
            [self loadDefaultData];
        }];
    }else{//赞帖
        [SVProgressHUD showWithStatus:@"点赞中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/postPraise.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            pageNo = 1;
            [self loadDefaultData];
            
        }];
    }
    
    
    
    
}
//回复事件
-(void)reply_callBack:(NSInteger)postId{
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        loginVC.delegate = self;
        loginVC.donotUpdate = self.donotUpdate;
        [self.navigationController pushViewController:loginVC animated:true];
        return;
    }
//    NSLog(@"准备回复");
    //弹出的回复界面
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"请评论" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [SVProgressHUD showWithStatus:@"评论中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        NSString * msg = alert.textFields.firstObject.text;
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:msg forKey:@"comment"];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/postRevert.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            [SVProgressHUD dismiss];
//            NSLog(@"back:%@",back_dic);
            pageNo = 1;
            [self loadDefaultData];
        }];
        
        
//        NSLog(@"信息:%@",msg);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:action];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){
        tf.placeholder = @"请输入评论消息";
    }];
    [alert addAction:cancel];
    [self showDetailViewController:alert sender:nil];
    
    
    
}
//分享事件
-(void)share_callBack:(NSDictionary *)post_dic{
    SharedManagerVC * share = [SharedManagerVC new];
    NSMutableDictionary * dic = [NSMutableDictionary new];
    [dic setValue:@"2" forKey:@"type"];
    [dic setValue:post_dic[@"postId"] forKey:@"typeId"];
    if (MEMBERID) {
        [dic setValue:MEMBERID forKey:@"memberId"];
    }
    share.sharedDic = dic;
    share.sharedDictionary = @{
                               @"title":post_dic[@"shareTitle"],
                               @"shareDescribe":post_dic[@"shareDescribe"],
                               @"img_url":post_dic[@"url"][0][@"smallUrl"],
                               @"shared_url":post_dic[@"postDetailUrl"] ? post_dic[@"postDetailUrl"] : @""
                               };
    [share show];
}
//更新数据
-(void)updateData{
    pageNo = 1;
    [self loadDefaultData];
}

//缩放图片
-(void)showZoomImageView:(UITapGestureRecognizer *)tap
{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    
    UIView *bgView = [[UIView alloc] init];
    
    bgView.frame = [UIScreen mainScreen].bounds;
    
    bgView.backgroundColor = [UIColor blackColor];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    UITapGestureRecognizer *tapBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    
    [bgView addGestureRecognizer:tapBgView];
    //必不可少的一步，如果直接把点击获取的imageView拿来玩的话，返回的时候，原图片就完蛋了
    
    UIImageView *tempImageView = (UIImageView*)tap.view;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tempImageView.frame];
    imageView.image = tempImageView.image;
    [bgView addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
    
}
//再次点击取消全屏预览
-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
    [tapBgRecognizer.view removeFromSuperview];
}
#pragma mark - 发帖按钮回调
-(void)submitPostBtnBack{
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        loginVC.delegate = self;
        loginVC.donotUpdate = self.donotUpdate;
        [self.navigationController pushViewController:loginVC animated:true];
        return;
    }
//    NSLog(@"准备发帖");
    SubmitPostViewController * postVC = [SubmitPostViewController new];
    postVC.title = @"发帖";
    [self.navigationController pushViewController:postVC animated:true];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
//加载默认数据
-(void)loadDefaultData{
    NSString * source = @"";
    if ([current_btn.currentTitle isEqualToString:@"精选"]) {
        source = @"choiceness";
    }else if ([current_btn.currentTitle isEqualToString:@"圈子"]) {
        source = @"circle";
    }else{
        source = @"subscribe";
    }
    
    NSString * interfaceName = @"/community/getPost.intf";
    //source：choiceness 精选 subscribe订阅 circle 圈子
    
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    [send_dic setValue:source forKey:@"source"];
    [send_dic setValue:[NSString stringWithFormat:@"%d",pageNo] forKey:@"pageNo"];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    if ([source isEqualToString:@"circle"]) {
        for (NSDictionary * dictt in circle_img_title_value_array) {
            NSString * label = dictt[@"label"];
            if ([current_title_circle_img_title isEqualToString:label]) {
                NSString * value = dictt[@"value"];
                if (value == nil || value.length == 0) {
                    
                }else{
                    [send_dic setValue:value forKey:@"type"];
                }
                break;
            }
        }
//        NSInteger index = [circle_imgTitle_array indexOfObject:current_title_circle_img_title];
//        [send_dic setValue:[NSString stringWithFormat:@"%ld",index] forKey:@"type"];
    }
//    NSLog(@"send:%@",send_dic);
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:send_dic andSuccess:^(NSDictionary * back_dic){
//        NSLog(@"back:%@",back_dic);
        bool flag = [back_dic[@"code"] boolValue];
        NSString * msg = back_dic[@"msg"];
//        NSLog(@"%d--%@",flag,msg);
        if (!flag) {
            pageNo --;
            [SVProgressHUD showErrorWithStatus:msg duration:2];
            return;
        }
        NSArray * arr = back_dic[@"postList"];
        //NSLog(@"count:%ld",arr.count);
        //成功--如果页数=1，重置数组，如果页数>1，数据加上去
        if (pageNo > 1) {
            
            if (arr.count > 0) {
                [self.data_array addObjectsFromArray:arr];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
            
        }else{
            self.data_array = [NSMutableArray arrayWithArray:back_dic[@"postList"]];
        }
        NSString * title = current_btn.currentTitle;
        [self.tableView reloadData];
        if ([title isEqualToString:@"精选"]) {
            [(UITableView *)current_view reloadData];
            [self loadBannerData];
        }else if([title isEqualToString:@"圈子"]){
            [(UITableView *)down_img_circle_view reloadData];
        }else{//订阅
            
        }
        if (self.data_array.count == 0) {
            self.noDateView.hidden = false;
        }else{
            self.noDateView.hidden = true;
        }
    }andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.data_array removeAllObjects];
            [self.tableView reloadData];
        }else{
            pageNo --;
        }
    }];
    
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    NSDictionary * carouselDic = self.bannerArray[index];
    NSInteger category = [carouselDic[@"category"] longValue];
    //Category：导航类别(1：富文本 2：商品 3：帖子 4:商品组)
    if (category == 1) {//富文本
        NSString * content = carouselDic[@"content"];
        TextBannerVC * text = [TextBannerVC new];
        text.content = content;
        text.title = carouselDic[@"bannerTitle"];
        NSString * viewUrl = carouselDic[@"viewUrl"];
        text.viewUrl = viewUrl;
        [self.navigationController pushViewController:text animated:true];
    }else if (category == 2) {//商品
        //网络获取商品详情
        NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
        NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
        if (cityId == nil) {
            cityId = @"320300";
        }
        NSDictionary * sendDict = @{
                                    @"goodsId":carouselDic[@"categoryId"],
                                    @"cityId":cityId
                                    };
        [MYTOOL netWorkingWithTitle:@"获取商品"];
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"商品:%@",back_dic);
            GoodsInfoViewController * info = [GoodsInfoViewController new];
            info.goodsInfoDictionary = back_dic[@"goods"];
            [self.navigationController pushViewController:info animated:true];
        }];
    }else if (category == 3) {//帖子
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
        if (memberId) {
            [send_dic setValue:memberId forKey:@"memberId"];
        }
        [send_dic setValue:carouselDic[@"categoryId"] forKey:@"postId"];
        
        //开始请求
        [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
        [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            bool flag = [back_dic[@"code"] boolValue];
            if (flag) {
                [SVProgressHUD dismiss];
                PostInfoViewController * postVC = [PostInfoViewController new];
                postVC.title = @"帖子详情";
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
                [dict setValue:@([carouselDic[@"categoryId"] intValue]) forKey:@"postId"];
                postVC.post_dic = dict;
                [self.navigationController pushViewController:postVC animated:true];
            }else{
                [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
            }
        }];
    }else if (category == 4) {//商品组
        NSString * interface = @"/shop/goods/getGoodList.intf";
        [MYTOOL netWorkingWithTitle:@"获取商品组"];
        NSInteger bannerId = [carouselDic[@"bannerId"] longValue];
        NSDictionary * send = @{
                                @"bannerId":[NSString stringWithFormat:@"%ld",bannerId]
                                };
        [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
            //                NSLog(@"back:%@",back_dic);
            NSArray * goodsList = back_dic[@"goodsList"];
            GoodsBannerVC * goodsB = [GoodsBannerVC new];
            goodsB.title = back_dic[@"title"];
            goodsB.goodsList = goodsList;
            [self.navigationController pushViewController:goodsB animated:true];
        }];
        
    }else if (category == 5) {//url加载web
        NSString * viewUrl = carouselDic[@"viewUrl"];
        TextBannerVC * text = [TextBannerVC new];
        text.viewUrl = viewUrl;
        text.title = carouselDic[@"bannerTitle"];
        [self.navigationController pushViewController:text animated:true];
    }
    
    
}
//加载轮播图数据
-(void)loadBannerData{
    NSString * interface = @"/sys/getBanner.intf";
    NSDictionary * send = @{
                            @"key":@"community"
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        NSArray * array = back_dic[@"list"];
//        NSLog(@"count:%ld",array.count);
        self.bannerArray = array;
        if ([self.tableView isKindOfClass:[SelectView class]]) {
            SelectView * select = (SelectView *)self.tableView;
            [select setImgArray:array];
        }
    }];
    
}
//获取分类数据
-(void)getCircleTypeArray{
    NSString * interface = @"/sys/getDictInfo.intf";
    NSDictionary * send = @{@"type":@"community"};
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * communityList = back_dic[@"dictEntities"][@"community"];
        NSMutableArray * nameArray = [NSMutableArray new];//名字数组
        NSMutableArray * urlArray = [NSMutableArray new];//图片url数组
        for (int i = 0; i < communityList.count; i ++) {
            NSDictionary * dict = communityList[i];
            NSString * name = dict[@"label"];//名字
            NSString * url = dict[@"url"];//图片url
            [nameArray addObject:name];
            [urlArray addObject:url];
        }
        circle_imgTitle_array = nameArray;
        circle_imgUrl_array = urlArray;
        circle_img_title_value_array = communityList;
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [self getCircleTypeArray];
    //左按钮-nav_-add
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_-add"] style:UIBarButtonItemStyleDone target:self action:@selector(addOfNavigationBar)];
    //右按钮-nav_top
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_top"] style:UIBarButtonItemStyleDone target:self action:@selector(topOfNavigationBar)];
    [self.navigation_titleView setHidden:NO];
    if (!self.donotUpdate) {
        [self loadDefaultData];
        self.donotUpdate = true;
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigation_titleView setHidden:true];
    
}
@end
