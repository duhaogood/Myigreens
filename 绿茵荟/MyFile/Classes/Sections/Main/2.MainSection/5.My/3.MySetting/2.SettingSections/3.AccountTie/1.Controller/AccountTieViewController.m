//
//  AccountTieViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "AccountTieViewController.h"

@interface AccountTieViewController ()
@property(nonatomic,strong)NSMutableDictionary * title_swich_dictionary;//标题和开关
@end

@implementation AccountTieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //背景视图
    UIView * back_view = [UIView new];
    back_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:10 andWidth:375 andHeight:175];
    back_view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:back_view];
    //分割线
    float height = back_view.frame.size.height;
    for (int i = 0; i < 2; i ++) {
        UIView * space_view = [UIView new];
        space_view.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
        space_view.frame = CGRectMake(10, height/3 * (i + 1)-1, WIDTH-20, 1);
        [back_view addSubview:space_view];
    }
    //文字 & switch按钮
    NSArray * title_array = @[@"新浪微博",@"微信",@"QQ"];
    self.title_swich_dictionary = [NSMutableDictionary new];
    for (int i = 0; i < title_array.count; i ++) {
        //文字
        UILabel * title_label = [UILabel new];
        title_label.frame = CGRectMake(10, height/6 + height / 3 * i - 9, WIDTH/3, 18);
        title_label.text = title_array[i];
        [back_view addSubview:title_label];
        //按钮
        UISwitch * btn = [UISwitch new];
        btn.frame = CGRectMake(WIDTH - 70, height/6 + height / 3 * i - 15.5, 53, 31);
        btn.on = false;
        [btn addTarget:self action:@selector(swichBtn_callBack:) forControlEvents:UIControlEventValueChanged];
        [back_view addSubview:btn];
        [self.title_swich_dictionary setObject:btn forKey:title_array[i]];
    }
    
    
}
//swich开关回调
-(void)swichBtn_callBack:(UISwitch *)btn{
    for (NSString * key in self.title_swich_dictionary.allKeys) {
        UISwitch * s_btn = self.title_swich_dictionary[key];
        if ([s_btn isEqual:btn]) {
//            NSLog(@"点击:%@,目前状态:%d",key,btn.on);
            
            return;
        }
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
