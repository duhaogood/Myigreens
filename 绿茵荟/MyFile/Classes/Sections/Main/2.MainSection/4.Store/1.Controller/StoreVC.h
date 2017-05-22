//
//  StoreVC.h
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreNetWorking.h"
#import "CarouselImageCell.h"
#import "StorePageTableViewCell.h"
#import "SDCycleScrollView.h"
#import "GoodsTagViewController.h"
#import "ShoppingCartVC.h"
@interface StoreVC : UIViewController
@property(nonatomic,strong)StoreNetWorking * storeNetWorking;//处理网络请求





//获取当前显示图片序号
-(int)getIndexOfimage;
//商品分类图片点击事件
-(void)clickImgOfGoodsCategory:(UITapGestureRecognizer *)tap;
//点击标签右侧全部回调
-(void)clickAllBtn_callBack:(UIButton * )btn;
//商品图片点击事件
-(void)clickImgOfGoods:(UITapGestureRecognizer *)tap;

@end
