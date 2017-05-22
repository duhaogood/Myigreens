//
//  MyIssueTableView.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/31.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "MyIssueTableView.h"

@implementation MyIssueTableView
-(instancetype)init{
    if (self = [super init]) {
//        self.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    }
    return self;
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    
    [self.subviews enumerateObjectsUsingBlock:^( id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[UIImageView class]]) {
            
            UIImageView * imageView = [[UIImageView alloc] init];
            
            imageView = obj;
            
            imageView.backgroundColor = [MYTOOL RGBWithRed:156 green:201 blue:103 alpha:1];
            imageView.tintColor = [UIColor clearColor];
        }
        
    }];
    
    UIView * view = [self.subviews lastObject];
    view.layer.masksToBounds = true;
    view.layer.cornerRadius = 6/375.0*WIDTH/2;
    CGRect frame = view.frame;
    
    frame.size.width = 6/375.0*WIDTH;
    
    frame.origin.x = 0;
    
    view.frame = frame;
    
}

@end
