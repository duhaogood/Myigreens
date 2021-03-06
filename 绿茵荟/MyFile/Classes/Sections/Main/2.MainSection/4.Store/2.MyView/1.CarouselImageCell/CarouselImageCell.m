//
//  CarouselImageCell.m
//  绿茵荟
//
//  Created by Mac on 17/4/17.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "CarouselImageCell.h"
#import "StoreVC.h"
#import "SDCycleScrollView.h"
@implementation CarouselImageCell
//carouselImage_array;//轮播图数据goodsCategory_array//商品分类数据
+(instancetype)cellWithCarouselImage_array:(NSArray *)carouselImage_array andGoodsCategory_array:(NSArray *)goodsCategory_array andDelegate:(id)delegate{
    //总高度257
    UITableViewCell * cell = [UITableViewCell new];
    //无法选中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //轮播图
    //图片url数组
    NSMutableArray * url_arr = [NSMutableArray new];
    for (NSDictionary * dic in carouselImage_array) {
        NSString * bannerUrl = dic[@"bannerUrl"];
//        NSLog(@"url:%@",bannerUrl);
        [url_arr addObject:bannerUrl];
    }
    SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(10, 10, WIDTH-20, 151) imageURLStringsGroup:url_arr];
    cycleScrollView.layer.masksToBounds = true;
//    cycleScrollView.layer.cornerRadius = 12;
    cycleScrollView.delegate = delegate;
    [cell addSubview:cycleScrollView];
    cycleScrollView.tag = 100;
    
    
    
//    UIImageView * imgV = [UIImageView new];
//    imgV.frame = CGRectMake(10, 10, WIDTH-20, 151);
//    [cell addSubview:imgV];
//    imgV.layer.masksToBounds = true;
//    imgV.layer.cornerRadius = 12;
//    imgV.backgroundColor = [UIColor greenColor];
    
    
    
    //商品分类scrollView
    UIScrollView * scrollView = [UIScrollView new];
    scrollView.frame = CGRectMake(0, 169, WIDTH, 80);
    [cell addSubview:scrollView];
//    NSLog(@"商品分类:%ld",goodsCategory_array.count);
    for (int i = 0; i < goodsCategory_array.count; i ++) {
        NSDictionary * goodsDic = goodsCategory_array[i];
        NSInteger goodsCatId = [goodsDic[@"goodsCatId"] longValue];//商品分类id
        NSString * name = goodsDic[@"name"];
        if (name == nil || name.length == 0) {
            name = @"未知";
        }
        NSString * image_url = goodsDic[@"url"];
        //图片clickImgOfGoodsCategory
        {
            UIImageView * imgV = [UIImageView new];
            imgV.frame = CGRectMake(14 + (14+70)*i, 5, 70, 70);
            imgV.layer.masksToBounds = true;
            imgV.layer.cornerRadius = 35;
            [scrollView addSubview:imgV];
//            imgV.backgroundColor = [UIColor redColor];
            imgV.tag = goodsCatId;
            [imgV sd_setImageWithURL:[NSURL URLWithString:image_url] placeholderImage:[UIImage imageNamed:@"logo"]];
            imgV.tag = goodsCatId;
            [imgV setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:delegate action:@selector(clickImgOfGoodsCategory:)];
            tapGesture.numberOfTapsRequired=1;
            [imgV addGestureRecognizer:tapGesture];
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.text = name;
            label.textColor = [UIColor whiteColor];
            label.frame = CGRectMake(14 + (14+70)*i, 32.5, 70, 15);
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:14];
            [scrollView addSubview:label];
        }
        
    }
    scrollView.contentSize = CGSizeMake((14+70)*goodsCategory_array.count, 0);
    
    
    
    
    return (CarouselImageCell*)cell;
}

@end
