//
//  Cell_menu_icon_brush.m
//  绿茵荟
//
//  Created by Mac on 17/3/24.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "Cell_menu_icon_brush.h"

@implementation Cell_menu_icon_brush

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithFrame:(CGRect)frame{
    
    
    //@"最新",@"花艺",@"植物",@"家居",@"婚嫁",@"情感",@"未知"
    //menu_icon_brush,menu_icon_cut,menu_icon_Flowers,menu_icon_door,
    //menu_icon_wine,menu_icon_tv,menu_icon_box
    if (self = [super initWithFrame:frame]) {
        self.textLabel.text = @"最新";
        
        //下边小图标及数字
        {
            float top = frame.size.height * 0.9;
            //下边小图标  icon_praise
            UIImageView * icon1 = [UIImageView new];
            icon1.image = [UIImage imageNamed:@"icon_praise"];
            icon1.frame = CGRectMake(WIDTH/6-30, top, 30, 30);
            [self addSubview:icon1];
            //数字
            UILabel * num_label1 = [UILabel new];
            num_label1.text = @"456";
            num_label1.frame = CGRectMake(WIDTH/6, top+5, WIDTH/6, 20);
            num_label1.font = [UIFont systemFontOfSize:12];
            //        num_label1.backgroundColor = [UIColor greenColor];
            [self addSubview:num_label1];
            
            //下边小图标  icon_message
            UIImageView * icon2 = [UIImageView new];
            icon2.image = [UIImage imageNamed:@"icon_message"];
            icon2.frame = CGRectMake(WIDTH/2-30, top, 30, 30);
            [self addSubview:icon2];
            //数字
            UILabel * num_label2 = [UILabel new];
            num_label2.text = @"123";
            num_label2.frame = CGRectMake(WIDTH/2-5, top+5, WIDTH/6-20, 20);
            num_label2.font = [UIFont systemFontOfSize:12];
            //        num_label2.backgroundColor = [UIColor greenColor];
            [self addSubview:num_label2];
            
            //下边小图标  icon_message
            UIImageView * icon3 = [UIImageView new];
            icon3.image = [UIImage imageNamed:@"icon_share"];
            icon3.frame = CGRectMake(WIDTH*4/6, top, 30, 30);
            [self addSubview:icon3];
            //数字
            UILabel * num_label3 = [UILabel new];
            num_label3.text = @"分享";
            num_label3.frame = CGRectMake(WIDTH*4/6+25, top+5, 40, 20);
            num_label3.font = [UIFont systemFontOfSize:12];
            [self addSubview:num_label3];
        }
        
        
        //分割线
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [DHTOOL RGBWithRed:227 green:227 blue:227 alpha:1];
        spaceView.frame = CGRectMake(20, frame.size.height-1, WIDTH-40, 1);
        [self addSubview:spaceView];
        
    }
    return self;
}
@end
