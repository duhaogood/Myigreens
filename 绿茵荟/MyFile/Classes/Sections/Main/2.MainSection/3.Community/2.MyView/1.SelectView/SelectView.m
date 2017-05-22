//
//  SelectView.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/23.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SelectView.h"

@implementation SelectView
-(instancetype)initWithFrame:(CGRect)frame andDataDictionary:(NSDictionary*)dataDictionary andDelegate:(id)delegate{
    if (self = [super initWithFrame:frame]) {
        self.dataSource = delegate;
        self.delegate = delegate;
//        NSLog(@"[%.0f,%.0f]",WIDTH,HEIGHT);
        UIView * headerView = [UIView new];
        headerView.frame = CGRectMake(0, 0, frame.size.width, (WIDTH-380/414.0*WIDTH)/2+218/736.0*HEIGHT + 10 + 58);
        self.tableHeaderView = headerView;
//        headerView.backgroundColor = [UIColor redColor];
        //https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490283351788&di=556af2843556c417fc3f5d141c0fe492&imgtype=0&src=http%3A%2F%2Ff.namibox.com%2Fuser%2F1981741%2Fsns%2F20151210_0.jpg
        //https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490283352560&di=16f549fc354455fdd33cd80aaf3d8c63&imgtype=0&src=http%3A%2F%2Fpic31.nipic.com%2F20130710%2F3350339_140646309128_2.jpg
        //https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490283352560&di=184d0485895d1ed9827de6c8c1a196e1&imgtype=0&src=http%3A%2F%2Fpic45.nipic.com%2F20140810%2F9448607_092358530000_2.jpg
        //轮播图。380*218  5.5寸
        UIImageView * imgView = [UIImageView new];
        imgView.frame = CGRectMake((WIDTH-380/414.0*WIDTH)/2, (WIDTH-380/414.0*WIDTH)/2, 380/414.0*WIDTH, 218/736.0*HEIGHT);
//        imgView.backgroundColor = [UIColor greenColor];
        [headerView addSubview:imgView];
        imgView.layer.masksToBounds = true;
        imgView.layer.cornerRadius = 10;
        [imgView sd_setImageWithURL:[NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1490283352560&di=16f549fc354455fdd33cd80aaf3d8c63&imgtype=0&src=http%3A%2F%2Fpic31.nipic.com%2F20130710%2F3350339_140646309128_2.jpg"]];
        
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
        title_label.textColor = [UIColor greenColor];
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


@end
