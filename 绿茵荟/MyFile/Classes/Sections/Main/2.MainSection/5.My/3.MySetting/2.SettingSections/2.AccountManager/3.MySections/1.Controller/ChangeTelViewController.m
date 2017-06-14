//
//  ChangeTelViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/4/8.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ChangeTelViewController.h"
#import "AccountManagerViewController.h"
@interface ChangeTelViewController ()
@property(nonatomic,strong)UITextField * tel_tf;//手机号码
@property(nonatomic,strong)UITextField * code_tf;//验证码
@property(nonatomic,strong)UIButton * getCodeBtn;//获取验证码按钮
@end

@implementation ChangeTelViewController
{
    int timeLeft;//再次获取验证码剩余时间
    NSTimer * timer;//定时器
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToUpView)];
    //背景视图
    UIView * back_view = [UIView new];
    back_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:10 andWidth:375 andHeight:117];
    back_view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:back_view];
    
    float height = back_view.frame.size.height;
    //分割线
    UIView * space_view = [UIView new];
    space_view.frame = CGRectMake(10, height/2-0.5, WIDTH-20, 1);
    space_view.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
    [back_view addSubview:space_view];
    //手机号
    {
        UITextField * tf = [UITextField new];
        tf.frame = CGRectMake(10, height/4-9, WIDTH/2, 18);
        tf.placeholder = @"请输入手机号";
        tf.font = [UIFont systemFontOfSize:18];
        tf.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        [back_view addSubview:tf];
        self.tel_tf = tf;
    }
    //验证码
    {
        UITextField * tf = [UITextField new];
        tf.frame = CGRectMake(10, height/4*3-9, WIDTH/2, 18);
        tf.placeholder = @"请输入验证码";
        tf.font = [UIFont systemFontOfSize:18];
        tf.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        [back_view addSubview:tf];
        self.code_tf = tf;
    }
    //获取验证码按钮
    {
        UIButton * btn = [UIButton new];
        [btn addTarget:self action:@selector(getCodeBtn_callBack) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_follow_pre"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(WIDTH - 100, height/4*3-18, 84, 36);
        [back_view addSubview:btn];
        [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[MYTOOL RGBWithRed:117 green:160 blue:52 alpha:1] forState:UIControlStateNormal];
        self.getCodeBtn = btn;
        timeLeft = 10;
    }
    //完成按钮
    {
        UIButton * btn = [UIButton new];
        [btn addTarget:self action:@selector(finishBtn_callBack) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_submit"] forState:UIControlStateNormal];
        btn.frame = [MYTOOL getRectWithIphone_six_X:88 andY:229-64 andWidth:200 andHeight:52];
        [self.view addSubview:btn];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    
}


//完成按钮回调
-(void)finishBtn_callBack{
    NSString * code = self.code_tf.text;
    NSDictionary * send_dic = @{
                                @"mobileNo":self.tel_tf.text,
                                @"captcha":code,
                                @"memberId":MEMBERID
                                };
    [MYNETWORKING getWithInterfaceName:@"/sys/checkCaptcha.intf" andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        [SVProgressHUD dismiss];
        bool success = [back_dic[@"code"] boolValue];
        NSString * msg = back_dic[@"msg"];
        NSString * memberId = back_dic[@"memberId"];
        if (success) {
            //把登录状态写进程序
            [MYTOOL setProjectPropertyWithKey:@"isLogin" andValue:@"1"];
            [MYTOOL setProjectPropertyWithKey:@"memberId" andValue:memberId];
            [SVProgressHUD showSuccessWithStatus:msg duration:1];
            [self.delegate refresh_tel_label];
            [self backToUpView];
        }else{
            [SVProgressHUD showErrorWithStatus:msg duration:2];
        }
        
        
    }];
}

//获取验证码按钮回调
-(void)getCodeBtn_callBack{
//    NSLog(@"获取验证码");
    if (self.tel_tf.text.length != 11) {
        [SVProgressHUD showErrorWithStatus:@"手机号长度有误" duration:2];
        return;
    }
    [SVProgressHUD showWithStatus:@"获取验证码" maskType:SVProgressHUDMaskTypeClear];
    
    NSDictionary * send_dic = @{
                                @"mobileNo":self.tel_tf.text,
                                @"cc":@"86"
                                };
    [MYNETWORKING getWithInterfaceName:@"/sys/sendSMS.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        //        NSLog(@"back:%@",back_dic);
        [SVProgressHUD dismiss];
        bool success = [back_dic[@"code"] boolValue];
        NSString * msg = back_dic[@"msg"];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:msg duration:1];
            [MYTOOL hideKeyboard];
            [self.code_tf becomeFirstResponder];
            self.getCodeBtn.enabled = false;
            self.tel_tf.enabled = false;
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refreshGetCodeAgagin) userInfo:nil repeats:true];
            [timer fire];
        }else{
            [SVProgressHUD showErrorWithStatus:msg duration:2];
        }
    }];
}
//刷新验证码再次获取时间
-(void)refreshGetCodeAgagin{
    if (timeLeft < 0) {
        [timer invalidate];
        timer = nil;
        timeLeft = 10;
        self.getCodeBtn.enabled = true;
        [self.getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    }else{
        [self.getCodeBtn setTitle:[NSString stringWithFormat:@"剩余%d秒",timeLeft] forState:UIControlStateNormal];
        timeLeft --;
    }
}
//返回上个界面
-(void)backToUpView{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}
@end
