//
//  SpecialVC.m
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "SpecialVC.h"

@interface SpecialVC ()
@property(nonatomic,strong)UIScrollView * scrollView;
@property(nonatomic,strong)NSMutableArray * data_array;
@end

@implementation SpecialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"[%.0f]",self.view.frame.size.height);
    
    self.data_array = [NSMutableArray new];
    for(int i = 0;i < 5;i++){
        [self.data_array addObject:@"123321"];
    }
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    UIScrollView * scrollView = [UIScrollView new];
    scrollView.frame = CGRectMake(0, 0, WIDTH, HEIGHT - 64-49);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    
    
}
//重新加载scrollView
-(void)updateScrollView{
    NSInteger count = self.data_array.count;
    
    
    
}


@end
