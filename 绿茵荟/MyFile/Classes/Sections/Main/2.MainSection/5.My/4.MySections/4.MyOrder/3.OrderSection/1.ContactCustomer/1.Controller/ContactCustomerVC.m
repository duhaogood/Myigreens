//
//  ContactCustomerVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/3.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ContactCustomerVC.h"

@interface ContactCustomerVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UITextField * contentTF;//要发送的消息文本框
@property(nonatomic,strong)NSMutableArray * msgArray;//显示消息数组
@end

@implementation ContactCustomerVC
{
    int pageNo;//分页数
}
- (void)viewDidLoad {
    [super viewDidLoad];
    pageNo = 1;
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    //消息区
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-64-51-10);
        tableView.backgroundColor = [UIColor whiteColor];
        self.automaticallyAdjustsScrollViewInsets = false;
        [self.view addSubview:tableView];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTableView)];
        tapGesture.numberOfTapsRequired=1;
        [tableView addGestureRecognizer:tapGesture];
        tableView.delegate = self;
        tableView.dataSource = self;
        self.tableView = tableView;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            pageNo ++;
            [self getAllMessage];
            // 结束刷新
            [tableView.mj_header endRefreshing];
        }];
        //不显示分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        tableView.mj_header.automaticallyChangeAlpha = YES;
    }
    //底部发送消息区
    {
        UIView * bgView = [UIView new];
        {
            bgView.frame = CGRectMake(0, HEIGHT-64-50, WIDTH, 50);
            bgView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:bgView];
        }
        //文本框
        {
            //背景view
            UIView * view = [UIView new];
            {
                view.frame = CGRectMake(10, 6, WIDTH-20-88, 38);
                view.backgroundColor = self.view.backgroundColor;
                [bgView addSubview:view];
                view.layer.masksToBounds = true;
                view.layer.cornerRadius = 19;
            }
            UITextField * tf = [UITextField new];
            self.contentTF = tf;
            tf.frame = CGRectMake(19, 10, WIDTH-20-88-38, 18);
            [view addSubview:tf];
            tf.font = [UIFont systemFontOfSize:15];
            tf.placeholder = @"请在此处留言,客服会在第一时间回复您";
        }
        //发送按钮-btn_sent_line-78-38
        {
            UIButton * btn = [UIButton new];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_sent_line"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(WIDTH-10-78, 6, 78, 38);
            [btn setTitle:@"发送" forState:UIControlStateNormal];
            [btn setTitleColor:[MYTOOL RGBWithRed:113 green:157 blue:52 alpha:1] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submitBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:20];
            [bgView addSubview:btn];
        }
    }
}


//提交按钮回调
-(void)submitBtnCallback:(UIButton *)btn{
    NSString * text = self.contentTF.text;
    [self sendMessage:text];
}

