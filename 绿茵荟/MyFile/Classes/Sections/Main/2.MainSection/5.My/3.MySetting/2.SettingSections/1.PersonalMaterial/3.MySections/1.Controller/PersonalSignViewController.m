//
//  PersonalSignViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/4/7.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "PersonalSignViewController.h"
#import "SubmitPostTV.h"
#import "PersonalMaterialViewController.h"
@interface PersonalSignViewController ()<UITextViewDelegate>
@property(nonatomic,strong)UILabel * title_count_label;//显示文本框文字个数
@property(nonatomic,strong)SubmitPostTV * myTV;//文本框
@end

@implementation PersonalSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(submitCancelBtn)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    //右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(submitSaveBtn)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    //加载主界面
    [self loadMainView];
    
    
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    
    UIView * back_view = [UIView new];
    back_view.backgroundColor = [UIColor whiteColor];
    back_view.frame = [MYTOOL getRectWithIphone_six_X:0 andY:10 andWidth:375 andHeight:152];
    [self.view addSubview:back_view];
    //文本框
    SubmitPostTV * tv = [[SubmitPostTV alloc]initWithFrame:[MYTOOL getRectWithIphone_six_X:0 andY:0 andWidth:375 andHeight:80]];
    tv.placeholderLabel.frame = CGRectMake(0, 10, tv.frame.size.width, 20);
    tv.placeholderLabel.text = @"一句话描述自己…";
    tv.placeholderLabel.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
    tv.placeholderLabel.font = [UIFont systemFontOfSize:15];
    [back_view addSubview:tv];
    self.myTV = tv;
    tv.delegate = self;
    //字数个数label
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(WIDTH-90, back_view.frame.size.height-30, 75, 15);
    label.textAlignment = NSTextAlignmentRight;
    label.text = @"0/20";
    label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
    label.font = [UIFont systemFontOfSize:12];
    [back_view addSubview:label];
    self.title_count_label = label;
    
    if (self.content && self.content.length) {
        tv.text = self.content;
        tv.placeholderLabel.hidden = true;
        self.title_count_label.text = [NSString stringWithFormat:@"%ld/20",tv.text.length];
    }
    
}
#pragma mark - 自定义事件
//返回我的  页面
-(void)backToMyVC{
    [self.navigationController popViewControllerAnimated:YES];
}
//提交保存按钮
-(void)submitSaveBtn{
    if (self.myTV.text.length > 20) {
        [SVProgressHUD showErrorWithStatus:@"字数最多20" duration:2];
        return;
    }
    [MYTOOL hideKeyboard];
    [self.delegate personalSign_callBack:self.myTV.text];
    [SVProgressHUD showSuccessWithStatus:@"保存成功" duration:1];
    [self performSelector:@selector(backToMyVC) withObject:nil afterDelay:1];
}
//提交取消按钮
-(void)submitCancelBtn{
    [self backToMyVC];
}
#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (range.length == 0 && textView.text.length >= 20) {
        [SVProgressHUD showErrorWithStatus:@"字数最多20" duration:2];
        [MYTOOL hideKeyboard];
        return false;
    }
    return true;
}
-(void)textViewDidChange:(UITextView *)textView{
    self.title_count_label.text = [NSString stringWithFormat:@"%ld/20",textView.text.length];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}
@end
