//
//  OrderInfoVC.m
//  绿茵荟
//
//  Created by Mac on 17/5/15.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "OrderInfoVC.h"
#import "SelectPayTypeVC.h"
#import "MyOrderVC.h"
#import "ShowExpress.h"
#import "ContactCustomerVC.h"
#import "GoodsInfoViewController.h"
@interface OrderInfoVC ()<UIScrollViewDelegate>
@property(nonatomic,strong)SelectPayTypeVC * selectPayVC;
@property(nonatomic,strong)UIScrollView * scrollView;//总背景
@property(nonatomic,strong)UILabel * timeLabel;//剩余时间

@end

@implementation OrderInfoVC
{
    bool isUpdateOrder;//已经刷新订单
    NSTimer * timer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
//    NSLog(@"订单详情:%@",self.orderDictionary);
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    NSInteger orderId = [self.orderDictionary[@"orderId"] longValue];
    //总背景
    UIScrollView * scrollView = [UIScrollView new];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    scrollView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    scrollView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    float top_all = 0;
    //顶部提示框
    {
        if (self.timeLeft > 0) {
            //背景view
            float left = 0;
            UIView * view = [UIView new];
            float view_height = [MYTOOL getHeightWithIphone_six:33];
            top_all += view_height + 10;
            {
                view.frame = CGRectMake(0, 0, WIDTH, view_height);
                view.backgroundColor = [UIColor whiteColor];
                [self.scrollView addSubview:view];
            }
            //图标
            {
                UIImageView * icon = [UIImageView new];
                icon.image = [UIImage imageNamed:@"icon_clock"];
                icon.frame = CGRectMake(14, view_height/2-7, 14, 14);
                [view addSubview:icon];
            }
            //时间
            {
                UILabel * label = [UILabel new];
                self.timeLabel = label;
                label.text = [NSString stringWithFormat:@"%d:%02d",self.timeLeft/60,self.timeLeft%60];
                label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
                [view addSubview:label];
                label.font = [UIFont systemFontOfSize:14];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(35, view_height/2-size.height/2, size.width + 14, size.height);
                left = 35 + label.frame.size.width + 20;
            }
            //开启定时器
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerWork) userInfo:nil repeats:true];
            //提示文字
            {
                UILabel * label = [UILabel new];
                label.text = @"订单超时将自动取消，请尽快结算";
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = [MYTOOL RGBWithRed:92 green:92 blue:92 alpha:1];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(left, view_height/2-size.height/2, size.width, size.height);
                [view addSubview:label];
            }
        }
        
    }
    //接收地址
    {
        //背景view的总高度
        float view_height = [MYTOOL getHeightWithIphone_six:91];
        //背景view
        UIView * view = [UIView new];
        {
            view.frame = CGRectMake(0, top_all, WIDTH, view_height);
            view.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:view];
        }
        //接收地址信息
        NSDictionary * receiptAddress = self.orderDictionary[@"receiptAddress"];
