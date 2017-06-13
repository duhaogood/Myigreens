//
//  WallpaperShowViewController.h
//  绿茵荟
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallpaperShowViewController : UIViewController
@property(nonatomic,assign)UIImage * image_show;//要显示的image
@property(nonatomic,copy)NSString * name;
@property(nonatomic,strong)NSArray * img_array;//上个页面传过来的数组
@property(nonatomic,assign)NSInteger current_index;//显示的图片在数组中的序号


@property(nonatomic,strong)NSArray * wallpaperList;//上个页面加载界面的数据
@end
