//
//  MyMessageVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "MyMessageVC.h"
#import "CustomerListVC.h"
@interface MyMessageVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * cell_data_arr;
@property(nonatomic,strong)NSArray * myUnreadMessageArray;//未读消息数组
@end

@implementation MyMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [UIColor whiteColor];
    //加载界面数据
    {
        self.cell_data_arr = @[
                               @[@"收到的评论",@"MyMessageSectionsViewController"],
                               @[@"收到的赞",@"ReceiveSupportViewController"],
                               @[@"新的订阅",@"NewSubscribeViewController"],
                               @[@"系统消息",@"SystemMessageViewController"],
                               @[@"我的客服",@"CustomerListVC"]
                               ];
    }
    //tableView
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = [MYTOOL getRectWithIphone_six_X:0 andY:10 andWidth:375 andHeight:594];
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        //不显示分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = 50/667.0*HEIGHT;
    }
    
    
    
    
}

#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];// 取消选中
    NSString * className = self.cell_data_arr[indexPath.row][1];
    NSString * title = self.cell_data_arr[indexPath.row][0];
    Class class = NSClassFromString(className);
    id vc = [class new];
    [vc setTitle:title];
    [self.navigationController pushViewController:vc animated:true];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cell_data_arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    //标题
    UILabel * title_label = [UILabel new];
    {
        title_label.frame = [MYTOOL getRectWithIphone_six_X:14 andY:16 andWidth:180 andHeight:18];
        title_label.text = self.cell_data_arr[indexPath.row][0];
        title_label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
//        title_label.font = [UIFont systemFontOfSize:18/375.0*HEIGHT];
        [cell addSubview:title_label];
    }
    //右侧图片
    {
        UIImageView * next_icon = [UIImageView new];
        next_icon.frame = CGRectMake(WIDTH-40, tableView.rowHeight/2-15, 30, 30);
        next_icon.image = [UIImage imageNamed:@"arrow_right"];
        [cell addSubview:next_icon];
    }
    //分割线
    {
        UIView * space_view = [UIView new];
        space_view.frame = CGRectMake(title_label.frame.origin.x, tableView.rowHeight-1, WIDTH-title_label.frame.origin.x-20, 1);
        space_view.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
        [cell addSubview:space_view];
    }
    //未读消息数量
    {
        NSDictionary * unreadDic = self.myUnreadMessageArray[indexPath.row];
        int count = [unreadDic[@"unread"] intValue];
        if (count > 0) {
            NSString * text = [NSString stringWithFormat:@"%d",count];
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
    return cell;
}


//获取我的消息
-(void)getMyMessage{
    NSString * interfaceName = @"/member/myMessage.intf";
    
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"我的消息:%@",back_dic);
        self.myUnreadMessageArray = back_dic[@"typeList"];
        [self.tableView reloadData];
    }];
}

#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getMyMessage];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}

@end
