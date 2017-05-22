//
//  ExchangeViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ExchangeViewController.h"
#import "IntegralRuleVC.h"
@interface ExchangeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,strong)UICollectionView * collectionView;
@end

@implementation ExchangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    self.automaticallyAdjustsScrollViewInsets = false;
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    flowLayout.headerReferenceSize=CGSizeMake(self.view.frame.size.width, [MYTOOL getHeightWithIphone_six:211]); //设置collectionView头视图的大小
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell2"];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    //注册头视图
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeaderView"];
    
}
#pragma mark - UICollectionViewDataSource,UICollectionViewDelegate
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
    static NSString * CellIdentifier = @"UICollectionViewCell2";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary * goodsDic = self.goodsList[indexPath.row];
    //商品图片
    float top = 0;
    {
        UIImageView * imgV = [cell viewWithTag:100];
        float height = [MYTOOL getHeightWithIphone_six:177];
        if (imgV) {
            NSString * url = goodsDic[@"url"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
        }else{
            imgV = [UIImageView new];
            imgV.tag = 100;
            
            imgV.frame = CGRectMake(0, top, cell.frame.size.width, height);
            NSString * url = goodsDic[@"url"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"logo"]];
            [cell addSubview:imgV];
        }
        top += height + 5;
    }
    //商品名字
    {
        UILabel * label = [cell viewWithTag:101];
        if (label) {
            NSString * goodsName = goodsDic[@"goodsName"];
            label.text = goodsName;
            CGSize size = [MYTOOL getSizeWithLabel:label];
            if (size.width > cell.frame.size.width) {
                label.numberOfLines = 0;
                if (size.width > cell.frame.size.width*2) {
                    while (size.width >= cell.frame.size.width * 2 - label.font.pointSize) {
                        label.font = [UIFont systemFontOfSize:label.font.pointSize-0.1];
                        size = [MYTOOL getSizeWithLabel:label];
                    }
                }
                label.frame = CGRectMake(0, top, cell.frame.size.width, size.height * 2);
                top += size.height * 2 + 5;
            }else{
                label.frame = CGRectMake(0, top, cell.frame.size.width, size.height);
                top += size.height + 5;
            }
        }else{
            NSString * goodsName = goodsDic[@"goodsName"];
            label = [UILabel new];
            label.tag = 101;
            label.text = goodsName;
            label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:18]];
            label.textColor = MYCOLOR_46_42_42;
            CGSize size = [MYTOOL getSizeWithLabel:label];
            if (size.width > cell.frame.size.width) {
                label.numberOfLines = 0;
                if (size.width > cell.frame.size.width*2) {
                    while (size.width >= cell.frame.size.width * 2 - label.font.pointSize) {
                        label.font = [UIFont systemFontOfSize:label.font.pointSize-0.1];
                        size = [MYTOOL getSizeWithLabel:label];
                    }
                }
                label.frame = CGRectMake(0, top, cell.frame.size.width, size.height * 2);
                top += size.height * 2 + 5;
            }else{
                label.frame = CGRectMake(0, top, cell.frame.size.width, size.height);
                top += size.height + 5;
            }
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:label];
        }
        
    }
    //需要积分数量
    float left = 0;
    {
        UILabel * label = [cell viewWithTag:102];
        NSInteger point = [goodsDic[@"point"] longValue];
        NSString * text = [NSString stringWithFormat:@"积分%ld",point];
        if (label) {
            label.text = text;
            CGSize size = [MYTOOL getSizeWithLabel:label];
            left = cell.frame.size.width/2-size.width/2;
            label.frame = CGRectMake(left, top, size.width, size.height);
        }else{
            label = [UILabel new];
            label.tag = 102;
            label.text = text;
            label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:15]];
            label.textColor = MYCOLOR_229_64_73;
            CGSize size = [MYTOOL getSizeWithLabel:label];
            left = cell.frame.size.width/2-size.width/2;
            label.frame = CGRectMake(left, top, size.width, size.height);
            [cell addSubview:label];
        }
    }
    //积分图标-icon_dollor
    {
        UIImageView * imgV = [cell viewWithTag:103];
        if (imgV) {
            imgV.frame = CGRectMake(left - 14, top+2, 12, 15);
        }else{
            imgV = [UIImageView new];
            imgV.tag = 103;
            imgV.image = [UIImage imageNamed:@"icon_dollor"];
            imgV.frame = CGRectMake(left - 14, top+2, 12, 15);
            [cell addSubview:imgV];
        }
    }
    /*
     exchangeMaxCount = 1;
     goodsId = 9;
     settingId = 1;
     */
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((WIDTH-40)/2, [MYTOOL getHeightWithIphone_six:255]);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 15, 15);
}
//  返回头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"collectionHeaderView" forIndexPath:indexPath];
        //添加头视图的内容
        float height = header.frame.size.height;
        float down_height = [MYTOOL getHeightWithIphone_six:50];
        NSLog(@"height:%.2f",height);
        //顶部背景
        {
            UIView * view = [UIView new];
            view.frame = CGRectMake(0, 0, WIDTH, 10);
            view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
            [header addSubview:view];
        }
        //背景图-bg_ripple
        {
            UIImageView * imgV = [UIImageView new];
            imgV.image = [UIImage imageNamed:@"bg_ripple"];
            imgV.frame = CGRectMake(0, 10, WIDTH, height-10-down_height);
            [header addSubview:imgV];
        }
        //可用积分提示
        float top = 0;
        {
            UILabel * label = [UILabel new];
            label.text = @"当前可用积分";
            label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:18]];
            label.textColor = [MYTOOL RGBWithRed:189 green:189 blue:189 alpha:1];
            CGSize size = LABEL_SIZE;
            label.frame = CGRectMake(0, 20, WIDTH, size.height);
            label.textAlignment = NSTextAlignmentCenter;
            [header addSubview:label];
            top = 20 + size.height;
        }
        //积分数量
        {
            NSInteger integral = [self.member_dic[@"integral"] longValue];
            UILabel * label = [UILabel new];
            label.text = [NSString stringWithFormat:@"%ld",integral];
            label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:50]];
            label.textColor = MYCOLOR_46_42_42;
            CGSize size = LABEL_SIZE;
            label.frame = CGRectMake(0, top + 5, WIDTH, size.height);
            label.textAlignment = NSTextAlignmentCenter;
            [header addSubview:label];
        }
        //兑换规则按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = CGRectMake(0, height-down_height+2, WIDTH, down_height-4);
            btn.backgroundColor = [UIColor clearColor];
            [header addSubview:btn];
            [btn addTarget:self action:@selector(exchangeRuleCallback:) forControlEvents:UIControlEventTouchUpInside];
        }
        //按钮下方图标及文字
        {
            //左侧图标-icon_rule
            {
                UIImageView * icon = [UIImageView new];
                icon.image = [UIImage imageNamed:@"icon_rule"];
                icon.frame = CGRectMake(14, height-down_height/2-11, 22, 22);
                [header addSubview:icon];
            }
            //文字
            {
                UILabel * label = [UILabel new];
                label.text = @"兑换规则";
                label.font = [UIFont systemFontOfSize:[MYTOOL getHeightWithIphone_six:18]];
                label.textColor = MYCOLOR_46_42_42;
                CGSize size = [MYTOOL getSizeWithLabel:label];
                label.frame = CGRectMake(50, height-down_height/2-size.height/2, size.width, size.height);
                [header addSubview:label];
            }
            //右侧图标-arrow_right
            {
                UIImageView * icon = [UIImageView new];
                icon.image = [UIImage imageNamed:@"arrow_right"];
                icon.frame = CGRectMake(WIDTH - 14 - 10, height-down_height/2-11, 22, 22);
                [header addSubview:icon];
            }
        }
        //分割线
        {
            UIView * view = [UIView new];
            view.frame = CGRectMake(0, height-1, WIDTH, 1);
            view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
            [header addSubview:view];
        }
        return header;
    }
    return nil;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * goodsDic = self.goodsList[indexPath.row];
    [MYTOOL netWorkingWithTitle:@"获取商品"];
    NSString * interface = @"/shop/pointGoods/getPointGoodsInfo.intf";
    NSDictionary * sendDic = @{
                               @"settingId":[NSString  stringWithFormat:@"%ld",[goodsDic[@"settingId"] longValue]]
                                   };
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        NSLog(@"back:%@",back_dic);
    }];
    
    
}
#pragma mark - 按钮事件
//兑换规则按钮事件
-(void)exchangeRuleCallback:(UIButton *)btn{
    [SVProgressHUD showSuccessWithStatus:@"兑换规则" duration:1];
    NSString * interface = @"/sys/getSysInfoBykey.intf";
    NSDictionary * sendDic = @{
                               @"infoKey":@"integral_rule"
                               };
    [MYTOOL netWorkingWithTitle:@"规则获取"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        IntegralRuleVC * vc = [IntegralRuleVC new];
        vc.url = back_dic[@"info"][@"content"];
        vc.title = @"积分规则";
        [self.navigationController pushViewController:vc animated:true];
    }];
}
#pragma mark - 重写返回按钮事件
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
    [MYTOOL hiddenTabBar];
    
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
}

@end
