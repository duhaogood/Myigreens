//
//  SelectBonusVC.m
//  绿茵荟
//
//  Created by Mac on 17/5/31.
//  Copyright © 2017年 杜浩. All rights reserved.
//

#import "SelectBonusVC.h"
#import "ConfirmOrderVC.h"
@interface SelectBonusVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@property(nonatomic,strong)NSMutableArray * bonusArray;
@end

@implementation SelectBonusVC
{
    int pageNo;
}
- (void)viewDidLoad {
    pageNo = 1;
    [super viewDidLoad];
    self.bonusArray = [NSMutableArray arrayWithArray:self.bonusList];
    self.view.backgroundColor = [UIColor whiteColor];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //表视图
    {
        UITableView * tableView = [UITableView new];
        tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT - 64);
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.rowHeight = [MYTOOL getHeightWithIphone_six:98] + 20;
        self.automaticallyAdjustsScrollViewInsets = false;
        tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self headerRefresh];
            // 结束刷新
            [tableView.mj_header endRefreshing];
        }];
        
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        tableView.mj_header.automaticallyChangeAlpha = YES;
        
        // 上拉刷新
        tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            [self footerRefresh];
            [tableView.mj_footer endRefreshing];
        }];
        //覆盖一个没有数据时显示的view
        //@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
        {
            UIView * view = [UIView new];
            view.frame = tableView.bounds;
            self.noDateView = view;
            view.hidden = true;
            [tableView addSubview:view];
            view.backgroundColor = [MYTOOL RGBWithRed:240 green:240 blue:240 alpha:1];
            //没有数据提示
            {
                UILabel * label = [UILabel new];
                label.text = @"暂无优惠券";
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = MYCOLOR_46_42_42;
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(0, 10, WIDTH, 20);
                [view addSubview:label];
            }
        }
        if (_bonusList && _bonusList.count) {
            self.noDateView.hidden = true;
        }else{
            self.noDateView.hidden = false;
        }
    }
    
}
#pragma mark - 上拉、下拉刷新
-(void)headerRefresh{
    pageNo = 1;
    [self freshDiscountCoupon];
}
-(void)footerRefresh{
    pageNo ++;
    [self freshDiscountCoupon];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * bonusDict = self.bonusList[indexPath.row];
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate changeBonusWithDictionary:bonusDict];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bonusArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * bonusDic = self.bonusArray[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
    //背景图
    {
        UIImageView * icon = [UIImageView new];
        icon.frame = CGRectMake(10, 10, WIDTH - 20, tableView.rowHeight - 20);
        icon.image = [UIImage imageNamed:@"coupon"];
        [cell addSubview:icon];
    }
    //优惠券名称
    {
        NSString * name = bonusDic[@"bonusName"];
        UILabel * label = [UILabel new];
        label.text = name;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = MYCOLOR_46_42_42;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(20 + (WIDTH - 20)*0.33, tableView.rowHeight/5, size.width, size.height);
        [cell addSubview:label];
    }
    //优惠券过期时间
    {
        NSString * userEndDate = bonusDic[@"userEndDate"];
        UILabel * label = [UILabel new];
        label.text = [NSString stringWithFormat:@"过期时间:%@",userEndDate];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = MYCOLOR_181_181_181;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(20 + (WIDTH - 20)*0.33, tableView.rowHeight/2, size.width, size.height);
        [cell addSubview:label];
    }
    //订单最低金额可用
    {
        NSString * minGoodsAmount = bonusDic[@"minGoodsAmount"];
        UILabel * label = [UILabel new];
        label.text = [NSString stringWithFormat:@"金额满足%@可以使用",minGoodsAmount];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = MYCOLOR_181_181_181;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(20 + (WIDTH - 20)*0.33, tableView.rowHeight/4*3-size.height/2, size.width, size.height);
        [cell addSubview:label];
    }
    //优惠金额
    {
        float bonusMoney = [bonusDic[@"bonusMoney"] floatValue];
        NSString * text = [NSString stringWithFormat:@"￥%.2f",bonusMoney];
        if (bonusMoney == (int)bonusMoney) {
            text = [NSString stringWithFormat:@"￥%d",(int)bonusMoney];
        }
        UILabel * label = [UILabel new];
        label.text = text;
        label.font = [UIFont systemFontOfSize:25];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        CGSize size = [MYTOOL getSizeWithLabel:label];
        label.frame = CGRectMake(10 , tableView.rowHeight/2-size.height/2, + (WIDTH - 20)*0.33, size.height);
        [cell addSubview:label];
        
    }
    /*
     bonusMoney = 50;
     bonusStatus = 3;
     minGoodsAmount = 100;
     */
    return cell;
}
//重新加载
-(void)freshDiscountCoupon{
    NSString * interface = @"/shop/goods/getUseBonus.intf";
    NSDictionary * send = @{
                            @"memberId":MEMBERID,
                            @"orderPrice":self.orderPrice,
                            @"pageNo":@(pageNo)
                            };
    [MYTOOL netWorkingWithTitle:@"获取可用优惠券"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        //        NSLog(@"back:%@",back_dic);
        NSArray * bonusList = back_dic[@"bonusList"];
        if (pageNo > 1) {
            if (bonusList.count > 0) {
                [self.bonusArray addObjectsFromArray:bonusList];
            }else{
                pageNo --;
                [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
            }
        }else{
            self.bonusArray = [NSMutableArray arrayWithArray:bonusList];
        }
        [self.tableView reloadData];
    } andFailure:^(NSError *error_failure) {
        if (pageNo == 1) {
            [self.bonusArray removeAllObjects];
            [self.tableView reloadData];
        }else{
            pageNo --;
        }
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