//        NSLog(@"地址:%@",receiptAddress);
        {
            //文字字体
            float fontSize = [MYTOOL getHeightWithIphone_six:15];
            UIFont * font = [UIFont systemFontOfSize:fontSize];
            //收货人姓名
            {
                UILabel * label = [UILabel new];
                label.font = font;
                NSString * name = receiptAddress[@"name"];
                if (!name) {
                    name = @"匿名用户";
                }
                label.text = [NSString stringWithFormat:@"收货人:%@",name];
                label.frame = CGRectMake(14, view_height/4.0-fontSize/2.0, WIDTH/3*2, fontSize);
                label.textColor = MYCOLOR_46_42_42;
                [view addSubview:label];
            }
            //收货人电话
            {
                UILabel * label = [UILabel new];
                label.font = font;
                NSString * mobile = receiptAddress[@"mobile"];
                if (!mobile) {
                    mobile = @"****";
                }
                label.text = mobile;
                label.textAlignment = NSTextAlignmentRight;
                label.frame = CGRectMake(WIDTH/2, view_height/4.0-fontSize/2.0, WIDTH/2-14, fontSize);
                label.textColor = MYCOLOR_46_42_42;
                [view addSubview:label];
            }
            //地址
            {
                float left = 14;
                //提示
                {
                    UILabel * label = [UILabel new];
                    label.font = font;
                    label.text = @"收货地址：";
                    label.textColor = MYCOLOR_46_42_42;
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(left, view_height/2-fontSize/2, size.width, size.height);
                    [view addSubview:label];
                    left += size.width + 5;
                }
                UILabel * label = [UILabel new];
                label.font = font;
                label.textColor = MYCOLOR_46_42_42;
                NSString * address = receiptAddress[@"address"];
                if (!address) {
                    address = @"***********";
                }
                NSString * area = receiptAddress[@"area"];
                label.text = [NSString stringWithFormat:@"%@%@",area,address];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                float name_width = WIDTH - 14 - left;
                if (size.width > name_width) {
                    while (size.width >= name_width * 2 - font.pointSize) {
                        font = [UIFont systemFontOfSize:font.pointSize-0.1];
                        label.font = font;
                        size = [MYTOOL getSizeWithLabel:label];
                    }
                    label.frame = CGRectMake(left, view_height/2-fontSize/2, name_width, size.height*2);
                    label.numberOfLines = 0;
                }else{
                    label.frame = CGRectMake(left, view_height/2-fontSize/2, name_width, size.height);
                }
                
                [view addSubview:label];
            }
        }
        top_all += view_height + 10;
        /*
         receiptAddress =     {
         address = "\U65b0\U79d1\U56db\U8def7\U53f7\U7231\U4fe1\U8bfa\U5927\U53a61807";
         area = "\U6c5f\U82cf\U7701-\U5357\U4eac\U5e02-\U6d66\U53e3\U533a";
         mobile = 18724199038;
         name = "\U5feb\U4e50\U795e";
         };
         */
    }
    //订单信息
    {
        //背景view的总高度
        float view_height = [MYTOOL getHeightWithIphone_six:323];
        //背景view
        UIView * view = [UIView new];
        {
            view.frame = CGRectMake(0, top_all, WIDTH, view_height);
            view.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:view];
        }
        float view_top = 0;
        //订单号
        {
            UIFont * font = [UIFont systemFontOfSize:14];
//            NSInteger orderId = [self.orderDictionary[@"orderId"] longValue];
            NSString * orderNo = self.orderDictionary[@"orderNo"];
            //label
            {
                UILabel * label = [UILabel new];
                label.frame = CGRectMake(14, 14, WIDTH/3.0*2, font.pointSize);
                label.text = [NSString stringWithFormat:@"订单号:%@",orderNo];
                label.font = font;
                label.textColor = MYCOLOR_46_42_42;
                [view addSubview:label];
            }
            //按钮-btn_copy
            {
                UIButton * btn = [UIButton new];
                [btn addTarget:self action:@selector(copyOrderIdCallback:) forControlEvents:UIControlEventTouchUpInside];
                btn.frame = CGRectMake(WIDTH-14-65, 14+font.pointSize/2-25/2.0, 65, 25);
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_copy"] forState:UIControlStateNormal];
                [btn setTitle:@"复制单号" forState:UIControlStateNormal];
                btn.titleLabel.font = font;
                [btn setTitleColor:MYCOLOR_46_42_42 forState:UIControlStateNormal];
                btn.tag = orderId;
                [view addSubview:btn];
            }
        }
        //商品信息
        {
            view_top = 45;
            NSArray * goodsList = self.orderDictionary[@"goodsList"];
//            NSLog(@"商品数量:%ld",goodsList.count);
            float height_goodsView = [MYTOOL getHeightWithIphone_six:111];
            for (int i = 0; i < goodsList.count; i ++) {
                NSDictionary * goodsDictionary = goodsList[i];
                //背景view
                UIView * bgView = [UIView new];
                bgView.backgroundColor = [MYTOOL RGBWithRed:249 green:251 blue:247 alpha:1];
                bgView.frame = CGRectMake(14, view_top, WIDTH-28, height_goodsView);
                [view addSubview:bgView];
                //图片
                float width_img = height_goodsView - 16;
                {
                    UIImageView * imgV = [UIImageView new];
                    imgV.frame = CGRectMake(0, 8, width_img, width_img);
                    [imgV sd_setImageWithURL:[NSURL URLWithString:goodsDictionary[@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
                    [bgView addSubview:imgV];
                    imgV.tag = [goodsDictionary[@"goodsId"] longValue];
                    [imgV setUserInteractionEnabled:YES];
                    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickImgOfGoods:)];
                    tapGesture.numberOfTapsRequired=1;
                    [imgV addGestureRecognizer:tapGesture];
                }
                //商品名称
                float right_top = 0;
                float name_width = WIDTH - 28-8-width_img;
                {
                    UILabel * label = [UILabel new];
                    NSString * goodsName = goodsDictionary[@"goodsName"];
                    UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:16]];
                    label.text = goodsName;
                    label.font = font;
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(width_img+8, 8, name_width, size.height);
                    if (size.width > name_width) {
                        label.numberOfLines = 0;
                        if (size.width > name_width*2- font.pointSize) {
                            while (size.width >= name_width * 2 - font.pointSize) {
                                font = [UIFont systemFontOfSize:font.pointSize-0.1];
                                label.font = font;
                                size = [MYTOOL getSizeWithLabel:label];
                            }
                        }
                        label.frame = CGRectMake(width_img+8, 8, name_width, size.height * 2);
                        right_top = 8 + size.height * 2;
                    }else{
                        right_top = 8 + size.height;
                    }
                    [bgView addSubview:label];
                    label.textColor = MYCOLOR_46_42_42;
                }
                //规格名称
                {
                    right_top += 3;
                    UILabel * label = [UILabel new];
                    NSString * productName = goodsDictionary[@"productName"];
                    UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:13]];
                    label.text = [NSString stringWithFormat:@"规格:%@",productName];
                    label.font = font;
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(width_img+8, right_top, name_width, size.height);
                    if (size.width > name_width) {
                        label.numberOfLines = 0;
                        if (size.width > name_width*2 - font.pointSize) {
                            while (size.width >= name_width * 2 - font.pointSize) {
                                font = [UIFont systemFontOfSize:font.pointSize-0.1];
                                label.font = font;
                                size = [MYTOOL getSizeWithLabel:label];
                            }
                        }
                        label.frame = CGRectMake(width_img+8, right_top, name_width, size.height * 2);
                        right_top += 3 + size.height * 2;
                    }else{
                        right_top += 3 + size.height;
                    }
                    [bgView addSubview:label];
                    label.textColor = MYCOLOR_181_181_181;
                }
                //价格
                {
                    UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:16]];
                    float price = [goodsDictionary[@"price"] floatValue];
                    NSString * price_string = [NSString stringWithFormat:@"¥%.2f",price];
                    if ((int)price == price) {
                        price_string = [NSString stringWithFormat:@"¥%d",(int)price];
                    }else if((int)(10 * price) == price*10) {
                        price_string = [NSString stringWithFormat:@"¥%.1f",price];
                    }
                    if ([goodsDictionary[@"point"] floatValue] > 0) {
                        price_string = [NSString stringWithFormat:@"%@积分 + %@",goodsDictionary[@"point"],price_string];
                    }
                    UILabel * label = [UILabel new];
                    label.font = font;
                    label.text = price_string;
                    label.textColor = MYCOLOR_46_42_42;
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(width_img+8, right_top, size.width, size.height);
                    [bgView addSubview:label];
                    float price_top = height_goodsView - 8 - size.height;
                    if (price_top > right_top) {
                        right_top = price_top;
                        label.frame = CGRectMake(width_img+8, price_top, size.width, size.height);
                    }
                }
                //数量
                {
                    UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:16]];
                    int quantity = [goodsDictionary[@"quantity"] intValue];
                    NSString * quantity_string = [NSString stringWithFormat:@"X%d",quantity];
                    UILabel * label = [UILabel new];
                    label.font = font;
                    label.text = quantity_string;
                    label.textColor = MYCOLOR_181_181_181;
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(bgView.frame.size.width-size.width, right_top, size.width, size.height);
                    [bgView addSubview:label];
                }
                /*
                 goodsId = 116;
                 marketPrice = 160;
                 */
                view_top = (8+height_goodsView)*(i+1) + 45;
            }
        }
        //优惠券
        {
            CGSize size;
            //左侧提示
            {
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:18]];
                label.textColor = MYCOLOR_46_42_42;
                label.text = @"优惠券";
                view_top += 8;
                size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(14, view_top, size.width, size.height);
                [view addSubview:label];
            }
            //右侧显示
            {
                NSString * text = self.orderDictionary[@"bonusTitle"];
                UILabel * label = [UILabel new];
                label.text = text;
                label.font = [UIFont systemFontOfSize:15];
                label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                label.frame = CGRectMake(WIDTH/2-20, view_top + size.height/2 - 8, WIDTH/2, 14);
                [view addSubview:label];
                label.textAlignment = NSTextAlignmentRight;
            }
            
            view_top += size.height;
        }
        //分割线
        {
            UIView * spaceView = [UIView new];
            view_top += 16;
            spaceView.frame = CGRectMake(14, view_top, WIDTH-28, 1);
            spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
            [view addSubview:spaceView];
            view_top += 1;
        }
        //留言
        {
            float label_middle_top = 0;
            float left = 0;
            //左侧提示
            {
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:18]];
                label.textColor = MYCOLOR_46_42_42;
                label.text = @"留言";
                view_top += 18;
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(14, view_top, size.width, size.height);
                label_middle_top = view_top + size.height/2;
                left = 14 + size.width + 10;
                [view addSubview:label];
                view_top += size.height;
            }
            //右侧显示
            {
                NSString * remarks = self.orderDictionary[@"remarks"];
                UILabel * label = [UILabel new];
                label.text = remarks;
                label.font = [UIFont systemFontOfSize:12];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                float width = WIDTH - 14 - left;
                label.frame = CGRectMake(left, label_middle_top - size.height/2, width, size.height);
                if (size.width > width) {
                    label.numberOfLines = 0;
                    label.frame = CGRectMake(left, label_middle_top - size.height/2, width, size.height*2);
                }else{
                    label.textAlignment = NSTextAlignmentRight;
                }
                label.textColor = MYCOLOR_181_181_181;
                [view addSubview:label];
            }
        }
        //分割线
        {
            UIView * spaceView = [UIView new];
            view_top += 18;
            spaceView.frame = CGRectMake(14, view_top, WIDTH-28, 1);
            spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
            [view addSubview:spaceView];
            view_top += 1;
        }
        //是否匿名
        {
            float label_height = 0;
            //左侧提示
            {
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:18]];
                label.textColor = MYCOLOR_46_42_42;
                label.text = @"是否匿名";
                view_top += 18;
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(14, view_top, size.width, size.height);
                [view addSubview:label];
                view_top += size.height;
                label_height = size.height;
            }
            //右侧显示
            {
                UILabel * label = [UILabel new];
                label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
                label.textColor = MYCOLOR_181_181_181;
                bool flag = [self.orderDictionary[@"anonymous"] boolValue];
                NSString * text = flag ? @"是" : @"否";
                label.text = text;
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(WIDTH-14-size.width, view_top - label_height/2-size.height/2, size.width, size.height);
                [view addSubview:label];
            }
        }
        view_top += 20;
        
        
        
        view.frame = CGRectMake(0, top_all, WIDTH, view_top);
        top_all += view_top + 10;
    }
    //下侧合计及客服
    {
        //背景view
        UIView * bgView = [UIView new];
        float bg_height = [MYTOOL getHeightWithIphone_six:185];//背景view总高度
        float view_top = [MYTOOL getHeightWithIphone_six:15];//各个控件的y坐标
        float view_height = 0;//左侧label高度
        {
            bgView.frame = CGRectMake(0, top_all, WIDTH, bg_height);
            bgView.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:bgView];
        }
        
        //价格信息
        {
            //3行文字，间隔13.5
            {
                bool integral = [self.orderDictionary[@"totalPoint"] intValue] > 0;
                NSArray * showPriceItems = nil;
                //商品个数
                NSInteger count = 0;
                for (NSDictionary * dic in self.orderDictionary[@"goodsList"]) {
                    NSInteger quantity = [dic[@"quantity"] longValue];
                    count += quantity;
                }
                NSString * countString = [NSString stringWithFormat:@"共%ld件商品:",count];
                //商品总钱
                float orderPrice = [self.orderDictionary[@"orderPrice"] floatValue];
                NSString * priceString = [NSString stringWithFormat:@"¥%.2f",orderPrice];
                if ((int)orderPrice == orderPrice) {
                    priceString = [NSString stringWithFormat:@"¥%d",(int)orderPrice];
                }
                //运费
                float expressPrice = [self.orderDictionary[@"expressPrice"] floatValue];
                NSString * expressPriceString = [NSString stringWithFormat:@"¥%.2f",expressPrice];
                if ((int)expressPrice == expressPrice) {
                    expressPriceString = [NSString stringWithFormat:@"¥%d",(int)expressPrice];
                }
                //合计
                float totalPrice = [self.orderDictionary[@"totalPrice"] floatValue];
                NSString * totalPriceString = [NSString stringWithFormat:@"¥%.2f",totalPrice];
                if ((int)totalPrice == totalPrice) {
                    totalPriceString = [NSString stringWithFormat:@"¥%d",(int)totalPrice];
                }
                if (integral) {//积分商品
                    //积分
                    NSInteger totalPoint = [self.orderDictionary[@"totalPoint"] longValue];
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
                    float top = space + (space + label_height)*i + 5;
                    NSString * left_string = showPriceItems[i][0];
                    NSString * right_string = showPriceItems[i][1];
                    //左侧
                    {
                        UILabel * label = [UILabel new];
                        label.text = left_string;
                        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                        label.frame = CGRectMake(14, top, WIDTH/2, 15);
                        label.font = [UIFont systemFontOfSize:15];
                        [bgView addSubview:label];
                    }
                    //右侧
                    {
                        UILabel * label = [UILabel new];
                        label.text = right_string;
                        label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
                        label.font = [UIFont systemFontOfSize:16];
                        label.textAlignment = NSTextAlignmentRight;
                        label.frame = CGRectMake(WIDTH/2, top, WIDTH/2-15, 16);
                        [bgView addSubview:label];
                        
                    }
                }
            }
        }