//发送消息
-(void)sendMessage:(NSString *)msg{
    if (msg == nil || msg.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"请先输入消息" duration:2];
        return;
    }
    NSString * interface = @"/shop/order/createOrderAsk.intf";
    NSDictionary * sendDic = @{
                               @"orderId":[NSString stringWithFormat:@"%ld",self.orderId],
                               @"memberId":MEMBERID,
                               @"content":msg
                               };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        self.contentTF.text = @"";
        pageNo = 1;
        [self getAllMessage];
    }];
    
}
//获取所有消息
-(void)getAllMessage{
    NSString * interface = @"/shop/order/getOrderAsk.intf";
    NSDictionary * sendDic = @{
                               @"pageNo":[NSString stringWithFormat:@"%d",pageNo],
                               @"orderId":[NSString stringWithFormat:@"%ld",self.orderId]
                               };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * msgList = back_dic[@"myCustomerServiceList"];
        if (pageNo > 1) {
            if (msgList.count > 0) {
                [self.msgArray addObjectsFromArray:msgList];
            }else{
                pageNo --;
            }
        }else{
            self.msgArray = [NSMutableArray arrayWithArray:msgList];
        }
        [self.tableView reloadData];
        [self scrollToBottom];
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.msgArray removeAllObjects];
            [self.tableView reloadData];
        }else{
            pageNo --;
        }
    }];
}
//tableView点击事件
-(void)clickTableView{
//    NSLog(@"点击");
    [MYTOOL hideKeyboard];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.msgArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * msgDic = self.msgArray[indexPath.row];
    NSString * content = msgDic[@"content"];
    //1:咨询   2:回复
    int status = [msgDic[@"status"] intValue];
    UILabel * label = [UILabel new];
    label.text = content;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = status == 1 ? [UIColor whiteColor] : MYCOLOR_46_42_42;
    float r = 60;
    float left = 10 + r + 10 + 20;
    float width = WIDTH - left * 2;
    CGSize size = [MYTOOL getSizeWithLabel:label];
    //一行文字
    if (size.width <= width) {
        return size.height + 40 + 40;
    }else{//多行
        int row = size.width / width;
        if (size.width > width * row) {
            row ++;
        }
        return size.height * row + 40 + 40;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSDictionary * msgDic = self.msgArray[indexPath.row];
    //1:咨询   2:回复
    int status = [msgDic[@"status"] intValue];
    //头像
    float r = 60;
    {
        UIImageView * icon = [UIImageView new];
        [cell addSubview:icon];
        if (status == 1) {
            icon.image = [UIImage imageNamed:@"logo"];
            icon.frame = CGRectMake(WIDTH-r-10, 20, r, r);
        }else{
            icon.image = [UIImage imageNamed:@"logo"];
            icon.frame = CGRectMake(10, 20, r, r);
        }
    }
    //消息
    {
        NSString * content = msgDic[@"content"];
        UILabel * label = [UILabel new];
        label.text = content;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = status == 1 ? [UIColor whiteColor] : MYCOLOR_46_42_42;
        float left = 10 + r + 10 + 20;
        float right = WIDTH - left;
        float width = WIDTH - left * 2;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        if (status == 1) {
            //一行文字
            if (size.width <= width) {
                label.frame = CGRectMake(right-size.width, 40, size.width, size.height);
            }else{//多行
                int row = size.width / width;
                if (size.width > width * row) {
                    row ++;
                }
                label.numberOfLines = 0;
                label.frame = CGRectMake(left,40 , width, size.height*row);
            }
        }else{
            //一行文字
            if (size.width <= width) {
                label.frame = CGRectMake(left, 40, size.width, size.height);
            }else{//多行
                int row = size.width / width;
                if (size.width > width * row) {
                    row ++;
                }
                label.numberOfLines = 0;
                label.frame = CGRectMake(left,40 , width, size.height*row);
            }
        }
//        label.backgroundColor = [UIColor redColor];
        //背景图
        {
            //dialog-box_green
            //dialog-box_gray
            UIImage * img=[UIImage imageNamed:@"dialog-box_green"];//原图
            if (status != 1) {
                img=[UIImage imageNamed:@"dialog-box_gray"];
            }
            UIEdgeInsets edge=UIEdgeInsetsMake(0, 30, 0,30);
            //UIImageResizingModeStretch：拉伸模式，通过拉伸UIEdgeInsets指定的矩形区域来填充图片
            img= [img resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
            //背景图
            UIImageView * bg = [UIImageView new];
            bg.image = img;
            CGRect rect = label.frame;
            
            bg.frame = CGRectMake(rect.origin.x - 30, rect.origin.y - 25, rect.size.width + 60, rect.size.height + 50);
            [cell addSubview:bg];
            
        }
        
        [cell addSubview:label];
    }
    
    //创建时间
    NSInteger createtime = [msgDic[@"createtime"] longValue];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:createtime];
    NSDateFormatter * formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString * text = [formatter stringFromDate:date];
    {
        UILabel * label = [UILabel new];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = MYCOLOR_181_181_181;
        label.frame = CGRectMake(0, 0, WIDTH, 14);
        label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:label];
        label.text = text;
    }
    //无法选中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - 键盘出现和隐藏事件
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //键盘高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    //UITextField相对屏幕上侧位置
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[self.contentTF convertRect: [self.contentTF bounds] toView:window];
    //UITextField底部坐标
    float tf_y = rect.origin.y + self.contentTF.frame.size.height;
    if (height + tf_y > HEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 64-height, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
}
//tableView滚动到底部
- (void)scrollToBottom
{
    CGFloat yOffset = 0; //设置要滚动的位置 0最顶部 CGFLOAT_MAX最底部
    if (self.tableView.contentSize.height > self.tableView.bounds.size.height) {
        yOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height;
    }
    [self.tableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
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
    [self getAllMessage];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
