//
//  ConfirmOrderVC.h
//  绿茵荟
//
//  Created by Mac on 17/4/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//  确认订单

#import <UIKit/UIKit.h>

@interface ConfirmOrderVC : UIViewController
@property(nonatomic,strong)NSArray * goodsList;//商品列表
@property(nonatomic,strong)NSDictionary * order;//订单详情
@property(nonatomic,strong)NSDictionary * receiptAddress;//接收地址信息

@property(nonatomic,strong)NSDictionary * goodsInfoDictionary;//商品直接进来传递的商品详情

/**更改地址*/
-(void)changeAddress:(NSDictionary *)addressDic;
//更改快递方式
-(void)changeExpressWithDictionary:(NSDictionary *)expressDict;
@end
