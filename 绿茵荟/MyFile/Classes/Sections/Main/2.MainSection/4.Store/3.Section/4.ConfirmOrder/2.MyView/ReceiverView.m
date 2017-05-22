//
//  ReceiverView.m
//  绿茵荟
//
//  Created by Mac on 17/4/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ReceiverView.h"
@interface ReceiverView()
@property(nonatomic,strong)UILabel * nameLabel;
@property(nonatomic,strong)UILabel * telLabel;
@property(nonatomic,strong)UILabel * addressLabel;
@property(nonatomic,strong)UILabel * stateLabel;//提示
@end
@implementation ReceiverView


-(instancetype)initWithReceiverInfo:(NSDictionary *)info andFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //获取3个信息
        NSString * name = info[@"name"];
        NSString * tel = info[@"mobile"];
        NSString * address = info[@"address"];
        //名字
        {
            UILabel * label = [UILabel new];
            label.frame = CGRectMake(14, 18, WIDTH/2-14, 15);
            label.font = [UIFont systemFontOfSize:15];
            self.nameLabel = label;
            [self addSubview:label];
            if (name) {
                label.text = [NSString stringWithFormat:@"收货人：%@",name];
            }
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        }
        //电话
        {
            UILabel * label = [UILabel new];
            if (tel) {
                label.text = tel;
            }
            label.font = [UIFont systemFontOfSize:15];
            label.frame = CGRectMake(WIDTH/2, 18, WIDTH/2-35, 15);
            label.textAlignment = NSTextAlignmentRight;
            self.telLabel = label;
            [self addSubview:label];
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        }
        //地址
        {
            UILabel * label = [UILabel new];
            if (address) {
                label.text = [NSString stringWithFormat:@"收货地址：%@",address];
            }
            label.font = [UIFont systemFontOfSize:15];
            label.numberOfLines = 0;
            label.frame = CGRectMake(15, 43, WIDTH-40-14, 36);
            self.addressLabel = label;
            [self addSubview:label];
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        }
        if (info.allKeys.count <= 0) {//没有地址信息提示用户选择地址
            UILabel * label = [UILabel new];
            self.stateLabel = label;
            label.text = @"请选择地址";
            label.frame = CGRectMake(15, 35.5, WIDTH/2, 20);
            [self addSubview:label];
        }
        //右侧图标
        {
            UIImageView * imgV = [UIImageView new];
            imgV.frame = CGRectMake(WIDTH-30, frame.size.height/2-15, 30, 30);
            imgV.image = [UIImage imageNamed:@"arrow_right_store"];
            [self addSubview:imgV];
        }
    }
    return self;
}
-(void)updateReceiverInfo:(NSDictionary *)info{
    if (info) {
        self.stateLabel.text = @"";
    }
    //获取3个信息
    NSString * name = info[@"name"];
    NSString * tel = info[@"mobile"];
    NSString * address = info[@"address"];
    self.nameLabel.text = [NSString stringWithFormat:@"收货人：%@",name];
    self.telLabel.text = tel;
    self.addressLabel.text = [NSString stringWithFormat:@"收货地址：%@",address];
}
@end
