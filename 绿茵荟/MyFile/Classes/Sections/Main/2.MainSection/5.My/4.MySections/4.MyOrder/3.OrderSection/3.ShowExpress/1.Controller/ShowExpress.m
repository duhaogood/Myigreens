//
//  ShowExpress.m
//  绿茵荟
//
//  Created by Mac on 17/5/19.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ShowExpress.h"

@interface ShowExpress ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * expressArray;//快递信息
@property(nonatomic,copy)NSString * shipperCode;//快递编号
@property(nonatomic,copy)NSString * nameOfExpress;//名字
@property(nonatomic,copy)NSString * expressStatic;//状态
@end

@implementation ShowExpress
{
    NSArray * expressName_code_array;//快递名称及code数组
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = [[NSBundle mainBundle] pathForResource:@"express" ofType:@"plist"];
    expressName_code_array = [NSArray arrayWithContentsOfFile:path];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    UITableView * tableView = [UITableView new];
    self.automaticallyAdjustsScrollViewInsets = false;
    tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    tableView.rowHeight = 80;
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getExpressInfo];
        // 结束刷新
        [tableView.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getExpressInfo];
        [tableView.mj_footer endRefreshing];
    }];
}


#pragma mark -UITableViewDataSource,UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [MYTOOL getHeightWithIphone_six:153];
    }
    UILabel * label = [UILabel new];
    float width = WIDTH - 50 - 14;
    NSString * acceptStation = self.expressArray[indexPath.row][@"acceptStation"];
    label.text = acceptStation;
    label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
    if (indexPath.row == 0) {
        label.textColor = [MYTOOL RGBWithRed:114 green:158 blue:52 alpha:1];
    }
    CGSize size = [MYTOOL getSizeWithLabel:label];
    int row = size.width/width;
    if (size.width > row * width) {
        row ++;
    }
    return row * size.height + 15 + 35;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return self.expressArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    //无法选中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        //背景view
        {
            UIView * bgView = [UIView new];
            [cell addSubview:bgView];
            float height = [MYTOOL getHeightWithIphone_six:153];
            bgView.frame = CGRectMake(0, 0, WIDTH, height);
            bgView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
            //白色背景
            UIView * view = [UIView new];
            {
                view.backgroundColor = [UIColor whiteColor];
                view.frame = CGRectMake(0, 10, WIDTH, height-20);
                [bgView addSubview:view];
            }
            height -= 20;
            //两条分割线
            {
                for (int i = 0; i < 2; i ++) {
                    UIView * spaceView = [UIView new];
                    spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
                    spaceView.frame = CGRectMake(14, height/3*(i+1), WIDTH-28, 1);
                    [view addSubview:spaceView];
                }
            }
            //三条数据
            {
                UIFont * font = [UIFont systemFontOfSize:16];
                float left = 0;
                //物流编号
                {
                    //提示
                    {
                        UILabel * label = [UILabel new];
                        label.font = font;
                        label.text = @"订单编号:";
                        label.textColor = MYCOLOR_46_42_42;
                        CGSize size = [MYTOOL getSizeWithLabel:label];
                        label.frame = CGRectMake(14, height/6-size.height/2, size.width, size.height);
                        [view addSubview:label];
                        left = size.width + 14 + 30;
                    }
                    //编号
                    {
                        UILabel * label = [UILabel new];
                        label.text = self.logisicCode;
                        label.font = font;
                        label.textColor = MYCOLOR_181_181_181;
                        CGSize size = [MYTOOL getSizeWithLabel:label];
                        label.frame = CGRectMake(left, height/6-size.height/2, size.width, size.height);
                        [view addSubview:label];
                    }
                }
                //物流状态
                {
                    //提示
                    {
                        UILabel * label = [UILabel new];
                        label.font = font;
                        label.text = @"物流状态:";
                        label.textColor = MYCOLOR_46_42_42;
                        CGSize size = [MYTOOL getSizeWithLabel:label];
                        label.frame = CGRectMake(14, height/2-size.height/2, size.width, size.height);
                        [view addSubview:label];
                    }
                    //状态
                    {
                        UILabel * label = [UILabel new];
                        //订单状态-expressStatic: 0-无轨迹 2-在途中，3-签收,4-问题件
                        NSString * expressStatic = self.expressStatic;
                        int state = [expressStatic intValue];
                        NSString * text = @"";
                        if (state == 0) {
                            text = @"无轨迹";
                        }else if(state == 2){
                            text = @"在途中";
                        }else if(state == 3){
                            text = @"签收";
                        }else if(state == 4){
                            text = @"问题件";
                        }
                        label.text = text;
                        label.font = font;
                        label.textColor = MYCOLOR_181_181_181;
                        CGSize size = [MYTOOL getSizeWithLabel:label];
                        label.frame = CGRectMake(left, height/2-size.height/2, size.width, size.height);
                        [view addSubview:label];
                    }
                }
                //承运来源
                {
                    //提示
                    {
                        UILabel * label = [UILabel new];
                        label.font = font;
                        label.text = @"承运来源:";
                        label.textColor = MYCOLOR_46_42_42;
                        CGSize size = [MYTOOL getSizeWithLabel:label];
                        label.frame = CGRectMake(14, height/6*5-size.height/2, size.width, size.height);
                        [view addSubview:label];
                    }
                    //名称
                    {
                        UILabel * label = [UILabel new];
                        label.text = self.nameOfExpress;
                        label.font = font;
                        label.textColor = MYCOLOR_181_181_181;
                        CGSize size = [MYTOOL getSizeWithLabel:label];
                        label.frame = CGRectMake(left, height/6*5-size.height/2, size.width, size.height);
                        [view addSubview:label];
                    }
                }
            }
            
        }
        
        
        return cell;
    }
    float width = WIDTH - 50 - 14;
    float top = 0;
    //文字
    {
        NSString * acceptStation = self.expressArray[indexPath.row][@"acceptStation"];
        UILabel * label = [UILabel new];
        label.text = acceptStation;
        label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        if (indexPath.row == 0) {
            label.textColor = [MYTOOL RGBWithRed:114 green:158 blue:52 alpha:1];
        }
        CGSize size = [MYTOOL getSizeWithLabel:label];
        int row = size.width/width;
        if (size.width > row * width) {
            row ++;
        }
        if (row > 1) {
            label.numberOfLines = 0;
        }
        label.frame = CGRectMake(50, 15, width, row*size.height);
        [cell addSubview:label];
        top = 15 + row*size.height;
    }
    //时间
    {
        NSString * acceptTime = self.expressArray[indexPath.row][@"acceptTime"];
        UILabel * label = [UILabel new];
        label.text = acceptTime;
        label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        if (indexPath.row == 0) {
            label.textColor = [MYTOOL RGBWithRed:114 green:158 blue:52 alpha:1];
        }
        label.frame = CGRectMake(50, top + 10, width, 15);
        [cell addSubview:label];
    }
    //分割线-横
    {
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = MYCOLOR_181_181_181;
        spaceView.frame = CGRectMake(50, top+10+15+9, width, 1);
        [cell addSubview:spaceView];
    }
    //左竖线
    {
        UIView * leftView = [UIView new];
        leftView.backgroundColor = MYCOLOR_181_181_181;
        leftView.frame = CGRectMake(24, 0, 1, top+10+15+10);
        if (indexPath.row == 0) {
            leftView.frame = CGRectMake(24, 18, 1, top+10+10-3);
        }
        [cell addSubview:leftView];
    }
    //标志图片
    {
        UIImageView * icon = [UIImageView new];
        icon.image = [UIImage imageNamed:@"dot_gray"];
        icon.frame = CGRectMake(20.5, 18, 9, 9);
        if (indexPath.row == 0) {
            icon.image = [UIImage imageNamed:@"dot_green"];
            icon.frame = CGRectMake(16, 15, 18, 18);
        }
        [cell addSubview:icon];
    }
    
    return cell;
}
//重新加载物流信息
-(void)getExpressInfo{
    [MYTOOL netWorkingWithTitle:@"获取中"];
    NSString * shipperCode = @"";//快递公司编号
    NSString * interface = @"/shop/order/expressInfo.intf";
    //加载plist
    NSString * path = [[NSBundle mainBundle] pathForResource:@"expressCode" ofType:@"plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary * name_code in array) {
        NSString * name = name_code[@"name"];
        if ([name isEqualToString:self.expressName]) {
            NSString * code = name_code[@"code"];
            shipperCode = code;
            break;
        }
        if ([self.expressName rangeOfString:name].location != NSNotFound) {
            NSString * code = name_code[@"code"];
            shipperCode = code;
            break;
        }
    }
    NSString * logisticCode = self.logisicCode;//快递号
    NSDictionary * sendDic = @{
                               @"shipperCode":shipperCode,
                               @"logisticCode":logisticCode
                               };
    
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        NSDictionary * expressInfo = back_dic[@"expressList"];
        self.expressStatic = expressInfo[@"expressStatic"];
        self.logisicCode = expressInfo[@"logisicCode"];
        self.shipperCode = expressInfo[@"shipperCode"];
        self.nameOfExpress = expressInfo[@"expressName"];
        NSArray * arr = expressInfo[@"tracesList"];
        NSMutableArray * array = [NSMutableArray new];
        for (int i = 0; i < arr.count; i ++) {
            [array addObject:arr[arr.count-i-1]];
        }
        self.expressArray = array;
        [self.tableView reloadData];
    }];
}
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 界面隐藏或显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getExpressInfo];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}
@end
