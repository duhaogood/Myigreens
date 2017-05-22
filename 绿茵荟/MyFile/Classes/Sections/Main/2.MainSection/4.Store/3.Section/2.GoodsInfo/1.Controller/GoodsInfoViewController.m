//
//  GoodsInfoViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/19.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "GoodsInfoViewController.h"
#import "ConfirmOrderVC.h"
#import <UShareUI/UShareUI.h>
#import "SharedManagerVC.h"
@interface GoodsInfoViewController ()
@property(nonatomic,strong)UIWebView * webView;//商品h5页面
@property(nonatomic,strong)UILabel * numberOfGoodsLabel;//购物车商品数字label
@property(nonatomic,strong)UIView * goodsView;//商品详情view
@property(nonatomic,strong)UILabel * goodsCountLabel;//购买商品数量
@property(nonatomic,strong)UILabel * sellerCountLabel;//库存数量
@property(nonatomic,strong)UILabel * goodsPriceLabel;//商品价格
@property(nonatomic,strong)NSDictionary * selectProductDic;//已选商品型号
@property(nonatomic,strong)UIImageView * goodsImgV;//商品图片
@property(nonatomic,strong)UIButton * subtractBtn;//减少按钮
@end

@implementation GoodsInfoViewController
{
    float goodsViewHeight;//商品详情view高度
    NSArray * productListArray;//商品规格数组
    NSMutableArray * productBtnArray;//商品规格按钮数组
}
- (void)viewDidLoad {
    [super viewDidLoad];
    productListArray = self.goodsInfoDictionary[@"productList"];
    //加载主界面
    [self loadMainView];
    NSLog(@"商品详情:%@",self.goodsInfoDictionary);
}
//加载主界面
-(void)loadMainView{
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    
    {
        UIWebView * web = [UIWebView new];
        web.frame = CGRectMake(0, 0, WIDTH, HEIGHT-50);
        NSURL *url = [NSURL URLWithString:@"http://115.28.40.117:8180/api/shop/goods/getGoodsDetail.intf"];
        // 2. 把URL告诉给服务器,请求,从m.baidu.com请求数据
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [web loadRequest:request];
        [self.view addSubview:web];
        self.webView = web;
    }
    //返回按钮
    {
        UIButton * backBtn = [UIButton new];
        [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        backBtn.frame = CGRectMake(10, 30, 30, 30);
        [self.view addSubview:backBtn];
        [backBtn addTarget:self action:@selector(popUpViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    //分享按钮-share
    {
        UIButton * btn = [UIButton new];
        [btn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(WIDTH-14-30, 30, 30, 30);
        [self.view addSubview:btn];
        [btn addTarget:self action:@selector(showBottomNormalView) forControlEvents:UIControlEventTouchUpInside];
    }
    //商品详情view
    {
        NSArray * productList = self.goodsInfoDictionary[@"productList"];
        self.selectProductDic = productList[0];
        UIView * goodsView = [UIView new];
        {
            goodsViewHeight = 350;
            goodsView.frame = CGRectMake(0, HEIGHT-goodsViewHeight-50, WIDTH, goodsViewHeight);
            goodsView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:goodsView];
            self.goodsView = goodsView;
            goodsView.hidden = true;
        }
        //关闭按钮-btn_close
        {
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(WIDTH-30-14, 21, 30, 30);
            [goodsView addSubview:btn];
            [btn addTarget:self action:@selector(closeGoodsViewCallback) forControlEvents:UIControlEventTouchUpInside];
        }
        //商品图片
        {
            UIImageView * imgV = [UIImageView new];
            imgV.frame = CGRectMake(14, 17, 100, 100);
            NSString * url = self.goodsInfoDictionary[@"url"];
            imgV.image = [UIImage imageNamed:@"logo"];
            if (url) {
                [imgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
            }
            imgV.layer.masksToBounds = true;
            imgV.layer.cornerRadius = 12;
            [goodsView addSubview:imgV];
            self.goodsImgV = imgV;
            imgV.backgroundColor = [UIColor greenColor];
        }
        //商品名称
        {
            UILabel * label = [UILabel new];
            label.text = self.goodsInfoDictionary[@"goodsName"];
            label.font = [UIFont systemFontOfSize:16];
            [goodsView addSubview:label];
            label.numberOfLines = 0;
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            float width = WIDTH-128-50;
            while (size.width > width * 2 - label.font.pointSize) {
                label.font = [UIFont systemFontOfSize:label.font.pointSize - 0.1];
                size = [MYTOOL getSizeWithLabel:label];
            }
            label.frame = CGRectMake(128, 15, width, size.height * 2);
        }
        //库存
        {
            UILabel * label = [UILabel new];
            label.frame = CGRectMake(128, 60, WIDTH-128-50, 20);
            NSInteger enableStore = [productList[0][@"enableStore"] longValue];
            label.text = [NSString stringWithFormat:@"库存%ld",enableStore];
            label.font = [UIFont systemFontOfSize:18];
            [goodsView addSubview:label];
            self.sellerCountLabel = label;
            label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        }
        //价钱
        {
            UILabel * label = [UILabel new];
            self.goodsPriceLabel = label;
            label.frame = CGRectMake(128, 98, WIDTH-128-50, 20);
            float price = [productList[0][@"price"] floatValue];
            label.text = [NSString stringWithFormat:@"¥%.2f",price];
            if ((int) price == price) {
                label.text = [NSString stringWithFormat:@"¥%d",(int)price];
            }
            label.font = [UIFont systemFontOfSize:20];
            [goodsView addSubview:label];
            label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
        }
        //分割线
        {
            UIView * view = [UIView new];
            view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
            view.frame = CGRectMake(14, 136, WIDTH-28, 1);
            [goodsView addSubview:view];
        }
        //规格
        float top = 228;//top,最大是goodsViewHeight-60，350-60
        {
            //标题
            {
                UILabel * label = [UILabel new];
                label.text = @"规格";
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                label.frame = CGRectMake(14, 150, WIDTH/4, 18);
                [goodsView addSubview:label];
            }
            //规格选择按钮
            {
                float btn_left = 14;
                float btn_top = 170;
                float btn_height = 38;
                productBtnArray = [NSMutableArray new];
                for (int i = 0; i < productListArray.count; i ++) {
                    UIButton * btn = [UIButton new];
                    [productBtnArray addObject:btn];
                    [goodsView addSubview:btn];
                    [btn setTitleColor:[MYTOOL RGBWithRed:92 green:92 blue:92 alpha:1] forState:UIControlStateNormal];
                    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
                    btn.layer.masksToBounds = true;
                    NSString * productName = productListArray[i][@"productName"];
                    [btn setTitle:productName forState:UIControlStateNormal];
                    btn.titleLabel.font = [UIFont systemFontOfSize:15];
                    CGSize size = [MYTOOL getSizeWithString:productName andFont:[UIFont systemFontOfSize:15]];
                    float btn_width = size.width + 10;
                    if (btn_width > WIDTH-14-btn_left) {//不够放按钮了
                        /*两种情况*/
                        //左边没有按钮
                        if (btn_left == 14) {
                            float fontSize = 14.9;
                            while (true) {
                                UIFont * font = [UIFont systemFontOfSize:fontSize];
                                size = [MYTOOL getSizeWithString:productName andFont:font];
                                btn_width = size.width + 10;
                                if (btn_width > WIDTH-14-btn_left) {
                                    fontSize -= 0.1;
                                }else{
                                    btn.frame = CGRectMake(btn_left, btn_top, WIDTH-14-btn_left, btn_height);
                                    top += 35;
                                    break;
                                }
                            }
                        }else{//左边有按钮，后边不够放，则换一行
                            /*还有两种情况*/
                            btn_left = 14;
                            btn_top += btn_height + 5;
                            if (btn_width > WIDTH-14-btn_left) {//不够放按钮了
                                //改变字体大小
                                float fontSize = 14.9;
                                while (true) {
                                    UIFont * font = [UIFont systemFontOfSize:fontSize];
                                    size = [MYTOOL getSizeWithString:productName andFont:font];
                                    btn_width = size.width + 20;
                                    if (btn_width > WIDTH-14-btn_left) {
                                        fontSize -= 0.1;
                                    }else{
                                        btn.frame = CGRectMake(btn_left, btn_top, btn_width, btn_height);
                                        btn_left += btn_width + 14;
                                        break;
                                    }
                                }
                                
                            }else{
                                btn.frame = CGRectMake(btn_left, btn_top, btn_width, btn_height);
                                btn_left += btn_width + 14;
                            }
                        }
                    }else{//够放，直接放
                        if (btn_width < 50) {
                            btn_width = 50;
                        }
                        btn.frame = CGRectMake(btn_left, btn_top, btn_width, btn_height);
                        btn_left += btn_width + 14;
                    }
                    
                    if (btn_top + 35 > top) {
                        top = btn_top + btn_width+5;
                    }
                    //设置背景图片-btn_pay_gray-btn_pay_green
                    {
                        //普通
                        {
                            UIImage* img=[UIImage imageNamed:@"btn_pay_gray"];//原图
                            UIEdgeInsets edge=UIEdgeInsetsMake(0, 20, 0,20);
                            //UIImageResizingModeStretch：拉伸模式，通过拉伸UIEdgeInsets指定的矩形区域来填充图片
                            img= [img resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
                            [btn setBackgroundImage:img forState:UIControlStateNormal];
                        }
                        //不可用
                        {
                            UIImage* img=[UIImage imageNamed:@"btn_pay_green"];//原图
                            UIEdgeInsets edge=UIEdgeInsetsMake(0, 20, 0,20);
                            //UIImageResizingModeStretch：拉伸模式，通过拉伸UIEdgeInsets指定的矩形区域来填充图片
                            img= [img resizableImageWithCapInsets:edge resizingMode:UIImageResizingModeStretch];
                            [btn setBackgroundImage:img forState:UIControlStateDisabled];
                        }
                    }
                    if (i == 0) {
                        btn.enabled = false;
                    }
                    btn.tag = i;
                    [btn addTarget:self action:@selector(selectProductCallback:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
                
            }
            
            
        }
        
        //购买数量View
        {
            UIView * countView = [UIView new];
            {
                countView.frame = CGRectMake(0, top, WIDTH, 50);
                [goodsView addSubview:countView];
            }
            //分割线
            {
                UIView * view = [UIView new];
                view.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
                view.frame = CGRectMake(14, 0, WIDTH-28, 1);
                [countView addSubview:view];
            }
            //购买数量title
            {
                UILabel * label = [UILabel new];
                label.text = @"购买数量";
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                label.frame = CGRectMake(14, 16.5, WIDTH/2, 18);
                [countView addSubview:label];
            }
            //减少数量按钮-btn_reduce_nor-btn_reduce_disabled
            {
                UIButton * btn = [UIButton new];
                self.subtractBtn = btn;
                btn.frame = CGRectMake(WIDTH-14-30-37-30, 10, 30, 30);
                [btn setImage:[UIImage imageNamed:@"btn_reduce_nor"] forState:UIControlStateNormal];
                [btn setImage:[UIImage imageNamed:@"btn_reduce_disabled"] forState:UIControlStateDisabled];
                [btn addTarget:self action:@selector(subtractBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
                [countView addSubview:btn];
                btn.enabled = false;
            }
            //数量30
            {
                UILabel * label = [UILabel new];
                label.frame = CGRectMake(WIDTH-14-30-37, 17.5, 37, 15);
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                [countView addSubview:label];
                label.font = [UIFont systemFontOfSize:15];
                label.text = @"1";
                self.goodsCountLabel = label;
            }
            //增加数量按钮37
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH-14-30, 10, 30, 30);
                [btn setImage:[UIImage imageNamed:@"btn_plus"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(addBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
                [countView addSubview:btn];
            }
        }
        
        /*
         productList =     (
         {
         enableStore = 0;
         expressFree = 1;
         expressPrice = 0;
         marketPrice = 0;
         price = 136;
         productId = 116;
         productName = "\U7389\U5170\U6cb9\U6c34\U611f\U900f\U767d\U660e\U7738\U8d70\U73e0\U7cbe\U534e\U7b14 6ml";
         storeId = 0;
         url = "http://static.v4.javamall.com.cn/attachment/goods/201202231706544833.jpg";
         }
         );
         */
    }
    
    
    //底部view
    {
        UIView * down_view = [UIView new];
        {
            down_view.frame = CGRectMake(0, HEIGHT-50, WIDTH, 50);
            down_view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:down_view];
            //分割线
            {
                UIView * spaceView = [UIView new];
                spaceView.frame = CGRectMake(0, 0, WIDTH, 1);
                spaceView.backgroundColor = [MYTOOL RGBWithRed:201 green:201 blue:201 alpha:1];
                [down_view addSubview:spaceView];
            }
            //购物车按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(14, 10, 30, 30);
                [btn setImage:[UIImage imageNamed:@"Shopping-cart"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(shoppingCartBtnCallback) forControlEvents:UIControlEventTouchUpInside];
                [down_view addSubview:btn];
            }
            {
                UILabel * label = [UILabel new];
                label.backgroundColor = [UIColor redColor];
                label.frame = CGRectMake(34, 7, 20, 14);
                label.text = @"";
                label.layer.masksToBounds = true;
                label.layer.cornerRadius = 7;
                [down_view addSubview:label];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:14];
                label.textColor = [UIColor whiteColor];
                self.numberOfGoodsLabel = label;
            }
            //加入购物车
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH - 115 -115-15-15, 5.5, 115, 39);
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_gray"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(addToShoppingCartCallback) forControlEvents:UIControlEventTouchUpInside];
                [down_view addSubview:btn];
                [btn setTitle:@"加入购物车" forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                [btn setTitleColor:[MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1] forState:UIControlStateNormal];
                
            }
            //立即购买
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(WIDTH - 115 - 15, 5.5, 115, 39);
                [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_green"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(buyBtnCallback) forControlEvents:UIControlEventTouchUpInside];
                [down_view addSubview:btn];
                [btn setTitle:@"立即购买" forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:15];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
    
}



#pragma mark - 按键事件回调
//分享事件
- (void)showBottomNormalView
{
    SharedManagerVC * show = [SharedManagerVC new];
    show.delegate = self;
    
    NSString * goodsName = self.goodsInfoDictionary[@"goodsName"];
    float price = [self.goodsInfoDictionary[@"price"] floatValue];
    NSString * title = [NSString stringWithFormat:@"%@ - %.2f元",goodsName,price];
    NSString * img_url = self.goodsInfoDictionary[@"url"];
    NSString * shared_url = @"www.baidu.com";
    NSDictionary * sharedDic = @{
                                 @"title":title,
                                 @"img_url":img_url,
                                 @"shared_url":shared_url
                                 };
    show.sharedDictionary = sharedDic;
    [show show];
    
}
//重选规格
-(void)selectProductCallback:(UIButton *)btn{
    NSInteger index = btn.tag;
    //按钮状态
    for (int i = 0; i < productBtnArray.count; i ++) {
        UIButton * btn = productBtnArray[i];
        if (index == i) {
            btn.enabled = false;
        }else{
            btn.enabled = true;
        }
    }
    self.goodsCountLabel.text = @"1";//数量重置为1
    self.subtractBtn.enabled = false;//减少按钮不可用
    //重置库存
    
    NSInteger enableStore = [productListArray[index][@"enableStore"] longValue];
    self.sellerCountLabel.text = [NSString stringWithFormat:@"库存%ld",enableStore];
    //重置价格
    float price = [productListArray[index][@"price"] floatValue];
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
    if ((int)price == price) {
        self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥%d",(int)price];
    }
    //重置商品图片
    NSString * url = productListArray[index][@"url"];
    [self.goodsImgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
    //重置已选规格dic
    NSArray * productList = self.goodsInfoDictionary[@"productList"];
    self.selectProductDic = productList[index];
}
//减少商品数量
-(void)subtractBtnCallback:(UIButton *)btn{
    UILabel * numberLabel = self.goodsCountLabel;
    NSInteger number = [numberLabel.text intValue];
    number--;
    numberLabel.text = [NSString stringWithFormat:@"%ld",number];
    if (number <= 1) {
        btn.enabled = false;
    }
    
}
//增加商品数量
-(void)addBtnCallback:(UIButton *)btn{
    NSInteger number = [self.goodsCountLabel.text intValue];
    number++;
    self.goodsCountLabel.text = [NSString stringWithFormat:@"%ld",number];
    //减少的按钮设置为可用
    self.subtractBtn.enabled = true;
    
}
//商品详情view关闭事件
-(void)closeGoodsViewCallback{
    [UIView animateWithDuration:0.3 animations:^{
        self.goodsView.frame = CGRectMake(0, HEIGHT, WIDTH, goodsViewHeight);
    } completion:^(BOOL finished) {
        self.goodsView.hidden = true;
        self.webView.userInteractionEnabled = true;
    }];
    
}
//购物车按钮回调
-(void)shoppingCartBtnCallback{
    ShoppingCartVC * shop = [ShoppingCartVC new];
    shop.title = @"我的购物车";
    [self.navigationController pushViewController:shop animated:true];
}
//加入购物车
-(void)addToShoppingCartCallback{
    if (self.goodsView.hidden) {
        self.goodsView.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            self.goodsView.frame = CGRectMake(0, HEIGHT-goodsViewHeight-50, WIDTH, goodsViewHeight);
        } completion:^(BOOL finished) {
            self.webView.userInteractionEnabled = false;
        }];
    }else{
        //准备加入购物车
        [MYTOOL netWorkingWithTitle:@"加入购物车…"];
        NSString * interfaceName = @"/shop/cart/addProduct.intf";
        NSInteger productId = [self.selectProductDic[@"productId"] longValue];
        NSDictionary * sendDic = @{
                                   @"quantity":self.goodsCountLabel.text,
                                   @"memberId":MEMBERID,
                                   @"productId":[NSString stringWithFormat:@"%ld",productId]
                                   };
//        NSLog(@"send:%@",sendDic);
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"back:%@",back_dic);
            NSString * msg = back_dic[@"msg"];
            if (!msg) {
                msg = @"添加成功";
            }
            [MYNETWORKING getNumberOfShoppingCartCallback:^(NSDictionary * back) {
                int count = [back[@"count"] intValue];
                [SVProgressHUD showSuccessWithStatus:msg duration:1];
                [self refreshGoodsNumber:count];
            }];
        }];
        /*
         8.12添加商品到购物车
         Ø接口地址：/shop/cart/addProduct.intf
         Ø接口描述：添加商品到购物车
         71.72.73.73.1Ø输入参数：
         参数名称	参数含义	参数类型	是否必录
         productId	产品id	数字	是
         quantity	购买数量	数字	是
         memberId	会员Id	数字	是
         */
    }
}
//立即购买事件
-(void)buyBtnCallback{
    if (self.goodsView.hidden) {
        self.goodsView.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            self.goodsView.frame = CGRectMake(0, HEIGHT-goodsViewHeight-50, WIDTH, goodsViewHeight);
        } completion:^(BOOL finished) {
            self.webView.userInteractionEnabled = false;
        }];
    }else{
        //准备购买
        NSString * interfaceName = @"/shop/order/confirmOrder.intf";
        NSMutableDictionary * sendDic = [NSMutableDictionary new];
        [sendDic setValue:MEMBERID forKey:@"memberId"];
        NSString * productId_1 = [NSString stringWithFormat:@"%ld",[self.selectProductDic[@"productId"] longValue]];
        NSString * quantity_1 = self.goodsCountLabel.text;
        [sendDic setValue:productId_1 forKey:@"productId"];
        [sendDic setValue:quantity_1 forKey:@"quantity"];
//        NSLog(@"product:%@",self.selectProductDic);
        NSInteger enableStore = [self.selectProductDic[@"enableStore"] longValue];
        if ([quantity_1 intValue] > enableStore) {
            [SVProgressHUD showErrorWithStatus:@"数量不足" duration:2];
            return;
        }
        [SVProgressHUD showWithStatus:@"购买中…" maskType:SVProgressHUDMaskTypeClear];
//        NSLog(@"send:%@",sendDic);
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"back:%@",back_dic);
            ConfirmOrderVC * orderVC = [ConfirmOrderVC new];
            orderVC.order = back_dic[@"order"];
            orderVC.goodsList = back_dic[@"goodsList"];
            orderVC.receiptAddress = back_dic[@"receiptAddress"];
            orderVC.title = @"确认订单";
//            orderVC.goodsArray = back_dic[@"goodsList"];
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.goodsInfoDictionary];
            [dict setValue:self.selectProductDic[@"productId"] forKey:@"productId"];
            orderVC.goodsInfoDictionary = dict;
            [self.navigationController pushViewController:orderVC animated:true];

        }];
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
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
//刷新购物车商品数量
-(void)refreshGoodsNumber:(NSInteger)goodsNumber{
    CGRect rect = self.numberOfGoodsLabel.frame;
    self.numberOfGoodsLabel.text = [NSString stringWithFormat:@"%ld",goodsNumber];
    if (goodsNumber > 99) {
        self.numberOfGoodsLabel.text = @"99+";
    }
    CGSize size = [MYTOOL getSizeWithString:self.numberOfGoodsLabel.text andFont:self.numberOfGoodsLabel.font];
    self.numberOfGoodsLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
    if (size.width < 20) {
        self.numberOfGoodsLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, 20, size.height);
    }
    if (goodsNumber == 0) {
        self.numberOfGoodsLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, 0, size.height);
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [MYTOOL hiddenTabBar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [MYNETWORKING getNumberOfShoppingCartCallback:^(NSDictionary * back) {
        int count = [back[@"count"] intValue];
        [self refreshGoodsNumber:count];
    }];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:false animated:YES];
    [MYTOOL showTabBar];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
@end
