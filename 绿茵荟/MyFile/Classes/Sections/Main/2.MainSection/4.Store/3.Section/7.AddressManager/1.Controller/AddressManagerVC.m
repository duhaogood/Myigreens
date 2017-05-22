//
//  AddressManagerVC.m
//  绿茵荟
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "AddressManagerVC.h"
#import "ConfirmOrderVC.h"
#import "ManagerAddressVC.h"
@interface AddressManagerVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * addressArray;//地址数组
@end

@implementation AddressManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    
    
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //管理按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"管理" style:UIBarButtonItemStyleDone target:self action:@selector(managerBtnCallback)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-74);
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.rowHeight = 100;
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate changeAddress:self.addressArray[indexPath.row]];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.addressArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSDictionary * addressDic = self.addressArray[indexPath.row];
//    NSLog(@"address:%@",addressDic);
    //是否默认
    bool isDefault = [addressDic[@"default_addr"] boolValue];
    //姓名
    NSString * name = addressDic[@"name"];
    //联系方式
    NSString * mobile = addressDic[@"mobile"];
    //详细地址
    NSString * addr = addressDic[@"addr"];
    //姓名
    {
        UILabel * label = [UILabel new];
        label.text = name;
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        label.frame = CGRectMake(12, 16, WIDTH/2, 18);
        label.font = [UIFont systemFontOfSize:18];
        [cell addSubview:label];
    }
    //联系方式
    {
        UILabel * label = [UILabel new];
        label.text = mobile;
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        label.frame = CGRectMake(WIDTH/2, 16, WIDTH/2-14, 18);
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentRight;
        [cell addSubview:label];
    }
    //详细地址
    UILabel * add_label = [UILabel new];
    {
        add_label.text = addr;
        add_label.textColor = [MYTOOL RGBWithRed:93 green:93 blue:93 alpha:1];
        add_label.frame = CGRectMake(12, 44, WIDTH-12-14, 35);
        add_label.font = [UIFont systemFontOfSize:16];
        [cell addSubview:add_label];
    }
    //是否默认
    if (isDefault) {
        add_label.text = [NSString stringWithFormat:@"            %@",addr];
        UILabel * label = [UILabel new];
        label.text = @"[默认]";
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
        label.frame = CGRectMake(12, 44, size.width, 16);
        [cell addSubview:label];
        
    }
    CGSize size = [MYTOOL getSizeWithString:add_label.text andFont:add_label.font];
    int row = 1;
    {
        float width = WIDTH-12-14;
        float temp = size.width/width;
        if (temp > 0) {
            row = (int)temp + 1;
        }
    }
    add_label.frame = CGRectMake(12, 44, WIDTH-12-14, row*size.height);
    add_label.numberOfLines = 0;
    //分割线
    {
        UIView * spaceView = [UIView new];
        spaceView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
        [cell addSubview:spaceView];
        spaceView.frame = CGRectMake(14, tableView.rowHeight-1, WIDTH-28, 1);
    }
    return cell;
}
//获取所有地址信息
-(void)getAllAddress{
//    NSMutableArray * array = [NSMutableArray new];
//    
//    for (int i = 0; i < 3; i ++) {
//        NSMutableDictionary * dic = [NSMutableDictionary new];
//        [dic setValue:[NSString stringWithFormat:@"向哲-%d",i+1] forKey:@"name"];
//        [dic setValue:[NSString stringWithFormat:@"1872419903%d",i+1] forKey:@"mobile"];
//        [dic setValue:@(100+i+1) forKey:@"addressId"];
//        [dic setValue:@"江苏省南京市浦口区浦珠寺路123号爱心诺大厦18层1801室" forKey:@"addr"];
//        [dic setValue:@"0" forKey:@"default_addr"];
//        [array addObject:dic];
//    }
//    [array[0] setValue:@"1" forKey:@"default_addr"];
//    self.addressArray = array;
//    [self.tableView reloadData];
//    return;
    
    
    
    
    NSString * interface = @"/shop/address/getAddress.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSMutableArray * array = back_dic[@"addressList"];
        if (!array || array.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"暂无地址" duration:2];
        }else{
            self.addressArray = array;
            [self.tableView reloadData];
        }
    }];
    
    /*
    8.15会员地址列表
    Ø接口地址：/shop/address/getAddress.intf
    Ø接口描述：获取会员地址列表
    Ø特别说明：
default：0 不默认 1 默认
    80.81.82.82.1Ø输入参数：
    参数名称	参数含义	参数类型	是否必录
    memberId	会员id	数字	是
    */
}
//右按钮-管理回调
-(void)managerBtnCallback{
    ManagerAddressVC * manager = [ManagerAddressVC new];
    manager.title = @"管理收货地址";
    manager.addressArray = self.addressArray;
    [self.navigationController pushViewController:manager animated:true];
}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getAllAddress];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}
@end
