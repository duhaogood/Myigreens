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
        label.font = [UIFont systemFontOfSize:24];
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
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
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
            float width = (WIDTH - 30-10)/2.0;
            //商品图片
            UIImageView * imgV = [UIImageView new];
            {
                top = 70 + 240.0*(i/2);
                imgV.frame = CGRectMake(15+(width+10)*(i%2), top, width, 149);
                imgV.layer.masksToBounds = true;
                imgV.layer.cornerRadius = 12;
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
            {
                UILabel * label = [UILabel new];
                label.text = [NSString stringWithFormat:@"¥%.2f",price];
                label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont systemFontOfSize:15];
                CGRect rect = name_label.frame;
                label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+10, rect.size.width, 15);
                [cell addSubview:label];
            }
        }
        //分割线
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
        [cell addSubview:spaceView];
        NSInteger row = goodsList.count/2;
        if (goodsList.count > row * 2) {
            row ++;
        }
        spaceView.frame = CGRectMake(0, 70 + 240.0*row-10, WIDTH, 10);
    }else if (showType == 3) {//中间的新鲜热卖
        NSLog(@"bannerList:%@",dictionary[@"bannerList"]);
        //图片序号
        {
            UILabel * leftLabel = [UILabel new];
            leftLabel.text = [NSString stringWithFormat:@"%d",[delegate getIndexOfimage]];
            leftLabel.textColor = [MYTOOL RGBWithRed:106 green:151 blue:53 alpha:1];
            leftLabel.font = [UIFont systemFontOfSize:18];
            leftLabel.frame = CGRectMake(WIDTH-72, 27, 36, 18);//39
            leftLabel.textAlignment = NSTextAlignmentRight;
            self.leftLabel = leftLabel;
            [delegate setLeftLabel:leftLabel];
//            leftLabel.backgroundColor = [UIColor greenColor];
            [cell addSubview:leftLabel];
            
            UILabel * rightLabel = [UILabel new];
            rightLabel.text = [NSString stringWithFormat:@"/%ld",[dictionary[@"bannerList"] count]];
            rightLabel.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
            rightLabel.font = [UIFont systemFontOfSize:18];
            rightLabel.frame = CGRectMake(WIDTH-36, 27, 30, 18);
            self.rightLabel = rightLabel;
//            rightLabel.backgroundColor = [UIColor redColor];
            [cell addSubview:rightLabel];
        }
        //图片url数组
        NSMutableArray * url_arr = [NSMutableArray new];
        for (NSDictionary * dic in dictionary[@"bannerList"]) {
            NSString * bannerUrl = dic[@"bannerUrl"];
            [url_arr addObject:bannerUrl];
        }
        SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(15, 71, WIDTH-30, 229) imageURLStringsGroup:url_arr];
        cycleScrollView.tag = 200;
        cycleScrollView.layer.masksToBounds = true;
        cycleScrollView.layer.cornerRadius = 12;
        cycleScrollView.delegate = delegate;
        [cell addSubview:cycleScrollView];
        cycleScrollView.infiniteLoop = false;//无限循环
        cycleScrollView.autoScroll = true;//自动滚动
        cycleScrollView.showPageControl = false;//不显示分页控件
        
        
        //分割线
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
        [cell addSubview:spaceView];
        spaceView.frame = CGRectMake(0, 332-10, WIDTH, 10);
    }
    
    return (StorePageTableViewCell *)cell;
}








@end
