//
//  TextBannerVC.m
//  绿茵荟
//
//  Created by Mac on 17/5/25.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "TextBannerVC.h"
#import "GoodsInfoViewController.h"
@interface TextBannerVC ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView * webView;//商品h5页面

@end

@implementation TextBannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    
    {
        UIWebView * web = [UIWebView new];
        web.delegate = self;
        web.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
        if (self.content) {
            [web loadHTMLString:self.content baseURL:nil];
        }else if(self.viewUrl){
            NSURL *url = [[NSURL alloc] initWithString:self.viewUrl];
            [web loadRequest:[NSURLRequest requestWithURL:url]];
        }
        [self.view addSubview:web];
        self.webView = web;
    }
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString * requestString = request.URL.absoluteString;
    NSMutableDictionary * netDic = [MYTOOL getURLParameters:requestString];
    NSString * goodsId = netDic[@"goodsId"];
    if (goodsId && goodsId.length) {
        [MYTOOL netWorkingWithTitle:@"获取商品详情"];
        GoodsInfoViewController * info = [GoodsInfoViewController new];
        //网络获取商品详情
        NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
        NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
        if (cityId == nil) {
            cityId = @"320300";
        }
        NSDictionary * sendDict = @{
                                    @"goodsId":goodsId,
                                    @"cityId":cityId
                                    };
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
            //        NSLog(@"商品详情:%@",back_dic[@"goods"]);
            info.goodsInfoDictionary = back_dic[@"goods"];
            [self.navigationController pushViewController:info animated:true];
        }];
        
        return false;
    }
    
    return true;
}
//返回
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}



@end
