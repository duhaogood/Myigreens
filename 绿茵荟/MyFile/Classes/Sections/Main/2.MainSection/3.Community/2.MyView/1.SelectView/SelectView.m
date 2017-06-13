//
//  SelectView.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/23.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SelectView.h"
#import "SDCycleScrollView.h"
@interface SelectView()
@property(nonatomic,strong)SDCycleScrollView * scrollView;
@end
@implementation SelectView
-(instancetype)initWithFrame:(CGRect)frame andDataDictionary:(NSDictionary*)dataDictionary andDelegate:(id)delegate withBannerArray:(NSArray *)bannerArray{
    if (self = [super initWithFrame:frame]) {
        self.dataSource = delegate;
        self.delegate = delegate;
//        NSLog(@"[%.0f,%.0f]",WIDTH,HEIGHT);
        UIView * headerView = [UIView new];
        headerView.frame = CGRectMake(0, 0, frame.size.width, (WIDTH-380/414.0*WIDTH)/2+218/736.0*HEIGHT + 10 + 58);
        self.tableHeaderView = headerView;
        //轮播图。380*218  5.5寸
        
        //图片url数组
        NSMutableArray * url_arr = [NSMutableArray new];
        for (NSDictionary * dic in bannerArray) {
            NSString * bannerUrl = dic[@"bannerUrl"];
            [url_arr addObject:bannerUrl];
        }
        SDCycleScrollView * cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake((WIDTH-380/414.0*WIDTH)/2, (WIDTH-380/414.0*WIDTH)/2, 380/414.0*WIDTH, 218/736.0*HEIGHT) imageURLStringsGroup:url_arr];
        self.scrollView = cycleScrollView;
        cycleScrollView.layer.masksToBounds = true;
        cycleScrollView.layer.cornerRadius = 12;
        cycleScrollView.delegate = delegate;
        [headerView addSubview:cycleScrollView];
        cycleScrollView.tag = 100;
        
        
        
        //分割线
        UIView * space_view = [UIView new];
        space_view.frame = CGRectMake(0, (WIDTH-380/414.0*WIDTH)/2+218/736.0*HEIGHT, WIDTH, 10);
        space_view.backgroundColor = [DHTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
        [headerView addSubview:space_view];
        
        float top = (WIDTH-380/414.0*WIDTH)/2+218/736.0*HEIGHT + 10;
        //每日精选
        UIImageView * title_imgV = [UIImageView new];
        title_imgV.image = [UIImage imageNamed:@"pic_frame"];
        title_imgV.frame = CGRectMake(WIDTH/2-82, top + 10, 164, 48);
        [headerView addSubview:title_imgV];
        //每日精选  -- 文字
        UILabel * title_label = [UILabel new];
        title_label.text = @"每日精选";
        title_label.textColor = [MYTOOL RGBWithRed:116 green:158 blue:59 alpha:1];
        title_label.frame = CGRectMake(WIDTH/2-60, top + 13, 120, 40);
        title_label.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:title_label];
        title_label.font = [UIFont systemFontOfSize:24];
        
        
        //去掉分割线
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.rowHeight = HEIGHT/2.5;
        
    }
    return self;
}
//设置图片数组
-(void)setImgArray:(NSArray *)arr{
    NSMutableArray * url_arr = [NSMutableArray new];
    for (NSDictionary * dic in arr) {
        NSString * bannerUrl = dic[@"bannerUrl"];
        [url_arr addObject:bannerUrl];
    }
    self.scrollView.imageURLStringsGroup = url_arr;
}

@end
