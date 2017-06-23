//
//  CustomerListVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "CustomerListVC.h"
#import "ContactCustomerVC.h"
@interface CustomerListVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * myCustomerServiceList;//客服列表数组
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@end

@implementation CustomerListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back_pop)];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    UITableView * tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-74);
    [self.view addSubview:tableView];
    tableView.rowHeight = 75/667.0*HEIGHT;
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    self.automaticallyAdjustsScrollViewInsets = false;
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
            label.text = @"暂无客服消息";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = MYCOLOR_46_42_42;
            label.font = [UIFont systemFontOfSize:15];
            label.frame = CGRectMake(0, 10, WIDTH, 20);
            [view addSubview:label];
        }
    }
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * customerDic = self.myCustomerServiceList[indexPath.row];
    
//    NSLog(@"dic:%@",self.myCustomerServiceList[indexPath.row]);
    //如果消息未读，置为已读
    NSString * interface = @"/member/readMyCustomerServiceList.intf";
    NSObject * obj = customerDic[@"orderId"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:@{@"orderId":obj} andSuccess:^(NSDictionary *back_dic) {
        //重新刷新界面
        [self getCustomerServiceList];
        //进入聊天模式
        NSInteger orderId = [customerDic[@"orderId"] longValue];
        ContactCustomerVC * customer = [ContactCustomerVC new];
        customer.orderId = orderId;
        customer.title = @"我的客服";
        [self.navigationController pushViewController:customer animated:true];
    }];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myCustomerServiceList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSDictionary * dict = self.myCustomerServiceList[indexPath.row];
    //头像
    UIImageView * user_icon = [UIImageView new];
    {
        
        user_icon.frame = [MYTOOL getRectWithIphone_six_X:14 andY:12 andWidth:34 andHeight:34];
        user_icon.layer.masksToBounds = true;
        user_icon.layer.cornerRadius = user_icon.frame.size.width/2;
        [cell addSubview:user_icon];
        user_icon.image = [UIImage imageNamed:@"logo"];
        NSString * face = dict[@"face"];
        if (face) {
            [MYTOOL setImageIncludePrograssOfImageView:user_icon withUrlString:face];
        }
        //是否已读
        {
            bool readType = [dict[@"unRead"] intValue] > 0;
            if (readType) {
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
    NSString * name = @"绿茵荟客服";
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
    NSString * time = dict[@"createtime"];
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
        content_label.font = [UIFont systemFontOfSize:14];
        content_label.text = dict[@"content"];;
        content_label.textColor = [MYTOOL RGBWithRed:112 green:112 blue:112 alpha:1];
        content_label.frame = [MYTOOL getRectWithIphone_six_X:56 andY:48 andWidth:270 andHeight:15];
        [cell addSubview:content_label];
    }
    //分割线
    {
        UIView * space_view = [UIView new];
        space_view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
        space_view.frame = CGRectMake(10, tableView.rowHeight - 2, WIDTH-20, 1);
        [cell addSubview:space_view];
    }
    /*
     orderId	订单Id	数字
     content	咨询或回复内容	字符串
     createtime	订单咨询或回复时间	字符串
     unRead	未读信息条数	数字
     */
    return cell;
}

-(void)getCustomerServiceList{
    NSString * interface = @"/member/myCustomerServiceList.intf";
    NSDictionary * send = @{
                            @"memberId":MEMBERID
                            };
    [MYTOOL netWorkingWithTitle:@"获取客服列表"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * array = back_dic[@"myCustomerServiceList"];
        self.myCustomerServiceList = array;
        /*
         orderId	订单Id	数字
         content	咨询或回复内容	字符串
         createtime	订单咨询或回复时间	字符串
         unRead	未读信息条数	数字
         */
        if (array.count > 0) {
            self.noDateView.hidden = true;
        }else{
            self.noDateView.hidden = false;
        }
        [self.tableView reloadData];
    }];
}
//返回上个界面
-(void)back_pop{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getCustomerServiceList];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}
@end
