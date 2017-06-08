//
//  TextBannerVC.m
//  绿茵荟
//
//  Created by Mac on 17/5/25.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "TextBannerVC.h"

@interface TextBannerVC ()
@property(nonatomic,strong)UIWebView * webView;//商品h5页面

@end

@implementation TextBannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    
    {
        UIWebView * web = [UIWebView new];
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
