//
//  LoginViewController.h
//  绿茵荟
//
//  Created by Mac on 17/3/30.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainVC.h"
@interface LoginViewController : UIViewController
@property(nonatomic,assign)id delegate;
@property(nonatomic,assign)bool donotUpdate;//不要更新
@property(nonatomic,assign)bool fromExitLogin;//退出登录进入
@end
