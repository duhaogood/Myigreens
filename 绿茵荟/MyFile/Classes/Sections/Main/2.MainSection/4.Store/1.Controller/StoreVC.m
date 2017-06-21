//
//  StoreVC.m
//  野马
//
//  Created by Mac on 17/3/9.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "StoreVC.h"
#import "GoodsInfoViewController.h"
#import "SearchGoodsVC.h"
#import "GoodsCategoryVC.h"
#import "PostInfoViewController.h"
#import "GoodsBannerVC.h"
#import "GYZChooseCityController.h"
@interface StoreVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,SDCycleScrollViewDelegate,GYZChooseCityDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * tagsList_array;//商品首页数据
@property(nonatomic,strong)NSArray * carouselImage_array;//轮播图数据
@property(nonatomic,strong)NSArray * goodsCategory_array;//商品分类数据
@property(nonatomic,strong)UILabel * numberOfGoodsLabel;//购物车商品数字label
@property(nonatomic,strong)UISearchBar * searchBar;//搜索框
@property(nonatomic,strong)UIView * shopView;//购物车view
@property(nonatomic,strong)UILabel * cityLabel;//城市名label
@property(nonatomic,strong)UIImageView * areaIcon;//城市图标

@property(nonatomic,strong)StorePageTableViewCell * storeCell;//下侧cell
@end

@implementation StoreVC
{
    int indexOfImage;//当前显示图片数字
}
- (void)viewDidLoad {
    [super viewDidLoad];
    indexOfImage = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    self.storeNetWorking = [StoreNetWorking new];
    
    
    //购物车按钮
    {
        UIView * rightView = [UIView new];
        rightView.tag = 123000;
        rightView.frame = CGRectMake(WIDTH-50, 0, 50, 44);
        //        rightView.backgroundColor = [UIColor greenColor];
        [self.navigationController.navigationBar addSubview:rightView];
        self.shopView = rightView;
        UIButton * btn = [UIButton new];
        [btn setImage:[UIImage imageNamed:@"nav_Shopping-cart"] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 10, 30, 30);
        [btn addTarget:self action:@selector(shoppingCartBtn_callBack) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:btn];
        UILabel * label = [UILabel new];
        label.backgroundColor = [UIColor redColor];
        label.frame = CGRectMake(20, 7, 20, 14);
        label.text = @"0";
        label.tag = 123001;
        label.layer.masksToBounds = true;
        label.layer.cornerRadius = 7;
        [rightView addSubview:label];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        self.numberOfGoodsLabel = label;
        [self refreshGoodsNumber:0];
    }
    //搜索框
    UISearchBar * searchBar = [[UISearchBar alloc]init];
    searchBar.delegate = self;
    self.searchBar = searchBar;
    searchBar.tag = 123123;
    searchBar.frame = CGRectMake(90, 14, WIDTH-160, 14.5);
    [self.navigationController.navigationBar addSubview:searchBar];
    searchBar.placeholder = @"搜索美图、专题和商品";
    
    [self refreshViewData];
    
}
//加载主界面
-(void)loadMainView{
    //定位
    //左侧定位按钮
    {
        UIView * v = [UIView new];
        v.frame = CGRectMake(0, 0, 70, 44);
        UIBarButtonItem * bar = [[UIBarButtonItem alloc] initWithCustomView:v];
        self.navigationItem.leftBarButtonItem = bar;
        //右侧图标-arrow_bottom_md 11*6
        {
            UIImageView * icon = [UIImageView new];
            icon.image = [UIImage imageNamed:@"arrow_bottom_md"];
            self.areaIcon = icon;
            [v addSubview:icon];
            //城市名称
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:13];
            label.textColor = [UIColor whiteColor];
            [v addSubview:label];
            label.text = @"定位中…";
            self.cityLabel = label;
            CGSize size = [MYTOOL getSizeWithLabel:label];
            label.frame = CGRectMake(0, 22-size.height/2, size.width, size.height);
            icon.frame = CGRectMake(label.frame.origin.x + label.frame.size.width + 5, 19, 11, 6);
        }
        //按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = v.bounds;
            [v addSubview:btn];
            [btn addTarget:self action:@selector(clickUpLeftCityBtn) forControlEvents:UIControlEventTouchUpInside];
        }
        [[MyLocationManager sharedLocationManager] startLocation];
    }
    //
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64-49);
    tableView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView reloadData];
    self.tableView = tableView;
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self updateViewDate];
        // 结束刷新
        [tableView.mj_header endRefreshing];
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
}

