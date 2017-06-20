//
//  MyOrderVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "MyOrderVC.h"
#import "ContactCustomerVC.h"
#import "AliPayTool.h"
#import "SelectPayTypeVC.h"
#import "OrderInfoVC.h"
#import "ShowExpress.h"
#import "ShoppingCartVC.h"
@interface MyOrderVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray * orderArray;//所有订单信息
@property(nonatomic,strong)NSMutableArray * timerArray;//定时器
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIView * greenView;//按钮下方view
@property(nonatomic,assign)SelectPayTypeVC * selectPayVC;//选择支付方式
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@end

@implementation MyOrderVC
{
    NSTimer * timer;//定时器
    NSMutableArray * statusBtnArray;//状态按钮数组
    int pageNo;//分页
    NSInteger currentIndex;//当前按钮序号
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //加载主界面
    [self loadMainView];
    pageNo = 1;
    [self orderStatusBtnCallback:statusBtnArray[0]];
}
//加载主界面
-(void)loadMainView{
    //状态选择view
    UIView * bgView = [UIView new];
    {
        bgView.frame = CGRectMake(0, 0, WIDTH, 46);
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
    }
    //4个按钮
    NSArray * nameArray = @[@"全部",@"待付款",@"待发货",@"待收货"];
    float space = (WIDTH - 60*4)/5.0;
    float width = 60;
    statusBtnArray = [NSMutableArray new];
    for (int i = 0; i < 4 ;i ++) {
        UIButton * btn = [UIButton new];
        [btn setTitle:nameArray[i] forState:UIControlStateNormal];
        btn.frame = CGRectMake(space+(width + space)*i, 14, 60, 18);
        [btn setTitleColor:[MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:[MYTOOL RGBWithRed:115 green:159 blue:52 alpha:1] forState:UIControlStateDisabled];
        [statusBtnArray addObject:btn];
        [bgView addSubview:btn];
        [btn addTarget:self action:@selector(orderStatusBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
    }
    //初始化第一个按钮及下边的view
    {
        UIView * view = [UIView new];
        UIButton * btn = statusBtnArray[0];
        btn.enabled = false;
        CGRect rect = btn.frame;
        view.frame = CGRectMake(rect.origin.x, bgView.frame.size.height-3, rect.size.width, 3);
        [bgView addSubview:view];
        view.layer.masksToBounds = true;
        view.layer.cornerRadius = 1.5;
        self.greenView = view;
        view.backgroundColor = [MYTOOL RGBWithRed:115 green:158 blue:52 alpha:1];
    }
    //表视图
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 46, WIDTH, HEIGHT-64-46);
        self.tableView = tableView;
        [self.view addSubview:tableView];
        tableView.dataSource = self;
        tableView.delegate = self;
        //解决tableView露白
        self.automaticallyAdjustsScrollViewInsets = false;
        //不显示分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
                label.text = @"暂无订单数据";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = MYCOLOR_46_42_42;
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(0, 10, WIDTH, 20);
                [view addSubview:label];
            }
        }
    }
}
//订单状态按钮回调
-(void)orderStatusBtnCallback:(UIButton *)btn{
    btn.enabled = false;
    CGRect rect = btn.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.greenView.frame = CGRectMake(rect.origin.x, 43, rect.size.width, 3);
    }];
    for (UIButton * button in statusBtnArray) {
        if (![button isEqual:btn]) {
            button.enabled = true;
        }
    }
    NSInteger index = [statusBtnArray indexOfObject:btn];
    if (index != currentIndex) {
        pageNo = 1;
    }
    currentIndex = index;
    [self getOrderDataWithStatus:(int)index];
}
#pragma mark - 上拉、下拉刷新
-(void)headerRefresh{
    pageNo = 1;
    [self orderStatusBtnCallback:statusBtnArray[currentIndex]];
}
-(void)footerRefresh{
    pageNo ++;
    [self orderStatusBtnCallback:statusBtnArray[currentIndex]];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * orderDic = self.orderArray[indexPath.section];
//    NSLog(@"订单:%@",orderDic);
    [MYTOOL netWorkingWithTitle:@"查询订单…"];
    NSString * interface = @"/shop/order/getOrderInfo.intf";
    NSDictionary * sendDic = @{
                               @"orderId":orderDic[@"orderId"]
                               };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        NSDictionary * orderDic = back_dic[@"order"];
        if (orderDic) {
            OrderInfoVC * infoVC = [OrderInfoVC new];
            infoVC.title = @"订单详情";
            infoVC.orderDictionary = orderDic;
            infoVC.timeLeft = -1;
            //订单状态
            int sta = [orderDic[@"orderStatus"] intValue];
            //如果未支付
            if (sta == 1) {
                for (NSMutableDictionary * dic in self.timerArray) {
                    //订单号
                    NSInteger orderId = [dic[@"orderId"] longValue];
                    if (orderId == [orderDic[@"orderId"] longValue]) {
                        infoVC.timeLeft = [dic[@"timeLeft"] intValue];
                        break;
                    }
                }
            }
            
            
            infoVC.delegate = self;
            [self.navigationController pushViewController:infoVC animated:true];
        }else{
            [SVProgressHUD showErrorWithStatus:@"订单有误" duration:2];
        }
    }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * dic = self.orderArray[indexPath.section];
    NSInteger count = [dic[@"goodsList"] count];
    return 280 - 113 + 113 * count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.orderArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * orderDic = self.orderArray[indexPath.section];
    NSInteger count = [orderDic[@"goodsList"] count];
    float height = 280 - 113 + 113 * count;
    //订单编号
    {
        UILabel * label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15];
        NSString * orderNo = orderDic[@"orderNo"];
        label.text = [NSString stringWithFormat:@"订单号：%@",orderNo];
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(15, 12, size.width, size.height);
        [cell addSubview:label];
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
    }
    //订单状态
    int sta = [orderDic[@"orderStatus"] intValue];
    {
        UILabel * label = [UILabel new];
        label.text = orderDic[@"statusName"];
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [MYTOOL RGBWithRed:113 green:157 blue:52 alpha:1];
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(WIDTH-14-size.width, 12, size.width, size.height);
        [cell addSubview:label];
    }
    //创建时间
    {
        NSString * createDate = orderDic[@"createDate"];
        UILabel * label = [UILabel new];
        label.textColor = [MYTOOL RGBWithRed:188 green:188 blue:188 alpha:1];
        label.text = createDate;
        label.font = [UIFont systemFontOfSize:13];
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(15, 34, size.width, size.height);
        [cell addSubview:label];
    }
    //剩余时间
    {
        if (sta == 1) {
            //剩余时间
            NSInteger timeLeft = [orderDic[@"timeLeft"] longValue];
            if (timeLeft > 0) {
                UILabel * label = [UILabel new];
                label.text = [NSString stringWithFormat:@"剩余时间: %02ld:%02ld",timeLeft/60,timeLeft%60];
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = MYCOLOR_181_181_181;
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(WIDTH-size.width-20, 34, size.width + 5, size.height);
                [cell addSubview:label];
                //获取订单号相同的数据
                for (NSMutableDictionary * dictionary in self.timerArray) {
                    NSInteger orderId = [dictionary[@"orderId"] longValue];
                    if (orderId == [orderDic[@"orderId"] longValue]) {
                        [dictionary setValue:label forKey:@"label"];
                        break;
                    }
                }
            }
        }
    }
    //商品分割线
    {
        UIView * view = [UIView new];
        view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
        view.frame = CGRectMake(15, 55, WIDTH-15-14, 1);
        [cell addSubview:view];
    }
    //商品
    {
        NSArray * goodsArray = orderDic[@"goodsList"];
        float height = 112;
        for (int i = 0; i < goodsArray.count; i ++) {
            NSDictionary * goodsDic = goodsArray[i];
            //背景
            UIView * bgView = [UIView new];
            {
                bgView.backgroundColor = [MYTOOL RGBWithRed:249 green:251 blue:247 alpha:1];
                bgView.frame = CGRectMake(15, 56+(2+height)*i, WIDTH-15-14, height);
                [cell addSubview:bgView];
            }
            //图片
            {
                UIImageView * imgV = [UIImageView new];
                NSString * url = goodsDic[@"url"];
                imgV.frame = CGRectMake(0, 11, 90, 90);
                [imgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
                [bgView addSubview:imgV];
            }
            //商品名称
            float top = 5;
            {
                NSString * goodsName = goodsDic[@"goodsName"];
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:16];
                label.text = goodsName;
//                label.backgroundColor = [UIColor greenColor];
                [bgView addSubview:label];
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                float width = WIDTH - 15 - 90 - 10 - 14;
                label.frame = CGRectMake(100, top, width, size.height);
                if (size.width > width) {
                    label.frame = CGRectMake(100, top, width, size.height*2);
                    label.numberOfLines = 0;
                    if (size.width > width * 2) {
                        while (size.width > width * 2) {
                            label.font = [UIFont systemFontOfSize:label.font.pointSize - 1];
                            size = [MYTOOL getSizeWithLabel:label];
                        }
                    }
                    top += size.height * 2 + 10;
                }else{
                    top += size.height + 10;
                }
                
            }
            //商品规格
            {
                NSString * productName = goodsDic[@"productName"];
                UILabel * label = [UILabel new];
//                label.backgroundColor = [UIColor greenColor];
                label.font = [UIFont systemFontOfSize:13];
                label.text = [NSString stringWithFormat:@"规格：%@",productName];
                [bgView addSubview:label];
                label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                float width = WIDTH - 15 - 90 - 10 - 14;
                label.frame = CGRectMake(100, top, width, size.height);
                
                if (size.width > width) {
                    label.frame = CGRectMake(100, top, width, size.height*2);
                    label.numberOfLines = 0;
                    if (size.width > width * 2) {
                        while (size.width > width * 2) {
                            label.font = [UIFont systemFontOfSize:label.font.pointSize - 1];
                            size = [MYTOOL getSizeWithLabel:label];
                        }
                    }
                    top += size.height * 2 + 10;
                }else{
                    top += size.height + 10;
                }
            }
            //价格
            {
                float price = [goodsDic[@"price"] floatValue];
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:16];
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                label.text = [NSString stringWithFormat:@"￥%.2f",price];
                if (price == (int)price) {
                    label.text = [NSString stringWithFormat:@"￥%d",(int)price];
                }
//                if ([goodsDic[@"point"] floatValue] > 0) {
//                    label.text = [NSString stringWithFormat:@"%@积分 + %@",goodsDic[@"point"],label.text];
//                }
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(100, 90, size.width, size.height);
                [bgView addSubview:label];
            }
            //数量
            {
                int quantity = [goodsDic[@"quantity"] intValue];
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:16];
                label.text = [NSString stringWithFormat:@"X%d",quantity];
                label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:181];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(bgView.frame.size.width - size.width, 90, size.width, size.height);
                [bgView addSubview:label];
            }
        }
    }
    //分割线
    {
        UIView * view = [UIView new];
        view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
        view.frame = CGRectMake(15, height - 55, WIDTH-15-14, 1);
        [cell addSubview:view];
    }
    //价钱
    {
        float left = WIDTH - 14;
        float top = height - 65;
        //快递金额	double
        float expressPrice = [orderDic[@"expressPrice"] floatValue];
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.text = [NSString stringWithFormat:@"(含运费%.2f元)",expressPrice];
            if (expressPrice == (int)expressPrice) {
                label.text = [NSString stringWithFormat:@"(含运费%d元)",(int)expressPrice];
            }
            CGSize size = [MYTOOL getSizeWithLabel:label];
            left -= size.width;
            label.frame = CGRectMake(left, top-size.height, size.width, size.height);
            [cell addSubview:label];
            left -= 5;
        }
        //订单总金额	double
        float totalPrice = [orderDic[@"totalPrice"] floatValue];
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [MYTOOL RGBWithRed:220 green:53 blue:53 alpha:1];
            label.text = [NSString stringWithFormat:@"￥%.2f",totalPrice];
            if (totalPrice == (int)totalPrice) {
                label.text = [NSString stringWithFormat:@"￥%d",(int)totalPrice];
            }
