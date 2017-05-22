//
//  GoodsTagViewController.h
//  绿茵荟
//
//  Created by Mac on 17/4/18.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//  商品标签查询全部商品

#import <UIKit/UIKit.h>

@interface GoodsTagViewController : UIViewController
@property(nonatomic,assign)NSInteger tagId;//商品标签id
@property(nonatomic,assign)NSInteger goodsTagId;//商品分类id
@property(nonatomic,assign)int type;//类型，1分类，2标签
@end
