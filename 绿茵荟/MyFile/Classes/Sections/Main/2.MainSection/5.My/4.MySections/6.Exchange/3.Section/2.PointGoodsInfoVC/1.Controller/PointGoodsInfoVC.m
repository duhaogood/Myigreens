//
//  PointGoodsInfoVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/22.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "PointGoodsInfoVC.h"
#import "ConfirmOrderVC.h"
@interface PointGoodsInfoVC ()
@property(nonatomic,strong)UIWebView * webView;//商品h5页面
@property(nonatomic,strong)UIView * goodsView;//商品详情view
@property(nonatomic,strong)UILabel * goodsCountLabel;//购买商品数量
@property(nonatomic,strong)UILabel * sellerCountLabel;//库存数量
@property(nonatomic,strong)UILabel * goodsPointLabel;//商品价格
@property(nonatomic,strong)NSDictionary * selectProductDic;//已选商品型号
@property(nonatomic,strong)UIImageView * goodsImgV;//商品图片
@property(nonatomic,strong)UIButton * subtractBtn;//减少按钮
@end

@implementation PointGoodsInfoVC
{
    float goodsViewHeight;//隐藏view高度
    NSArray * productListArray;//商品规格数组
    NSMutableArray * productBtnArray;//商品规格按钮数组
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"point:%@",self.goodsInfo);
    self.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //webView
    UIWebView * webView = [UIWebView new];
    webView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64-50);
    webView.frame = self.view.bounds;
    self.webView = webView;
    NSString * url = self.goodsInfo[@"goodDetailUrl"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    //商品详情view
    {
        NSArray * productList = self.goodsInfo[@"productList"];
        productListArray = productList;
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
            NSString * url = self.selectProductDic[@"url"];
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
            label.text = self.goodsInfo[@"goodsName"];
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
                label.text = @"兑换数量";
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
    }
    //底部兑换view
    {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.frame = CGRectMake(0, HEIGHT-64-50, WIDTH, 50);
        [self.view addSubview:view];
        //分割线
        {
            UIView * space = [UIView new];
            space.frame = CGRectMake(0, 0, WIDTH, 1);
            space.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
            [view addSubview:space];
        }
        float left = 0;
        //提示
        {
            UILabel * label = [UILabel new];
            label.text = @"兑换积分:";
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = MYCOLOR_46_42_42;
//            label.font = [UIFont fontWithName:@"PingFang SC Regular" size:18];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            label.frame = CGRectMake(14, 25-size.height/2, size.width, size.height);
            [view addSubview:label];
            left = size.width + 25;
        }
        //需要积分
        {
            UILabel * label = [UILabel new];
            self.goodsPointLabel = label;
            label.text = [NSString stringWithFormat:@"%ld",[self.goodsInfo[@"point"] longValue]];
            label.textColor = MYCOLOR_229_64_73;
            label.font = [UIFont systemFontOfSize:18];
            [view addSubview:label];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            label.frame = CGRectMake(left, 25-size.height/2, WIDTH/2, size.height);
        }
        //兑换按钮
        {
            UIButton * btn = [UIButton new];
            [btn addTarget:self action:@selector(convertCallback) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:@"兑换商品" forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_green"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.frame = CGRectMake(WIDTH - 130, 6, 114, 38);
            [view addSubview:btn];
        }
    }
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
    int point = [self.goodsInfo[@"point"] intValue];
    self.goodsPointLabel.text = [NSString stringWithFormat:@"¥%d",point];
    //数量重置1
    self.goodsCountLabel.text = @"1";
    //减少不可用
    self.subtractBtn.enabled = false;
    //重置商品图片
    NSString * url = productListArray[index][@"url"];
    [self.goodsImgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
    //重置已选规格dic
    NSArray * productList = self.goodsInfo[@"productList"];
    self.selectProductDic = productList[index];
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
//减少商品数量
-(void)subtractBtnCallback:(UIButton *)btn{
    UILabel * numberLabel = self.goodsCountLabel;
    NSInteger number = [numberLabel.text intValue];
    number--;
    numberLabel.text = [NSString stringWithFormat:@"%ld",number];
    if (number <= 1) {
        btn.enabled = false;
    }
    self.goodsPointLabel.text = [NSString stringWithFormat:@"%ld",[self.goodsInfo[@"point"] intValue] * number];
}
//增加商品数量
-(void)addBtnCallback:(UIButton *)btn{
    NSInteger number = [self.goodsCountLabel.text intValue];
    number++;
    self.goodsCountLabel.text = [NSString stringWithFormat:@"%ld",number];
    //减少的按钮设置为可用
    self.subtractBtn.enabled = true;
    self.goodsPointLabel.text = [NSString stringWithFormat:@"%ld",[self.goodsInfo[@"point"] intValue] * number];
}
//兑换事件
-(void)convertCallback{
    if (self.goodsView.hidden) {
        self.goodsView.hidden = false;
        [UIView animateWithDuration:0.3 animations:^{
            self.goodsView.frame = CGRectMake(0, HEIGHT-goodsViewHeight-50, WIDTH, goodsViewHeight);
        } completion:^(BOOL finished) {
            self.webView.userInteractionEnabled = false;
        }];
    }else{
//        NSLog(@"%@",self.selectProductDic);
        int goodsCount = [self.goodsCountLabel.text intValue];
        NSInteger enableStore = [self.selectProductDic[@"enableStore"] longValue];
        if (goodsCount > enableStore) {
            [SVProgressHUD showErrorWithStatus:@"可换数量有限哦" duration:2];
            return;
        }
        
        NSString * interfaceName = @"/shop/order/confirmOrder.intf";
        NSMutableDictionary * sendDic = [NSMutableDictionary new];
        [sendDic setValue:MEMBERID forKey:@"memberId"];
        NSString * productId_1 = [NSString stringWithFormat:@"%ld",[self.goodsInfo[@"productList"][0][@"productId"] longValue]];
        NSString * quantity_1 = self.goodsCountLabel.text;
        [sendDic setValue:productId_1 forKey:@"productId"];
        [sendDic setValue:quantity_1 forKey:@"quantity"];
        [sendDic setValue:@"1" forKey:@"integral"];
//        NSLog(@"send:%@",sendDic);
        [SVProgressHUD showWithStatus:@"购买中…" maskType:SVProgressHUDMaskTypeClear];
        //        NSLog(@"send:%@",sendDic);
//        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//                        NSLog(@"back:%@",back_dic);
//            NSLog(@"send:%@",sendDic);
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
                NSLog(@"back:%@",back_dic);
                ConfirmOrderVC * orderVC = [ConfirmOrderVC new];
                orderVC.order = back_dic[@"order"];
                orderVC.goodsList = back_dic[@"goodsList"];
                orderVC.receiptAddress = back_dic[@"receiptAddress"];
                orderVC.title = @"确认订单";
                orderVC.integral = 1;
                //            orderVC.goodsArray = back_dic[@"goodsList"];
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:self.goodsInfo];
                [dict setValue:self.selectProductDic[@"productId"] forKey:@"productId"];
                orderVC.goodsInfoDictionary = dict;
                [self.navigationController pushViewController:orderVC animated:true];
                
            }];
//        }];
    
    
    
    
    
    
}
}

//返回上个界面
-(void)backToUpView{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}
@end
