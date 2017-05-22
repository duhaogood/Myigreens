//
//  MyView.m
//  绿茵荟
//
//  Created by Mac on 17/3/21.
//  Copyright © 2017年 江苏野马软件. All rights reserved.
//

#import "MyView.h"

@implementation MyView

-(instancetype)initWithFrame:(CGRect)frame andDelegate:(id)delegate{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = delegate;
        self.dataSource = delegate;
    }
    //不显示分割线
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    return self;
}





@end
