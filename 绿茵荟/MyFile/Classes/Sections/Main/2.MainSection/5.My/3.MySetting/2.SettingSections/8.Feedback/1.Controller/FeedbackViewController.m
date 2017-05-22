//
//  FeedbackViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "FeedbackViewController.h"
#import "SubmitPostTV.h"
@interface FeedbackViewController ()<UITextViewDelegate>
@property(nonatomic,strong)UILabel * title_count_label;//显示文本框文字个数
@property(nonatomic,strong)SubmitPostTV * myTV;//文本框

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    //上侧背景图
    {
        UIImageView * back_imgV = [UIImageView new];
        back_imgV.frame = [MYTOOL getRectWithIphone_six_X:0 andY:0 andWidth:375 andHeight:241];
        back_imgV.image = [UIImage imageNamed:@"pic_bg"];
        [self.view addSubview:back_imgV];
    }
    //中间标题
    {
        UILabel * title_label = [UILabel new];
        title_label.text = self.title;
        title_label.textColor = [UIColor whiteColor];
        title_label.frame = CGRectMake(WIDTH/4, 34, WIDTH/2, 18);
        title_label.font = [UIFont systemFontOfSize:18];
        [self.view addSubview:title_label];
        title_label.textAlignment = NSTextAlignmentCenter;
    }
    //返回按钮
    {
        UIButton * back_btn = [UIButton new];
        [back_btn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [back_btn addTarget:self action:@selector(backToUpView) forControlEvents:UIControlEventTouchUpInside];
        back_btn.frame = CGRectMake(10, 30, 30, 30);
        [self.view addSubview:back_btn];
    }
    //文本框
    {
        //文本框
        SubmitPostTV * tv = [[SubmitPostTV alloc]initWithFrame:[MYTOOL getRectWithIphone_six_X:0 andY:241 andWidth:375 andHeight:182]];
        tv.placeholderLabel.frame = CGRectMake(0, 10, tv.frame.size.width, 20);
        tv.placeholderLabel.text = @"感谢您的宝贵意见…";
        tv.placeholderLabel.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        tv.placeholderLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:tv];
        self.myTV = tv;
        tv.delegate = self;
        //字数个数label
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(WIDTH-120, tv.frame.size.height-30, 100, 15);
        label.textAlignment = NSTextAlignmentRight;
        label.text = @"0/100";
        label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        label.font = [UIFont systemFontOfSize:12];
        [tv addSubview:label];
        self.title_count_label = label;
        //down 241+182  = 423
        
    }
    //提交按钮
    {
        UIButton * btn = [UIButton new];
        btn.frame = [MYTOOL getRectWithIphone_six_X:88 andY:474 andWidth:200 andHeight:52];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_submit"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(submit_btn_callBack) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:@"提交" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:btn];
        
    }
    
}
#pragma mark - 自定义事件
//提交按钮回调
-(void)submit_btn_callBack{
//    NSLog(@"内容:%@",self.myTV.text);
    NSString * content = self.myTV.text;
    if (content.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"输入意见" duration:2];
        return;
    }
    NSString * interfaceName = @"/sys/saveFeedBack.intf";
    NSDictionary * sendDic = @{
                               @"memberId":[MYTOOL getProjectPropertyWithKey:@"memberId"],
                               @"type":@"1",//反馈类型
                               @"clientType":@"1",//设备型号1:ios，2:android
                               @"content":content//反馈内容
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        [SVProgressHUD showSuccessWithStatus:@"反馈成功" duration:1];
        [self.navigationController popViewControllerAnimated:true];
    }];
}
//返回上个界面
-(void)backToUpView{
    [self.navigationController popViewControllerAnimated:true];
}
//键盘即将显示
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //键盘高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    //文本框底部高度
    float tv_top = 423/667.0*HEIGHT;
    if (tv_top + height > HEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, HEIGHT - height - tv_top, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }

}
//键盘即将消失
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.length == 0 && textView.text.length >= 100) {
        [SVProgressHUD showErrorWithStatus:@"字数最多100" duration:2];
        [MYTOOL hideKeyboard];
        return false;
    }
    return true;
}
-(void)textViewDidChange:(UITextView *)textView{
    self.title_count_label.text = [NSString stringWithFormat:@"%ld/100",textView.text.length];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - view隐藏和显示
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self.navigationController setNavigationBarHidden:true animated:true];
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
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    [self.navigationController setNavigationBarHidden:false animated:true];
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
