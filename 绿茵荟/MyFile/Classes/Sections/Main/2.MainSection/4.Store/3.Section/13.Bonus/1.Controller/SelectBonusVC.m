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

@end

@implementation SelectBonusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        tableView.rowHeight = [MYTOOL getHeightWithIphone_six:98] + 20;
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
}


#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * bonusDict = self.bonusList[indexPath.row];
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate changeBonusWithDictionary:bonusDict];
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.bonusList.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * bonusDic = self.bonusList[indexPath.row];
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
