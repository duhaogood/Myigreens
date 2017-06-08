//
//  ManagerAddressVC.m
//  绿茵荟
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ManagerAddressVC.h"
#import "NewAddressVC.h"
#import "EditAddressVC.h"
@interface ManagerAddressVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@end

@implementation ManagerAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    
    
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [UIColor whiteColor];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64-50);
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    tableView.rowHeight = 146;
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
            label.text = @"暂无地址数据";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = MYCOLOR_46_42_42;
            label.font = [UIFont systemFontOfSize:15];
            label.frame = CGRectMake(0, 10, WIDTH, 20);
            [view addSubview:label];
        }
    }
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //添加新地址-icon_add_green
    {
        //文字
        UILabel * label = [UILabel new];
        {
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.text = @"添加新地址";
            label.font = [UIFont systemFontOfSize:18];
            CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
            label.frame = CGRectMake(WIDTH/2 - size.width/2, HEIGHT-64-34, size.width, size.height);
            [self.view addSubview:label];
        }
        //图标
        {
            UIImageView * icon = [UIImageView new];
            icon.image = [UIImage imageNamed:@"icon_add_green"];
            icon.frame = CGRectMake(label.frame.origin.x-30, HEIGHT-64-32, 18, 18);
            [self.view addSubview:icon];
        }
        //添加新地址按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = CGRectMake(0, HEIGHT-64-50, WIDTH, 50);
            [btn addTarget:self action:@selector(addNewAddressBtnCallback) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btn];
        }
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.addressArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    //无法选中
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * addressDic = self.addressArray[indexPath.section];
    //    NSLog(@"address:%@",addressDic);
    //是否默认
    bool isDefault = [addressDic[@"default_addr"] boolValue];
    //地址id
    NSInteger addressId = [addressDic[@"addressId"] longValue];
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
    //设为默认
    UIButton * defaultBtn = nil;
    float top = 114;
    {
        //按钮-btn_circle_nor-btn_circle_sel
        {
            UIButton * btn = [UIButton new];
            defaultBtn = btn;
            [btn setImage:[UIImage imageNamed:@"btn_circle_nor"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(5, 108, 30, 30);
            btn.tag = addressId * 10 + 0;
            [btn addTarget:self action:@selector(setDefaultAddress:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:18];
            label.text = @"设为默认";
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.frame = CGRectMake(40, top, 80, 18);
            [cell addSubview:label];
        }
    }
    //编辑
    {
        //按钮-icon_write
        {
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"icon_write"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(WIDTH-180, 108, 30, 30);
            btn.tag = addressId;
            [btn addTarget:self action:@selector(editAddressBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:18];
            label.text = @"编辑";
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.frame = CGRectMake(WIDTH-150, top, 40, 18);
            [cell addSubview:label];
        }
    }
    //删除
    {
        //按钮-icon_delete
        {
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
            btn.frame = CGRectMake(WIDTH-86, 108, 30, 30);
            btn.tag = addressId;
            [btn addTarget:self action:@selector(deleteAddressBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:18];
            label.text = @"删除";
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.frame = CGRectMake(WIDTH-56, top, 80, 18);
            [cell addSubview:label];
        }
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
        [defaultBtn setImage:[UIImage imageNamed:@"btn_circle_sel"] forState:UIControlStateNormal];
        defaultBtn.tag = addressId * 10 + 1;
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
        spaceView.frame = CGRectMake(14, 99, WIDTH-28, 1);
    }
    return cell;
}

//添加新地址回调
-(void)addNewAddressBtnCallback{
    NewAddressVC * newVC = [NewAddressVC new];
    newVC.title = @"新建地址";
    [self.navigationController pushViewController:newVC animated:true];
}
//编辑地址
-(void)editAddressBtnCallback:(UIButton *)btn{
    for (NSMutableDictionary * dic in self.addressArray) {
        NSInteger addressId = [dic[@"addressId"] longValue];
        if (addressId == btn.tag) {
            EditAddressVC * edit = [EditAddressVC new];
            edit.title = @"编辑地址";
            edit.addressDic = dic;
            [self.navigationController pushViewController:edit animated:true];
            return;
        }
    }
    
}
//删除地址
-(void)deleteAddressBtnCallback:(UIButton *)btn{
//    NSLog(@"删除地址:%ld",btn.tag);
    [MYTOOL showAlertWithViewController:self andTitle:@"确定删除这个地址?" andSureTile:@"删除" andSureBlock:^{
        for (NSMutableDictionary * dic in self.addressArray) {
            NSInteger addressId = [dic[@"addressId"] longValue];
            if (addressId == btn.tag) {
                NSString * interfaceName = @"/shop/address/delAddress.intf";
                NSDictionary * sendDic = @{@"addressId":[NSString stringWithFormat:@"%ld",addressId]};
                [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
                    [self getAllAddress];
                    [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
                }];
                return;
            }
        }
    } andCacel:^{
        
    }];
}
//设为默认地址
-(void)setDefaultAddress:(UIButton *)btn{
//    NSLog(@"设为默认地址:%ld",btn.tag);
    if (btn.tag%10 == 1) {
        return;
    }
    //地址id
    NSInteger addId = btn.tag/10;
    for (NSDictionary * addressDic in self.addressArray) {
        NSInteger addressId = [addressDic[@"addressId"] longValue];
        if (addId == addressId) {
            NSMutableDictionary * sendDic = [NSMutableDictionary new];
            for (NSString * key in addressDic.allKeys) {
                NSString * value = addressDic[key];
                [sendDic setValue:value forKey:key];
            }
            [sendDic setValue:@"1" forKey:@"defaultAddr"];
            [sendDic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
            NSString * interfaceName = @"/shop/address/updateAddress.intf";
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
                [self getAllAddress];
            }];
            return;
        }
    }
}
//获取所有地址信息
-(void)getAllAddress{
    NSString * interface = @"/shop/address/getAddress.intf";
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    [MYNETWORKING getWithInterfaceName:interface andDictionary:@{@"memberId":memberId} andSuccess:^(NSDictionary *back_dic) {
        //        NSLog(@"back:%@",back_dic);
        NSMutableArray * array = back_dic[@"addressList"];
        if (!array || array.count == 0) {
            self.noDateView.hidden = false;
        }else{
            self.noDateView.hidden = true;
            self.addressArray = array;
            [self.tableView reloadData];
        }
    }];
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
