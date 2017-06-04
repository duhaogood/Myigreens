//
//  SelectView.h
//  绿茵荟
//
//  Created by mac_hao on 2017/3/23.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectView : UITableView

//初始化方法
-(instancetype)initWithFrame:(CGRect)frame andDataDictionary:(NSDictionary*)dataDictionary andDelegate:(id)delegate withBannerArray:(NSArray *)bannerArray;

//设置图片数组
-(void)setImgArray:(NSArray *)arr;


@end
