//
//  Cell_menu_icon_Flowers.m
//  绿茵荟
//
//  Created by Mac on 17/3/24.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "Cell_menu_icon_Flowers.h"

@implementation Cell_menu_icon_Flowers

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
        self.textLabel.text = @"植物";
    }
    return self;
}
@end
