//
//  SelectPayTypeVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/4/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SelectPayTypeVC.h"
#import "AliPayTool.h"
#import "WXPayTool.h"
#import "ConfirmOrderVC.h"
@interface SelectPayTypeVC ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *backgroundTapView;
@property(nonatomic,strong)UIButton * zhiBtn;//支付宝按钮
@property(nonatomic,strong)UIImageView * zhiIcon;//支付宝图标
@property(nonatomic,strong)UIButton * weiBtn;//微信按钮
@property(nonatomic,strong)UIImageView * weiIcon;//微信图标
@property(nonatomic,strong)NSDictionary * goodsDic;//订单信息
@end

@implementation SelectPayTypeVC


- (void)show {
    UIWindow * window = ((AppDelegate*)[UIApplication sharedApplication].delegate).window;
    UIViewController *rootViewController = window.rootViewController;
    [rootViewController addChildViewController:self];
    [rootViewController.view addSubview:self.view];
    [self didMoveToParentViewController:rootViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperViewController:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    tap.delaysTouchesBegan = YES;
    [self.backgroundTapView addGestureRecognizer:tap];
    
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:0 green:0 blue:0 alpha:0.5];
    UIView * view = [UIView new];
    float height = 360;
    view.frame = CGRectMake(0, HEIGHT-height, WIDTH, height);
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    //选择支付方式
    {
        //标题
        {
            UILabel * label = [UILabel new];
            label.text = @"请选择支付方式";
            label.font = [UIFont systemFontOfSize:18];
            CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
            label.frame = CGRectMake(WIDTH/2 - size.width/2, 23, size.width, 18);
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            [view addSubview:label];
        }
        //分割线-1
        {
            UIView * spaceView = [UIView new];
            spaceView.frame = CGRectMake(14, 126, WIDTH-28, 1);
            spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
            [view addSubview:spaceView];
        }
        //分割线-2
        {
            UIView * spaceView = [UIView new];
            spaceView.frame = CGRectMake(14, 195, WIDTH-28, 1);
            spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
            [view addSubview:spaceView];
        }
        //支付宝
        {
            //图标
            {
                UIImageView * imgV = [UIImageView new];
                imgV.frame = CGRectMake(9, 77, 40, 40);
                imgV.image = [UIImage imageNamed:@"zhifubao"];
                [view addSubview:imgV];
            }
            //文字
            {
                UILabel * label = [UILabel new];
                label.text = @"支付宝支付";
                label.font = [UIFont systemFontOfSize:18];
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                label.frame = CGRectMake(63, 88, WIDTH/2, 18);
                [view addSubview:label];
            }
            //是否选择图标
            {
                UIImageView * icon = [UIImageView new];
                icon.image = [UIImage imageNamed:@"pay_sel"];
                icon.frame = CGRectMake(WIDTH-30-14, 88-5, 30, 30);
                [view addSubview:icon];
                icon.tag = 1;
                self.zhiIcon = icon;
            }
            //按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(0, 126-68, WIDTH, 68);
                [view addSubview:btn];
                btn.tag = 1;
                self.zhiBtn = btn;
                [btn addTarget:self action:@selector(zhiBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        //微信
        {
            //图标
            {
                UIImageView * imgV = [UIImageView new];
                imgV.frame = CGRectMake(9, 144, 40, 40);
                imgV.image = [UIImage imageNamed:@"wxzhifu"];
                [view addSubview:imgV];
            }
            //文字
            {
                UILabel * label = [UILabel new];
                label.text = @"微信支付";
                label.font = [UIFont systemFontOfSize:18];
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                label.frame = CGRectMake(63, 88+68, WIDTH/2, 18);
                [view addSubview:label];
            }
            //是否选择图标
            {
                UIImageView * icon = [UIImageView new];
                icon.image = [UIImage imageNamed:@"pay_bor"];
                icon.frame = CGRectMake(WIDTH-30-14, 88+68-5, 30, 30);
                [view addSubview:icon];
                icon.tag = 0;
                self.weiIcon = icon;
            }
            //按钮
            {
                UIButton * btn = [UIButton new];
                btn.frame = CGRectMake(0, 126, WIDTH, 68);
                [view addSubview:btn];
                self.weiBtn = btn;
                btn.tag = 0;
                [btn addTarget:self action:@selector(weiBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        //分割线
        {
            UIView * spaceView = [UIView new];
            spaceView.frame = CGRectMake(0, view.frame.size.height-45, WIDTH, 1);
            spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
            [view addSubview:spaceView];
        }
        //支付按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = CGRectMake(0, view.frame.size.height-45, WIDTH, 45);
            [btn setTitle:@"支付" forState:UIControlStateNormal];
            [btn setTitleColor:[MYTOOL RGBWithRed:117 green:160 blue:52 alpha:1] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:18];
            [btn addTarget:self action:@selector(payCallback) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
        }
    }
}
//支付按钮回调
-(void)payCallback{
    if (self.zhiBtn.tag == 1) {
        [[AliPayTool new] aliPayWithGoodsDictionary:self.orderDictionary];
        
    }else{
        [[WXPayTool new] wxPayWithGoodsDictionary:self.orderDictionary];
    }
}
//支付宝按钮回调
-(void)zhiBtnCallback:(UIButton *)btn{
    if (btn.tag == 1) {
        return;
    }
    //btn改为选中状态
    btn.tag = 1;
    self.zhiIcon.image = [UIImage imageNamed:@"pay_sel"];
    self.zhiIcon.tag = 1;
    //微信改为未选中
    self.weiIcon.image = [UIImage imageNamed:@"pay_bor"];
    self.weiIcon.tag = 0;
    self.weiBtn.tag = 0;
}
//微信按钮回调
-(void)weiBtnCallback:(UIButton *)btn{
    if (btn.tag == 1) {
        return;
    }
    //btn改为选中状态
    btn.tag = 1;
    self.weiIcon.image = [UIImage imageNamed:@"pay_sel"];
    self.weiIcon.tag = 1;
    //支付宝改为未选中
    self.zhiIcon.image = [UIImage imageNamed:@"pay_bor"];
    self.zhiIcon.tag = 0;
    self.zhiBtn.tag = 0;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (point.y > self.view.frame.size.height-360) {
        return;
    }
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"确定要取消支付？" message:@"取消后可以在我的订单中查看" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消支付" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        [self removeFromSuperViewController:nil];
        [((UIViewController *)self.delegate).navigationController popToRootViewControllerAnimated:true];
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"继续支付" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:action];
    [alert addAction:cancelAction];
    [self showDetailViewController:alert sender:nil];
    
}

- (void)removeFromSuperViewController:(UIGestureRecognizer *)gr {
    [self didMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [self.backgroundTapView removeGestureRecognizer:gr];
}

@end
