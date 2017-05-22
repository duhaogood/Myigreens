//
//  StorePageTableViewCell.h
//  绿茵荟
//
//  Created by Mac on 17/4/17.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//  商品组

#import <UIKit/UIKit.h>

@interface StorePageTableViewCell : UITableViewCell

@property(nonatomic,strong)UILabel * leftLabel;//前面数字
@property(nonatomic,strong)UILabel * rightLabel;//后面数字

@end

@interface StorePageTableViewCell()

-(instancetype)cellWithDictionary:(NSDictionary *)dictionary andDelegate:(id)delegate;

@end
