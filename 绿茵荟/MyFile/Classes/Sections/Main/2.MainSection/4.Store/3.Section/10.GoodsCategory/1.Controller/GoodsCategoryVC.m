//
//  GoodsCategoryVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "GoodsCategoryVC.h"
#import "ShoppingCartVC.h"
#import "SearchGoodsVC.h"
#import "GoodsInfoViewController.h"
@interface GoodsCategoryVC ()<UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UISearchBar * searchBar;//搜索框
@property(nonatomic,strong)UILabel * numberOfGoodsLabel;//购物车商品数字label
@property(nonatomic,strong)UIView * shopView;//购物车view
@property(nonatomic,strong)UITableView * tableView;//左侧分类列表
@property(nonatomic,strong)UICollectionView * collectionView ;
@property(nonatomic,strong)NSMutableArray * goodsList_array;//展示商品数组

@end

@implementation GoodsCategoryVC
{
    int pageNo;
    NSInteger goodsCatId;//分类id
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    pageNo = 1;
    goodsCatId = [self.goodsCatList[0][@"goodsCatId"] longValue];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //加载主界面
    [self loadMainView];
    
    
}
//加载主界面
-(void)loadMainView{
    //加载左侧分类列表
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 0, 80, HEIGHT-64);
    self.tableView = tableView;
    tableView.dataSource = self;
    tableView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    tableView.delegate = self;
    [self.view addSubview:tableView];
    tableView.rowHeight = 45;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //商品区域
    //collectionView
    {
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(80, 0, WIDTH-80, HEIGHT-64) collectionViewLayout:flowLayout];
        self.collectionView.dataSource=self;
        self.collectionView.delegate=self;
        //注册Cell，必须要有
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell-11"];
        [self.view addSubview:self.collectionView];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        //解决tableView露白
        self.automaticallyAdjustsScrollViewInsets = false;
        self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            //        [self headerRefresh];
            pageNo = 1;
            [self getGoods];
            // 结束刷新
            [self.collectionView.mj_header endRefreshing];
        }];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        self.collectionView.mj_header.automaticallyChangeAlpha = YES;
        
        // 上拉刷新
        self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            //        [self footerRefresh];
            pageNo ++;
            [self getGoods];
            [self.collectionView.mj_footer endRefreshing];
        }];
        pageNo = 1;
        [self getGoods];
    }
}
//获取商品
-(void)getGoods{
    NSString * interface = @"/shop/goods/getCatGoods.intf";
    NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
    if (cityId == nil) {
        cityId = @"320300";
    }
    NSDictionary * send = @{
                            @"city":cityId,
                            @"goodsCatId":[NSString stringWithFormat:@"%ld",goodsCatId],
                            @"pageNo":@(pageNo)
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        NSLog(@"back:%@",back_dic);
        NSArray * array = back_dic[@"goodsList"];
//        if (array == nil || array.count == 0) {
//            [SVProgressHUD showErrorWithStatus:@"数据有误" duration:2];
//            return;
//        }
//        self.goodsList_array = array;
//        [self.collectionView reloadData];
//        
        if (pageNo > 1) {
            
            if (array.count > 0) {
                [self.goodsList_array addObjectsFromArray:array];
            }else{
                pageNo --;
                if (self.goodsList_array.count == 0) {
                    [SVProgressHUD showErrorWithStatus:@"没有数据" duration:1];
                }else{
                    [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
                }
            }
            
        }else{
            self.goodsList_array = [NSMutableArray arrayWithArray:array];
        }
        [self.collectionView reloadData];
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.goodsList_array removeAllObjects];
            [self.collectionView reloadData];
        }else{
            pageNo --;
        }
    }];
    
    /*
     goodsCatId	商品分类id	数字	是
     city	城市id	数字	否
     pageNo	页数	数字	是
     */
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger _goodsCatId = [self.goodsCatList[indexPath.row][@"goodsCatId"] longValue];
    if (goodsCatId == _goodsCatId) {
        return;
    }
    goodsCatId = _goodsCatId;
    //重新获取商品
    pageNo = 1;
    self.goodsList_array = [NSMutableArray new];
    [self getGoods];
    
    [SVProgressHUD showSuccessWithStatus:@"稍等" duration:1];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    //文本
    UILabel * label = [cell viewWithTag:100];
    label.textColor = [MYTOOL RGBWithRed:114 green:158 blue:52 alpha:1];
    cell.backgroundColor = [UIColor whiteColor];
    //左侧绿色view
    UIView * view = [cell viewWithTag:88];
    view.backgroundColor = [MYTOOL RGBWithRed:106 green:151 blue:53 alpha:1];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //文本
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel * label = [cell viewWithTag:100];
    label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
    cell.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //左侧绿色view
    UIView * view = [cell viewWithTag:88];
    view.backgroundColor = [UIColor clearColor];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.goodsCatList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSString * name = self.goodsCatList[indexPath.row][@"name"];
    //文字
    {
        UILabel * label = [UILabel new];
        label.tag = 100;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = name;
        label.font = [UIFont systemFontOfSize:15];
        label.frame = CGRectMake(3, 15, tableView.frame.size.width-3, 15);
        [MYTOOL setFontWithLabel:label];
        [cell addSubview:label];
    }
    //左侧绿色view
    {
        UIView * view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, 0, 3, tableView.rowHeight);
        [cell addSubview:view];
        view.tag = 88;
        if (indexPath.row == 0) {
            view.backgroundColor = [MYTOOL RGBWithRed:106 green:151 blue:53 alpha:1];
        }
    }
    //分割线
    {
        UIView * view = [UIView new];
        view.backgroundColor = MYCOLOR_181_181_181;
        view.frame = CGRectMake(0, tableView.rowHeight-1, tableView.frame.size.width, 1);
        [cell addSubview:view];
    }
    return cell;
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.goodsList_array.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"UICollectionViewCell-11";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //    UICollectionViewCell * cell = [UICollectionViewCell new];
    //获取各个参数
    NSDictionary * dicForCell = self.goodsList_array[indexPath.row];
    NSString * goodsName = dicForCell[@"goodsName"];
    //    NSLog(@"%ld:%@",indexPath.row,goodsName);
    float price = [dicForCell[@"price"] floatValue];
    NSString * url = dicForCell[@"url"];
    float width_cell = (WIDTH - 45 - 80)/2;
    float top = width_cell + 5;
    //图片
    UIImageView * imgV = [cell viewWithTag:10000];
    if (imgV == nil){
        imgV = [UIImageView new];
        imgV.frame = CGRectMake(0, 0, width_cell, width_cell);
        imgV.backgroundColor = [UIColor greenColor];
        [cell addSubview:imgV];
        imgV.tag = 10000;
        imgV.layer.masksToBounds = true;
//        imgV.layer.cornerRadius = 12;
        [imgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
    }else{
        [imgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    //商品名字
    {
        UILabel * label = [cell viewWithTag:10001];
        if (label) {
            CGRect rect = imgV.frame;
            float width = rect.size.width;
            label.text = goodsName;
            label.frame = CGRectMake(rect.origin.x, top, rect.size.width, 15);
            CGSize size = [MYTOOL getSizeWithLabel:label];
            //一行还显示不全，变成两行
            if (size.width > width) {
                label.numberOfLines = 0;
                //两行显示不全
                while (size.width > width * 2 - label.font.pointSize) {
                    label.font = [UIFont systemFontOfSize:label.font.pointSize-0.1];
                    size = [MYTOOL getSizeWithLabel:label];
                }
                label.frame = CGRectMake(rect.origin.x, top, width, size.height*2);
            }
        }else{
            label = [UILabel new];
            label.tag = 10001;
            label.text = goodsName;
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:15];
            CGRect rect = imgV.frame;
            float width = rect.size.width;
            label.frame = CGRectMake(rect.origin.x, top, rect.size.width, 15);
            [cell addSubview:label];
            CGSize size = [MYTOOL getSizeWithLabel:label];
            //一行还显示不全，变成两行
            if (size.width > width) {
                label.numberOfLines = 0;
                //两行显示不全
                while (size.width > width * 2 - label.font.pointSize) {
                    label.font = [UIFont systemFontOfSize:label.font.pointSize-0.1];
                    size = [MYTOOL getSizeWithLabel:label];
                }
                label.frame = CGRectMake(rect.origin.x, top, width, size.height*2);
            }
        }
        top += label.frame.size.height + 5;
    }
    
    //商品价格
    UILabel * priceLabel = [cell viewWithTag:10002];
    if (priceLabel) {
        priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
        if ((int)price == price) {
            priceLabel.text = [NSString stringWithFormat:@"¥%d",(int)price];
        }
        UILabel * nameLabel = [cell viewWithTag:10001];
        CGRect rect = nameLabel.frame;
        CGSize size = [MYTOOL getSizeWithLabel:priceLabel];
        priceLabel.frame = CGRectMake(rect.origin.x + rect.size.width/2 - size.width/2, top, size.width, size.height);
    }else{
        UILabel * label = [UILabel new];
        label.tag = 10002;
        label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        UILabel * nameLabel = [cell viewWithTag:10001];
        [cell addSubview:label];
        label.text = [NSString stringWithFormat:@"¥%.2f",price];
        if ((int)price == price) {
            label.text = [NSString stringWithFormat:@"¥%d",(int)price];
        }
        CGRect rect = nameLabel.frame;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(rect.origin.x + rect.size.width/2 - size.width/2, top, size.width, size.height);
    }
    
    
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((WIDTH-45-80)/2, (WIDTH-45-80)/2+55);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"选中:%d",[self.goodsList_array[indexPath.row][@"goodsId"] intValue]);
    GoodsInfoViewController * info = [GoodsInfoViewController new];
    info.title = self.goodsList_array[indexPath.row][@"goodsName"];
    
    //网络获取商品详情
    NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
    NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
    if (cityId == nil) {
        cityId = @"320300";
    }
    NSDictionary * sendDict = @{
                                @"goodsId":[NSString stringWithFormat:@"%d",[self.goodsList_array[indexPath.row][@"goodsId"] intValue]],
                                @"cityId":cityId
                                };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
        //        NSLog(@"商品详情:%@",back_dic[@"goods"]);
        info.goodsInfoDictionary = back_dic[@"goods"];
        [self.navigationController pushViewController:info animated:true];
    }];
    
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
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
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    
    self.searchBar = [self.navigationController.navigationBar viewWithTag:123123];
    self.searchBar.hidden = false;
    self.searchBar.delegate = self;
    self.shopView = [self.navigationController.navigationBar viewWithTag:123000];
    self.numberOfGoodsLabel = [self.shopView viewWithTag:123001];
    self.shopView.hidden = false;
    
    [MYNETWORKING getNumberOfShoppingCartCallback:^(NSDictionary * back) {
        int count = [back[@"count"] intValue];
        [self refreshGoodsNumber:count];
    }];
    //默认选中第一个
    NSInteger selectedIndex = 0;
    NSIndexPath * selectedIndexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
    [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    self.searchBar.hidden = true;
    self.shopView.hidden = true;
}
@end
