//
//  MyLocationManager.h
//  立寻
//
//  Created by mac on 2017/6/13.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyLocationManager : NSObject
//获取单例工具
+(instancetype)sharedLocationManager;
//开始定位
-(void)startLocation;


@end
