//
//  ReceiveSupportViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/1.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ReceiveSupportViewController.h"
#import "PostInfoViewController.h"
@interface ReceiveSupportViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * receiveCommentArray;//收到的赞数组
@end

@implementation ReceiveSupportViewController

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
#pragma mark - UITableViewDelegate,UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.receiveCommentArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dict = self.receiveCommentArray[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
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
    //时间
    NSString * time = dict[@"releaseTime"];
    {
        UILabel * time_label = [UILabel new];
        time_label.font = [UIFont systemFontOfSize:12];
        time_label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:time andFont:time_label.font];
        time_label.frame = CGRectMake(WIDTH-10-size.width, name_label.frame.origin.y+name_label.frame.size.height-12, size.width, 12);
        time_label.text = time;
        [cell addSubview:time_label];
    }
    //点赞提示
    {
        UILabel * content_label = [UILabel new];
        content_label.font = [UIFont systemFontOfSize:15/667.0*HEIGHT];
        content_label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        content_label.frame = [MYTOOL getRectWithIphone_six_X:57 andY:49 andWidth:300 andHeight:15];
        content_label.text = @"给你点了个赞";
        [cell addSubview:content_label];
    }
    return cell;
}
//返回上个界面
-(void)back_pop{
    [self.navigationController popViewControllerAnimated:true];
}
//重新加载界面数据
-(void)reloadViewData{
    NSString * interfaceName = @"/member/receivedPraise.intf";
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":MEMBERID} andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%ld",[back_dic[@"praiseList"] count]);
        self.receiveCommentArray = back_dic[@"praiseList"];
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
