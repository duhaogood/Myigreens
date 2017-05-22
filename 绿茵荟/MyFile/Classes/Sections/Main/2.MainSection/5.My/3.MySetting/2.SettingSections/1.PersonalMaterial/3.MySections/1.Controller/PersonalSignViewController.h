//
//  PersonalSignViewController.h
//  绿茵荟
//
//  Created by mac_hao on 2017/4/7.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalSignViewController : UIViewController
@property(nonatomic,assign)id delegate;//上个界面传过来的代理
@property(nonatomic,copy)NSString * content;//文本要显示的内容
@end
