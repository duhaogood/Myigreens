//
//  MyLocationManager.m
//  立寻
//
//  Created by mac on 2017/6/13.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "MyLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static id instance;
@interface MyLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager * locationManager;



@end
@implementation MyLocationManager
//开始定位
-(void)startLocation{
    if([ CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [SVProgressHUD showErrorWithStatus:@"请开启定位" duration:2];
        return;
    }
    if([CLLocationManager locationServicesEnabled])
    {
        // 启动位置更新
        // 开启位置更新需要与服务器进行轮询所以会比较耗电，在不需要时用stopUpdatingLocation方法关闭;
        _locationManager = [[CLLocationManager alloc] init];
        //设置定位的精度
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        _locationManager.distanceFilter = 10.0f;
        _locationManager.delegate = self;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0)
        {
            [_locationManager requestAlwaysAuthorization];
            [_locationManager requestWhenInUseAuthorization];
        }
        //开始实时定位
        [_locationManager startUpdatingLocation];
    }else {
        [SVProgressHUD showErrorWithStatus:@"请开启定位" duration:2];
    }
}
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopUpdatingLocation];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
        // 获取当前所在的城市名
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        //根据经纬度反向地理编译出地址信息
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error)
         {
             if (array.count > 0)
             {
                 CLPlacemark *placemark = [array objectAtIndex:0];
                 //获取城市
                 NSString *city = placemark.locality;
                 if (!city) {
                     //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                     city = placemark.administrativeArea;
                 }
                 NSDictionary * locationDic = @{
                                                @"city":city,
                                                @"address":placemark.name
                                                };
                 [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_UPDATELOCATION_SUCCESS object:locationDic];
             }
             else if (error == nil && [array count] == 0)
             {
                 [SVProgressHUD showErrorWithStatus:@"未定位到位置" duration:2];
                 [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_UPDATELOCATION_FAILED object:@{@"msg":@"未定位到位置"}];
             }
             else if (error != nil)
             {
                 [SVProgressHUD showErrorWithStatus:@"定位出错" duration:2];
                 [MYCENTER_NOTIFICATION postNotificationName:NOTIFICATION_UPDATELOCATION_FAILED object:@{@"msg":@"定位出错"}];
             }
         }];
    
    
}











+(instancetype)alloc{
    if (instance == nil) {
        instance = [[super alloc] init];
    }
    return instance;
}
-(instancetype)init{
    if (instance == nil) {
        instance = [super init];
    }
    return instance;
}
+(instancetype)sharedLocationManager{
    if (instance == nil) {
        instance = [self alloc];
    }
    return instance;
}
@end