//点击左上角定位城市事件
-(void)clickUpLeftCityBtn{
    GYZChooseCityController *cityPickerVC = [[GYZChooseCityController alloc] init];
    [cityPickerVC setDelegate:self];
    [self.navigationController pushViewController:cityPickerVC animated:true];
}
//获取当前显示图片序号
-(int)getIndexOfimage{
    return indexOfImage;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString * searchString = searchBar.text;
    searchBar.text = @"";//清空搜索框
    [MYTOOL hideKeyboard];//键盘隐藏
    SearchGoodsVC * search = [SearchGoodsVC new];
    search.keyWord = searchString;
    [self.navigationController pushViewController:search animated:true];
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSInteger tag = cycleScrollView.tag;
    if (tag == 100) {//顶部轮播图
        NSDictionary * carouselDic = _carouselImage_array[index];
        NSInteger category = [carouselDic[@"category"] longValue];
        //Category：导航类别(1：富文本 2：商品 3：帖子 4:商品组)
        if (category == 1) {//富文本
            NSString * content = carouselDic[@"content"];
            TextBannerVC * text = [TextBannerVC new];
            text.title = carouselDic[@"bannerTitle"];
            text.content = content;
            [self.navigationController pushViewController:text animated:true];
        }else if (category == 2) {//商品
            //网络获取商品详情
            NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
            NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
            if (cityId == nil ) {
                cityId = @"320300";
            }
            NSDictionary * sendDict = @{
                                        @"goodsId":carouselDic[@"categoryId"],
                                        @"cityId":cityId
                                        };
            [MYTOOL netWorkingWithTitle:@"获取商品"];
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
//                NSLog(@"商品:%@",back_dic);
                GoodsInfoViewController * info = [GoodsInfoViewController new];
                info.goodsInfoDictionary = back_dic[@"goods"];
                info.title = carouselDic[@"bannerTitle"];
                [self.navigationController pushViewController:info animated:true];
            }];
        }else if (category == 3) {//帖子
            NSMutableDictionary * send_dic = [NSMutableDictionary new];
            NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
            if (memberId) {
                [send_dic setValue:memberId forKey:@"memberId"];
            }
            [send_dic setValue:carouselDic[@"categoryId"] forKey:@"postId"];
            
            //开始请求
            [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
            [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
                bool flag = [back_dic[@"code"] boolValue];
                if (flag) {
                    [SVProgressHUD dismiss];
                    PostInfoViewController * postVC = [PostInfoViewController new];
                    postVC.title = @"帖子详情";
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
                    [dict setValue:@([carouselDic[@"categoryId"] intValue]) forKey:@"postId"];
                    postVC.post_dic = dict;
                    [self.navigationController pushViewController:postVC animated:true];
                }else{
                    [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
                }
            }];
        }else if (category == 4) {//商品组
            NSString * interface = @"/shop/goods/getGoodList.intf";
            [MYTOOL netWorkingWithTitle:@"获取商品组"];
            NSInteger bannerId = [carouselDic[@"bannerId"] longValue];
            NSDictionary * send = @{
                                    @"bannerId":[NSString stringWithFormat:@"%ld",bannerId]
                                    };
            [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
//                NSLog(@"back:%@",back_dic);
                NSArray * goodsList = back_dic[@"goodsList"];
                GoodsBannerVC * goodsB = [GoodsBannerVC new];
                goodsB.title = back_dic[@"title"];
                goodsB.goodsList = goodsList;
                [self.navigationController pushViewController:goodsB animated:true];
            }];
            
        }else if (category == 5) {//url加载web
            NSString * viewUrl = carouselDic[@"viewUrl"];
            TextBannerVC * text = [TextBannerVC new];
            text.viewUrl = viewUrl;
            text.title = carouselDic[@"bannerTitle"];
            [self.navigationController pushViewController:text animated:true];
        }
    }else{//导航设置
//
        NSDictionary * carouselDic = nil;
        for (NSDictionary * dictt in _tagsList_array) {
            int showType = [dictt[@"showType"] intValue];
            if (showType == 3) {
                carouselDic = dictt[@"bannerList"][index];
                break;
            }
        }
        NSInteger category = [carouselDic[@"category"] longValue];
//        NSLog(@"---点击了上第%ld张图片", (long)index);
//        NSLog(@"barouselDic:%@",carouselDic);
        //Category：导航类别(1：富文本 2：商品 3：帖子 4:商品组)
        if (category == 1) {//富文本
            NSString * content = carouselDic[@"content"];
            TextBannerVC * text = [TextBannerVC new];
            text.content = content;
            [self.navigationController pushViewController:text animated:true];
        }else if (category == 2) {//商品
            //网络获取商品详情
            NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
            NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
            if (cityId == nil ) {
                cityId = @"320300";
            }
            NSDictionary * sendDict = @{
                                        @"goodsId":carouselDic[@"categoryId"],
                                        @"cityId":cityId
                                        };
            [MYTOOL netWorkingWithTitle:@"获取商品"];
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
//                NSLog(@"商品:%@",back_dic);
                GoodsInfoViewController * info = [GoodsInfoViewController new];
                info.goodsInfoDictionary = back_dic[@"goods"];
                [self.navigationController pushViewController:info animated:true];
            }];
        }else if (category == 3) {//帖子
            NSMutableDictionary * send_dic = [NSMutableDictionary new];
            NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
            if (memberId) {
                [send_dic setValue:memberId forKey:@"memberId"];
            }
            [send_dic setValue:carouselDic[@"categoryId"] forKey:@"postId"];
            
            //开始请求
            [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
            [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
                bool flag = [back_dic[@"code"] boolValue];
                if (flag) {
                    [SVProgressHUD dismiss];
                    PostInfoViewController * postVC = [PostInfoViewController new];
                    postVC.title = @"帖子详情";
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
                    [dict setValue:@([carouselDic[@"categoryId"] intValue]) forKey:@"postId"];
                    postVC.post_dic = dict;
                    [self.navigationController pushViewController:postVC animated:true];
                }else{
                    [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
                }
            }];
        }else if (category == 4) {//商品组
            NSString * interface = @"/shop/goods/getGoodList.intf";
            [MYTOOL netWorkingWithTitle:@"获取商品组"];
            NSInteger bannerId = [carouselDic[@"bannerId"] longValue];
            NSDictionary * send = @{
                                    @"bannerId":[NSString stringWithFormat:@"%ld",bannerId]
                                    };
            [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
                //                NSLog(@"back:%@",back_dic);
                NSArray * goodsList = back_dic[@"goodsList"];
                GoodsBannerVC * goodsB = [GoodsBannerVC new];
                goodsB.title = back_dic[@"title"];
                goodsB.goodsList = goodsList;
                [self.navigationController pushViewController:goodsB animated:true];
            }];
            
        }else if (category == 5) {//url加载web
            NSString * viewUrl = carouselDic[@"viewUrl"];
            TextBannerVC * text = [TextBannerVC new];
            text.viewUrl = viewUrl;
            [self.navigationController pushViewController:text animated:true];
        }
        
        
        
    }
    
}
#pragma mark - UITableViewDataSource,UITabBarDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int count = 1;
    for (NSDictionary * dic in self.tagsList_array) {
        NSInteger showType = [dic[@"showType"] longValue];//展示类型
        if (showType == 1 || showType == 3 || showType == 2) {
            count ++;
        }
    }
    //    NSLog(@"count:%d",count);
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 267;
    }else{
        NSDictionary * dictt = self.tagsList_array[indexPath.section-1];
        int showType = [dictt[@"showType"] intValue];
        if (showType == 1) {
            NSArray * arr = dictt[@"goodsList"];
            NSInteger row = arr.count/2;
            if (arr.count > row * 2) {
                row ++;
            }
            return 70 + 240.0*row;
        }else if(showType == 2){
            NSArray * arr = dictt[@"bannerList"];
            NSInteger row = arr.count/2;
            float height = WIDTH/950.0*440;
            if (arr.count > row * 2) {
                row ++;
            }
            return 70 + (height - 50 - 10)*row;
        }else{//showType=3
            float height = 70+WIDTH/950.0*440 - 50 - 20;
            return height;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [CarouselImageCell cellWithCarouselImage_array:self.carouselImage_array andGoodsCategory_array:self.goodsCategory_array andDelegate:self];
    }else{
        return [[StorePageTableViewCell alloc] cellWithDictionary:self.tagsList_array[indexPath.section - 1] andDelegate:self];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 8;
}
#pragma mark - 按钮回调
//点击商品组图片事件
-(void)clickImgOfGoodsGroup:(UITapGestureRecognizer *)tap{
    
    NSDictionary * carouselDic = nil;
    for (NSDictionary * dictt in _tagsList_array) {
        int showType = [dictt[@"showType"] intValue];
        if (showType == 1) {
            continue;
            
            break;
        }
        bool flag = false;
        NSArray * bannerList = dictt[@"bannerList"];
        for (NSDictionary * bannerDic in bannerList) {
            NSInteger bannerId = [bannerDic[@"bannerId"] longValue];
            if (bannerId == tap.view.tag) {
                carouselDic = bannerDic;
                flag = true;
                break;
            }
        }
        if (flag) {
            break;
        }
    }
//    NSLog(@"back:%@",carouselDic);
//    for (NSString * key in carouselDic.allKeys) {
//        NSLog(@"%@:%@",key,carouselDic[key]);
//    }
    NSInteger category = [carouselDic[@"category"] longValue];
    //        NSLog(@"---点击了上第%ld张图片", (long)index);
    //        NSLog(@"barouselDic:%@",carouselDic);
    //Category：导航类别(1：富文本 2：商品 3：帖子 4:商品组)
    if (category == 1) {//富文本
        NSString * content = carouselDic[@"content"];
        TextBannerVC * text = [TextBannerVC new];
        text.content = content;
        text.title = carouselDic[@"bannerTitle"];
        [self.navigationController pushViewController:text animated:true];
    }else if (category == 2) {//商品
        //网络获取商品详情
        NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
        NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
        if (cityId == nil ) {
            cityId = @"320300";
        }
        NSDictionary * sendDict = @{
                                    @"goodsId":carouselDic[@"categoryId"],
                                    @"cityId":cityId
                                    };
        [MYTOOL netWorkingWithTitle:@"获取商品"];
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
            //                NSLog(@"商品:%@",back_dic);
            GoodsInfoViewController * info = [GoodsInfoViewController new];
            info.goodsInfoDictionary = back_dic[@"goods"];
            info.title = carouselDic[@"bannerTitle"];
            [self.navigationController pushViewController:info animated:true];
        }];
    }else if (category == 3) {//帖子
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
        if (memberId) {
            [send_dic setValue:memberId forKey:@"memberId"];
        }
        [send_dic setValue:carouselDic[@"categoryId"] forKey:@"postId"];
        
        //开始请求
        [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
        [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            bool flag = [back_dic[@"code"] boolValue];
            if (flag) {
                [SVProgressHUD dismiss];
                PostInfoViewController * postVC = [PostInfoViewController new];
                postVC.title = @"帖子详情";
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:back_dic[@"post"]];
                [dict setValue:@([carouselDic[@"categoryId"] intValue]) forKey:@"postId"];
                postVC.post_dic = dict;
                [self.navigationController pushViewController:postVC animated:true];
            }else{
                [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
            }
        }];
    }else if (category == 4) {//商品组
        NSString * interface = @"/shop/goods/getGoodList.intf";
        [MYTOOL netWorkingWithTitle:@"获取商品组"];
        NSInteger bannerId = [carouselDic[@"bannerId"] longValue];
        NSDictionary * send = @{
                                @"bannerId":[NSString stringWithFormat:@"%ld",bannerId]
                                };
        [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
            //                NSLog(@"back:%@",back_dic);
            NSArray * goodsList = back_dic[@"goodsList"];
            GoodsBannerVC * goodsB = [GoodsBannerVC new];
            goodsB.title = back_dic[@"bannerTitle"];
            goodsB.goodsList = goodsList;
            [self.navigationController pushViewController:goodsB animated:true];
        }];
        
    }else if (category == 5) {//url加载web
        NSString * viewUrl = carouselDic[@"viewUrl"];
        TextBannerVC * text = [TextBannerVC new];
        text.viewUrl = viewUrl;
        text.title = carouselDic[@"bannerTitle"];
        [self.navigationController pushViewController:text animated:true];
    }
    
    
    
    
    
    
    
    return;
    NSInteger bannerId = tap.view.tag;
