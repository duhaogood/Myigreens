//
//  LoginViewController.m
//  绿茵荟
//
//  Created by Mac on 17/3/30.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UIButton * loginBtn;
@property(nonatomic,strong)UIButton * registerBtn;
@property(nonatomic,strong)UIButton * currentBtn;
@property(nonatomic,strong)UIButton * getCodeBtn;//获取验证码按钮
@property(nonatomic,strong)UIButton * nextBtn;//登录按钮
@property(nonatomic,strong)UITextField * tel_tf;//手机号文本
@property(nonatomic,strong)UITextField * code_tf;//验证码文本
@end

@implementation LoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主页面
    [self loadMainView];
    
    
}
//加载主页面
-(void)loadMainView{
    self.view.backgroundColor = [UIColor whiteColor];
    //750*1135
    //背景
    UIImageView * back_imgV = [UIImageView new];
    back_imgV.frame = CGRectMake(0, 0, WIDTH, 174*WIDTH/375.0);
    back_imgV.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:back_imgV];
    
    
    //返回按钮
    UIButton * backBtn = [UIButton new];
    [backBtn setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn_callback) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(10, 25, 50, 50);
    [self.view addSubview:backBtn];
    
    float top = 0;
    //登录、注册按钮  -  btn_login_pre btn_login_nor  65*31
    {
        //登录
        UIButton * loginBtn = [UIButton new];
        self.loginBtn = loginBtn;
        self.currentBtn = loginBtn;
        loginBtn.frame = CGRectMake(WIDTH/2 - 65 - 5, 174*WIDTH/375.0 - 20, 65, 31);
        [loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_pre"] forState:UIControlStateNormal];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(loginBtn_callback:) forControlEvents:UIControlEventTouchUpInside];
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:loginBtn];
        //注册
        UIButton * registerBtn = [UIButton new];
        self.registerBtn = registerBtn;
        registerBtn.frame = CGRectMake(WIDTH/2 + 5, 174*WIDTH/375.0 - 20, 65, 31);
        [registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_nor"] forState:UIControlStateNormal];
        [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
        [registerBtn addTarget:self action:@selector(registerBtn_callback:) forControlEvents:UIControlEventTouchUpInside];
        [registerBtn setTitleColor:[MYTOOL RGBWithRed:34 green:31 blue:32 alpha:1] forState:UIControlStateNormal];
        [self.view addSubview:registerBtn];
    }
    //手机号
    {
        top = 238/736.0*HEIGHT;
        //背景图 293*69
        UIImageView * tel_back_imgV = [UIImageView new];
        tel_back_imgV.image = [UIImage imageNamed:@"login_input_sel"];
        tel_back_imgV.frame = CGRectMake(40, top, WIDTH - 80, (WIDTH - 80)/293.0*69);
        [self.view addSubview:tel_back_imgV];
        //手机号文本框
        UITextField * tel_tf = [UITextField new];
        tel_tf.frame = CGRectMake(70, (WIDTH - 80)/293.0*69/2-10+top, (WIDTH - 80)*3/5.0, 20);
        tel_tf.placeholder = @"请输入手机号";
        [self.view addSubview:tel_tf];
        self.tel_tf = tel_tf;
        tel_tf.keyboardType = UIKeyboardTypeNumberPad;
        //获取验证码按钮
        UIButton * getCodeBtn = [UIButton new];
        [getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        getCodeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        CGSize size;
        {
            UILabel * label = [UILabel new];
            label.text = @"获取验证码";
            label.font = [UIFont systemFontOfSize:12];
            size = [MYTOOL getSizeWithLabel:label];
        }
        [getCodeBtn setTitleColor:[MYTOOL RGBWithRed:180 green:180 blue:180 alpha:1] forState:UIControlStateNormal];
        getCodeBtn.frame = CGRectMake(WIDTH - 40 - size.width-15, (WIDTH - 80)/293.0*69/2-10+top, size.width, 20);
        [getCodeBtn addTarget:self action:@selector(getCode_back) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:getCodeBtn];
        self.getCodeBtn = getCodeBtn;
        
        
    }
    //验证码
    {
        //背景图
        UIImageView * tel_back_imgV = [UIImageView new];
        tel_back_imgV.image = [UIImage imageNamed:@"login_input_sel"];
        tel_back_imgV.frame = CGRectMake(40, 238/736.0*HEIGHT + (WIDTH - 80)/293.0*69, WIDTH - 80, (WIDTH - 80)/293.0*69);
        [self.view addSubview:tel_back_imgV];
        
        
        //验证码文本框
        UITextField * code_tf = [UITextField new];
        code_tf.frame = CGRectMake(70, (WIDTH - 80)/293.0*69/2-10  + 238/736.0*HEIGHT + (WIDTH - 80)/293.0*69, (WIDTH - 80)/2.0, 20);
        code_tf.placeholder = @"请输入验证码";
        [self.view addSubview:code_tf];
        self.code_tf = code_tf;
        code_tf.keyboardType = UIKeyboardTypeNumberPad;
        [self.code_tf addTarget:self action:@selector(textChangeAction:) forControlEvents:UIControlEventEditingChanged];
        top = 238/736.0*HEIGHT + (WIDTH - 80)/293.0*69 + (WIDTH - 80)/293.0*69;
    }
    //登录按钮
    {
        UIButton * nextBtn = [UIButton new];
        [nextBtn setImage:[UIImage imageNamed:@"icon_right_disabled"] forState:UIControlStateNormal];
        nextBtn.frame = CGRectMake(WIDTH/2-44/736.0*HEIGHT/2, top+44/736.0*HEIGHT/2, 44/736.0*HEIGHT, 44/736.0*HEIGHT);
        [self.view addSubview:nextBtn];
        self.nextBtn = nextBtn;
        nextBtn.enabled = false;
        [nextBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    }
#warning 第三方登录
    
    
    
    
}






#pragma mark - 按钮回调
//获取验证码
-(void)getCode_back{
    [MYTOOL hideKeyboard];
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
            [self.tel_tf resignFirstResponder];
        }else{
            [SVProgressHUD showErrorWithStatus:msg duration:2];
        }
    }];
    
    
}
//登录
-(void)login{
//    NSLog(@"登录");
    NSString * tel = self.tel_tf.text;
    if (tel.length != 11) {
        [SVProgressHUD showErrorWithStatus:@"手机长度有误" duration:2];
        return;
    }
    NSString * code = self.code_tf.text;
    NSDictionary * send_dic = @{
                                @"mobileNo":tel,
                                @"captcha":code
                                };
   [MYNETWORKING getWithInterfaceName:@"/sys/checkCaptcha.intf" andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
//       NSLog(@"back:%@",back_dic);
       [SVProgressHUD dismiss];
       bool success = [back_dic[@"code"] boolValue];
       NSString * msg = back_dic[@"msg"];
       NSString * memberId = back_dic[@"memberId"];
       if (success) {
           //把登录状态写进程序
           [MYTOOL setProjectPropertyWithKey:@"user_tel" andValue:tel];
           [MYTOOL setProjectPropertyWithKey:@"isLogin" andValue:@"1"];
           [MYTOOL setProjectPropertyWithKey:@"memberId" andValue:memberId];
           
           //跳转
           [(AppDelegate *)[UIApplication sharedApplication].delegate window].rootViewController = [MainVC new];
           
           
           [SVProgressHUD showSuccessWithStatus:msg duration:1];
       }else{
           [SVProgressHUD showErrorWithStatus:msg duration:2];
       }
       
       
   }];
    
    
}
-(void)loginBtn_callback:(UIButton *)btn{
    if ([btn isEqual:self.currentBtn]) {
        return;
    }
    self.currentBtn = btn;
    [_registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_nor"] forState:UIControlStateNormal];
    [_registerBtn setTitleColor:[MYTOOL RGBWithRed:34 green:31 blue:32 alpha:1] forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_pre"] forState:UIControlStateNormal];
    
    
}
-(void)registerBtn_callback:(UIButton *)btn{
    if ([btn isEqual:self.currentBtn]) {
        return;
    }
    self.currentBtn = btn;
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_nor"] forState:UIControlStateNormal];
    [_loginBtn setTitleColor:[MYTOOL RGBWithRed:34 green:31 blue:32 alpha:1] forState:UIControlStateNormal];
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_pre"] forState:UIControlStateNormal];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - 检测code_tf中文字变化
- (void) textChangeAction:(id) sender {
    NSString * code = [sender text];
    if (code.length == 4) {
        self.nextBtn.enabled = true;
        [self.nextBtn setImage:[UIImage imageNamed:@"icon_right"] forState:UIControlStateNormal];
        [sender resignFirstResponder];
    }else{
        self.nextBtn.enabled = false;
        [self.nextBtn setImage:[UIImage imageNamed:@"icon_right_disabled"] forState:UIControlStateNormal];
    }
    
}
#pragma mark - 返回上个界面
-(void)backBtn_callback{
    if (self.fromExitLogin) {//跳转至主页
        AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        MainVC * main = [MainVC new];
        app.window.rootViewController = main;
        main.selectedIndex = 0;
        return;
    }
    if (self.donotUpdate) {
        [self.delegate setDonotUpdate:self.donotUpdate];
    }
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - view显示及消失
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MYTOOL hiddenTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MYTOOL showTabBar];
    [self.navigationController setNavigationBarHidden:false animated:YES];
}

@end
