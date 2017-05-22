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
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    self.automaticallyAdjustsScrollViewInsets = false;
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * customerDic = self.myCustomerServiceList[indexPath.row];
    NSInteger orderId = [customerDic[@"orderId"] longValue];
    ContactCustomerVC * customer = [ContactCustomerVC new];
    customer.orderId = orderId;
    customer.title = @"我的客服";
    [self.navigationController pushViewController:customer animated:true];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.myCustomerServiceList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSDictionary * customerDic = self.myCustomerServiceList[indexPath.row];
    NSInteger orderId = [customerDic[@"orderId"] longValue];
    //订单号
    {
        UILabel * label = [UILabel new];
        label.text = [NSString stringWithFormat:@"订单号:%ld",orderId];
        label.textColor = MYCOLOR_46_42_42;
        label.font = [UIFont systemFontOfSize:18];
        [cell addSubview:label];
        label.frame = CGRectMake(14, 75/667.0*HEIGHT/2-10, WIDTH/2, 20);
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
        NSLog(@"back:%@",back_dic);
        NSArray * array = back_dic[@"myCustomerServiceList"];
        self.myCustomerServiceList = array;
        
        
        self.myCustomerServiceList = @[
                                       @{
                                           @"orderId":@(126),
                                           @"createtime":@"123321123",
                                           @"unRead":@(2),
                                           @"content":@"哈哈"
                                           },
                                       @{
                                           @"orderId":@(125),
                                           @"createtime":@"123321123",
                                           @"unRead":@(2),
                                           @"content":@"哈哈"
                                           }
                                       ];
        /*
         orderId	订单Id	数字
         content	咨询或回复内容	字符串
         createtime	订单咨询或回复时间	字符串
         unRead	未读信息条数	数字
         */
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
