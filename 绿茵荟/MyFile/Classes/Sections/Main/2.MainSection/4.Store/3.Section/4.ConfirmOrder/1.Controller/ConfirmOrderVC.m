//
//  ConfirmOrderVC.m
//  绿茵荟
//
//  Created by Mac on 17/4/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ConfirmOrderVC.h"
#import "ReceiverView.h"
#import "SubmitPostTV.h"
#import "SelectPayTypeVC.h"
#import "AddressManagerVC.h"
#import "SelectExpressVC.h"
#import "SelectBonusVC.h"
@interface ConfirmOrderVC ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView * scrollView;//总背景
@property(nonatomic,strong)ReceiverView * receiverView;//收货人view
@property(nonatomic,strong)SubmitPostTV * messageTV;//留言
@property(nonatomic,strong)UILabel * discountCouponLabel;//优惠券label
@property(nonatomic,strong)UILabel * expressLabel;//快递label
@property(nonatomic,strong)UIButton * noTicketBtn;//不需要发票按钮
@property(nonatomic,strong)UIButton * ticketBtn;//需要发票按钮
@property(nonatomic,strong)UITextField * ticketTF;//发票抬头
@property(nonatomic,strong)UIView * ticketView;//发票抬头view
@property(nonatomic,strong)UILabel * quantityLabel;//数量label
@property(nonatomic,strong)UILabel * goodsPriceLabel;//商品价格label
@property(nonatomic,strong)UILabel * expressPriceLabel;//运费label
@property(nonatomic,strong)UILabel * pointLabel;//积分label
@property(nonatomic,strong)UILabel * totalPriceLabel;//总价label
@property(nonatomic,strong)UILabel * totalPriceLabel2;//合计总价label
@property(nonatomic,strong)UILabel * priceStateLabel;//总价提示label
@property(nonatomic,assign)SelectPayTypeVC * selectPayVC;//选择支付方式

@property(nonatomic,strong)UIView * middle_goods_view;//中间view
@property(nonatomic,strong)UIView * price_view;///价格view
@property(nonatomic,strong)UIView * btn_view;//底部按钮view
@end