//    NSLog(@"bannerId:%ld",bannerId);
    NSDictionary * send = @{@"bannerId":@(bannerId)};
    NSString * interface = @"/shop/goods/getGoodsContent.intf";
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic1) {
        NSLog(@"back1:%@",back_dic1);
        NSString * interface2 = @"/shop/goods/getGoodList.intf";
        [MYNETWORKING getWithInterfaceName:interface2 andDictionary:send andSuccess:^(NSDictionary *back_dic2) {
            NSLog(@"back2:%@",back_dic2);
            
            
        }];
        
    }];
    
    
    
    
}
//商品分类图片点击事件
-(void)clickImgOfGoodsCategory:(UITapGestureRecognizer *)tap{
    NSInteger goodsCategory = tap.view.tag;
//    NSLog(@"点击goodsCategory:%ld",goodsCategory);
    NSString * interface = @"/shop/goods/getGoodsCat.intf";
    NSDictionary * send = @{
                            @"goodsCatId":[NSString stringWithFormat:@"%ld",(long)goodsCategory]
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * array = back_dic[@"goodsCatList"];
        if (array == nil || array.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"木有数据" duration:2];
            return;
        }else{
            GoodsCategoryVC * vc = [GoodsCategoryVC new];
            vc.goodsCatList = array;
            [self.navigationController pushViewController:vc animated:true];
        }
    }];
    
}

