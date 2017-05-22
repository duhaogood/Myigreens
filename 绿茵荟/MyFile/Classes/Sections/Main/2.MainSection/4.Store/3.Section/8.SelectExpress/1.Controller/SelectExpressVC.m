//
//  SelectExpressVC.m
//  绿茵荟
//
//  Created by Mac on 17/5/3.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SelectExpressVC.h"
#import "ConfirmOrderVC.h"
@interface SelectExpressVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SelectExpressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    
}
//加载主界面
-(void)loadMainView{
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    
//    NSLog(@"快递:%@",self.expressArray);
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    self.automaticallyAdjustsScrollViewInsets = false;
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 50;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary * dic = self.expressArray[indexPath.row];
//    NSLog(@"选择的快递:%@",dic);
    [self.delegate changeExpressWithDictionary:dic];
    [self.navigationController popViewControllerAnimated:true];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.expressArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    cell.textLabel.text = self.expressArray[indexPath.row][@"expressName"];
    //分割线
    {
        UIView * view = [UIView new];
        view.frame = CGRectMake(15, tableView.rowHeight-1, WIDTH-30, 1);
        view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
        [cell addSubview:view];
    }
    return cell;
}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}
@end
