//
//  WallpaperShowViewController.m
//  绿茵荟
//
//  Created by Mac on 17/3/23.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "WallpaperShowViewController.h"

@interface WallpaperShowViewController ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIImageView * up_view;
@property(nonatomic,strong)UIImageView * down_view;
@property(nonatomic,strong)UILabel * nameLabel;
@property(nonatomic,strong)UIScrollView * scrollView;//图片查看界面
@property(nonatomic,strong)NSMutableArray * imgV_array;//图片View数组
@end

@implementation WallpaperShowViewController
{
    BOOL isHidden;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.name = self.img_array[self.current_index/4][@"name"];
    self.img_array = self.wallpaperList;
//    [self loadFalseArray];
    isHidden = NO;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHidden:)];
    tapGesture.numberOfTapsRequired=1;
    
    
/*UIScrollView*/
    UIScrollView * scrollView = [UIScrollView new];
    self.scrollView = scrollView;
    [scrollView addGestureRecognizer:tapGesture];
    [[[UIApplication sharedApplication] keyWindow] addSubview:scrollView];
    scrollView.frame = [UIScreen mainScreen].bounds;
    scrollView.contentSize = CGSizeMake(self.img_array.count * WIDTH * 4, 0);
    self.scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.delegate = self;
    scrollView.showsVerticalScrollIndicator = FALSE;
    scrollView.showsHorizontalScrollIndicator = FALSE;
    self.imgV_array = [NSMutableArray new];
    for(int i = 0;i < self.img_array.count; i ++){
        for (int j = 0; j < 4; j ++) {
            UIImageView * imgV = [UIImageView new];
            imgV.frame = CGRectMake((i*4+j)*WIDTH, 0, WIDTH, HEIGHT);
            [imgV sd_setImageWithURL:[NSURL URLWithString:self.img_array[i][@"url"][j][@"normalUrl"]]];
            [scrollView addSubview:imgV];
            [self.imgV_array addObject:imgV];
        }
    }
    scrollView.contentOffset = CGPointMake(_current_index * WIDTH, 0);
    
    //显示控制界面
    [self showView];
    [self scrollViewDidEndDragging:self.scrollView willDecelerate:YES];
}
//显示返回和下载按钮
-(void)showView{
    if (!self.up_view) {
        self.up_view = [UIImageView new];
        self.up_view.image = [UIImage imageNamed:@"pic_bg_top"];
        self.up_view.frame = CGRectMake(0, 0, WIDTH, HEIGHT/6);
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.up_view];
        [self.up_view setUserInteractionEnabled:YES];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHidden:)];
        tapGesture.numberOfTapsRequired=1;
        [self.up_view addGestureRecognizer:tapGesture];
        //名字
        UILabel * name_label = [UILabel new];
        name_label.frame = CGRectMake(WIDTH/2-50, 40, 100, 30);
        name_label.textAlignment = NSTextAlignmentCenter;
        name_label.text = self.name;
        self.nameLabel = name_label;
        [self.up_view addSubview:name_label];
        name_label.textColor = [UIColor whiteColor];
        name_label.font = [UIFont systemFontOfSize:20];
        //增加返回按钮
        UIImageView * back_img = [UIImageView new];
        back_img.frame = CGRectMake(10, 40, 30, 30);
        [self.up_view addSubview:back_img];
        back_img.image = [UIImage imageNamed:@"nav_back"];
        
        
        
        
        self.down_view = [UIImageView new];
        self.down_view.image = [UIImage imageNamed:@"pic_bg_bottom"];
        self.down_view.frame = CGRectMake(0, HEIGHT - HEIGHT/6, WIDTH, HEIGHT/6);
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.down_view];
        [self.down_view setUserInteractionEnabled:YES];
        UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHidden:)];
        tapGesture2.numberOfTapsRequired=1;
        [self.down_view addGestureRecognizer:tapGesture2];
        //下载按钮
        float r_btn = 57;
        UIButton * down_btn = [UIButton new];
        [down_btn setImage:[UIImage imageNamed:@"btn_download"] forState:UIControlStateNormal];
        down_btn.frame = CGRectMake(WIDTH-r_btn-20, 0, r_btn, r_btn);
        [self.down_view addSubview:down_btn];
        [down_btn addTarget:self action:@selector(downloadImage) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [UIView animateWithDuration:0.4 animations:^{
            self.down_view.frame = CGRectMake(0, HEIGHT/6*5, WIDTH, HEIGHT/6);
            self.up_view.frame = CGRectMake(0, 0, WIDTH, HEIGHT/6);
        } completion:nil];
    }
}
//隐藏返回和下载按钮
-(void)hiddenView{
    [UIView animateWithDuration:0.4 animations:^{
        self.down_view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT/6);
        self.up_view.frame = CGRectMake(0, -HEIGHT/6, WIDTH, HEIGHT/6);
    } completion:nil];
}
//返回上一个界面
-(void)back{
    if (self.scrollView) {
        [self.up_view removeFromSuperview];
        [self.down_view removeFromSuperview];
        [self.scrollView removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 用户点击事件
//显示或者隐藏
-(void)showOrHidden:(UITapGestureRecognizer *)tap{
    if (isHidden) {
        isHidden = NO;
        //显示
        [self showView];
    }else{
        UIImageView * imgV = (UIImageView *)tap.view;
        if ([imgV isEqual:self.up_view]) {
            CGPoint point = [tap locationInView:self.up_view];
            if (point.x < WIDTH / 4.0) {
                [self back];
                return;
            }
            
        }
        isHidden = YES;
        //隐藏
        [self hiddenView];
        
    }
}
//下载图片事件
-(void)downloadImage{
    UIImageWriteToSavedPhotosAlbum(self.image_show, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"图片保存成功" duration:1];
    }else{
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error] duration:2];
    }
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    //手指离开，停止滑动
    [scrollView setContentOffset:scrollView.contentOffset animated:NO];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //scrollview偏移量
    float x = scrollView.contentOffset.x;
    //显示的图片的序号
    int temp = x / WIDTH;
    int index = x - temp * WIDTH > WIDTH / 2 ? temp + 1 : temp;
    if (index < 0) {
        index = 0;
    }
    if (index > self.imgV_array.count - 1) {
        index  = (int)self.imgV_array.count - 1;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = CGPointMake((index)*WIDTH, 0);
    }];
    
    self.current_index = index;
    self.name = self.img_array[self.current_index/4][@"name"];
    self.nameLabel.text = self.name;
    self.image_show = (UIImage *)[self.imgV_array[self.current_index] image];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *views = [app.window.rootViewController.view subviews];
    for(id v in views){
        if([v isKindOfClass:[UITabBar class]]){
            [(UITabBar *)v setHidden:YES];
        }
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *views = [app.window.rootViewController.view subviews];
    for(id v in views){
        if([v isKindOfClass:[UITabBar class]]){
            [(UITabBar *)v setHidden:NO];
        }
    }
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