//        //共几件商品
//        {
//            int quantity = [self.orderDictionary[@"quantity"] intValue];
//            NSString * text = [NSString stringWithFormat:@"共%d件商品:",quantity];
//            UILabel * label = [UILabel new];
//            label.textColor = MYCOLOR_46_42_42;
//            label.text = text;
//            UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
//            label.font = font;
//            CGSize size = [MYTOOL getSizeWithLabel:label];
//            label.frame = CGRectMake(14, view_top, size.width, size.height);
//            [bgView addSubview:label];
//            view_height = size.height;
//        }
//        //商品价格
//        {
//            float orderPrice = [self.orderDictionary[@"orderPrice"] floatValue];
//            NSString * text = [NSString stringWithFormat:@"¥%.2f",orderPrice];
//            if ((int)orderPrice == orderPrice) {
//                text = [NSString stringWithFormat:@"¥%d",(int)orderPrice];
//            }else if ((int)(orderPrice * 10) == orderPrice * 10) {
//                text = [NSString stringWithFormat:@"¥%.1f",orderPrice];
//            }
//            UILabel * label = [UILabel new];
//            label.textColor = MYCOLOR_229_64_73;
//            label.text = text;
//            UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:16]];
//            label.font = font;
//            CGSize size = [MYTOOL getSizeWithLabel:label];
//            label.frame = CGRectMake(WIDTH - 14 - size.width, view_top + view_height / 2 - size.height / 2, size.width, size.height);
//            [bgView addSubview:label];
//            view_height = 0;
//            view_top += size.height + [MYTOOL getHeightWithIphone_six:14];
//        }
//        //运费提示
//        {
//            UILabel * label = [UILabel new];
//            label.textColor = MYCOLOR_46_42_42;
//            label.text = @"运费:";
//            UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
//            label.font = font;
//            CGSize size = [MYTOOL getSizeWithLabel:label];
//            label.frame = CGRectMake(14, view_top, size.width, size.height);
//            [bgView addSubview:label];
//            view_height = size.height;
//        }
//        //运费价格
//        {
//            float expressPrice = [self.orderDictionary[@"expressPrice"] floatValue];
//            NSString * text = [NSString stringWithFormat:@"¥%.2f",expressPrice];
//            if ((int)expressPrice == expressPrice) {
//                text = [NSString stringWithFormat:@"¥%d",(int)expressPrice];
//            }else if ((int)(expressPrice * 10) == expressPrice * 10) {
//                text = [NSString stringWithFormat:@"¥%.1f",expressPrice];
//            }
//            UILabel * label = [UILabel new];
//            label.textColor = MYCOLOR_229_64_73;
//            label.text = text;
//            UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:16]];
//            label.font = font;
//            CGSize size = [MYTOOL getSizeWithLabel:label];
//            label.frame = CGRectMake(WIDTH - 14 - size.width, view_top + view_height / 2 - size.height / 2, size.width, size.height);
//            [bgView addSubview:label];
//            view_height = 0;
//            view_top += size.height + [MYTOOL getHeightWithIphone_six:14];
//        }
//        //合计提示
//        {
//            UILabel * label = [UILabel new];
//            label.textColor = MYCOLOR_46_42_42;
//            label.text = @"合计:";
//            UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
//            label.font = font;
//            CGSize size = [MYTOOL getSizeWithLabel:label];
//            label.frame = CGRectMake(14, view_top, size.width, size.height);
//            [bgView addSubview:label];
//            view_height = size.height;
//        }
//        //合计价格
//        {
//            float totalPrice = [self.orderDictionary[@"totalPrice"] floatValue];
//            NSString * text = [NSString stringWithFormat:@"¥%.2f",totalPrice];
//            if ((int)totalPrice == totalPrice) {
//                text = [NSString stringWithFormat:@"¥%d",(int)totalPrice];
//            }else if ((int)(totalPrice * 10) == totalPrice * 10) {
//                text = [NSString stringWithFormat:@"¥%.1f",totalPrice];
//            }
//            UILabel * label = [UILabel new];
//            label.textColor = MYCOLOR_229_64_73;
//            label.text = text;
//            UIFont * font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:16]];
//            label.font = font;
//            CGSize size = [MYTOOL getSizeWithLabel:label];
//            label.frame = CGRectMake(WIDTH - 14 - size.width, view_top + view_height / 2 - size.height / 2, size.width, size.height);
//            [bgView addSubview:label];
//            view_height = 0;
//            view_top += size.height + [MYTOOL getHeightWithIphone_six:23];
//        }
        view_top += 99;
        //分割线
        {
            UIView * spaceView = [UIView new];
            spaceView.frame = CGRectMake(14, view_top, WIDTH-28, 1);
            spaceView.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
            [bgView addSubview:spaceView];
            view_top += 1;
        }
        //联系客服按钮
        {
            view_top += [MYTOOL getHeightWithIphone_six:14];
            //在线客服-Online-Service
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH/2 - 13 - 110, view_top, 110, 39);
                [btn setImage:[UIImage imageNamed:@"Online-Service-2"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onlineServiceCallback:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:btn];
                btn.tag = orderId;
            }
            //电话客服-Tel-Service
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH/2 + 13, view_top, 110, 39);
                [btn setImage:[UIImage imageNamed:@"Tel-Service"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(telServiceCallback:) forControlEvents:UIControlEventTouchUpInside];
                [bgView addSubview:btn];
                btn.tag = orderId;
            }
            view_top += 39 + [MYTOOL getHeightWithIphone_six:22];
        }
        bg_height = view_top;
        bgView.frame = CGRectMake(0, top_all, WIDTH, bg_height);
        
        top_all += bg_height + 10;
    }
    //底部按钮
    {
        //背景
        UIView * cell = [UIView new];
        {
            cell.frame = CGRectMake(0, top_all, WIDTH, 50);
            cell.backgroundColor = [UIColor whiteColor];
            [self.scrollView addSubview:cell];
            top_all += 50;
        }
        //下侧按钮
        {
            float top = 9.5;
            int orderStatus = [self.orderDictionary[@"orderStatus"] intValue];
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
                    btn.tag = orderId;
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
                    [btn addTarget:self action:@selector(onlineServiceCallback:) forControlEvents:UIControlEventTouchUpInside];
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
    }
    self.scrollView.contentSize = CGSizeMake(0, top_all);
}
//商品图片点击事件
-(void)clickImgOfGoods:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
    //网络获取商品详情
    NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
    NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
    if (cityId == nil || cityId.length == 0) {
        cityId = @"320300";
    }
    NSDictionary * sendDict = @{
                                @"goodsId":[NSString stringWithFormat:@"%ld",tag],
                                @"cityId":cityId
                                };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
        GoodsInfoViewController * info = [GoodsInfoViewController new];
        //                        NSLog(@"商品详情:%@",back_dic[@"goods"]);
        info.goodsInfoDictionary = back_dic[@"goods"];
        [self.navigationController pushViewController:info animated:true];
    }];
}
//定时器
-(void)timerWork{
//    NSLog(@"订单详情定时器");
    self.timeLeft --;
    if (self.timeLeft <= 0) {
        [self popUpViewController];
//        NSLog(@"订单需要取消");
    }else{
        self.timeLabel.text =[NSString stringWithFormat:@"%d:%02d",self.timeLeft/60,self.timeLeft%60];
    }
}
#pragma mark - 按钮事件
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
    NSString * expressName = self.orderDictionary[@"expressName"];
    NSString * expressNo = self.orderDictionary[@"expressNo"];
    ShowExpress * show = [ShowExpress new];
    show.expressName = expressName;
    show.logisicCode = expressNo;
    show.title = @"物流信息";
    [self.navigationController pushViewController:show animated:true];
}
//提醒发货事件
-(void)remindDispatchGoodsCallback:(UIButton *)btn{
    NSString * interface = @"/shop/order/remindOrder.intf";
    [MYTOOL netWorkingWithTitle:@"提醒中…"];
    NSDictionary * send = @{
                            @"orderId":@(btn.tag)
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"提醒成功" duration:1];
    }];
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
        [self.delegate updateViewAllState];
        [self.navigationController popViewControllerAnimated:true];
        [SVProgressHUD showSuccessWithStatus:@"订单已取消" duration:1];
    }];
}
//立即付款事件
-(void)rightNowPayCallback:(UIButton *)btn{
    NSDictionary * goodsDictionary = self.orderDictionary;
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
//        NSLog(@"删除订单-orderId:%ld",btn.tag);
        NSString * interface = @"/shop/order/delOrder.intf";
        [MYTOOL netWorkingWithTitle:@"订单删除…"];
        NSDictionary * sendDic = @{
                                   @"orderId":[NSString stringWithFormat:@"%ld",btn.tag]
                                   };
        [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
            [self.delegate updateViewAllState];
            [self.navigationController popViewControllerAnimated:true];
            [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
        }];
    } andCacel:^{
        
    }];
    
    
}
//确认收货事件
-(void)confirmReceiveCallback:(UIButton *)btn{
    [SVProgressHUD showSuccessWithStatus:@"确认收货" duration:0.5];
    //    NSLog(@"确认收货-orderId:%ld",btn.tag);
    NSString * interface = @"/shop/order/confirmReceipt.intf";
    [MYTOOL netWorkingWithTitle:@"确认收货中…"];
    NSDictionary * send = @{
                            @"orderId":@(btn.tag)
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"已经确认收货" duration:1];
        [self.delegate updateViewAllState];
    }];
    
    
    
}
//联系客服按钮事件
-(void)onlineServiceCallback:(UIButton *)btn{
    NSInteger orderId = btn.tag;
    ContactCustomerVC * customer = [ContactCustomerVC new];
    customer.title = @"联系客服";
    customer.orderId = orderId;
    [self.navigationController pushViewController:customer animated:true];
}
//电话客服按钮事件
-(void)telServiceCallback:(UIButton *)btn{
    NSString * hotLine = self.orderDictionary[@"hotLine"];
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",hotLine];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}



//复制订单
-(void)copyOrderIdCallback:(UIButton *)btn{
//    NSLog(@"订单编号:%ld",btn.tag);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [NSString stringWithFormat:@"%ld",btn.tag];
    [SVProgressHUD showSuccessWithStatus:@"复制成功" duration:0.5];
}
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    
    [timer invalidate];
    timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 支付成功
-(void)paySuccess{
    [self.selectPayVC removeFromSuperViewController:nil];
    [timer invalidate];
    timer = nil;
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate updateViewAllState];
}
#pragma mark - 界面隐藏或显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(paySuccess) name:NOTIFICATION_PAY_SUCCESS object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_PAY_SUCCESS object:nil];
}
@end
