//
//  SelectBonusVC.h
//  绿茵荟
//
//  Created by Mac on 17/5/31.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectBonusVC : UIViewController
@property(nonatomic,strong)NSArray * bonusList;//优惠券列表
@property(nonatomic,strong)NSObject * orderPrice;//订单金额
@property(nonatomic,assign)id delegate;
@end
