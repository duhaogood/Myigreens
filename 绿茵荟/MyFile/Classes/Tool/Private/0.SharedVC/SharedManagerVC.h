//
//  SharedManagerVC.h
//  绿茵荟
//
//  Created by mac_hao on 2017/5/18.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedManagerVC : UIViewController
@property(nonatomic,assign)id delegate;

/**
 *title -
 *img_url -
 *shared_url -
 */
@property(nonatomic,strong)NSDictionary * sharedDictionary;//分享参数
- (void)show;
- (void)removeFromSuperViewController:(UIGestureRecognizer *)gr;
@end
