//
//  SelectPayTypeVC.h
//  绿茵荟
//
//  Created by mac_hao on 2017/4/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfirmOrderVC.h"
@interface SelectPayTypeVC : UIViewController
@property(nonatomic,assign)bool isSuccess;//是否创建订单成功
@property(nonatomic,strong)NSDictionary * orderDictionary;//需要支付的订单信息
@property(nonatomic,assign)id delegate;
- (void)show;
- (void)removeFromSuperViewController:(UIGestureRecognizer *)gr;
@end