//            int totalPoint = [orderDic[@"totalPoint"] intValue];
//            if (totalPoint > 0) {
//                label.text = [NSString stringWithFormat:@"%d积分 + %@",totalPoint,label.text];
//            }
            CGSize size = [MYTOOL getSizeWithLabel:label];
            left -= size.width;
            label.frame = CGRectMake(left, top-size.height, size.width, size.height);
            [cell addSubview:label];
            left -= 5;
        }
        //商品数量	数字
        int quantity = [orderDic[@"quantity"] intValue];
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.text = [NSString stringWithFormat:@"共%d件  应付总额:",quantity];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            left -= size.width;
            label.frame = CGRectMake(left, top-size.height, size.width, size.height);
            [cell addSubview:label];
        }
    }
    //下侧按钮
    {
        //订单id
        NSInteger orderId = [orderDic[@"orderId"] longValue];
        float top = height - 12-31;
        int orderStatus = [orderDic[@"orderStatus"] intValue];
        //按钮字体颜色
        UIColor * greenColor = [MYTOOL RGBWithRed:113 green:157 blue:52 alpha:1];
        UIColor * blackColor = [MYTOOL RGBWithRed:92 green:92 blue:92 alpha:1];
        //按钮背景图
        UIImage * greenImage = [UIImage imageNamed:@"btn_green"];
        UIImage * blackImage = [UIImage imageNamed:@"btn_gray"];
        //按钮字体大小
        UIFont * btnFont = [UIFont systemFontOfSize:15];
        //待付款
        if (orderStatus == 1) {
            //立即付款按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91, top, 91, 31);
                [btn setBackgroundImage:greenImage forState:UIControlStateNormal];
                [btn setTitle:@"立即付款" forState:UIControlStateNormal];
                [btn setTitleColor:greenColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = indexPath.section;
                [btn addTarget:self action:@selector(rightNowPayCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //取消订单按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91-91-5, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"取消订单" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(cancelOrderCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //联系客服按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91-91-5-91-5, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"联系客服" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(contactCustomerServiceCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else if(orderStatus == 2){//待发货
            //提醒发货按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91, top, 91, 31);
                [btn setBackgroundImage:greenImage forState:UIControlStateNormal];
                [btn setTitle:@"提醒发货" forState:UIControlStateNormal];
                [btn setTitleColor:greenColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(remindDispatchGoodsCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //联系客服按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91-91-5, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"联系客服" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(contactCustomerServiceCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else if(orderStatus == 3){//待收货
            //确认收货
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91, top, 91, 31);
                [btn setBackgroundImage:greenImage forState:UIControlStateNormal];
                [btn setTitle:@"确认收货" forState:UIControlStateNormal];
                [btn setTitleColor:greenColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(confirmReceiveCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //联系客服按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91-91-5, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"联系客服" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(contactCustomerServiceCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //查看物流
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91-91-5-91-5, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"查看物流" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(showExpressCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else if(orderStatus == 5){//已完成
            //再来一单
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91-91-5, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"再来一单" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(buyAgainCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //确认收货
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"删除订单" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(deleteOrderCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else if(orderStatus == 6){//已取消
            //确认收货
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-91, top, 91, 31);
                [btn setBackgroundImage:blackImage forState:UIControlStateNormal];
                [btn setTitle:@"删除订单" forState:UIControlStateNormal];
                [btn setTitleColor:blackColor forState:UIControlStateNormal];
                btn.titleLabel.font = btnFont;
                [cell addSubview:btn];
                btn.tag = orderId;
                [btn addTarget:self action:@selector(deleteOrderCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
    }
    
    return cell;
}
//再来一单事件
-(void)buyAgainCallback:(UIButton *)btn{
    NSString * interface = @"/shop/order/buyAgain.intf";
    NSDictionary * send = @{
                            @"orderId":@(btn.tag)
                            };
    [MYTOOL netWorkingWithTitle:@"购买中…"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        ShoppingCartVC * shop = [ShoppingCartVC new];
        shop.title = @"购物车";
        [self.navigationController pushViewController:shop animated:true];
    }];
}
//查看物流事件
-(void)showExpressCallback:(UIButton *)btn{
    [MYTOOL netWorkingWithTitle:@"获取物流"];
    NSString * interface = @"/shop/order/getOrderInfo.intf";
    NSDictionary * sendDic = @{
                               @"orderId":@(btn.tag)
                               };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        NSDictionary * orderDic = back_dic[@"order"];
        
        NSString * expressName = orderDic[@"expressName"];
        NSString * expressNo = orderDic[@"expressNo"];
        ShowExpress * show = [ShowExpress new];
        show.expressName = expressName;
        show.logisicCode = expressNo;
        show.title = @"物流信息";
        [self.navigationController pushViewController:show animated:true];
    }];
    
}
//提醒发货事件
-(void)remindDispatchGoodsCallback:(UIButton *)btn{
//    NSLog(@"提醒发货-orderId:%ld",btn.tag);
    NSString * interface = @"/shop/order/remindOrder.intf";
    [MYTOOL netWorkingWithTitle:@"提醒中…"];
    NSDictionary * send = @{
                            @"orderId":@(btn.tag)
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"提醒成功" duration:1];
    }];
}
//联系客服事件
-(void)contactCustomerServiceCallback:(UIButton *)btn{
    ContactCustomerVC * contactVC = [ContactCustomerVC new];
    contactVC.title = @"联系客服";
    contactVC.orderId = btn.tag;
    [self.navigationController pushViewController:contactVC animated:true];
}
//取消订单事件
-(void)cancelOrderCallback:(UIButton *)btn{
    NSInteger orderId = btn.tag;
    NSString * interface = @"/shop/order/cancelOrder.intf";
    NSDictionary * sendDic = @{
                               @"memberId":MEMBERID,
                               @"orderId":[NSString stringWithFormat:@"%ld",orderId]
                               };
    [MYTOOL netWorkingWithTitle:@"订单取消中…"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"订单已取消" duration:1];
        [self updateViewAllState];
    }];
}
//立即付款事件
-(void)rightNowPayCallback:(UIButton *)btn{
    NSDictionary * goodsDictionary = self.orderArray[btn.tag];
    SelectPayTypeVC * payVC = [SelectPayTypeVC new];
    payVC.isSuccess = true;
    payVC.orderDictionary = goodsDictionary;
    payVC.delegate = self;
    self.selectPayVC = payVC;
    [payVC show];
}
//删除订单事件
-(void)deleteOrderCallback:(UIButton *)btn{
    
    [MYTOOL showAlertWithViewController:self andTitle:@"确定删除此订单吗?" andSureTile:@"删除" andSureBlock:^{
        NSString * interface = @"/shop/order/delOrder.intf";
        [MYTOOL netWorkingWithTitle:@"订单删除…"];
        NSDictionary * sendDic = @{
                                   @"orderId":[NSString stringWithFormat:@"%ld",btn.tag]
                                   };
        [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
            [self updateViewAllState];
        }];
    } andCacel:^{
        
    }];
    
}
//确认收货事件
-(void)confirmReceiveCallback:(UIButton *)btn{
//    NSLog(@"确认收货-orderId:%ld",btn.tag);
    NSString * interface = @"/shop/order/confirmReceipt.intf";
    [MYTOOL netWorkingWithTitle:@"确认收货中…"];
    NSDictionary * send = @{
                            @"orderId":@(btn.tag)
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"确认收货成功" duration:1];
        [self updateViewAllState];
    }];
    
    
    
}
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}
//获取订单数据
-(void)getOrderDataWithStatus:(int)status{
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    NSString * interfaceName = @"/shop/order/getOrder.intf";
    NSDictionary * sendDic = @{
                               @"memberId":MEMBERID,
                               @"status":[NSString stringWithFormat:@"%d",status],
                               @"pageNo":@(pageNo)
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        NSArray * orderArray = back_dic[@"orderList"];
//        NSLog(@"订单列表:%@",orderArray[0]);
        self.timerArray = [NSMutableArray new];
        for (NSDictionary * orderDic in orderArray) {
            int payStatus = [orderDic[@"payStatus"] intValue];
            if (payStatus) {
                continue;
            }
            //订单id
            NSObject * orderId = orderDic[@"orderId"];
            //剩余时间
            NSInteger timeLeft = [orderDic[@"timeLeft"] longValue];
            if (timeLeft <= 0) {
//                NSLog(@"订单号:%@ - 需要取消",orderId);
                //取消订单--不可能取到负的时间
                
            }else{
                NSMutableDictionary * dict = [NSMutableDictionary new];
                [dict setValue:orderId forKey:@"orderId"];
                [dict setValue:@(timeLeft) forKey:@"timeLeft"];
                [self.timerArray addObject:dict];
            }
        }
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshTimeLeft) userInfo:nil repeats:true];
        
        if (pageNo == 1) {
            self.orderArray = [NSMutableArray arrayWithArray:orderArray];
        }else{
            if (orderArray.count > 0) {
                [self.orderArray addObjectsFromArray:orderArray];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
        }
        if (self.orderArray.count == 0) {
            self.noDateView.hidden = false;
        }else{
            self.noDateView.hidden = true;
        }
        [self.tableView reloadData];
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.orderArray removeAllObjects];
            [self.tableView reloadData];
        }else{
            pageNo --;
        }
    }];
}
//定时器刷新剩余时间
-(void)refreshTimeLeft{
    bool flag = false;
    for (NSMutableDictionary * dic in self.timerArray) {
        //订单号
        NSInteger orderId = [dic[@"orderId"] longValue];
        //剩余时间
        int timeLeft = [dic[@"timeLeft"] intValue];
        timeLeft -- ;
        if (timeLeft == 0) {
            UIView * view = [UIView new];
            view.tag = orderId;
            [self cancelOrderCallback:(UIButton *)view];
            continue;
        }
        [dic setValue:@(timeLeft) forKey:@"timeLeft"];
        //显示时间文本
        UILabel * label = dic[@"label"];
        if (label) {
            label.text = [NSString stringWithFormat:@"剩余时间: %2d:%02d",timeLeft/60,timeLeft%60];
        }
        if (timeLeft > 0) {
            flag = true;
        }
    }
    if (!flag) {
        [timer invalidate];
    }
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(paySuccess) name:NOTIFICATION_PAY_SUCCESS object:nil];
}
//更新界面
-(void)updateViewCurrentState{
    NSInteger index = 0;
    for (UIButton * button in statusBtnArray) {
        if (button.enabled == false) {
            index = [statusBtnArray indexOfObject:button];
            break;
        }
    }
    [self orderStatusBtnCallback:statusBtnArray[0]];
}
//重新加载全部订单
-(void)updateViewAllState{
    [self orderStatusBtnCallback:statusBtnArray[0]];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_PAY_SUCCESS object:nil];
}
-(void)paySuccess{
    [self.selectPayVC removeFromSuperViewController:nil];
    [self orderStatusBtnCallback:statusBtnArray[0]];
}
@end
