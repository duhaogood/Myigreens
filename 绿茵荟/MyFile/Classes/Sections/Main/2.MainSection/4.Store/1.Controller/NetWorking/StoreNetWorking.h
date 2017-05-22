//
//  StoreNetWorking.h
//  绿茵荟
//
//  Created by Mac on 17/4/17.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreNetWorking : NSObject
//获取商品分类数据
-(void)getGoodsCategory:(void(^)(NSDictionary* backDict))success;
//获取轮播图数据
-(void)getCarouselImageData:(void(^)(NSDictionary* backDict))success;
//加载要显示的页面数据
-(void)getViewData:(void(^)(NSDictionary* backDict))success;

@end
