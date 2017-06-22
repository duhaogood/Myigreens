//
//  MyIssueVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "MyIssueVC.h"
#import "SubmitPostViewController.h"
#import "MyIssueTableView.h"
#import "SubscribeInfoViewController.h"
@interface MyIssueVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UIView * progress_view;//进度条
@property(nonatomic,strong)MyIssueTableView * tableView;
@property(nonatomic,strong)NSMutableArray * myIssueArray;//我的发布数组
@end

@implementation MyIssueVC
{
    float progress_max_height;  //421
    int pageNo;//我的发布分页数
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"self:%@",self.member_dic);
    pageNo = 1;
    //加载主界面
    [self loadMainView];
    
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    
    //背景view
    UIView * bg_view = [UIView new];
    {
        {
            bg_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:9 andWidth:375 andHeight:594];
            bg_view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:bg_view];
        }
        //头像
        {
            NSString * headUrl = self.member_dic[@"headUrl"][@"normalUrl"];
            //http://v1.qzone.cc/avatar/201408/03/23/44/53de58e5da74c247.jpg%21200x200.jpg
            UIImageView * user_icon = [UIImageView new];
            user_icon.frame = [MYTOOL getRectWithIphone_six_X:14 andY:14 andWidth:51 andHeight:51];
            [user_icon sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
            [bg_view addSubview:user_icon];
            user_icon.layer.masksToBounds = true;
            user_icon.layer.cornerRadius = user_icon.frame.size.width/2;
            [user_icon setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImgOfUser:)];
            tapGesture.numberOfTapsRequired=1;
            [user_icon addGestureRecognizer:tapGesture];
        }
        //名字
        {
            UILabel * nameLabel = [UILabel new];
            nameLabel.frame = [MYTOOL getRectWithIphone_six_X:74 andY:25 andWidth:WIDTH/2 andHeight:15];
            NSString * nickName = self.member_dic[@"nickName"];
            if (nickName == nil || nickName.length == 0) {
                nickName = @"匿名用户";
            }
            nameLabel.text = nickName;
            nameLabel.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            nameLabel.font = [UIFont titleFontOfSize:nameLabel.frame.size.height];
            [bg_view addSubview:nameLabel];
        }
        //签名
        {
            UILabel * signLabel = [UILabel new];
            signLabel.frame = [MYTOOL getRectWithIphone_six_X:74 andY:49 andWidth:300 andHeight:15];
            NSString * signature = self.member_dic[@"signature"];
            if (signature == nil || signature.length == 0) {
                signature = @"这家伙太懒，什么都没留下…";
            }
            signLabel.text = signature;
            signLabel.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
            signLabel.font = [UIFont systemFontOfSize:signLabel.frame.size.height];
            [bg_view addSubview:signLabel];
        }
        //滚动条
        {
            //滚动条背景
            UIView * scroll_bg_view = [UIView new];
            scroll_bg_view.frame = [MYTOOL getRectWithIphone_six_X:35 andY:85 andWidth:10 andHeight:460];
            scroll_bg_view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
            scroll_bg_view.layer.masksToBounds = true;
            scroll_bg_view.layer.cornerRadius = scroll_bg_view.frame.size.width/2;
            [bg_view addSubview:scroll_bg_view];
        }
        //tableview
        {
            MyIssueTableView * tableView = [MyIssueTableView new];
            tableView.frame = [MYTOOL getRectWithIphone_six_X:37 andY:88 andWidth:330 andHeight:454];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [bg_view addSubview:tableView];
            tableView.rowHeight = 206/667.0*HEIGHT;
            self.tableView = tableView;
            tableView.tag = 836913;
            [tableView flashScrollIndicators];
            [tableView reloadData];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                pageNo = 1;
                [self loadMyIssueData];
                // 结束刷新
                [tableView.mj_header endRefreshing];
            }];
            
            // 设置自动切换透明度(在导航栏下面自动隐藏)
            tableView.mj_header.automaticallyChangeAlpha = YES;
            
            // 上拉刷新
            tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                pageNo ++;
                [self loadMyIssueData];
                [tableView.mj_footer endRefreshing];
            }];
        }
        
    }
    //发布新帖子按钮
    {
        UIButton * submitPostBtn = [UIButton new];
        [submitPostBtn setImage:[UIImage imageNamed:@"btn_write"] forState:UIControlStateNormal];
        submitPostBtn.frame = CGRectMake(309/375.0*WIDTH, HEIGHT*476/667.0, 45/375.0*WIDTH, 45/375.0*WIDTH);
        [self.view insertSubview:submitPostBtn atIndex:9999];
        [submitPostBtn addTarget:self action:@selector(submitPostBtnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}


//用户图片点击事件
-(void)clickImgOfUser:(UITapGestureRecognizer *)tap{
    SubscribeInfoViewController * subscribeInfo = [SubscribeInfoViewController new];
    subscribeInfo.member_dic = DHTOOL.memberDic;
    [self.navigationController pushViewController:subscribeInfo animated:true];
    
}
//发布新帖子按钮事件
-(void)submitPostBtnBack{
    SubmitPostViewController * postVC = [SubmitPostViewController new];
    postVC.title = @"发帖";
    [self.navigationController pushViewController:postVC animated:true];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"点击了:%ld",indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    //点击进入帖子详情
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:self.myIssueArray[indexPath.row][@"postId"] forKey:@"postId"];
    
    
    //开始请求
    [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        bool flag = [back_dic[@"code"] boolValue];
        if (flag) {
            [SVProgressHUD dismiss];
            PostInfoViewController * postVC = [PostInfoViewController new];
            postVC.title = @"帖子详情";
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
            [dict setValue:self.myIssueArray[indexPath.row][@"postId"] forKey:@"postId"];
            postVC.post_dic = dict;
            [self.navigationController pushViewController:postVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
        }
    }];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myIssueArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    //https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=4076113535,3983591520&fm=23&gp=0.jpg
    //图片
    UIImageView * imgV = [UIImageView new];
    {
        NSString * headImageString = self.myIssueArray[indexPath.row][@"image"];
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
        [imgV setContentScaleFactor:[[UIScreen mainScreen] scale]];
        imgV.frame = [MYTOOL getRectWithIphone_six_X:37 andY:20 andWidth:288 andHeight:143];
        [imgV sd_setImageWithURL:[NSURL URLWithString:headImageString]];
        [cell addSubview:imgV];
        imgV.layer.masksToBounds = true;
        imgV.layer.cornerRadius = 12/375.0*WIDTH;
    }
    //发布时间
    {
        UILabel * time_label = [UILabel new];
        time_label.frame = [MYTOOL getRectWithIphone_six_X:37 andY:176 andWidth:288 andHeight:14];
        time_label.font = [UIFont systemFontOfSize:time_label.frame.size.height];
        time_label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        NSString * releaseTime = self.myIssueArray[indexPath.row][@"releaseTime"];
        if (releaseTime == nil || releaseTime.length == 0) {
            releaseTime = @"未知";
        }
        time_label.text = releaseTime;
        [cell addSubview:time_label];
    }
    //分割线
    {
        UIView * space_view = [UIView new];
        space_view.frame = CGRectMake(imgV.frame.origin.x, tableView.rowHeight-1, imgV.frame.size.width, 1);
        space_view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
        [cell addSubview:space_view];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        NSLog(@"删除啦");
        NSInteger postCommentId = [self.myIssueArray[indexPath.row][@"postId"] longValue];
        NSString * interfaceName = @"/community/delPost.intf";
        [SVProgressHUD showWithStatus:@"正在删除" maskType:SVProgressHUDMaskTypeClear];
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"postId":[NSString stringWithFormat:@"%ld",postCommentId]} andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"back:%@",back_dic);
            [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
            pageNo = 1;
            [self loadMyIssueData];
        }];
        
    }
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
//加载我的发布数据
-(void)loadMyIssueData{
    NSString * interfaceName = @"/community/getMemberPost.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYTOOL netWorkingWithTitle:@"获取帖子"];
    NSDictionary * sendDic = @{
                                @"memberId":memberId,
                                @"pageNo":[NSString stringWithFormat:@"%d",pageNo]
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * arr = back_dic[@"postList"];
        //成功--如果页数=1，重置数组，如果页数>1，数据加上去
        if (pageNo > 1) {
            
            if (arr.count > 0) {
                [self.myIssueArray addObjectsFromArray:arr];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
            
        }else{
            self.myIssueArray = [NSMutableArray arrayWithArray:back_dic[@"postList"]];
        }
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(0, 1);
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
    pageNo = 1;
    [self loadMyIssueData];
    
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    
}

@end
