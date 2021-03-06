//
//  GoodsBannerVC.m
//  绿茵荟
//
//  Created by Mac on 17/5/26.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "GoodsBannerVC.h"
#import "GoodsInfoViewController.h"
@interface GoodsBannerVC ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UICollectionView * collectionView ;

@end

@implementation GoodsBannerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    
}
//加载主界面
-(void)loadMainView{
    //返回按钮
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    
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
    
}
#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.goodsList.count;
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
    NSDictionary * dicForCell = self.goodsList[indexPath.row];
    NSString * goodsName = dicForCell[@"goodsName"];
    //    NSLog(@"%ld:%@",indexPath.row,goodsName);
    float price = [dicForCell[@"price"] floatValue];
    NSString * url = dicForCell[@"url"];
    //图片
    UIImageView * imgV = [cell viewWithTag:10000];
    if (imgV == nil){
        imgV = [UIImageView new];
        imgV.frame = CGRectMake(0, 0, cell.frame.size.width, 171);
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
    UILabel * label = [cell viewWithTag:10001];
    float top = 0;
    if (label) {
        label.text = goodsName;
        CGRect rect = imgV.frame;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.numberOfLines = 0;
        int row = 1;
        if (size.width > rect.size.width + label.font.pointSize) {
            row = 2;
            while (size.width > rect.size.width * 2 + label.font.pointSize * 2) {
                label.font = [UIFont systemFontOfSize:label.font.pointSize - 0.1];
                size = [MYTOOL getSizeWithLabel:label];
            }
        }
        label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+19, rect.size.width, size.height * row);
        top = rect.origin.y+rect.size.height+19+size.height * row;
    }else{
        UILabel * label = [UILabel new];
        label.tag = 10001;
        label.text = goodsName;
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        CGRect rect = imgV.frame;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.numberOfLines = 0;
        int row = 1;
        if (size.width > rect.size.width + label.font.pointSize) {
            row = 2;
            while (size.width > rect.size.width * 2 + label.font.pointSize * 2) {
                label.font = [UIFont systemFontOfSize:label.font.pointSize - 0.1];
                size = [MYTOOL getSizeWithLabel:label];
            }
        }
        label.frame = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+19, rect.size.width, size.height * row);
        [cell addSubview:label];
        top = rect.origin.y+rect.size.height+10+size.height * row + 10;
    }
    //商品价格
    UILabel * priceLabel = [cell viewWithTag:10002];
    if (priceLabel) {
        priceLabel.text = [NSString stringWithFormat:@"¥%.2f",price];
        if ((int)price == price) {
            priceLabel.text = [NSString stringWithFormat:@"¥%d",(int)price];
        }
        float marketPrice = [dicForCell[@"marketPrice"] floatValue];
        if (marketPrice) {//有市场价格
            UILabel * label_r = [cell viewWithTag:10003];
            label_r.hidden = false;
            //市场价格
            label_r.text = [NSString stringWithFormat:@" ￥%.2f",marketPrice];
            if ((int)marketPrice == marketPrice) {
                label_r.text = [NSString stringWithFormat:@" ￥%d",(int)marketPrice];
            }
            //价格横线
            UIView * spaceView = [cell viewWithTag:10004];
            spaceView.hidden = false;
        }else{
            //有市场价格
            UILabel * label_r = [cell viewWithTag:10003];
            //价格横线
            UIView * spaceView = [cell viewWithTag:10004];
            label_r.hidden = true;
            spaceView.hidden = true;
        }
    }else{
        UILabel * label = [UILabel new];
        label.tag = 10002;
        label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        CGRect rect = imgV.frame;
        top = 225;
        label.frame = CGRectMake(rect.origin.x, top, rect.size.width, 15);
        [cell addSubview:label];
        label.text = [NSString stringWithFormat:@"¥%.2f",price];
        if ((int)price == price) {
            label.text = [NSString stringWithFormat:@"¥%d",(int)price];
        }
        float marketPrice = [dicForCell[@"marketPrice"] floatValue];
        if (marketPrice) {//有市场价格
            //价格占一半
            label.frame = CGRectMake(rect.origin.x, top, rect.size.width/2, 15);
            //市场价格
            {
                UILabel * label_r = [UILabel new];
                label_r.tag = 10003;
                label_r.frame = CGRectMake(rect.origin.x+rect.size.width/2, top, rect.size.width/2, 15);
                label_r.textAlignment = NSTextAlignmentLeft;
                label_r.textColor = [UIColor grayColor];
                label_r.text = [NSString stringWithFormat:@" ￥%.2f",marketPrice];
                label_r.font = [UIFont systemFontOfSize:15];
                label.textAlignment = NSTextAlignmentRight;
                if ((int)marketPrice == marketPrice) {
                    label_r.text = [NSString stringWithFormat:@" ￥%d",(int)marketPrice];
                }
                [cell addSubview:label_r];
                //价格横线
                {
                    CGSize size = [MYTOOL getSizeWithString:label_r.text andFont:label_r.font];
                    UIView * spaceView = [UIView new];
                    spaceView.tag = 10004;
                    spaceView.frame = CGRectMake(5, 7, size.width, 1);
                    spaceView.backgroundColor = [UIColor grayColor];
                    [label_r addSubview:spaceView];
                }
            }
        }
    }
    
    
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((WIDTH-40)/2, 260);
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
    info.title = self.goodsList[indexPath.row][@"goodsName"];
    
    //网络获取商品详情
    NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
    NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
    if (cityId == nil ) {
        cityId = @"320300";
    }
    NSDictionary * sendDict = @{
                                @"goodsId":[NSString stringWithFormat:@"%d",[self.goodsList[indexPath.row][@"goodsId"] intValue]],
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

//返回
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:true];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}


@end
