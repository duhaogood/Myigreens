//
//  SharedManagerVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/18.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SharedManagerVC.h"
#import <UShareUI/UShareUI.h>

@interface SharedManagerVC ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *backgroundTapView;

@end

@implementation SharedManagerVC

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
    float height = 210;
    view.frame = CGRectMake(0, HEIGHT-height, WIDTH, height);
    view.backgroundColor = [MYTOOL RGBWithRed:238 green:238 blue:238 alpha:1];
    [self.view addSubview:view];
    //选择支付方式
    {
        //标题
        {
            UILabel * label = [UILabel new];
            label.text = @"请选择分享平台";
            label.font = [UIFont systemFontOfSize:18];
            CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
            label.frame = CGRectMake(WIDTH/2 - size.width/2, 23, size.width, 18);
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            [view addSubview:label];
        }
        NSArray * btn_array = @[
                                @[@"icon_wechat",@"微信"],
                                @[@"icon_weibo",@"新浪微博"],
                                @[@"icon_qq",@"QQ"],
                                @[@"icon_moments",@"朋友圈"],
                                ];
        //分享按钮
        {
            float top1 = 56;
            float top2 = 126;
            float space = (WIDTH - 240)/5.0;
            UIFont * font = [UIFont systemFontOfSize:15];
            UIColor * color = [MYTOOL RGBWithRed:92 green:92 blue:92 alpha:1];
            NSMutableArray * arr = [NSMutableArray new];
            for (int i = 0; i < 4; i ++) {
                //按钮
                UIButton * btn = [UIButton new];
                {
                    [btn setImage:[UIImage imageNamed:btn_array[i][0]] forState:UIControlStateNormal];
                    btn.frame = CGRectMake(space + (60 + space) * i, top1, 60, 60);
                    [view addSubview:btn];
                    [arr addObject:btn];
                }
                //文字
                {
                    UILabel * label = [UILabel new];
                    label.font = font;
                    label.textColor = color;
                    label.text = btn_array[i][1];
                    CGSize size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(btn.frame.origin.x + btn.frame.size.width/2 - size.width/2, top2, size.width, size.height);
                    [view addSubview:label];
                }
            }
            [arr[0] addTarget:self action:@selector(sharedToWeiChat) forControlEvents:UIControlEventTouchUpInside];
            [arr[1] addTarget:self action:@selector(sharedToWeiBo) forControlEvents:UIControlEventTouchUpInside];
            [arr[2] addTarget:self action:@selector(sharedToQQ) forControlEvents:UIControlEventTouchUpInside];
            [arr[3] addTarget:self action:@selector(sharedToFriend) forControlEvents:UIControlEventTouchUpInside];
        }
        //取消按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = CGRectMake(0, 211-50, WIDTH, 50);
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(cancelShared) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.text = @"取消分享";
            label.textColor = MYCOLOR_46_42_42;
            label.font = [UIFont systemFontOfSize:18];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            label.frame = CGRectMake(0, 210-25-size.height/2, WIDTH, size.height);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
    }
}
#pragma mark - 按钮事件
//分享微信
-(void)sharedToWeiChat{
    [self sharedWithType:1];
}
//分享微博
-(void)sharedToWeiBo{
    [SVProgressHUD showErrorWithStatus:@"微博暂不支持" duration:2];
    return;
    [self sharedWithType:0];
}
//分享qq
-(void)sharedToQQ{
    [self sharedWithType:4];
}
//分享朋友圈
-(void)sharedToFriend{
    [self sharedWithType:2];
}
//分享事件
-(void)sharedWithType:(int)type{
    //网页分享
    UMSocialPlatformType platformType = type;
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    NSString * title = self.sharedDictionary[@"title"];
    NSString * img_url = self.sharedDictionary[@"img_url"];
    NSString * shared_url = self.sharedDictionary[@"shared_url"];
    NSString * shareDescribe = self.sharedDictionary[@"shareDescribe"];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:shareDescribe thumImage:img_url];
    //设置网页地址
    shareObject.webpageUrl = shared_url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            NSLog(@"错误:%@",error.userInfo[@"message"]);
            NSString * text = error.userInfo[@"message"];
            if (!text || text.length == 0) {
                text = @"分享失败";
            }
            [SVProgressHUD showErrorWithStatus:text duration:2];
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                [SVProgressHUD showSuccessWithStatus:@"分享成功" duration:1];
                [self removeFromSuperViewController:nil];
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                //分享成功，回调服务器
                [self sharedSuccess];
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}
//分享成功，回调服务器
-(void)sharedSuccess{
    if (self.sharedDic == nil) {
        return;
    }
    NSString * interface = @"/sys/shareBack.intf";
    [MYNETWORKING getNoPopWithInterfaceName:interface andDictionary:self.sharedDic andSuccess:^(NSDictionary *back_dic) {
//        for (NSString * key in back_dic.allKeys) {
//            NSLog(@"%@:%@",key,back_dic[key]);
//        }
    }];
    
    
}


//取消分享
-(void)cancelShared{
    [self removeFromSuperViewController:nil];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (point.y > self.view.frame.size.height-210) {
        return;
    }
//    [self removeFromSuperViewController:nil];
}

- (void)removeFromSuperViewController:(UIGestureRecognizer *)gr {
    [self didMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [self.backgroundTapView removeGestureRecognizer:gr];
}


@end
