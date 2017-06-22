//
//  WallpaperVC.m
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "WallpaperVC.h"
#import "WallpaperShowViewController.h"
#import "WallPaperShowVC.h"
@interface WallpaperVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray * data_array;
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIScrollView * scrollView;
@end

@implementation WallpaperVC
{
    float top_scrollView;
    int count;
    int current_page;//当前网络请求分页的页数
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //navigationbar背景图
    UIImage * nav_bg = [UIImage imageNamed:@"nav_bg"];
    UIImageView * nav_bg_view = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, WIDTH, 64)];
    nav_bg_view.image = nav_bg;
    [self.navigationController.navigationBar insertSubview:nav_bg_view atIndex:0];
    //加载图片资源
    self.data_array = [NSMutableArray new];
    //加载主界面
    [self loadMainView];
    self.img_array = [NSMutableArray new];
    current_page = 1;
    [self refresh];
}
//表示图
-(void)loadMainView{
    UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    //去掉分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //标题图片
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, (WIDTH-15*2)*48.0/347+36)];
    UIImageView * title_img_view = [UIImageView new];
    title_img_view.image = [UIImage imageNamed:@"pic_word"];
    title_img_view.frame = CGRectMake(15, 18, WIDTH-15*2, (WIDTH-15*2)*48.0/347);
    [headerView addSubview:title_img_view];
    tableView.tableHeaderView = headerView;
    
    count = 0;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        count = 0;
        [self refresh];
        // 结束刷新
        [tableView.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMore];
        
        [tableView.mj_footer endRefreshing];
    }];
    
    
}
//网络获取数据
-(void)getImgsFromNet:(void(^)(NSArray * array))img_back{
    [MYNETWORKING getWithInterfaceName:@"/wallpaper/getWallpaper.intf" andDictionary:@{@"pageNo":[NSString stringWithFormat:@"%d",current_page]} andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        BOOL flag = [back_dic[@"code"] boolValue];
        if (!flag) {
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
            return;
        }
        NSArray * array = back_dic[@"wallpaperList"];
        img_back(array);
    }];
}
-(void)refresh{
//    NSLog(@"下啦");
    //将数据重制为第一页
    current_page = 1;
    [self getImgsFromNet:^(NSArray *array) {
//        NSLog(@"array:%@",array);
        self.img_array = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
    }];
}
-(void)loadMore
{
//    NSLog(@"上拉");
    current_page ++;
    [self getImgsFromNet:^(NSArray *array) {
        if (array.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"已经到底了" duration:0.5];
            current_page --;
        }else{
            [self.img_array addObjectsFromArray:array];
            [self.tableView reloadData];
        }
    }];
}






