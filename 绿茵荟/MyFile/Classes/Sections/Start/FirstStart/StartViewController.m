//
//  StartViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/4/7.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "StartViewController.h"
#import "MainVC.h"
@interface StartViewController ()
@property(nonatomic,strong)UIView * back_view;//放置图片view
@property(nonatomic,strong)NSMutableArray * pra_img_array;//进度条图片
@property(nonatomic,strong)UIButton * start_btn;//开始按钮
@end

@implementation StartViewController
{
    float touch_x;//第一次点击x坐标
    BOOL is_move;//已经开始动
    int current_img_index;//当前显示的图片序号
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIView * back_view = [UIView new];
    back_view.frame = CGRectMake(0, 0, WIDTH*3, HEIGHT);
    [self.view addSubview:back_view];
    self.back_view = back_view;
    //加图片
    for (int i = 0; i < 3; i ++) {
        UIImageView * imgV = [UIImageView new];
        imgV.frame = CGRectMake(WIDTH*i, 0, WIDTH, HEIGHT);
        imgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"start_img_%d.jpg",i+1]];
        [back_view addSubview:imgV];
    }
    current_img_index = 0;
    //进度条 guide_dot_nor_gray guide_dot_sel
    self.pra_img_array = [NSMutableArray new];
    for (int i = 0; i < 3; i ++) {
        UIImageView * imgV = [UIImageView new];
        imgV.frame = CGRectMake(WIDTH/2 - 44.5 + i * 28, HEIGHT - 30, 23, 2);
        imgV.image = [UIImage imageNamed:@"guide_dot_nor_gray"];
        if (i == 0) {
            imgV.image = [UIImage imageNamed:@"guide_dot_sel"];
        }
        [self.view addSubview:imgV];
        [self.pra_img_array addObject:imgV];
    }
    //立即体验按钮
    UIButton * btn = [UIButton new];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_guide_nor"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"btn_guide_pre"] forState:UIControlStateHighlighted];
    btn.frame = CGRectMake(WIDTH/2 - 100, HEIGHT - 78, 200, 50);
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(button_callBack) forControlEvents:UIControlEventTouchUpInside];
    self.start_btn = btn;
    btn.hidden = true;
    [btn setTitle:@"立即体验" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:20];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    

}
//立即体验按钮
-(void)button_callBack{
    
    
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"isFirstStarThisApp"];
    MainVC * main = [MainVC new];
    [[UIApplication sharedApplication].delegate window].rootViewController = main;
}
//刷新进度条
-(void)refresh{
//    NSLog(@"当前显示:%d",current_img_index);
    for (int i = 0; i < 3; i ++) {
        UIImageView * imgV = self.pra_img_array[i];
        imgV.image = [UIImage imageNamed:@"guide_dot_nor_gray"];
        if (i == current_img_index) {
            imgV.image = [UIImage imageNamed:@"guide_dot_sel"];
        }
    }
    if (current_img_index == 2) {
        self.start_btn.hidden = false;
    }else{
        self.start_btn.hidden = true;
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    touch_x = point.x;
    is_move = true;
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!is_move) {
        return;
    }
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
//    NSLog(@"最后一次点击坐标:%.2f",point.x);
    float move_x = point.x - touch_x;
    if (fabsf(move_x) > WIDTH / 4 ) {
        is_move = false;
        if (move_x > 0) {
            //向右移动
            [self moveToRight];
        }else{
            //向左移动
            [self moveToLeft];
        }
    }
}
//向左移动
-(void)moveToLeft{
    if (self.back_view.frame.origin.x > -WIDTH * 2) {
        current_img_index ++;
        [self refresh];
        [UIView animateWithDuration:0.3 animations:^{
            self.back_view.frame = CGRectMake(self.back_view.frame.origin.x - WIDTH, 0, WIDTH, HEIGHT);
        }];
    }
}
//向右移动
-(void)moveToRight{
    if (self.back_view.frame.origin.x < 0) {
        current_img_index --;
        [self refresh];
        [UIView animateWithDuration:0.3 animations:^{
            self.back_view.frame = CGRectMake(self.back_view.frame.origin.x + WIDTH, 0, WIDTH, HEIGHT);
        }];
    }
}

@end