@implementation ConfirmOrderVC
{
    float offset_y;//键盘出现或隐藏
//    float freight;//运费
//    float price_all;//加上运费的总钱
//    NSDictionary * expressDic;//快递信息
    bool isSuccess;//是否创建成功
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    offset_y = -1;
//    NSLog(@"商品数组:%@",self.goodsList);
    isSuccess = false;
//    NSLog(@"order:%@",self.order);
}
//加载主界面
-(void)loadMainView{
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    //总背景
    UIScrollView * scrollView = [UIScrollView new];
    scrollView.delegate = self;
    {
        scrollView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
        scrollView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
        //添加点击监听
        {
            //对srcollView添加点击响应
            UITapGestureRecognizer *sigleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
            sigleTapRecognizer.numberOfTapsRequired = 1;
            [scrollView addGestureRecognizer:sigleTapRecognizer];
        }
    }
    //收货人信息
    {
        NSDictionary * dic = nil;
        if (self.receiptAddress) {
            dic = self.receiptAddress;
        }
        ReceiverView * receiverView = receiverView = [[ReceiverView alloc]initWithReceiverInfo:dic andFrame:CGRectMake(0, 10, WIDTH, 91)];
        receiverView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:receiverView];
        self.receiverView = receiverView;
        //覆盖一个clear按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = receiverView.bounds;
            btn.backgroundColor = [UIColor clearColor];
            [receiverView addSubview:btn];
            [btn addTarget:self action:@selector(selectReceiverInfoCallback) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    UIView * goodsView = [UIView new];
    //商品信息
    {
        float top = 10;
        goodsView.backgroundColor = [UIColor whiteColor];
        self.middle_goods_view = goodsView;
        [scrollView addSubview:goodsView];
        //遍历商品
        {
            float height = 112;
            for (NSDictionary * goodsDic in self.goodsList) {
                UIView * goods_view = [UIView new];
                goods_view.frame = CGRectMake(10, top, WIDTH-20, height);
                goods_view.backgroundColor = [MYTOOL RGBWithRed:249 green:251 blue:247 alpha:1];
                [goodsView addSubview:goods_view];
                top += height + 2;
                //图片
                {
                    UIImageView * imgV = [UIImageView new];
                    imgV.frame = CGRectMake(0, 10.5, 91, 91);
                    [imgV sd_setImageWithURL:[NSURL URLWithString:goodsDic[@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
                    [goods_view addSubview:imgV];
                }
                //名称
                int row = 1;
                {
                    UILabel * label = [UILabel new];
                    label.text = goodsDic[@"goodsName"];
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    label.frame = CGRectMake(101, 10, WIDTH-101-14, 16);
                    label.font = [UIFont systemFontOfSize:16];
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    if (size.width > WIDTH-101-14) {
                        row = 2;
                        label.frame = CGRectMake(101, 10, WIDTH-101-14, 40);
                        label.numberOfLines = 0;
                    }
                    [goods_view addSubview:label];
                }
                //规格
                {
                    NSString * product = [NSString stringWithFormat:@"规格：%@",goodsDic[@"productName"]];
                    UILabel * label = [UILabel new];
                    label.text = product;
                    label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                    label.font = [UIFont systemFontOfSize:13];
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    //位置
                    float top_1 = 39;
                    if (row == 2) {
                        top_1 = 50;
                    }
                    label.frame = CGRectMake(101, top_1, WIDTH-101-14, 13);
                    if (size.width > WIDTH-101-14) {
                        label.frame = CGRectMake(101, top_1, WIDTH-101-14, 31.2);
                        label.numberOfLines = 0;
                    }
                    [goods_view addSubview:label];
                }
                //价钱
                {
                    UILabel * label = [UILabel new];
                    label.text = [NSString stringWithFormat:@"￥%@",goodsDic[@"price"]];
                    if (self.integral) {
                        label.text = [NSString stringWithFormat:@"%@积分 + ￥%@",goodsDic[@"point"],goodsDic[@"price"]];
                    }
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    label.font = [UIFont systemFontOfSize:16];
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(101, 88, size.width, size.height);
                    [goods_view addSubview:label];
                }
                //数量
                {
                    NSString * string = [NSString stringWithFormat:@"x %@",goodsDic[@"quantity"]];
                    UILabel * label = [UILabel new];
                    label.text = string;
                    label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                    label.font = [UIFont systemFontOfSize:16];
                    CGSize size = [MYTOOL getSizeWithString:string andFont:label.font];
                    label.frame = CGRectMake(WIDTH-size.width-5-30, 88, size.width, 16);
                    [goods_view addSubview:label];
                }
                /*
                 goodsName = "\U56db\U8f6e\U4ee3\U6b65\U8f66";
                 image = "http://pic27.nipic.com/20130122/10558908_131118160000_2.jpg";
                 marketPrice = 100;
                 price = "15.1";
                 productId = 101;
                 productName = "4\U9a71\U7535\U52a8\U7cfb\U5217";
                 quantity = 2;
                 */
            }
        }
        goodsView.frame = CGRectMake(0, 111, WIDTH, 300+top);
        self.scrollView.contentSize = CGSizeMake(0, top+300+160+109);
        //选择优惠券
        {
            top += 8;
            UIView * view = [UIView new];
            view.frame = CGRectMake(14, top, WIDTH-28, 50);
//            view.backgroundColor = [UIColor greenColor];
            [goodsView addSubview:view];
            top += 60;
            {
                //选择优惠券label
                {
                    UILabel * label = [UILabel new];
                    label.text = @"选择优惠券";
                    label.font = [UIFont systemFontOfSize:18];
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    label.frame = CGRectMake(0, 16, WIDTH/2, 18);
                    [view addSubview:label];
                }
                //可用张数
                {
                    NSString * text = self.order[@"bonusTitle"];
                    UILabel * label = [UILabel new];
                    label.text = text;
                    label.font = [UIFont systemFontOfSize:15];
                    label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                    label.frame = CGRectMake(WIDTH/2-20, 17.5, WIDTH/2-30, 15);
                    [view addSubview:label];
                    label.textAlignment = NSTextAlignmentRight;
                    self.discountCouponLabel= label;
                }
                //右侧图标
                {
                    UIImageView * imgV = [UIImageView new];
                    imgV.frame = CGRectMake(WIDTH-40-14, 50/2-15, 30, 30);
                    imgV.image = [UIImage imageNamed:@"arrow_right_store"];
                    [view addSubview:imgV];
                }
                //选择优惠券按钮
                {
                    UIButton * btn = [UIButton new];
                    btn.frame = view.bounds;
                    btn.backgroundColor = [UIColor clearColor];
                    [view addSubview:btn];
                    [btn addTarget:self action:@selector(selectDiscountCouponCallback) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            //分割线
            {
                UIView * spaceView = [UIView new];
                spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
                spaceView.frame = CGRectMake(0, 49, WIDTH-28, 1);
                [view addSubview:spaceView];
            }
        }
        //选择快递方式
        {
            UIView * view = [UIView new];
            view.frame = CGRectMake(14, top, WIDTH-28, 50);
            //            view.backgroundColor = [UIColor greenColor];
            [goodsView addSubview:view];
            //文字
            {
                //选择优惠券label
                {
                    UILabel * label = [UILabel new];
                    label.text = @"快递方式";
                    label.font = [UIFont systemFontOfSize:18];
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    label.frame = CGRectMake(0, 25-9, WIDTH/2, 18);
                    [view addSubview:label];
                }
                //快递名称
                {
                    UILabel * label = [UILabel new];
                    self.expressLabel = label;
                    NSString * expressName = self.order[@"expressName"];
                    if (expressName) {
                        label.text = expressName;
                    }
                    label.font = [UIFont systemFontOfSize:15];
                    label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                    label.frame = CGRectMake(WIDTH/2-20, 17.5, WIDTH/2-30, 15);
                    [view addSubview:label];
                    label.textAlignment = NSTextAlignmentRight;
                    self.expressLabel= label;
                }
                //右边图标
                {
                    UIImageView * imgV = [UIImageView new];
                    imgV.frame = CGRectMake(WIDTH-40-9, 50/2-15, 30, 30);
                    imgV.image = [UIImage imageNamed:@"arrow_right_store"];
                    [view addSubview:imgV];
                }
                //按钮
                {
                    UIButton * btn = [UIButton new];
                    btn.frame = view.bounds;
                    btn.backgroundColor = [UIColor clearColor];
                    [view addSubview:btn];
                    [btn addTarget:self action:@selector(selectAddressOfTicket) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            //分割线
            {
                UIView * spaceView = [UIView new];
                spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
                spaceView.frame = CGRectMake(0, 49, WIDTH-28, 1);
                [view addSubview:spaceView];
            }
            top += 60;
        }
        //留言
        {
            SubmitPostTV * messageTV = [[SubmitPostTV alloc]initWithFrame:CGRectMake(14, top, WIDTH-28, 60)];
            self.messageTV = messageTV;
            messageTV.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
            [goodsView addSubview:messageTV];
            messageTV.placeholderLabel.text = @"   给卖家留言/特殊要求/其他…";
            messageTV.font = [UIFont systemFontOfSize:15];
            messageTV.placeholderLabel.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
            messageTV.placeholderLabel.font = [UIFont systemFontOfSize:15];
            top += 70;
        }
        //分割线
        {
            UIView * spaceView = [UIView new];
            spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
            spaceView.frame = CGRectMake(14, top, WIDTH-28, 1);
            [goodsView addSubview:spaceView];
        }
        //发票信息
        {
            //匿名
            {
                //按钮
                top += 13;
                UIButton * noTicketBtn = [UIButton new];
                noTicketBtn.frame = CGRectMake(14, top-7, 30, 30);
                [noTicketBtn setImage:[UIImage imageNamed:@"radio_nor"] forState:UIControlStateNormal];
                [goodsView addSubview:noTicketBtn];
                self.noTicketBtn = noTicketBtn;
                noTicketBtn.tag = 0;
                [noTicketBtn addTarget:self action:@selector(noTicketBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
                //右侧文字
                {
                    UILabel * label = [UILabel new];
                    label.frame = CGRectMake(46, top, 80, 15);
                    label.font = [UIFont systemFontOfSize:15];
                    label.text = @"匿名购买";
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    [goodsView addSubview:label];
                }
                //右侧小文字
                {
                    UILabel * label = [UILabel new];
                    label.frame = CGRectMake(46, top+2, WIDTH-46-17, 30);
                    label.font = [UIFont systemFontOfSize:12];
                    label.numberOfLines = 0;
                    label.text = @"                  （我们将为您的购买信息保密,以绿茵荟的名义将宝贝送出）";
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    [goodsView addSubview:label];
                }
            }
            //要发票
            {
                top += 60;
                UIButton * ticketBtn = [UIButton new];
                ticketBtn.frame = CGRectMake(14, top-7, 30, 30);
                [ticketBtn setImage:[UIImage imageNamed:@"radio_nor"] forState:UIControlStateNormal];
                [goodsView addSubview:ticketBtn];
                ticketBtn.tag = 0;
                self.ticketBtn = ticketBtn;
                [ticketBtn addTarget:self action:@selector(ticketBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
            //右侧文字
            {
                UILabel * label = [UILabel new];
                label.frame = CGRectMake(46, top, 80, 15);
                label.font = [UIFont systemFontOfSize:15];
                label.text = @"需要发票";
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                [goodsView addSubview:label];
            }
            //发票抬头
            {
                top += 15+14;
                //背景view
                UIView * ticketView = [UIView new];
                ticketView.hidden = true;
                self.ticketView = ticketView;
                {
                    ticketView.frame = CGRectMake(14, top, WIDTH-28, 39);
                    ticketView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
                    [goodsView addSubview:ticketView];
                }
                //文本框
                {
                    UITextField * tf = [UITextField new];
                    tf.frame = ticketView.bounds;
                    tf.placeholder = @"  发票抬头";
                    tf.font = [UIFont systemFontOfSize:15];
                    [ticketView addSubview:tf];
                    self.ticketTF = tf;
                }
                top += 50;
            }
        }
        
    }
    //价格信息
    {
        UIView * priceView = [UIView new];
        self.price_view = priceView;
        priceView.frame = CGRectMake(0, goodsView.frame.origin.y + goodsView.frame.size.height + 6, WIDTH, 99);
        priceView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:priceView];
        //3行文字，间隔13.5
        {
            bool integral = [self.order[@"integral"] boolValue];
            NSArray * showPriceItems = nil;
            //商品个数
            NSInteger count = 0;
            for (NSDictionary * dic in self.goodsList) {
                NSInteger quantity = [dic[@"quantity"] longValue];
                count += quantity;
            }
            NSString * countString = [NSString stringWithFormat:@"共%ld件商品:",count];
            //商品总钱
            float orderPrice = [self.order[@"orderPrice"] floatValue];
            NSString * priceString = [NSString stringWithFormat:@"¥%.2f",orderPrice];
            if ((int)orderPrice == orderPrice) {
                priceString = [NSString stringWithFormat:@"¥%d",(int)orderPrice];
            }
            //运费
            float expressPrice = [self.order[@"expressPrice"] floatValue];
            NSString * expressPriceString = [NSString stringWithFormat:@"¥%.2f",expressPrice];
            if ((int)expressPrice == expressPrice) {
                expressPriceString = [NSString stringWithFormat:@"¥%d",(int)expressPrice];
            }
            //合计
            float totalPrice = [self.order[@"totalPrice"] floatValue];
            NSString * totalPriceString = [NSString stringWithFormat:@"¥%.2f",totalPrice];
            if ((int)totalPrice == totalPrice) {
                totalPriceString = [NSString stringWithFormat:@"¥%d",(int)totalPrice];
            }
            if (integral) {//积分商品
                //积分
                NSInteger totalPoint = [self.order[@"totalPoint"] longValue];
                NSString * totalPointString = [NSString stringWithFormat:@"%ld",totalPoint];
                showPriceItems = @[
                                   @[countString,priceString],
                                   @[@"运费:",expressPriceString],
                                   @[@"使用积分:",totalPointString],
                                   @[@"合计:",totalPriceString]
                                   ];
            }else{//不是积分
                showPriceItems = @[
                                   @[countString,priceString],
                                   @[@"运费:",expressPriceString],
                                   @[@"合计:",totalPriceString]
                                   ];
            }
            /*
             总高度99，字体都是15
             */
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15];
            label.text = @"价格10000";
            CGSize size = [MYTOOL getSizeWithLabel:label];
            //文字高度
            float label_height = size.height;
            //每行文字间隔
            float space = (99-label_height * showPriceItems.count)/(showPriceItems.count +1);
            for(int i = 0; i < showPriceItems.count ; i ++){
                float top = space + (space + label_height)*i;
                NSString * left_string = showPriceItems[i][0];
                NSString * right_string = showPriceItems[i][1];
                //左侧
                {
                    UILabel * label = [UILabel new];
                    label.text = left_string;
                    if (i == 0) {//总价
                        self.quantityLabel = label;
                    }
                    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                    label.frame = CGRectMake(14, top, WIDTH/2, 15);
                    label.font = [UIFont systemFontOfSize:15];
                    [priceView addSubview:label];
                }
                //右侧
                {
                    UILabel * label = [UILabel new];
                    label.text = right_string;
                    label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
                    label.font = [UIFont systemFontOfSize:16];
                    label.textAlignment = NSTextAlignmentRight;
                    label.frame = CGRectMake(WIDTH/2, top, WIDTH/2-15, 16);
                    [priceView addSubview:label];
                    if(i == 0){//总价
                        self.totalPriceLabel = label;
                    }else if(i == 1){//运费
                        self.expressPriceLabel = label;
                    }else if(i == showPriceItems.count - 1){//最下面合计
                        self.totalPriceLabel = label;
                    }else{//积分
                        self.pointLabel = label;
                    }
                    
                }
            }
        }
    }
    //订单view
    {
        UIView * orderView = [UIView new];
        self.btn_view = orderView;
        orderView.frame = CGRectMake(0, goodsView.frame.origin.y + goodsView.frame.size.height + 106, WIDTH, 50);
        orderView.backgroundColor = [UIColor whiteColor];
        [scrollView addSubview:orderView];
        //总钱数
        UILabel * allPriceLabel = [UILabel new];
        self.totalPriceLabel2 = allPriceLabel;
        {
            float totalPrice = [self.order[@"totalPrice"] floatValue];
            allPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",totalPrice];
            allPriceLabel.font = [UIFont systemFontOfSize:18];
            CGSize size = [MYTOOL getSizeWithString:allPriceLabel.text andFont:allPriceLabel.font];
            allPriceLabel.frame = CGRectMake(WIDTH-14-115-30-size.width, 16, size.width, 18);
            allPriceLabel.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
            [orderView addSubview:allPriceLabel];
        }
        //合计
        {
            UILabel * label = [UILabel new];
            label.text = @"合计:";
            self.priceStateLabel = label;
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.frame = CGRectMake(allPriceLabel.frame.origin.x-45, 18.5, 50, 15);
            label.font = [UIFont systemFontOfSize:15];
            [orderView addSubview:label];
        }
        //按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = CGRectMake(WIDTH-115-14, 5.5, 115, 38);
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_green"] forState:UIControlStateNormal];
            [orderView addSubview:btn];
            [btn setTitle:@"提交订单" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(submitOrderCallback) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [self reloadPrice];
}



#pragma mrak - 自定义事件
//下个界面更改快递方式-回调
-(void)changeExpressWithDictionary:(NSDictionary *)expressDict{
    [SVProgressHUD showWithStatus:@"更新中…" maskType:SVProgressHUDMaskTypeClear];
    NSString * interfaceName = @"/shop/order/confirmOrder.intf";
    NSMutableDictionary * sendDic = [self getSendDictionaryToConfirmOrder];
    [sendDic setValue:expressDict[@"expressId"] forKey:@"expressId"];
//    NSLog(@"send:%@",sendDic);
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
                NSLog(@"back:%@",back_dic);
        self.goodsList = back_dic[@"goodsList"];
        self.order = back_dic[@"order"];
        self.receiptAddress = back_dic[@"receiptAddress"];
        [self.receiverView updateReceiverInfo:self.receiptAddress];
        self.expressLabel.text = self.order[@"expressName"];
        [self reloadPrice];
    }];
    
}
//选择快递方式
-(void)selectAddressOfTicket{
    [SVProgressHUD showWithStatus:@"获取快递…" maskType:SVProgressHUDMaskTypeClear];
    NSString * interfaceName = @"/shop/order/dlyInfo.intf";
    NSObject * addressId = self.receiptAddress[@"addressId"];
    if (addressId == nil) {
        [SVProgressHUD showErrorWithStatus:@"请先选择收货地址" duration:2];
        return;
    }
    NSDictionary * sendDic = @{
                               @"addressId":addressId
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * expressArray = back_dic[@"expressList"];
        SelectExpressVC * select = [SelectExpressVC new];
        select.title = @"选择快递方式";
        select.delegate = self;
        select.expressArray = expressArray;
        [self.navigationController pushViewController:select animated:true];
    }];
}
//提交订单
-(void)submitOrderCallback{
    //如果没有地址
    if (self.receiptAddress == nil || self.receiptAddress.allKeys.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择收货地址" duration:2];
        return;
    }
    NSString * interface = @"/shop/order/createOrder.intf";
    NSMutableDictionary * sendDiction = [self getSendDictionaryToConfirmOrder];
    [sendDiction setValue:self.order[@"expressId"] forKey:@"shippingId"];//快递编号
    //备注
    NSString * remark = self.messageTV.text;
    if (remark.length > 0) {
        [sendDiction setValue:remark forKey:@"remark"];
    }
    [sendDiction setValue:@"0" forKey:@"paymentId"];
    [sendDiction setValue:MEMBERID forKey:@"memberId"];//用户id
    
    if (self.integral) {
        [sendDiction setValue:@"true" forKey:@"exchange"];
    }else{
        [sendDiction setValue:@"false" forKey:@"exchange"];
    }
    
    //购物车号
    NSString * cartIds = self.order[@"cartIds"];
    if (cartIds && cartIds.length > 0) {//购物车
        [sendDiction setValue:cartIds forKey:@"cartIds"];
    }else{//商品
        NSObject * quantity = self.order[@"quantity"];
        [sendDiction setValue:quantity forKey:@"quantity"];//quantity	购买数量	数字	否
        NSObject * productId = self.goodsInfoDictionary[@"productId"];
        [sendDiction setValue:productId forKey:@"productId"];//productId	产品id	数字	否
    }
    //是否匿名-anonymous
    if(self.noTicketBtn.tag == 1){
        [sendDiction setValue:@"1" forKey:@"anonymous"];
    }else{
        [sendDiction setValue:@"0" forKey:@"anonymous"];
    }
    //发票信息
    if (self.ticketBtn.tag == 1) {//需要发票
        //发票抬头-receiptName
        NSString * receiptName = self.ticketTF.text;
        if (receiptName.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"发票抬头为空" duration:2];
            return;
        }else{
            [sendDiction setValue:receiptName forKey:@"receiptName"];
        }
    }
    //地址id-addressId
    NSObject * addressId = self.receiptAddress[@"addressId"];
    if (addressId) {
        [sendDiction setValue:addressId forKey:@"addressId"];
    }
    //优惠券id
    if ([self.order[@"couponId"] longValue]) {
        [sendDiction setValue:self.order[@"couponId"] forKey:@"bonusId"];
    }
//    NSLog(@"send:%@",sendDiction);
    [SVProgressHUD showWithStatus:@"创建订单中…" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDiction andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"创建订单:%@",back_dic);
        
        [SVProgressHUD showWithStatus:@"加载订单…" maskType:SVProgressHUDMaskTypeClear];
        NSString * interface = @"/shop/order/getOrderInfo.intf";
        NSDictionary * send = @{
                                @"orderId":back_dic[@"orderId"]
                                };
        [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"订单:%@",back_dic);
            [SVProgressHUD showSuccessWithStatus:@"订单创建成功" duration:1];
            SelectPayTypeVC * payVC = [SelectPayTypeVC new];
            payVC.isSuccess = true;
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"order"]];
//            [dict setValue:self.goodsInfoDictionary[@"productId"] forKey:@"productId"];
            payVC.orderDictionary = dict;
            payVC.delegate = self;
            self.selectPayVC = payVC;
            [payVC show];
        }];
    }];
    
    
    /*
     如果从购物车购买传递cartIds，以逗号拼接即可；如果直接购买，传递产品id和购买的数量
     anonymous：0 否  1 是
     receiptName：发票抬头传值就是需要发票。如果不传值，就是不需要发票。
     98.99.99.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     shippingId	配送方式Id	数字	是
     addressId	会员地址id	数字	是
     remark	留言	字符串	否
     paymentId	支付方式Id	数字	是
     memberId	用户Id	数字	是
     bonusId	优惠券Id	数字	否
     cartIds	购物车Id	字符串	否
     productId	商品Id	数字	否
     quantity	购买数量	数字	否
     anonymous	是否匿名	数字	是
     receiptName	发票抬头	字符串	否
     */
}
//不要发票回调-radio_nor-radio_sel
-(void)noTicketBtnCallback:(UIButton *)btn{
    NSInteger tag = btn.tag;
    if (tag == 0) {//选中
        [btn setImage:[UIImage imageNamed:@"radio_sel"] forState:UIControlStateNormal];
        btn.tag = 1;
    }else{
        [btn setImage:[UIImage imageNamed:@"radio_nor"] forState:UIControlStateNormal];
        btn.tag = 0;
    }
    
}
//需要发票回调
-(void)ticketBtnCallback:(UIButton *)btn{
    NSInteger tag = btn.tag;
    if (tag == 0) {//选中
        [btn setImage:[UIImage imageNamed:@"radio_sel"] forState:UIControlStateNormal];
        btn.tag = 1;
        self.ticketView.hidden = false;
        
        //下面界面向上动
        [UIView animateWithDuration:0.3 animations:^{
            UIView * goodsView = self.middle_goods_view;
            goodsView.frame = CGRectMake(0, goodsView.frame.origin.y, WIDTH, goodsView.frame.size.height+58);
            self.price_view.frame = CGRectMake(0, goodsView.frame.origin.y + goodsView.frame.size.height + 6, WIDTH, 99);
            self.btn_view.frame = CGRectMake(0, goodsView.frame.origin.y + goodsView.frame.size.height + 106, WIDTH, 50);
            self.scrollView.contentSize = CGSizeMake(0, self.btn_view.frame.origin.y + self.btn_view.frame.size.height);
        }];
    }else{
        [btn setImage:[UIImage imageNamed:@"radio_nor"] forState:UIControlStateNormal];
        btn.tag = 0;
        self.ticketView.hidden = true;
        //下面界面向下动
        [UIView animateWithDuration:0.3 animations:^{
            UIView * goodsView = self.middle_goods_view;
            goodsView.frame = CGRectMake(0, goodsView.frame.origin.y, WIDTH, goodsView.frame.size.height-58);
            self.price_view.frame = CGRectMake(0, goodsView.frame.origin.y + goodsView.frame.size.height + 6, WIDTH, 99);
            self.btn_view.frame = CGRectMake(0, goodsView.frame.origin.y + goodsView.frame.size.height + 106, WIDTH, 50);
            self.scrollView.contentSize = CGSizeMake(0, self.btn_view.frame.origin.y + self.btn_view.frame.size.height);
        }];
    }
    
}
//选择优惠券
-(void)selectDiscountCouponCallback{
    NSString * interface = @"/shop/goods/getUseBonus.intf";
    NSDictionary * send = @{
                            @"memberId":MEMBERID,
                            @"orderPrice":self.order[@"orderPrice"]
                            };
    [MYTOOL netWorkingWithTitle:@"获取可用优惠券"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * bonusList = back_dic[@"bonusList"];
        SelectBonusVC * bonusVC = [SelectBonusVC new];
        bonusVC.bonusList = bonusList;
        bonusVC.title = @"选择优惠券";
        bonusVC.delegate = self;
        [self.navigationController pushViewController:bonusVC animated:true];
    }];
    /*
     8.10获取优惠券
     Ø接口地址：/shop/goods/getBonus.intf
     Ø接口描述：获取优惠券接口
     Ø特殊说明：bonusStatus：1：已领取 2：未领取 3：已过期 4：已使用
     67.68.69.69.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     memberId	会员Id	数字	是
     Ø输出参数：
     参数名称		参数含义	参数类型
     code		响应编码	数字
     msg		响应描述	字符串
     bonusList
     bonusName	优惠券名称	字符串
     bonusId	优惠券Id	数字
     bonusMoney	优惠券金额	double
     userEndDate	有效期	字符串
     minGoodsAmount	最小订单金额	double
     bonusStatus	优惠券状态	数字
     */
}
//选择收货人信息
-(void)selectReceiverInfoCallback{
    AddressManagerVC * addressVC = [AddressManagerVC new];
    addressVC.title = @"地址管理";
    addressVC.delegate = self;
    [self.navigationController pushViewController:addressVC animated:true];
    
}
//选择优惠券回调
-(void)changeBonusWithDictionary:(NSDictionary *)bonusDict{
//    NSLog(@"bonusDict:%@",bonusDict);
    [SVProgressHUD showWithStatus:@"更新中…" maskType:SVProgressHUDMaskTypeClear];
    NSString * interfaceName = @"/shop/order/confirmOrder.intf";
    NSMutableDictionary * sendDic = [self getSendDictionaryToConfirmOrder];
    if(bonusDict[@"bonusId"]){
        [sendDic setValue:bonusDict[@"bonusId"] forKey:@"bonusId"];
    }
//        NSLog(@"send:%@",sendDic);
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//                NSLog(@"back:%@",back_dic);
        self.goodsList = back_dic[@"goodsList"];
        self.order = back_dic[@"order"];
        self.receiptAddress = back_dic[@"receiptAddress"];
        [self.receiverView updateReceiverInfo:self.receiptAddress];
        [self reloadPrice];
    }];
}
/**更改地址*/
-(void)changeAddress:(NSDictionary *)addressDic{
//    NSLog(@"array:%@",self.goodsArray);
    [SVProgressHUD showWithStatus:@"更新中…" maskType:SVProgressHUDMaskTypeClear];
    NSString * interfaceName = @"/shop/order/confirmOrder.intf";
    NSMutableDictionary * sendDic = [self getSendDictionaryToConfirmOrder];
//    NSLog(@"send:%@",sendDic);
    [sendDic setValue:addressDic[@"addressId"] forKey:@"addressId"];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        self.goodsList = back_dic[@"goodsList"];
        self.order = back_dic[@"order"];
        self.receiptAddress = back_dic[@"receiptAddress"];
        [self.receiverView updateReceiverInfo:self.receiptAddress];
        [self reloadPrice];
    }];
}
//重新加载下侧价格
-(void)reloadPrice{
    //优惠券标题更新
    self.discountCouponLabel.text = self.order[@"bonusTitle"];
    //运费
    float expressPrice = [self.order[@"expressPrice"] floatValue];
    self.expressPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",expressPrice];
    if ((int)expressPrice == expressPrice) {
        self.expressPriceLabel.text = [NSString stringWithFormat:@"¥%d",(int)expressPrice];
    }
    //订单价格
    float orderPrice = [self.order[@"orderPrice"] floatValue];
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",orderPrice];
    if ((int)orderPrice == orderPrice) {
        self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥%d",(int)orderPrice];
    }
    //总价
    float totalPrice = [self.order[@"totalPrice"] floatValue];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",totalPrice];
    if ((int)totalPrice == totalPrice) {
        self.totalPriceLabel.text = [NSString stringWithFormat:@"¥%d",(int)totalPrice];
    }
    //总价2
    self.totalPriceLabel2.text = [NSString stringWithFormat:@"¥%.2f",totalPrice];
    if ((int)totalPrice == totalPrice) {
        self.totalPriceLabel2.text = [NSString stringWithFormat:@"¥%d",(int)totalPrice];
    }
    //调整位置
    {
        //价格
        CGSize size = [MYTOOL getSizeWithString:self.totalPriceLabel2.text andFont:self.totalPriceLabel2.font];
        self.totalPriceLabel2.frame = CGRectMake(WIDTH-14-115-30-size.width, 16, size.width, 18);
        //总价提示
        self.priceStateLabel.frame = CGRectMake(self.totalPriceLabel2.frame.origin.x-45, 18.5, 50, 15);
    }
    if ([self.order[@"integral"] boolValue] && self.pointLabel) {
        //积分
        NSInteger totalPoint = [self.order[@"totalPoint"] longValue];
        NSString * totalPointString = [NSString stringWithFormat:@"%ld",totalPoint];
        self.pointLabel.text = totalPointString;
    }
}
//点击事件
-(void)handleTapGesture:( UITapGestureRecognizer *)tapRecognizer
{
    [MYTOOL hideKeyboard];
}
//拼接确认订单发送参数
-(NSMutableDictionary *)getSendDictionaryToConfirmOrder{
    NSMutableDictionary * sendDic = [NSMutableDictionary new];
    [sendDic setValue:MEMBERID forKey:@"memberId"];//memberId	会员id	数字	是
    NSObject * addressId = self.receiptAddress[@"addressId"];
    if (addressId) {
        [sendDic setValue:addressId forKey:@"addressId"];//addressId	地址Id	数字	否
    }
    //判断是从购物车进来，还是从商品直接过来
    NSString * cartIds = self.order[@"cartIds"];
    if (cartIds && cartIds.length) {//购物车
        [sendDic setValue:cartIds forKey:@"cartIds"];//cartIds	购物车Ids	字符串	否
    }else{//商品
        NSObject * quantity = self.order[@"quantity"];
        [sendDic setValue:quantity forKey:@"quantity"];//quantity	购买数量	数字	否
        NSObject * productId = self.goodsInfoDictionary[@"productId"];
        [sendDic setValue:productId forKey:@"productId"];//productId	产品id	数字	否
    }
    [sendDic setValue:@(self.integral) forKey:@"integral"];//是否积分商品
    if ([self.order[@"bonusId"] longValue]) {
        [sendDic setValue:self.order[@"bonusId"] forKey:@"bonusId"];
    }
    
    
    /*
     expressId	快递Id	数字	否
     couponId	优惠券Id	数字	否
     */
//    NSLog(@"send1:%@",sendDic);
    return sendDic;
}
#pragma mark - 键盘出现及消失通知
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //键盘高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    //文本框
    id someOne = nil;
    if ([self.messageTV isFirstResponder]) {
        someOne = self.messageTV;
    }else if ([self.ticketTF isFirstResponder]){
        someOne = self.ticketTF;
    }
    if (someOne == nil) {
        return;
    }
    //someOne相对屏幕上侧位置
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[someOne convertRect: [someOne bounds] toView:window];
    //someOne底部坐标
    float tf_y = rect.origin.y + [someOne frame].size.height;
    if (height + tf_y > HEIGHT) {
        offset_y = self.scrollView.contentOffset.y;
        [self.scrollView setContentOffset:CGPointMake(0, offset_y+(height + tf_y - HEIGHT)) animated:true];
    }
    
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    if (offset_y >= 0 && offset_y < HEIGHT) {
        [self.scrollView setContentOffset:CGPointMake(0, offset_y) animated:true];
        offset_y = -1;
    }
}
- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return NO;
}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
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
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(paySuccess) name:NOTIFICATION_PAY_SUCCESS object:nil];
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(payCancel) name:NOTIFICATION_PAY_CANCEL object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_PAY_SUCCESS object:nil];
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_PAY_CANCEL object:nil];
    
}
-(void)paySuccess{
    if (self.selectPayVC) {
        [self.selectPayVC removeFromSuperViewController:nil];
    }
    [self.navigationController popToRootViewControllerAnimated:true];
}
-(void)payCancel{
    if (self.selectPayVC) {
        [self.selectPayVC removeFromSuperViewController:nil];
    }
    [self.navigationController popToRootViewControllerAnimated:true];
}
@end
