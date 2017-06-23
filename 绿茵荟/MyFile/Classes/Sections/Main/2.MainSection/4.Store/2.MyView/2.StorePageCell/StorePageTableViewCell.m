//
//  StorePageTableViewCell.m
//  绿茵荟
//
//  Created by Mac on 17/4/17.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "StorePageTableViewCell.h"
#import "StoreVC.h"
@implementation StorePageTableViewCell



-(instancetype)cellWithDictionary:(NSDictionary *)dictionary andDelegate:(id)delegate{
    UITableViewCell * cell = [UITableViewCell new];
    //无法被点击
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSInteger showType = [dictionary[@"showType"] longValue];//展示类型
    NSString * tagName = dictionary[@"tagName"];//标签名称
    NSInteger tagId = [dictionary[@"tagId"] longValue];//标签id
    
    //标签名称
    {
        UILabel * label = [UILabel new];
        label.text = tagName;
        label.textColor = [MYTOOL RGBWithRed:106 green:151 blue:53 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18];
        label.font = [UIFont titleFontOfSize:18];
        CGSize size = [MYTOOL getSizeWithLabel:label];
        float width = WIDTH - 140;
        while (size.width > width) {
            label.font = [UIFont systemFontOfSize:label.font.pointSize - 0.1];
            size = [MYTOOL getSizeWithLabel:label];
        }
        label.frame = CGRectMake(70, 23, WIDTH-140, 24);
        [cell addSubview:label];
    }
    if (showType == 1) {//下面的商品组
        //右侧图标
        {
            UIImageView * right = [UIImageView new];
            right.frame = CGRectMake(WIDTH-30, 20, 30, 30);
            right.image = [UIImage imageNamed:@"arrow_right"];
            [cell addSubview:right];
        }
        //全部按钮
        {
            UIButton * btn = [UIButton new];
            [btn setTitle:@"全部" forState:UIControlStateNormal];
            [btn setTitleColor:[MYTOOL RGBWithRed:119 green:119 blue:119 alpha:1] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.frame = CGRectMake(WIDTH-65, 20, 60, 30);
            [cell addSubview:btn];
            [btn addTarget:delegate action:@selector(clickAllBtn_callBack:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = tagId;
        }
        float top = 0;
        NSArray * goodsList = dictionary[@"goodsList"];
        for(int i = 0 ; i < goodsList.count ; i ++){
            NSDictionary * goodsDic = goodsList[i];
            NSInteger goodsId = [goodsDic[@"goodsId"] longValue];
            NSString * goodsName = goodsDic[@"goodsName"];
            NSString * url = goodsDic[@"url"];
            float price = [goodsDic[@"price"] floatValue];
            float marketPrice = [goodsDic[@"marketPrice"] floatValue];
            float width = (WIDTH - 30-10)/2.0;
            //商品图片
            UIImageView * imgV = [UIImageView new];
            {
                top = 70 + 240.0*(i/2);
                imgV.frame = CGRectMake(15+(width+10)*(i%2), top, width, 149);
                imgV.layer.masksToBounds = true;
//                imgV.layer.cornerRadius = 12;
                [cell addSubview:imgV];
                [MYTOOL setImageIncludePrograssOfImageView:imgV withUrlString:url];
                imgV.tag = goodsId;
                [imgV setUserInteractionEnabled:YES];
                UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:delegate action:@selector(clickImgOfGoods:)];
                tapGesture.numberOfTapsRequired=1;
                [imgV addGestureRecognizer:tapGesture];
            }
            //商品名字
            UILabel * name_label = nil;
            {
                UILabel * label = [UILabel new];
                label.text = goodsName;
                name_label = label;
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:15];
                CGRect rect = imgV.frame;
                label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+19, width, 15);
                [cell addSubview:label];
                CGSize size = [MYTOOL getSizeWithLabel:label];
                //一行显示不全，把字体变小
                if (size.width > width) {
                    label.font = [UIFont systemFontOfSize:14];
                    size = [MYTOOL getSizeWithLabel:label];
                    label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+19, width, size.height);
                }
                //一行还显示不全，变成两行
                if (size.width > width) {
                    label.numberOfLines = 0;
                    //两行显示不全
                    while (size.width > width * 2 - label.font.pointSize) {
                        label.font = [UIFont systemFontOfSize:label.font.pointSize-0.1];
                        size = [MYTOOL getSizeWithLabel:label];
                    }
                    label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+10, width, size.height*2);
                }
            }
            //商品价格
            UILabel * priceLabel;
            {
                UILabel * label = [UILabel new];
                priceLabel = label;
                label.text = [NSString stringWithFormat:@"¥%.2f",price];
                label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:15];
                CGRect rect = name_label.frame;
                label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+10, rect.size.width, 15);
                [cell addSubview:label];
            }
            //市场价格-marketPrice
            {
                //市场价高于卖家才显示
                if (marketPrice > price) {
                    //卖价放右边一半
                    NSString * text = [NSString stringWithFormat:@"%.2f",price];
                    if (price * 10 == (int)(price * 10)) {
                        text = [NSString stringWithFormat:@"%.1f",price];
                    }
                    if (price == (int)price) {
                        text = [NSString stringWithFormat:@"%d",(int)price];
                    }
                    priceLabel.text = text;
                    priceLabel.textAlignment = NSTextAlignmentLeft;
                    priceLabel.frame = CGRectMake(WIDTH/4+i%2*WIDTH/2, priceLabel.frame.origin.y, WIDTH/4, priceLabel.frame.size.height);
                    //市场价放左边一半
                    UILabel * marketPriceLabel = [UILabel new];
                    marketPriceLabel.font = priceLabel.font;
                    text = [NSString stringWithFormat:@"¥%.2f",marketPrice];
                    if (marketPrice * 10 == (int)(marketPrice * 10)) {
                        text = [NSString stringWithFormat:@"¥%.1f",marketPrice];
                    }
                    if (marketPrice == (int)marketPrice) {
                        text = [NSString stringWithFormat:@"¥%d",(int)marketPrice];
                    }
                    marketPriceLabel.text = text;
                    CGSize size = [MYTOOL getSizeWithLabel:marketPriceLabel];
                    marketPriceLabel.frame = CGRectMake(i%2*WIDTH/2 + WIDTH/4-size.width-10, priceLabel.frame.origin.y, size.width, size.height);
                    marketPriceLabel.textAlignment = NSTextAlignmentRight;
                    [cell addSubview:marketPriceLabel];
                    
                    //价格横线
                    {
                        UIView * space = [UIView new];
                        space.frame = CGRectMake(marketPriceLabel.frame.origin.x - 3, marketPriceLabel.frame.origin.y + marketPriceLabel.frame.size.height/2-0.5, marketPriceLabel.frame.size.width+6, 1);
                        space.backgroundColor = MYCOLOR_229_64_73;
                        [cell addSubview:space];
                    }
                }
            }
        }
        //分割线
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
//        [cell addSubview:spaceView];
        NSInteger row = goodsList.count/2;
        if (goodsList.count > row * 2) {
            row ++;
        }
        spaceView.frame = CGRectMake(0, 70 + 240.0*row-10, WIDTH, 10);
    }else if (showType == 3) {//导航展示类型
        float height = WIDTH/950.0*440;
        NSArray * bannerList = dictionary[@"bannerList"];
//        NSLog(@"banner:%@",bannerList);
        float img_width = (WIDTH - 30)/2.0;
        //横向滚动
        UIScrollView * scroll = [UIScrollView new];
        scroll.frame = CGRectMake(0, 55, WIDTH, height - 50 - 20);
        //        scroll.backgroundColor = [UIColor greenColor];
        [cell addSubview:scroll];
        float left = 10;
        //添加图片
        for (int i = 0; i < bannerList.count ; i ++) {
            NSDictionary * imgDic = bannerList[i];
            NSString * bannerUrl = imgDic[@"bannerUrl"];//图片链接
            NSInteger bannerId = [imgDic[@"bannerId"] longValue];//tag
            //            NSLog(@"id:%ld",bannerId);
            UIImageView * icon = [UIImageView new];
            icon.frame = CGRectMake(10 + (10+img_width)*i, 0, img_width, height - 50 - 20);
            icon.tag = bannerId;
            [icon sd_setImageWithURL:[NSURL URLWithString:bannerUrl]];
            [scroll addSubview:icon];
            left += (10+img_width)*i;
            //添加点击事件
            [icon setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:delegate action:@selector(clickImgOfGoodsGroup:)];
            tapGesture.numberOfTapsRequired=1;
            [icon addGestureRecognizer:tapGesture];
        }
        scroll.contentSize = CGSizeMake(10 + (10+img_width)*bannerList.count, 0);
    }else if(showType == 2){
        float height = WIDTH/950.0*440;
        NSArray * bannerList = dictionary[@"bannerList"];
//        NSLog(@"banner:%@",bannerList);
        float img_width = (WIDTH - 30)/2.0;
        float left = 10;
        //添加图片
        for (int i = 0; i < bannerList.count ; i ++) {
            NSDictionary * imgDic = bannerList[i];
            NSString * bannerUrl = imgDic[@"bannerUrl"];//图片链接
            NSInteger bannerId = [imgDic[@"bannerId"] longValue];//tag
//            NSLog(@"id:%ld",bannerId);
            UIImageView * icon = [UIImageView new];
            icon.frame = CGRectMake(10 + (10+img_width)*(i%2), (i/2)*(height - 50 - 20+10)+70, img_width, height - 50 - 20);
            icon.tag = bannerId;
            [icon sd_setImageWithURL:[NSURL URLWithString:bannerUrl]];
            [cell addSubview:icon];
            left += (10+img_width)*i;
            //添加点击事件
            [icon setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:delegate action:@selector(clickImgOfGoodsGroup:)];
            tapGesture.numberOfTapsRequired=1;
            [icon addGestureRecognizer:tapGesture];
        }
    }
    
    return (StorePageTableViewCell *)cell;
}








@end
