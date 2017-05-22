//
//  SelectExpressVC.h
//  绿茵荟
//
//  Created by Mac on 17/5/3.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectExpressVC : UIViewController
@property(nonatomic,strong)NSArray * expressArray;//所有可选快递数组
@property(nonatomic,assign)id delegate;//代理
@end
