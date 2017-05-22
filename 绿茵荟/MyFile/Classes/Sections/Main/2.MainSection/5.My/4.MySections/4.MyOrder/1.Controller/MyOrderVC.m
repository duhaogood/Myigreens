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
@interface MyOrderVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSArray * orderArray;//所有订单信息
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIView * greenView;//按钮下方view
@property(nonatomic,assign)SelectPayTypeVC * selectPayVC;//选择支付方式
@end

@implementation MyOrderVC
{
    NSMutableArray * statusBtnArray;//状态按钮数组
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //加载主界面
    [self loadMainView];
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
    [self getOrderDataWithStatus:(int)index];
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
        //
        NSLog(@"back:%@",back_dic[@"order"]);
        NSDictionary * orderDic = back_dic[@"order"];
        if (orderDic) {
            OrderInfoVC * infoVC = [OrderInfoVC new];
            infoVC.title = @"订单详情";
            infoVC.orderDictionary = orderDic;
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
        NSString * orderNo = orderDic[@"orderId"];
        label.text = [NSString stringWithFormat:@"订单号：%@",orderNo];
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(15, 12, size.width, size.height);
        [cell addSubview:label];
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
    }
    //订单状态
    {
        NSString * status = @"待付款";
        int sta = [orderDic[@"orderStatus"] intValue];
        if (sta != 1) {
            switch (sta) {
                case 2:
                    status = @"待发货";
                    break;
                case 3:
                    status = @"待收货";
                    break;
                case 6:
                    status = @"已取消";
                    break;
                default:
                    printf("订单状态：%d",sta);
                    break;
            }
        }
        UILabel * label = [UILabel new];
        label.text = status;
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
    /*
     orderPrice		订单金额	double
     expressPrice		快递金额	double
     totalPrice		订单总金额	double
     discountPrice		优惠金额	数字
     quantity		商品数量	数字
     createDate		创建时间	日期
     payStatus		是否需要支付	boolean
     timeLeft		时间剩余多少	数字
     goodsList	goodsId	商品id	数字
     goodsName	商品名称	字符串
     image	商品图片	字符串
     price	商品价格	double
     marketPrice	市场价格	double
     productName	产品名称	字符串
     quantity	产品数量	数字
     */
    
    return cell;
}
//查看物流事件
-(void)showExpressCallback:(UIButton *)btn{
    ShowExpress * show = [ShowExpress new];
    show.title = @"物流信息";
    [self.navigationController pushViewController:show animated:true];
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
//    NSLog(@"联系客服-orderId:%ld",btn.tag);
//    NSString * interface = @"/shop/order/getOrderAsk.intf";
//    NSDictionary * sendDic = @{
//                               @"memberId":MEMBERID,
//                               @"orderId":[NSString stringWithFormat:@"%ld",btn.tag]
//                               };
//    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
//    }];
//    return;
    ContactCustomerVC * contactVC = [ContactCustomerVC new];
    contactVC.title = @"在线客服";
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
    NSLog(@"删除订单-orderId:%ld",btn.tag);
    NSString * interface = @"/shop/order/delOrder.intf";
    [MYTOOL netWorkingWithTitle:@"订单删除…"];
    NSDictionary * sendDic = @{
                               @"orderId":[NSString stringWithFormat:@"%ld",btn.tag]
                               };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
        [self updateViewAllState];
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
    }];
    
    
    
}
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
//获取订单数据
-(void)getOrderDataWithStatus:(int)status{
    [SVProgressHUD showWithStatus:@"加载中…" maskType:SVProgressHUDMaskTypeClear];
    NSString * interfaceName = @"/shop/order/getOrder.intf";
    NSDictionary * sendDic = @{
                               @"memberId":MEMBERID,
                               @"status":[NSString stringWithFormat:@"%d",status]
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        NSArray * orderArray = back_dic[@"orderList"];
//        NSLog(@"订单个数:%@",orderArray[0]);
        self.orderArray = orderArray;
//        for (NSDictionary * dic in orderArray) {
//            NSObject * obj = dic[@"createDate"];
//            NSLog(@"obj:%@",obj);
//        }
        [self.tableView reloadData];
    }];
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