//点击标签右侧全部回调
-(void)clickAllBtn_callBack:(UIButton * )btn{
    //NSLog(@"点击了标签id:%ld",btn.tag);
    GoodsTagViewController * goodsTag = [GoodsTagViewController new];
    for (NSDictionary * dictionary in self.tagsList_array) {
        NSInteger tagId = [dictionary[@"tagId"] longValue];
        if (tagId == btn.tag) {
            NSString * tagName = dictionary[@"tagName"];
            goodsTag.title = tagName;
            break;
        }
    }
    goodsTag.tagId = btn.tag;
    goodsTag.type = 2;
    [self.navigationController pushViewController:goodsTag animated:true];
}
//商品图片点击事件
-(void)clickImgOfGoods:(UITapGestureRecognizer *)tap{
    NSInteger tag = tap.view.tag;
//    NSLog(@"商品id:%ld",tag);
    
    GoodsInfoViewController * info = [GoodsInfoViewController new];
    for (NSDictionary * dictionary in self.tagsList_array) {
        bool flag = false;
        NSInteger showType = [dictionary[@"showType"] longValue];
        if (showType == 1) {
            NSArray * goodsList = dictionary[@"goodsList"];
            for (NSDictionary * dic in goodsList) {
                NSInteger goodsId = [dic[@"goodsId"] longValue];//商品id
                if (goodsId == tag) {
                    NSString * tagName = dic[@"goodsName"];//标签名称
                    info.title = tagName;
                    flag = true;
//                    NSLog(@"商品:%@",dic);
                    //网络获取商品详情
                    NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
                    NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
                    if (cityId == nil ) {
                        cityId = @"320300";
                    }
                    NSDictionary * sendDict = @{
                                                @"goodsId":[NSString stringWithFormat:@"%ld",(long)goodsId],
                                                @"cityId":cityId
                                                };
                    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
//                        NSLog(@"商品详情:%@",back_dic[@"goods"]);
                        info.goodsInfoDictionary = back_dic[@"goods"];
                        [self.navigationController pushViewController:info animated:true];
                    }];
                    /*
                     8.8商品详情
                     Ø接口地址：/shop/goods/getGoodsInfo.intf
                     Ø接口描述：获取分类商品
                     59.60.61.61.1Ø输入参数：
                     参数名称	参数含义	参数类型	是否必录
                     goodsId	商品id	数字	是
                     */
                    
                    break;
                }
            }
        }else{
            continue;
        }
        if (flag) {
            break;
        }
    }
}
//购物车按钮回调
-(void)shoppingCartBtn_callBack{
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        loginVC.delegate = self;
        [self.navigationController pushViewController:loginVC animated:true];
        return;
    }
    ShoppingCartVC * shop = [ShoppingCartVC new];
    shop.title = @"我的购物车";
    [self.navigationController pushViewController:shop animated:true];
}
//刷新购物车商品数量
-(void)refreshGoodsNumber:(NSInteger)goodsNumber{
    CGRect rect = self.numberOfGoodsLabel.frame;
    self.numberOfGoodsLabel.text = [NSString stringWithFormat:@"%ld",goodsNumber];
    if (goodsNumber > 99) {
        self.numberOfGoodsLabel.text = @"99+";
    }
    CGSize size = [MYTOOL getSizeWithString:self.numberOfGoodsLabel.text andFont:self.numberOfGoodsLabel.font];
    self.numberOfGoodsLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, size.width, size.height);
    if (size.width < 20) {
        self.numberOfGoodsLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, 20, size.height);
    }
    if (goodsNumber == 0) {
        self.numberOfGoodsLabel.frame = CGRectMake(rect.origin.x, rect.origin.y, 0, size.height);
    }
}
//刷新界面信息
-(void)refreshViewData{
    //轮播图数据有问题
    [self.storeNetWorking getCarouselImageData:^(NSDictionary * backDict) {//获取轮播图数据
        self.carouselImage_array = backDict[@"list"];
        
        NSArray * array = backDict[@"list"];
        self.carouselImage_array = array;
//                NSLog(@"轮播图:%@",self.carouselImage_array);
        [self.storeNetWorking getGoodsCategory:^(NSDictionary * backDict2) {//获取商品分类数据
            self.goodsCategory_array = backDict2[@"goodsCatList"];
//                        NSLog(@"分类数据:%@",self.goodsCategory_array);
            [self.storeNetWorking getViewData:^(NSDictionary * backDict3) {//获取商品组数据
                //self.tagsList_array
//                NSLog(@"back:%@",backDict3);
                NSArray * back_arr = backDict3[@"tagsList"];
                NSMutableArray * arr = [NSMutableArray new];
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    NSArray * bannerList = arr_dic[@"bannerList"];
                    if (showType == 3 && bannerList && bannerList.count > 0) {//导航展示类型
                        [arr addObject:arr_dic];
                        break;
                    }
                }
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    NSArray * bannerList = arr_dic[@"bannerList"];
                    if (showType == 2 && bannerList && bannerList.count > 0) {//商品组
                        [arr addObject:arr_dic];
                        break;
                    }
                }
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    NSArray * goodsList = arr_dic[@"goodsList"];
                    if (showType == 1 && goodsList && goodsList.count > 0) {//下面的商品标签
                        [arr addObject:arr_dic];
                    }
                }
                self.tagsList_array = [NSArray arrayWithArray:arr];
                //                NSLog(@"count3:%ld",self.tagsList_array.count);
                //此时加载界面
                [self loadMainView];
            }];
        }];
    }];
}
//重新刷新界面结构
-(void)updateViewDate{
    //轮播图数据有问题
    [self.storeNetWorking getCarouselImageData:^(NSDictionary * backDict) {//获取轮播图数据
        self.carouselImage_array = backDict[@"list"];
        
        NSArray * array = backDict[@"list"];
        self.carouselImage_array = array;
        //                NSLog(@"轮播图:%@",self.carouselImage_array);
        [self.storeNetWorking getGoodsCategory:^(NSDictionary * backDict2) {//获取商品分类数据
            self.goodsCategory_array = backDict2[@"goodsCatList"];
            //                        NSLog(@"分类数据:%@",self.goodsCategory_array);
            [self.storeNetWorking getViewData:^(NSDictionary * backDict3) {//获取商品组数据
                //self.tagsList_array
                NSArray * back_arr = backDict3[@"tagsList"];
                NSMutableArray * arr = [NSMutableArray new];
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    NSArray * bannerList = arr_dic[@"bannerList"];
                    if (showType == 3 && bannerList && bannerList.count > 0) {//中间的新鲜热卖
                        [arr addObject:arr_dic];
                        break;
                    }
                }
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    NSArray * bannerList = arr_dic[@"bannerList"];
                    if (showType == 2 && bannerList && bannerList.count > 0) {//商品组
                        [arr addObject:arr_dic];
//                        NSLog(@"arr_dic:%@",arr_dic);
                        break;
                    }
                }
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    NSArray * goodsList = arr_dic[@"goodsList"];
                    if (showType == 1 && goodsList && goodsList.count > 0) {//下面的商品组
                        [arr addObject:arr_dic];
                    }
                }
                self.tagsList_array = [NSArray arrayWithArray:arr];
//                                NSLog(@"count3:%ld",self.tagsList_array.count);
                //此时加载界面
                [self.tableView reloadData];
            }];
        }];
    }];
}
//轮播图自动滚动通知
-(void)autoScroll:(NSNotification *)sender{
    NSDictionary * dic = [sender object];
    NSInteger tag = [dic[@"tag"] longValue];
    int page = [dic[@"page"] intValue];
    if (tag == 200) {
        self.leftLabel.text = [NSString stringWithFormat:@"%d",page];
    }
}
//设置顶上文字
-(void)setCityName:(NSString *)city{
    if (city && city.length > 0) {
        if (city.length > 4) {//如果长度大于4，取前3个字+…
            city = [city substringToIndex:3];
            city = [NSString stringWithFormat:@"%@…",city];
        }
        self.cityLabel.text = city;
        CGSize size = [MYTOOL getSizeWithLabel:self.cityLabel];
        self.cityLabel.frame = CGRectMake(0, 22-size.height/2, size.width, size.height);
        self.areaIcon.frame = CGRectMake(self.cityLabel.frame.origin.x + self.cityLabel.frame.size.width + 5, 19, 11, 6);
    }
}
#pragma mark - GYZCityPickerDelegate
- (void) cityPickerController:(GYZChooseCityController *)chooseCityController didSelectCity:(GYZCity *)city
{
    [chooseCityController.navigationController popViewControllerAnimated:true];
    [self setCityName:city.cityName];
    [MYTOOL setProjectPropertyWithKey:@"cityId" andValue:[NSString stringWithFormat:@"%@",city.cityID]];
}

