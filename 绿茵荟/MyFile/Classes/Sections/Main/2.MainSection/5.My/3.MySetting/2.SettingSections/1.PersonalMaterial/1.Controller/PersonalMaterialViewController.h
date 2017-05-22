//
//  PersonalMaterialViewController.h
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
@interface PersonalMaterialViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,strong)NSMutableDictionary * personal_dictionary;//个人信息
@property(nonatomic,assign)id delegate;
@property(nonatomic,strong)NSDictionary * member_dic;//上个页面传过来的值


-(void)personalSign_callBack:(NSString *)content;
@end
