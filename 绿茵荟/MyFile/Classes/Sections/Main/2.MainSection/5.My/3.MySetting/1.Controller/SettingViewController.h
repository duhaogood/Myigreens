//
//  SettingViewController.h
//  绿茵荟
//
//  Created by Mac on 17/3/31.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalMaterialViewController.h"
#import "AccountManagerViewController.h"
#import "AccountTieViewController.h"
#import "ScoreRuleViewController.h"
#import "CertificationRulesViewController.h"
#import "AboutLYHViewController.h"
#import "BusinessCooperateViewController.h"
#import "FeedbackViewController.h"


@interface SettingViewController : UIViewController
@property(nonatomic,assign)bool push_state;//推送状态
@property(nonatomic,strong)NSDictionary * member_dic;//我的页面传过来
@end
