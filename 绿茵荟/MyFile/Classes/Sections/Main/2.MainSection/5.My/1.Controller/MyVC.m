//
//  MyVC.m
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "MyVC.h"
#import "MySubscribeVC.h"
#import "MyReaderVC.h"
//#import "PersonalMaterialVC.h"
@interface MyVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MyView * myView;
@property(nonatomic,strong)NSArray * mySectionsNames;//子菜单的控制器类名字,及图片名称
@property(nonatomic,strong)UIImageView * user_icon;//用户头像
@property(nonatomic,strong)UILabel * name_label;//用户名字
@property(nonatomic,strong)UILabel * submit_label;//发布数
@property(nonatomic,strong)UILabel * subscribe_label;//订阅
@property(nonatomic,strong)UILabel * reader_label;//阅读者

@property(nonatomic,strong)NSDictionary * member_dic;//用户信息
@end

@implementation MyVC
{
    int shopCartNumber;//购物车显示数字
    int messageNumber;//未读消息数字
}
- (void)viewDidLoad {
    [super viewDidLoad];
    shopCartNumber = 0;
    messageNumber = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    self.myView = [[MyView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-49) andDelegate:self];
    [self.view addSubview:self.myView];
    self.myView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    
    float up_height = 282/736.0*HEIGHT;
    UIView * view = [UIView new];
    view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    view.frame = CGRectMake(0, 0, WIDTH, up_height+10);
    //图片
    UIImageView * bac_imgV = [UIImageView new];
    bac_imgV.image = [UIImage imageNamed:@"pic"];
    bac_imgV.frame = CGRectMake(0, 0, WIDTH, up_height);
    [view addSubview:bac_imgV];
    //背景图上加东西
    {
        //设置按钮
        {
            UIButton * setBtn = [UIButton new];
            [setBtn setImage:[UIImage imageNamed:@"nav_set"] forState:UIControlStateNormal];
            setBtn.frame = CGRectMake(WIDTH - 40, 30, 30, 30);
            [view addSubview:setBtn];
            [setBtn addTarget:self action:@selector(setBtn_callback) forControlEvents:UIControlEventTouchUpInside];
        }
        float r_user = 90/414.0*WIDTH;
        //用户头像
        {
            UIImageView * user_icon = [UIImageView new];
            user_icon.image = [UIImage imageNamed:@"logo"];
            user_icon.frame = CGRectMake(WIDTH/2-r_user/2, r_user, r_user, r_user);
            [view addSubview:user_icon];
            user_icon.layer.masksToBounds = true;
            user_icon.layer.cornerRadius = user_icon.frame.size.width/2;
            [user_icon setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView:)];
            tapGesture2.numberOfTapsRequired=1;
            [user_icon addGestureRecognizer:tapGesture2];
            self.user_icon = user_icon;
        }
        //用户名字
        {
            UILabel * name_label = [UILabel new];
            name_label.frame = CGRectMake(WIDTH/4, r_user*2+10, WIDTH/2, 20);
            name_label.textAlignment = NSTextAlignmentCenter;
            name_label.text = @"绿茵荟";
            name_label.textColor = [MYTOOL RGBWithRed:39 green:42 blue:47 alpha:1];
            [view addSubview:name_label];
            self.name_label = name_label;
        }
        //上册背景图下部背景
        UIImageView * bgImgV = [UIImageView new];
        {//258/736.0*HEIGHT
            bgImgV.image = [UIImage imageNamed:@"my_bg"];
            bgImgV.frame = CGRectMake(0, up_height - 45/667.0*HEIGHT, WIDTH, 45/667.0*HEIGHT);
            [view addSubview:bgImgV];
        }
        
        //绿色背景上3个状态
        {
            float top_center = up_height - 45/667.0*HEIGHT + 45/667.0*HEIGHT/2.0;
            //两条竖线
            {
                UIView * spaceViewLeft = [UIView new];
                spaceViewLeft.frame = CGRectMake(WIDTH/3-0.5, top_center-8, 1, 16);
                [view addSubview:spaceViewLeft];
                spaceViewLeft.backgroundColor = [UIColor whiteColor];
                
                UIView * spaceViewRight = [UIView new];
                spaceViewRight.frame = CGRectMake(WIDTH/3*2-0.5, top_center-8, 1, 16);
                [view addSubview:spaceViewRight];
                spaceViewRight.backgroundColor = [UIColor whiteColor];
            }
            //3个状态
            {
                //发布
                {
                    UILabel * submit_label = [UILabel new];
                    submit_label.frame = CGRectMake(0, top_center-8, WIDTH/3-0.5, 16);
                    submit_label.textAlignment = NSTextAlignmentCenter;
                    submit_label.text = @"0发布";
                    submit_label.textColor = [UIColor whiteColor];
                    [view addSubview:submit_label];
                    self.submit_label = submit_label;
                }
                //订阅
                {
                    UILabel * subscribe_label = [UILabel new];
                    subscribe_label.frame = CGRectMake(WIDTH/3+0.5, top_center-8, WIDTH/3-1, 16);
                    subscribe_label.textAlignment = NSTextAlignmentCenter;
                    subscribe_label.text = @"0订阅";
                    subscribe_label.textColor = [UIColor whiteColor];
                    [view addSubview:subscribe_label];
                    self.subscribe_label = subscribe_label;
                }
                //阅读者
                {
                    UILabel * reader_label = [UILabel new];
                    reader_label.frame = CGRectMake(WIDTH/3*2+0.5, top_center-8, WIDTH/3-0.5, 16);
                    reader_label.textAlignment = NSTextAlignmentCenter;
                    reader_label.text = @"0订阅者";
                    reader_label.textColor = [UIColor whiteColor];
                    [view addSubview:reader_label];
                    self.reader_label = reader_label;
                }
            }
        }
        //3个隐藏按钮
        {
            float height = 45/667.0*HEIGHT;
            float width = WIDTH/3.0;
            float top = up_height - 45/667.0*HEIGHT;
            //我的发布
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(1, top, width-2, height);
                [btn addTarget:self action:@selector(myIssueCallback) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
            //我的订阅
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(width, top, width-1, height);
                [btn addTarget:self action:@selector(mySubscribeCallback) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
            //我的阅读者
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(width*2, top, width-1, height);
                [btn addTarget:self action:@selector(myReaderCallback) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:btn];
            }
        }
        
    }
    
    
    //self.userImage = imgView;
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false,
    self.myView.tableHeaderView = view;
    self.myView.rowHeight = (HEIGHT-49 - up_height-20)/7.0;
    self.mySectionsNames = @[
                             @[@"MyIssueVC",@"我的发布",@"icon_1"],
                             @[@"MyMessageVC",@"我的消息",@"icon_2"],
                             @[@"MyOrderVC",@"我的订单",@"icon_3"],
                             @[@"ShoppingCartVC",@"购物车",@"icon_4"],
                             @[@"PreferentialVC",@"优惠卷",@"icon_5"],
                             @[@"ExchangeViewController",@"积分兑换",@"icon_6"],
                             @[@"OtherViewController",@"我的等级",@"icon7"]
                             ];
    self.myView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getUserInfoAgagin];
        // 结束刷新
        [self.myView.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    self.myView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    self.myView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getUserInfoAgagin];
        [self.myView.mj_footer endRefreshing];
    }];
    
}
#pragma mark - 按钮回调
//我的发布
-(void)myIssueCallback{
    MyIssueVC * my = [MyIssueVC new];
    my.member_dic = self.member_dic;
    my.title = @"我的发布";
    [self.navigationController pushViewController:my animated:true];
}
//我的订阅
-(void)mySubscribeCallback{
    MySubscribeVC * subscribe = [MySubscribeVC new];
    subscribe.title = @"我的订阅列表";
    [self.navigationController pushViewController:subscribe animated:true];
}
//我的阅读者
-(void)myReaderCallback{
    MyReaderVC * reader = [MyReaderVC new];
    reader.title = @"我的订阅者列表";
    [self.navigationController pushViewController:reader animated:true];
}
//设置按钮回调
-(void)setBtn_callback{
    SettingViewController * setVC = [SettingViewController new];
    setVC.member_dic = self.member_dic;
    setVC.title = @"设置";
    [self.navigationController pushViewController:setVC animated:true];
}
//缩放图片
-(void)showZoomImageView:(UITapGestureRecognizer *)tap{
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
#pragma mark - 重新网络获取个人信息数据刷新页面
-(void)getUserInfoAgagin{
    //获取我的信息
    NSString * interfaceName = @"/member/getMember.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        [MYNETWORKING getNumberOfShoppingCartCallback:^(NSDictionary *backDict) {
            shopCartNumber = [backDict[@"count"] intValue];
            self.member_dic = back_dic[@"member"];
            DHTOOL.memberDic = self.member_dic;
            //用户头像
            NSString * headUrl = self.member_dic[@"headUrl"][@"normalUrl"];//
            if (headUrl && headUrl.length) {
                [self.user_icon sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
            }
            //用户名字
            NSString * nickName = self.member_dic[@"nickName"];
            if (nickName == nil || nickName.length == 0) {
                self.name_label.text = @"匿名用户";
            }else{
                self.name_label.text = nickName;
            }
            //发布数
            NSInteger releaseCount = [self.member_dic[@"releaseCount"] longValue];
            self.submit_label.text = [NSString stringWithFormat:@"%ld发布",releaseCount];
            //订阅
            NSInteger subscribeCount = [self.member_dic[@"subscribeCount"] longValue];
            self.subscribe_label.text = [NSString stringWithFormat:@"%ld订阅",subscribeCount];
            //阅读者
            NSInteger bySubscribeCount = [self.member_dic[@"bySubscribeCount"] longValue];
            self.reader_label.text = [NSString stringWithFormat:@"%ld订阅者",bySubscribeCount];
            [self.myView reloadData];
            
            NSString * interfaceName = @"/member/myMessage.intf";
            NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
                NSArray * msg_arr = back_dic[@"typeList"];
//                NSLog(@"msg_arr:%@",msg_arr);
                messageNumber = 0;
                for (NSDictionary * msgDic in msg_arr) {
                    int num = [msgDic[@"unread"] intValue];
                    messageNumber += num;
                }
                [self.myView reloadData];
            }];
        }];
        
    }];
    
    
    
    
    
    
}
#pragma mark - tableView代理和数据源
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * className = self.mySectionsNames[3*indexPath.section + indexPath.row][0];
    NSString * titleName = self.mySectionsNames[3*indexPath.section + indexPath.row][1];
    //NSLog(@"name:%@",name);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class class = NSClassFromString(className);
    UIViewController * vc = [class new];
    vc.title = titleName;
    if ([className isEqualToString:@"MyIssueVC"]) {
        MyIssueVC * my = (MyIssueVC *)vc;
        my.member_dic = self.member_dic;
    }
    if ([className isEqualToString:@"OtherViewController"]) {
        return;
    }
    //积分兑换
    if ([className isEqualToString:@"ExchangeViewController"]) {
        ExchangeViewController * exVC = (ExchangeViewController *)vc;
        exVC.member_dic = self.member_dic;
        [MYTOOL netWorkingWithTitle:@"获取商品列表"];
        NSString * interface = @"/shop/pointGoods/getPointGoods.intf";
        [MYNETWORKING getWithInterfaceName:interface andDictionary:@{@"pageNo":@"1"} andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"back:%@",back_dic);
            NSArray * array = back_dic[@"pointGoodsList"];
            exVC.goodsList = [NSMutableArray arrayWithArray:array];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell= [tableView dequeueReusableCellWithIdentifier:@"cellInden"];
    cell = [UITableViewCell new];
    //判断cell为nil则进入创建cell  @[@"MyIssueVC",@"我的发布",@"icon_1"]
    if (!cell) {
        //创建cell，添加标记
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellInden"];
    }
    //图标
    float width_icon = 20;
    UIImageView * iconV = [UIImageView new];
    iconV.frame = CGRectMake((54/414.0*WIDTH - 20)/2.0, tableView.rowHeight/2-width_icon/2, width_icon, width_icon);
    iconV.image = [UIImage imageNamed:self.mySectionsNames[indexPath.row][2]];
    [cell addSubview:iconV];
    //标题
    NSString * title = self.mySectionsNames[3*indexPath.section + indexPath.row][1];
    UILabel * label = [UILabel new];
    label.text = title;
    label.frame = CGRectMake(54/414.0*WIDTH, tableView.rowHeight/2-10, WIDTH/2, 20);
    label.font = [UIFont systemFontOfSize:20];
    [cell addSubview:label];
    
    
    if (indexPath.row > 0) {
        UIImageView * bImgV = [UIImageView new];
        bImgV.frame = CGRectMake(60, 0, WIDTH-60, 1);
        bImgV.image = [UIImage imageNamed:@"topLineGray"];
        [cell addSubview:bImgV];
    }
    if ([self.mySectionsNames[indexPath.row][1] isEqualToString:@"我的等级"]) {
        UILabel * label = [UILabel new];
        label.text = [NSString stringWithFormat:@"等级:%d",[self.member_dic[@"level"] intValue]];
        label.font = [UIFont systemFontOfSize:16];
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(WIDTH-size.width-15, tableView.rowHeight/2-8, WIDTH/4, 16);
        [cell addSubview:label];
        label.textColor = MYCOLOR_181_181_181;
    }else{
        UIImageView * imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"arrow_right"];
        imgV.frame = CGRectMake(WIDTH-30, tableView.rowHeight/2-15, 30, 30);
        [cell addSubview:imgV];
    }
    if ([self.mySectionsNames[indexPath.row][1] isEqualToString:@"购物车"]) {
        if (shopCartNumber > 0) {
            NSString * text = [NSString stringWithFormat:@"%d",shopCartNumber];
            UILabel * label = [UILabel new];
            label.text = text;
            label.font = [UIFont systemFontOfSize:12];
            label.backgroundColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
            label.textColor = [UIColor whiteColor];
            [cell addSubview:label];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            float width = size.width+10;
            if (width < 20) {
                width = 20;
            }
            label.frame = CGRectMake(WIDTH-40-size.width-10, tableView.rowHeight/2-10, width, 20);
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.masksToBounds = true;
            label.layer.cornerRadius = 10;
        }
    }
    if ([self.mySectionsNames[indexPath.row][1] isEqualToString:@"我的消息"]) {
        if (messageNumber > 0) {
            NSString * text = [NSString stringWithFormat:@"%d",messageNumber];
            UILabel * label = [UILabel new];
            label.text = text;
            label.font = [UIFont systemFontOfSize:12];
            label.backgroundColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
            label.textColor = [UIColor whiteColor];
            [cell addSubview:label];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            float width = size.width+10;
            if (width < 20) {
                width = 20;
            }
            label.frame = CGRectMake(WIDTH-40-size.width-10, tableView.rowHeight/2-10, width, 20);
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.masksToBounds = true;
            label.layer.cornerRadius = 10;
        }
    }
    //分割线
    if (indexPath.row < self.mySectionsNames.count - 1) {
        UIView * spaceView = [UIView new];
        spaceView.frame = CGRectMake(15, tableView.rowHeight-1, WIDTH-30, 1);
        spaceView.backgroundColor = [MYTOOL RGBWithRed:226 green:226 blue:226 alpha:1];
        [cell addSubview:spaceView];
    }
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mySectionsNames.count;
}

#pragma mark - navigationbar隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:true animated:false];
    [self getUserInfoAgagin];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:false animated:false];
}
@end
