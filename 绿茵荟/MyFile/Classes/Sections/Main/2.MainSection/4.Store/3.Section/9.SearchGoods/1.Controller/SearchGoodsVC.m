//
//  SearchGoodsVC.m
//  绿茵荟
//
//  Created by mac_hao on 2017/5/20.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SearchGoodsVC.h"
#import "GoodsInfoViewController.h"
@interface SearchGoodsVC ()<UISearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UICollectionView * collectionView ;
@property(nonatomic,strong)NSMutableArray * goodsList_array;//展示商品数组
@property(nonatomic,strong)UISearchBar * searchBar;//搜索框
@property(nonatomic,strong)UIView * stateView;//搜索结果没有的提示view
@end

@implementation SearchGoodsVC
{
    int pageNo;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    pageNo = 1;
    //搜索框
    {
        UISearchBar * searchBar = [[UISearchBar alloc]init];
        searchBar.delegate = self;
        searchBar.frame = CGRectMake(14, 14, WIDTH*0.8, 14.5);
        [self.navigationController.navigationBar addSubview:searchBar];
        searchBar.placeholder = @"搜索商品";
        self.searchBar = searchBar;
        searchBar.text = self.keyWord;
        searchBar.layer.masksToBounds = true;
        searchBar.layer.cornerRadius = 14.5/2;
    }
    //取消按钮
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        //隐藏原返回按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:nil action:0];
    }
    //collectionView
    {
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64) collectionViewLayout:flowLayout];
        self.collectionView.dataSource=self;
        self.collectionView.delegate=self;
        //注册Cell，必须要有
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        [self.view addSubview:self.collectionView];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        //解决tableView露白
        self.automaticallyAdjustsScrollViewInsets = false;
        self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            //        [self headerRefresh];
            pageNo = 1;
            [self searchGoods];
            // 结束刷新
            [self.collectionView.mj_header endRefreshing];
        }];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        self.collectionView.mj_header.automaticallyChangeAlpha = YES;
        
        // 上拉刷新
        self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            //        [self footerRefresh];
            pageNo ++;
            [self searchGoods];
            [self.collectionView.mj_footer endRefreshing];
        }];
        pageNo = 1;
        [self searchGoods];
    }
    //提示view
    {
        UIView * view = [UIView new];
        view.frame = self.collectionView.bounds;
        [self.view addSubview:view];
        self.stateView = view;
        view.hidden = true;
        //图标-big-search
        {
            UIImageView * icon = [UIImageView new];
            icon.image = [UIImage imageNamed:@"big-search"];
            icon.frame = CGRectMake(WIDTH/2-23, HEIGHT/2-100, 46, 46);
            [view addSubview:icon];
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = MYCOLOR_181_181_181;
            label.text = @"没有搜索到相关内容";
            label.frame = CGRectMake(0, HEIGHT/2-40, WIDTH, 20);
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
        }
    }
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
}
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
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    //    UICollectionViewCell * cell = [UICollectionViewCell new];
    //获取各个参数
    NSDictionary * dicForCell = self.goodsList_array[indexPath.row];
    NSString * goodsName = dicForCell[@"goodsName"];
    //    NSLog(@"%ld:%@",indexPath.row,goodsName);
    float price = [dicForCell[@"price"] floatValue];
    NSString * url = dicForCell[@"url"];
    float width_cell = (WIDTH - 45)/2;
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
            label.frame = CGRectMake(rect.origin.x, top, rect.size.width, 14);
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
            label.font = [UIFont systemFontOfSize:14];
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
        label.font = [UIFont systemFontOfSize:14];
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
    return CGSizeMake((WIDTH-40)/2, (WIDTH-40)/2+55);
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
    if (cityId == nil ) {
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





-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - UISearchBarDelegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString * searchString = searchBar.text;
    [MYTOOL hideKeyboard];//键盘隐藏
    self.keyWord = searchString;
    pageNo = 1;
    [self searchGoods];
}
-(void)searchGoods{
    NSString * interface = @"/shop/goods/searchGoods.intf";
    NSDictionary * send = @{
                            @"keyWord":self.keyWord,
                            @"pageNo":[NSString stringWithFormat:@"%d",pageNo]
                            };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        NSArray * goodsList = back_dic[@"goodsList"];
        if (pageNo > 1) {
            if (goodsList.count > 0) {
                [self.goodsList_array addObjectsFromArray:goodsList];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
            
        }else{
            self.goodsList_array = [NSMutableArray arrayWithArray:goodsList];
        }
        [self.collectionView reloadData];
        //判断是否有搜索结果
        if (self.goodsList_array.count == 0) {
            self.stateView.hidden = false;
        }else{
            self.stateView.hidden = true;
        }
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.goodsList_array removeAllObjects];
            [self.collectionView reloadData];
        }else{
            pageNo --;
        }
    }];
}


//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    self.searchBar.hidden = false;
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    self.searchBar.hidden = true;
}
@end
