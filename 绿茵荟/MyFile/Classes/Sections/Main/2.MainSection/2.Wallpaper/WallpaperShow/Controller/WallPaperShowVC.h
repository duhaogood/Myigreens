//
//  WallPaperShowVC.h
//  绿茵荟
//
//  Created by Mac on 17/6/19.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WallPaperShowVC : UIViewController

@property(nonatomic,assign)NSInteger current_index;//显示的图片在数组中的序号


@property(nonatomic,strong)NSArray * wallpaperList;//上个页面加载界面的数据
@end
