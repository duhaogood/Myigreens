//
//  OrderInfoVC.h
//  绿茵荟
//
//  Created by Mac on 17/5/15.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderInfoVC : UIViewController

@property(nonatomic,strong)NSDictionary * orderDictionary;//订单详情信息
@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)int timeLeft;//剩余时间
@end
