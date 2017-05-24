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
@interface StoreVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,SDCycleScrollViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSArray * tagsList_array;//商品首页数据
@property(nonatomic,strong)NSArray * carouselImage_array;//轮播图数据
@property(nonatomic,strong)NSArray * goodsCategory_array;//商品分类数据
@property(nonatomic,strong)UILabel * numberOfGoodsLabel;//购物车商品数字label
@property(nonatomic,strong)UISearchBar * searchBar;//搜索框
@property(nonatomic,strong)UIView * shopView;//购物车view
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
    searchBar.frame = CGRectMake(0.2*WIDTH, 14, WIDTH*0.6, 14.5);
    [self.navigationController.navigationBar addSubview:searchBar];
    searchBar.placeholder = @"搜索美图、专题和商品";
    
    [self refreshViewData];
    
}
//加载主界面
-(void)loadMainView{
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
        NSInteger bannerId = [carouselDic[@"bannerId"] longValue];
        NSInteger category = [carouselDic[@"category"] longValue];
        NSLog(@"---点击了上第%ld张图片", (long)index);
//        NSLog(@"barouselDic:%@",carouselDic);
    }else{//导航设置
        indexOfImage = index;
        [self.tableView reloadData];
        NSDictionary * carouselDic = _carouselImage_array[index];
        NSInteger bannerId = [carouselDic[@"bannerId"] longValue];
        NSInteger category = [carouselDic[@"category"] longValue];
        NSLog(@"---点击了下第%ld张图片", (long)index);
//        NSLog(@"bannerListDic:%@",carouselDic);
    }
    
}
#pragma mark - UITableViewDataSource,UITabBarDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count = 1;
    for (NSDictionary * dic in self.tagsList_array) {
        NSInteger showType = [dic[@"showType"] longValue];//展示类型
        if (showType == 1 || showType == 3) {
            count ++;
        }
    }
//    NSLog(@"count:%d",count);
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 267;
    }else{
        NSArray * arr = self.tagsList_array[indexPath.row-1][@"goodsList"];
        if (arr) {
            NSInteger row = arr.count/2;
            if (arr.count > row * 2) {
                row ++;
            }
            return 70 + 240.0*row;
        }else{
            return 332;
        }
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return [CarouselImageCell cellWithCarouselImage_array:self.carouselImage_array andGoodsCategory_array:self.goodsCategory_array andDelegate:self];
    }else{
        return [[StorePageTableViewCell alloc] cellWithDictionary:self.tagsList_array[indexPath.row - 1] andDelegate:self];
    }
}

#pragma mark - 按钮回调
//商品分类图片点击事件
-(void)clickImgOfGoodsCategory:(UITapGestureRecognizer *)tap{
    NSInteger goodsCategory = tap.view.tag;
    NSLog(@"点击goodsCategory:%ld",goodsCategory);
    NSString * interface = @"/shop/goods/getGoodsCat.intf";
    NSDictionary * send = @{
                            @"goodsCatId":[NSString stringWithFormat:@"%ld",goodsCategory]
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
    /*
     8.3获取商品分类
     Ø接口地址：/shop/goods/getGoodsCat.intf
     Ø接口描述：获取商品分类
     Ø特殊说明：如传入goodsCatId则是查出这个分类下的子集，不传则查出所有父类
     46.47.48.48.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     goodsCatId	商品分类id	数字	否
     */
    
    
//    NSLog(@"商品分类id:%ld",goodsId);
    //    self.goodsCategory_array;
//    GoodsTagViewController * goodsTag = [GoodsTagViewController new];
//    for (NSDictionary * dic in self.goodsCategory_array) {
//        NSInteger goodsCatId = [dic[@"goodsCatId"] longValue];
//        if (goodsCatId == goodsId) {
//            NSString * name = dic[@"name"];
//            goodsTag.title = name;
//            break;
//        }
//    }
//    goodsTag.type = 1;
//    [self.navigationController pushViewController:goodsTag animated:true];
//    
    
    
    
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
                    if (cityId == nil || cityId.length == 0) {
                        cityId = @"320300";
                    }
                    NSDictionary * sendDict = @{
                                                @"goodsId":[NSString stringWithFormat:@"%ld",goodsId],
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
        self.carouselImage_array = [array subarrayWithRange:NSMakeRange(2, array.count-2)];
        
        
                NSLog(@"轮播图:%@",self.carouselImage_array);
        [self.storeNetWorking getGoodsCategory:^(NSDictionary * backDict2) {//获取商品分类数据
            self.goodsCategory_array = backDict2[@"goodsCatList"];
//                        NSLog(@"分类数据:%@",self.goodsCategory_array);
            [self.storeNetWorking getViewData:^(NSDictionary * backDict3) {//获取商品组数据
                //self.tagsList_array
                NSArray * back_arr = backDict3[@"tagsList"];
                NSMutableArray * arr = [NSMutableArray new];
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    if (showType == 3) {//中间的新鲜热卖
                        [arr addObject:arr_dic];
                        break;
                    }
                }
                for (NSDictionary * arr_dic in back_arr) {
                    NSInteger showType = [arr_dic[@"showType"] longValue];
                    if (showType == 1) {//下面的商品组
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
}
-(void)viewWillDisappear:(BOOL)animated{
    self.searchBar.hidden = true;
    self.shopView.hidden = true;
}
@end
