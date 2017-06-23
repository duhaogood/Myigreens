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
    //NotoSansHans-Regular
    if (HEIGHT == 568) {
        fontSize -= 2;
    }
    
    UIFont * font = [UIFont fontWithName:@"FZLANTY_XIJW--GB1-0" size:fontSize];
    
    return font;
}
//加醋的字体
+ (UIFont *)titleFontOfSize:(CGFloat)fontSize{
    if (HEIGHT == 568) {
        fontSize -= 2;
    }
    UIFont * font = [UIFont fontWithName:@"FZLANTY_ZHUNJW--GB1-0" size:fontSize];
    
    return font;
}
/*
 .SFUIDisplay
 .SFUIDisplay-Black
 .SFUIDisplay-Light
 */
@end
