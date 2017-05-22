//
//  PointGoodsInfoVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/22.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "PointGoodsInfoVC.h"

@interface PointGoodsInfoVC ()
@property(nonatomic,strong)UIWebView * webView;

@end

@implementation PointGoodsInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //webView
    UIWebView * webView = [UIWebView new];
    webView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64-50);
    webView.frame = self.view.bounds;
    self.webView = webView;
    [self.view addSubview:webView];
    [self.webView loadHTMLString:@"https://www.baidu.com" baseURL:nil];
    //底部兑换view
    {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        view.frame = CGRectMake(0, HEIGHT-64-50, WIDTH, 50);
        [self.view addSubview:view];
        //需要积分
        {
            UILabel * label = [UILabel new];
            label.text = [NSString stringWithFormat:@"%ld",[self.goodsInfo[@"point"] longValue]];
            label.textColor = MYCOLOR_229_64_73;
            label.font = [UIFont systemFontOfSize:18];
            [view addSubview:label];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            label.frame = CGRectMake(14, 16, size.width, size.height);
        }
        //兑换按钮
        {
            UIButton * btn = [UIButton new];
            [btn addTarget:self action:@selector(convertCallback) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:@"兑换" forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_green"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.frame = CGRectMake(WIDTH - 130, 6, 114, 38);
            [view addSubview:btn];
        }
    }
}

//兑换事件
-(void)convertCallback{
    NSLog(@"%@",self.goodsInfo);
}



/*
 description = "\U65fa\U65fa \U6311\U8c46\U968f\U624b\U5305\U6d77\U82d4\U82b1\U751f45g/\U888b";
 exchangeMaxCount = 1;
 expressPrice = 0;
 goodsId = 9;
 goodsName = "\U65fa\U65fa\U6311\U8c46\U968f\U624b\U5305\U6d77\U82d4\U82b1\U751f45g/\U888b";
 image = "http://static.v4.javamall.com.cn/attachment/goods/201202221444355358.jpg";
 point = 500;
 */
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
