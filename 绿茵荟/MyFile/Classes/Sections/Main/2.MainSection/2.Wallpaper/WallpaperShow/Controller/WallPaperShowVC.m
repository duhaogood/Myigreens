//
//  WallPaperShowVC.m
//  绿茵荟
//
//  Created by Mac on 17/6/19.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "WallPaperShowVC.h"

@interface WallPaperShowVC ()
@property(nonatomic,strong)UIImageView * up_view;
@property(nonatomic,strong)UIImageView * down_view;
@property(nonatomic,strong)UILabel * nameLabel;


@property(nonatomic,strong)UIImageView * left_imgV;
@property(nonatomic,strong)UIImageView * right_imgV;
@property(nonatomic,strong)UIImageView * show_imgV;
@end

@implementation WallPaperShowVC

{
    BOOL isHidden;
    NSInteger current_section;//当前第几组
    NSInteger current_row;//当前组的第几张
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = true;
    current_section = self.current_index/10;
    current_row = self.current_index%10;
    UIImageView * imgV = [UIImageView new];
    imgV.frame = self.view.bounds;
    [imgV sd_setImageWithURL:[NSURL URLWithString:self.wallpaperList[_current_index/10][@"url"][_current_index%10][@"normalUrl"]]];
    [self.view addSubview:imgV];
    self.show_imgV = imgV;
    imgV.userInteractionEnabled = true;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showOrHidden:)];
    tapGesture.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tapGesture];
    //滑动事件-下一张
    UISwipeGestureRecognizer * swipeGest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextImageView:)];
    swipeGest.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGest.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGest];
    //滑动事件-上一张
    UISwipeGestureRecognizer * swipeGest_up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showUpImageView:)];
    swipeGest_up.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGest_up.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipeGest_up];
    //左图片
    self.left_imgV = [UIImageView new];
    self.left_imgV.frame = CGRectMake(-WIDTH, 0, WIDTH, HEIGHT);
    [self.view addSubview:self.left_imgV];
//    self.left_imgV.userInteractionEnabled = true;
//    [self.left_imgV addGestureRecognizer:tapGesture];
//    [self.left_imgV addGestureRecognizer:swipeGest];
//    [self.left_imgV addGestureRecognizer:swipeGest_up];
    //右图片
    self.right_imgV = [UIImageView new];
    self.right_imgV.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
    [self.view addSubview:self.right_imgV];
//    self.right_imgV.userInteractionEnabled = true;
//    [self.right_imgV addGestureRecognizer:tapGesture];
//    [self.right_imgV addGestureRecognizer:swipeGest];
//    [self.right_imgV addGestureRecognizer:swipeGest_up];
    
    
    
    //显示控制界面
    [self showView];
}

//查看上一张
-(void)showUpImageView:(UISwipeGestureRecognizer *)tapBgRecognizer{
    if (!(current_row == 0 && current_section == 0)) {//可以显示上一张[imgV sd_setImageWithURL:[NSURL
        current_row -- ;
        if (current_row < 0) {//当前组结束，上一组
            current_section -- ;
            NSArray * array = self.wallpaperList[current_section][@"url"];
            current_row = array.count - 1;
        }
        [self.left_imgV sd_setImageWithURL:[NSURL URLWithString:self.wallpaperList[current_section][@"url"][current_row][@"normalUrl"]]];
        [UIView animateWithDuration:0.3 animations:^{
            self.show_imgV.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
            self.left_imgV.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        } completion:^(BOOL finished) {
            UIImageView * imgV = self.show_imgV;
            self.show_imgV = self.left_imgV;
            self.left_imgV = self.right_imgV;
            self.left_imgV.frame = CGRectMake(-WIDTH, 0, WIDTH, HEIGHT);
            self.right_imgV = imgV;
            
            self.nameLabel.text = self.wallpaperList[current_section][@"name"];
        }];
    }
}
//查看下一张
-(void)showNextImageView:(UISwipeGestureRecognizer *)tapBgRecognizer{
    NSArray * arr = self.wallpaperList[current_section][@"url"];
    if (!(current_section == self.wallpaperList.count - 1 && current_row == arr.count - 1 )) {//可以显示上一张[imgV sd_setImageWithURL:[NSURL
        current_row ++ ;
        if (current_row >= arr.count) {
            current_row = 0;
            current_section ++;
        }
        [self.right_imgV sd_setImageWithURL:[NSURL URLWithString:self.wallpaperList[current_section][@"url"][current_row][@"normalUrl"]]];
        [UIView animateWithDuration:0.3 animations:^{
            self.show_imgV.frame = CGRectMake(-WIDTH, 0, WIDTH, HEIGHT);
            self.right_imgV.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        } completion:^(BOOL finished) {
            UIImageView * imgV = self.show_imgV;
            self.show_imgV = self.right_imgV;
            self.right_imgV = self.left_imgV;
            self.right_imgV.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
            self.left_imgV = imgV;
            self.nameLabel.text = self.wallpaperList[current_section][@"name"];
        }];
    }
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
        name_label.text = self.wallpaperList[_current_index/10][@"name"];
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
    UIImageWriteToSavedPhotosAlbum(self.show_imgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"图片保存成功" duration:1];
    }else{
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error] duration:2];
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
        [self.up_view removeFromSuperview];
        [self.down_view removeFromSuperview];
    
    [self.navigationController popViewControllerAnimated:false];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