#pragma mark - UITableViewDelegate,UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 303.0*WIDTH/414.0;
    }else{
        return (185*WIDTH/414.0)*271.0/185 * 2 + 10*WIDTH/414.0 * 3;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.img_array.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 8;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * img_dic = self.img_array[indexPath.section];
    NSArray * img_url_array = img_dic[@"url"];
    UITableViewCell * cell = [UITableViewCell new];
    float space = 10*WIDTH/414.0;
    float left_img = space;
    float top_img = space;
    if (indexPath.section == 0) {
        //第一个图片
        if (img_url_array.count >= 1){
            UIImageView * imgView = [UIImageView new];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
            imgView.layer.masksToBounds = true;
//            imgView.layer.cornerRadius = 10;
            imgView.frame = CGRectMake(left_img, top_img, 185*WIDTH/414.0, (185*WIDTH/414.0)*271.0/185);
            [cell addSubview:imgView];
            left_img += 185*WIDTH/414.0 + space;
            NSString * smallUrl = img_url_array[0][@"smallUrl"];
            if (smallUrl && smallUrl.length) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:smallUrl]];
            }
            [imgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigWallpaper:)];
            tapGesture.numberOfTapsRequired=1;
            [imgView addGestureRecognizer:tapGesture];
            imgView.tag = indexPath.section * 10 + 0;
        }
        //第二个图片
        if (img_url_array.count >= 2){
            UIImageView * imgView = [UIImageView new];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
            imgView.layer.masksToBounds = true;
//            imgView.layer.cornerRadius = 10;
            imgView.frame = CGRectMake(left_img, top_img, 185*WIDTH/414.0, (185*WIDTH/414.0)*128.0/185.0);
            [cell addSubview:imgView];
            top_img += (185*WIDTH/414.0)*128.0/185.0 + space;
            NSString * smallUrl = img_url_array[1][@"smallUrl"];
            if (smallUrl && smallUrl.length) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:smallUrl]];
            }
            [imgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigWallpaper:)];
            tapGesture.numberOfTapsRequired=1;
            [imgView addGestureRecognizer:tapGesture];
            imgView.tag = indexPath.section * 10 + 1;
        }
        //第三个图片
        if (img_url_array.count >= 3){
            UIImageView * imgView = [UIImageView new];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
            imgView.layer.masksToBounds = true;
//            imgView.layer.cornerRadius = 10;
            imgView.frame = CGRectMake(left_img, top_img, (182*WIDTH/414.0)*127.0/185.0/236.0*162, (185*WIDTH/414.0)*128.0/185.0);
            [cell addSubview:imgView];
            left_img += (182*WIDTH/414.0)*127.0/185.0/236.0*162 + space;
            NSString * smallUrl = img_url_array[2][@"smallUrl"];
            if (smallUrl && smallUrl.length) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:smallUrl]];
            }
            [imgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigWallpaper:)];
            tapGesture.numberOfTapsRequired=1;
            [imgView addGestureRecognizer:tapGesture];
            imgView.tag = indexPath.section * 10 + 2;
        }
        //第四个图片
        if (img_url_array.count >= 4){
            UIImageView * imgView = [UIImageView new];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
            imgView.layer.masksToBounds = true;
//            imgView.layer.cornerRadius = 10;
            imgView.frame = CGRectMake(left_img, top_img, (182*WIDTH/414.0)*127.0/185.0/236.0*162, (185*WIDTH/414.0)*127.0/185.0);
            [cell addSubview:imgView];
            NSString * smallUrl = img_url_array[3][@"smallUrl"];
            if (smallUrl && smallUrl.length) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:smallUrl]];
            }
            [imgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigWallpaper:)];
            tapGesture.numberOfTapsRequired=1;
            [imgView addGestureRecognizer:tapGesture];
            imgView.tag = indexPath.section * 10 + 3;
        }
    }else{
        //高度  185*WIDTH/414.0, (185*WIDTH/414.0)*271.0/185
        float width = 185*WIDTH/414.0;
        float height = (185*WIDTH/414.0)*271.0/185;
        for(int i = 0 ; i < img_url_array.count ; i ++){
            UIImageView * imgView = [UIImageView new];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
            imgView.layer.masksToBounds = true;
//            imgView.layer.cornerRadius = 10;
            imgView.frame = CGRectMake(left_img + (space + width)*(i%2), top_img + (space + height)*(i/2), width, height);
            [cell addSubview:imgView];
            NSString * smallUrl = img_url_array[i][@"smallUrl"];
            if (smallUrl && smallUrl.length) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:smallUrl]];
            }
            [imgView setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigWallpaper:)];
            tapGesture.numberOfTapsRequired=1;
            [imgView addGestureRecognizer:tapGesture];
            imgView.tag = indexPath.section * 10 + i;
        }
    }
    
    
    
    
    
    
    //无法被点击
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)showBigWallpaper:(UITapGestureRecognizer *)tap{
    UIImage * image = [(UIImageView *)tap.view image];
    if (!image) {
        return;
    }
//    NSLog(@"image:%@",image);
    WallPaperShowVC * vc = [WallPaperShowVC new];
    vc.wallpaperList = self.img_array;
    vc.current_index = tap.view.tag;
    [self.navigationController pushViewController:vc animated:true];
    return;
    
    
    WallpaperShowViewController * showVC = [WallpaperShowViewController new];
    showVC.wallpaperList = self.img_array;
    showVC.current_index = tap.view.tag/10*4 + tap.view.tag%10;
    [self.navigationController pushViewController:showVC animated:true];
    
}
@end
