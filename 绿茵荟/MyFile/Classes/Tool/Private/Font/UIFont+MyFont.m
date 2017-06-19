//
//  MyFont.m
//  绿茵荟
//
//  Created by Mac on 17/6/16.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "UIFont+MyFont.h"

@implementation UIFont(MyFont)


+ (UIFont *)systemFontOfSize:(CGFloat)fontSize{
    return [UIFont fontWithName:@"NotoSansHans-Regular" size:fontSize];
}
@end
