//
//  CarouselImageCell.h
//  绿茵荟
//
//  Created by Mac on 17/4/17.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//  轮播图

#import <UIKit/UIKit.h>

@interface CarouselImageCell : UITableViewCell


+(instancetype)cellWithCarouselImage_array:(NSArray *)carouselImage_array andGoodsCategory_array:(NSArray *)goodsCategory_array andDelegate:(id)delegate;



@end
