//
//  CommunityVC.h
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//  社区

#import <UIKit/UIKit.h>
#import "Cell_menu_icon_tv.h"
#import "Cell_menu_icon_box.h"
#import "Cell_menu_icon_cut.h"
#import "Cell_menu_icon_door.h"
#import "Cell_menu_icon_wine.h"
#import "Cell_menu_icon_brush.h"
#import "Cell_menu_icon_Flowers.h"
#import "PostInfoViewController.h"

@interface CommunityVC : UIViewController
@property(nonatomic,assign)bool donotUpdate;//不要更新


//更新数据
-(void)updateData;


@end
