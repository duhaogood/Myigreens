//
//  MyMessageSectionsViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/1.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "MyMessageSectionsViewController.h"
#import "PostInfoViewController.h"
@interface MyMessageSectionsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@property(nonatomic,strong)NSMutableArray * receiveCommentArray;//收到的评论数组
@end

@implementation MyMessageSectionsViewController
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
    //tableView
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-64-10);
        tableView.dataSource = self;
        tableView.delegate = self;
        self.tableView = tableView;
        [self.view addSubview:tableView];
        tableView.rowHeight = 106/667.0*HEIGHT;
        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
                label.text = @"暂无评论数据";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = MYCOLOR_46_42_42;
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(0, 10, WIDTH, 20);
                [view addSubview:label];
            }
        }
    }
    
    
}

//跳转帖子详情
-(void)pushPostInfoWithPostId:(NSString *)postId{
    //进入帖子详情
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:postId forKey:@"postId"];
    //开始请求
    [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        bool flag = [back_dic[@"code"] boolValue];
        if (flag) {
            [SVProgressHUD dismiss];
            PostInfoViewController * postVC = [PostInfoViewController new];
            postVC.title = @"帖子详情";
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
            [dict setValue:@([postId intValue]) forKey:@"postId"];
            postVC.post_dic = dict;
            [self.navigationController pushViewController:postVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
        }
    }];
    [self reloadViewData];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * commentDic = self.receiveCommentArray[indexPath.row];
    NSString * postId = [NSString stringWithFormat:@"%ld",[commentDic[@"postId"] longValue]];
    //消息是否已读
    bool flag = [commentDic[@"readType"] boolValue];
    if (flag) {
        [self pushPostInfoWithPostId:postId];
    }else{
        //将未读信息设成已读
        NSInteger flowId = [commentDic[@"flowId"] longValue];
        NSString * interfaceName = @"/member/readMessage.intf";
        NSDictionary * sendDic = @{
                                   @"flowId":[NSString stringWithFormat:@"%ld",flowId]
                                   };
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
            [self pushPostInfoWithPostId:postId];
//            NSLog(@"back:%@",back_dic);
        }];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.receiveCommentArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSDictionary * dict = self.receiveCommentArray[indexPath.row];
    //头像
    {
        UIImageView * user_icon = [UIImageView new];
        user_icon.frame = [MYTOOL getRectWithIphone_six_X:14 andY:20 andWidth:40 andHeight:40];
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
        name_label.frame = CGRectMake(63/375.0*WIDTH, 40/667.0*HEIGHT-8, size.width, 16);
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
        time_label.frame = CGRectMake(name_label.frame.origin.x + name_label.frame.size.width+10, name_label.frame.origin.y+name_label.frame.size.height-12, size.width, 12);
        time_label.text = time;
        [cell addSubview:time_label];
    }
    //图标
    {
        UIImageView * icon = [UIImageView new];
        icon.image = [UIImage imageNamed:@"icon_report"];
        icon.frame = [MYTOOL getRectWithIphone_six_X:342 andY:26 andWidth:20 andHeight:20];
        [cell addSubview:icon];
    }
    //回复内容
    {
        UILabel * content_label = [UILabel new];
        content_label.font = [UIFont systemFontOfSize:15/667.0*HEIGHT];
        NSString * text = dict[@"comment"];
        content_label.text = text;
        content_label.textColor = [MYTOOL RGBWithRed:112 green:112 blue:112 alpha:1];
        content_label.frame = [MYTOOL getRectWithIphone_six_X:63 andY:70 andWidth:270 andHeight:15];
        [cell addSubview:content_label];
    }
    //按钮
    {
        UIButton * answer_btn = [UIButton new];
        [answer_btn setTitle:@"回复" forState:UIControlStateNormal];
        answer_btn.titleLabel.font = [UIFont systemFontOfSize:15/667.0*HEIGHT];
//        NSLog(@"fontSize:%.2f",answer_btn.titleLabel.font.pointSize);
        answer_btn.frame = [MYTOOL getRectWithIphone_six_X:333 andY:64 andWidth:32 andHeight:16];
        [answer_btn setTitleColor:[MYTOOL RGBWithRed:114 green:158 blue:52 alpha:1] forState:UIControlStateNormal];
        [cell addSubview:answer_btn];
#warning 待增加字段
        answer_btn.tag = indexPath.row;
        [answer_btn addTarget:self action:@selector(answer_callback:) forControlEvents:UIControlEventTouchUpInside];
//        answer_btn.backgroundColor = [UIColor redColor];
        
    }
    //分割线
    {
        UIView * space = [UIView new];
        space.frame = CGRectMake(14, tableView.rowHeight - 1, WIDTH - 28, 1);
        space.backgroundColor = MYCOLOR_181_181_181;
        [cell addSubview:space];
    }
    return cell;
}
//回复按钮回调
-(void)answer_callback:(UIButton *)btn{
    //弹出的回复界面
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"请回复" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [SVProgressHUD showWithStatus:@"回复中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        NSString * msg = alert.textFields.firstObject.text;
        if (msg.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"请输入内容" duration:2];
            return;
        }
        NSDictionary * dicc = self.receiveCommentArray[btn.tag];
//        NSLog(@"aray:%@",self.receiveCommentArray);
//        NSLog(@"dicc:%@",dicc);
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:msg forKey:@"comment"];
        
        [send_dic setValue:dicc[@"postId"] forKey:@"postId"];
        [send_dic setValue:MEMBERID forKey:@"memberId"];
        [send_dic setValue:dicc[@"postCommentId"] forKey:@"parentPostCommentId"];
        //        NSLog(@"send:%@",send_dic);
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/postRevert.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            
            [self pushPostInfoWithPostId:[NSString stringWithFormat:@"%ld",[dicc[@"postId"] longValue]]];
            [SVProgressHUD showSuccessWithStatus:@"回复成功" duration:1];
        }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:action];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){
        tf.placeholder = @"请输入回复消息";
    }];
    [alert addAction:cancel];
    [self showDetailViewController:alert sender:nil];
    
}
//返回上个界面
-(void)back_pop{
    [self.navigationController popViewControllerAnimated:true];
}
//重新加载界面数据
-(void)reloadViewData{
    NSString * interfaceName = @"/member/receivedComments.intf";
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":MEMBERID,@"pageNo":@(pageNo)} andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * arr = back_dic[@"commentList"];
        if (pageNo > 1) {
            if (arr.count > 0) {
                [self.receiveCommentArray addObjectsFromArray:arr];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
        }else{
            self.receiveCommentArray = [NSMutableArray arrayWithArray:arr];
        }
        if (self.receiveCommentArray.count > 0) {
            self.noDateView.hidden = true;
        }else{
            self.noDateView.hidden = false;
        }
        [self.tableView reloadData];
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.receiveCommentArray removeAllObjects];
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