- (void) cityPickerControllerDidCancel:(GYZChooseCityController *)chooseCityController
{
    [chooseCityController.navigationController popViewControllerAnimated:true];
}
//接收到定位成功通知
-(void)receiveUpdateLocationSuccessNotification:(NSNotification *)notification{
    NSDictionary * obj = notification.object;
    NSString * city = obj[@"city"];
    [self setCityName:city];
}
//页面显示
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.searchBar.hidden = false;
    self.searchBar.delegate = self;
    self.shopView.hidden = false;
    [MYNETWORKING getNumberOfShoppingCartCallback:^(NSDictionary * back) {
        int count = [back[@"count"] intValue];
        [self refreshGoodsNumber:count];
    }];
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(autoScroll:) name:AUTOMATIC_SCROLL object:nil];
    [MYCENTER_NOTIFICATION addObserver:self selector:@selector(receiveUpdateLocationSuccessNotification:) name:NOTIFICATION_UPDATELOCATION_SUCCESS object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.searchBar.hidden = true;
    self.shopView.hidden = true;
    
    [MYCENTER_NOTIFICATION removeObserver:self name:NOTIFICATION_UPDATELOCATION_SUCCESS object:nil];
    [MYCENTER_NOTIFICATION removeObserver:self name:AUTOMATIC_SCROLL object:nil];
}
@end
