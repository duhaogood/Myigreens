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
 type：1.商品 2.帖子 3.专题
 typeId：比如是商品详情页，传递商品id，如果是帖子，就传帖子的id
 */
@property(nonatomic,strong)NSDictionary * sharedDic;
/**
 *title -
 *img_url -
 *shared_url -
 *shareDescribe-
 */
@property(nonatomic,strong)NSDictionary * sharedDictionary;//分享参数
- (void)show;
- (void)removeFromSuperViewController:(UIGestureRecognizer *)gr;
@end
