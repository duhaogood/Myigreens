//
//  ShoppingCartVC.m
//  绿茵荟
//
//  Created by Mac on 17/4/19.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "ShoppingCartVC.h"
#import "GoodsInfoViewController.h"
@interface ShoppingCartVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)UIButton * allSelectBtn;//全选
//@property(nonatomic,strong)NSMutableDictionary * viewPartsAllDictionary;//所有部件的字典
@property(nonatomic,strong)UIView * priceView;//总价view
@property(nonatomic,strong)UILabel * allPriceLabel;//总价label
@property(nonatomic,strong)UILabel * allCountLabel;//总个数label
@property(nonatomic,strong)UIView * noDateView;//没有数据时显示的view
@property(nonatomic,strong)UIButton * payBtn;//结算按钮
@end

@implementation ShoppingCartVC
{
    long long lastClickTime;//最后一次点击数量改变按钮
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    lastClickTime = 0;
}
//加载主界面
-(void)loadMainView{
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-74 - 50);
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    tableView.rowHeight = 126;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
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
            label.text = @"购物车空空如也";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = MYCOLOR_46_42_42;
            label.font = [UIFont systemFontOfSize:15];
            label.frame = CGRectMake(0, 10, WIDTH, 20);
            [view addSubview:label];
        }
    }
    //下侧view
    {
        UIView * downView = [UIView new];
        downView.frame = CGRectMake(0, HEIGHT-64-50, WIDTH, 50);
        [self.view addSubview:downView];
        //全选按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = CGRectMake(0, 10, 30, 30);
            [btn setImage:[UIImage imageNamed:@"btn_circle_sel"] forState:UIControlStateNormal];
            // goodsId * 10 + 1、0  :   1选中，0未选中
            btn.tag = 1;
            [btn addTarget:self action:@selector(selectAllBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            [downView addSubview:btn];
            self.allSelectBtn = btn;
        }
        //全选文字
        {
            UILabel * label = [UILabel new];
            label.text = @"全选";
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            label.frame = CGRectMake(28, 17.5, 32, 15);
            label.font = [UIFont systemFontOfSize:15];
            [downView addSubview:label];
            if (WIDTH <= 320) {
                label.frame = CGRectMake(30, 19, 32, 12);
                label.font = [UIFont systemFontOfSize:12];
            }
        }
        //中间的view
        /*合计(不含运费):还有下面共2件   放在一个辅助view上，随右侧钱的长度改变位置*/
        {
            UIView * priceView = [UIView new];
            {
                self.priceView = priceView;
                priceView.frame = CGRectMake(70, 0, 85, 50);
//                priceView.backgroundColor = [UIColor greenColor];
                [downView addSubview:priceView];
                if (WIDTH <= 320) {
                    priceView.frame = CGRectMake(62, 0, 85, 50);
                }
            }
            //合计提示
            UILabel * all_state_label = [UILabel new];
            {
                all_state_label.text = @"合计";
                all_state_label.font = [UIFont systemFontOfSize:15];
                all_state_label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                CGSize size = [MYTOOL getSizeWithString:all_state_label.text andFont:all_state_label.font];
                all_state_label.frame = CGRectMake(0, 10, size.width, size.height);
                [priceView addSubview:all_state_label];
                if (WIDTH <= 320) {
                    all_state_label.font = [UIFont systemFontOfSize:11];
                    size = [MYTOOL getSizeWithString:all_state_label.text andFont:all_state_label.font];
                    all_state_label.frame = CGRectMake(0, 10, size.width, size.height);
                }
            }
            //不含运费提示
            {
                UILabel * label = [UILabel new];
                label.text = @"(不含运费):";
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
                CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
                label.frame = CGRectMake(all_state_label.frame.size.width, 13, size.width, size.height);
                [priceView addSubview:label];
                if (WIDTH <= 320) {
                    label.font = [UIFont systemFontOfSize:8];
                    size = [MYTOOL getSizeWithString:label.text andFont:label.font];
                    label.frame = CGRectMake(all_state_label.frame.size.width, 13, size.width, size.height);
                }
            }
            //件数
            {
                UILabel * label = [UILabel new];
                self.allCountLabel = label;
                label.text = @"共112件";
                label.font = [UIFont systemFontOfSize:12];
                label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
                label.frame = CGRectMake(0, 32, WIDTH/2, 12);
                [priceView addSubview:label];
                if (WIDTH <= 320) {
                    label.font = [UIFont systemFontOfSize:9];
                    label.frame = CGRectMake(0, 29, WIDTH/2, 12);
                }
            }
        }
        //总钱
        {
            UILabel * label = [UILabel new];
            label.text = @"¥0";
            self.allPriceLabel = label;
            label.textColor = [MYTOOL RGBWithRed:229 green:64 blue:73 alpha:1];
            label.frame = CGRectMake(165, 10, WIDTH/3, 18);
            label.font = [UIFont systemFontOfSize:18];
            if (WIDTH <= 320) {
                label.font = [UIFont systemFontOfSize:15];
                label.frame = CGRectMake(132, 10, WIDTH/3, 18);
            }
            [downView addSubview:label];
        }
        //结算按钮
        {
            UIButton * btn = [UIButton new];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_green"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_pay_gray"] forState:UIControlStateDisabled];
            [btn setTitle:@"去结算" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(payCallback) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(WIDTH-119-10, 5.5, 119, 39);
            [downView addSubview:btn];
            self.payBtn = btn;
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            if (WIDTH <= 320) {
                btn.titleLabel.font = [UIFont systemFontOfSize:13];
                btn.frame = CGRectMake(WIDTH-100-10, 8.5, 100, 33);
            }
        }
    }
    
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * goodsDic = self.goodsOfCart_array[indexPath.row];
    NSInteger goodsId = [goodsDic[@"goodsId"] longValue];
    //网络获取商品详情
    NSString * interfaceName = @"/shop/goods/getGoodsInfo.intf";
    NSString * cityId = [MYTOOL getProjectPropertyWithKey:@"cityId"];
    if (cityId == nil ) {
        cityId = @"320300";
    }
    NSDictionary * sendDict = @{
                                @"goodsId":[NSString stringWithFormat:@"%ld",goodsId],
                                @"cityId":cityId
                                };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"商品详情:%@",back_dic[@"goods"]);
        GoodsInfoViewController * info = [GoodsInfoViewController new];
        info.goodsInfoDictionary = back_dic[@"goods"];
        [self.navigationController pushViewController:info animated:true];
    }];
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.goodsOfCart_array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    NSMutableDictionary * goodsDic = self.goodsOfCart_array[indexPath.row];
    float height = tableView.rowHeight;
    //选中按钮-btn_circle_nor-btn_circle_sel
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(5, height/2-15, 30, 30);
        [btn setImage:[UIImage imageNamed:@"btn_circle_sel"] forState:UIControlStateNormal];
        // indexPath.row * 10 + 1、0  :   1选中，0未选中
        btn.tag = indexPath.row * 10 + 1;
        bool isSelect = [goodsDic[@"select"] boolValue];
        if (!isSelect) {
            [btn setImage:[UIImage imageNamed:@"btn_circle_nor"] forState:UIControlStateNormal];
            // goodsId * 10 + 1、0  :   1选中，0未选中
            btn.tag = indexPath.row * 10 + 0;
        }
        [btn addTarget:self action:@selector(goodsSelectOrDeselectCallback:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [goodsDic setValue:btn forKey:@"selectBtn"];
    }
    //图片
    {
        UIImageView * imgV = [UIImageView new];
        imgV.frame = CGRectMake(34, 18, 90, 90);
        [imgV sd_setImageWithURL:[NSURL URLWithString:goodsDic[@"url"]] placeholderImage:[UIImage imageNamed:@"logo"]];
        [cell addSubview:imgV];
        
    }
    //商品名称
    float top = 14;
    {
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(130, top, WIDTH-140-35, 18);
        label.text = goodsDic[@"goodsName"];
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        label.font = [UIFont systemFontOfSize:18];
        if (WIDTH < 400) {
            label.font = [UIFont systemFontOfSize:14];
            if (WIDTH < 350) {
                label.font = [UIFont systemFontOfSize:12];
            }
        }
        CGSize size = [MYTOOL getSizeWithLabel:label];
        if (size.width > WIDTH-140-40) {
            label.frame = CGRectMake(130, top, WIDTH-140-35, size.height*2);
            label.numberOfLines = 0;
            top += size.height*2+5;
            if (size.width > 2*(WIDTH-180)) {
                while (size.width > 2*(WIDTH-180)) {
                    label.font = [UIFont systemFontOfSize:(label.font.pointSize-1)];
                    size = [MYTOOL getSizeWithLabel:label];
                }
            }
        }else{
            top += size.height + 5;
        }
        [cell addSubview:label];
    }
    //规格
    {
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(130, top, WIDTH-147, 15);
        label.text = [NSString stringWithFormat:@"规格:%@", goodsDic[@"productName"]];
        label.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        label.font = [UIFont systemFontOfSize:15];
        if (WIDTH < 400) {
            label.font = [UIFont systemFontOfSize:12];
            if (WIDTH < 350) {
                label.font = [UIFont systemFontOfSize:9];
            }
        }
        if (WIDTH < 350) {
            CGSize size = [MYTOOL getSizeWithLabel:label];
            label.frame = CGRectMake(130, top, WIDTH-147, size.height*2);
            label.numberOfLines = 0;
            if (size.width > 2*(WIDTH-147)) {
                while (size.width > 2*(WIDTH-147)) {
                    label.frame = CGRectMake(130, top, WIDTH-147, size.height*2);
                    label.font = [UIFont systemFontOfSize:(label.font.pointSize-1)];
                    size = [MYTOOL getSizeWithLabel:label];
                }
            }
        }else{
            CGSize size = [MYTOOL getSizeWithLabel:label];
            if (size.width > WIDTH-147) {
                [MYTOOL setFontWithLabel:label];
            }
        }
        [cell addSubview:label];
    }
    //删除按钮
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(WIDTH-40, 13, 30, 30);
        [btn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
        // goodsId * 10 + 1、0  :   1选中，0未选中
        btn.tag = indexPath.row;
        [btn addTarget:self action:@selector(deleteGoodsBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        
    }
    NSInteger quantity = [goodsDic[@"quantity"] longValue];
    //减少数量按钮-btn_reduce_nor-btn_reduce_disabled
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(130, 80, 30, 30);
        [btn setImage:[UIImage imageNamed:@"btn_reduce_nor"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_reduce_disabled"] forState:UIControlStateDisabled];
        btn.tag = indexPath.row;
        if (quantity <= 1) {
            btn.enabled = false;
        }
        [btn addTarget:self action:@selector(subtractBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [goodsDic setValue:btn forKey:@"subtract"];
    }
    //数量
    {
        UILabel * label = [UILabel new];
        label.frame = CGRectMake(160, 87.5, 37, 15);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        [cell addSubview:label];
        label.font = [UIFont systemFontOfSize:15];
        label.text = [NSString stringWithFormat:@"%ld",quantity];
        [goodsDic setValue:label forKey:@"number"];
    }
    //增加数量按钮
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(197, 80, 30, 30);
        [btn setImage:[UIImage imageNamed:@"btn_plus"] forState:UIControlStateNormal];
        btn.tag = indexPath.row;
        [btn addTarget:self action:@selector(addBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btn];
        [goodsDic setValue:btn forKey:@"add"];
    }
    //总钱
    {
        NSInteger quantity = [goodsDic[@"quantity"] longValue];//数量
        float price = [goodsDic[@"price"] floatValue];//单价
        UILabel * label = [UILabel new];
        label.textColor = [MYTOOL RGBWithRed:220 green:53 blue:53 alpha:1];
        float price_all = quantity*price;
        label.text = [NSString stringWithFormat:@"¥%.2f",price_all];
        if ((int)price_all == price_all) {
            label.text = [NSString stringWithFormat:@"¥%d",(int)price_all];
        }
        label.font = [UIFont systemFontOfSize:16];
        CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
        label.frame = CGRectMake(WIDTH-10-size.width, 93, size.width, 16);
        [cell addSubview:label];
        [goodsDic setValue:label forKey:@"priceLabel"];
    }
    //分割线
    {
        if (indexPath.row < self.goodsOfCart_array.count - 1) {
            UIView * view = [UIView new];;
            view.backgroundColor = [MYTOOL RGBWithRed:240 green:240 blue:240 alpha:1];
            view.frame = CGRectMake(10, 125, WIDTH-20, 1);
            [cell addSubview:view];
        }
    }
    /*
     cartId	购物车id	数字
     goodsId	商品id	数字
     goodsName	商品名称	字符串
     image	商品图片	字符串
     marketPrice	市场价格	double
     productId	产品id	数字
     productName	规格型号	字符串
     price	商品价格	double
     quantity	购买数量	数字
     */
//    [self.viewPartsAllDictionary setValue:viewPartsDictionary forKey:[NSString stringWithFormat:@"%ld",indexPath.row]];
    return cell;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
//进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [MYTOOL showAlertWithViewController:self andTitle:@"确定删除" andSureTile:@"删除" andSureBlock:^{
            [self deleteGoodsFromGoodsCartWithIndexOfCartArray:indexPath.row];
        } andCacel:^{
            
        }];
    }
}

#pragma mark - 用户点击事件
//减少商品数量
-(void)subtractBtnCallback:(UIButton *)btn{
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    if (theTime - lastClickTime <= 300) {
        return;
    }
    lastClickTime = theTime;
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:self.goodsOfCart_array[btn.tag]];
    NSInteger quantity = [dic[@"quantity"] longValue];
    quantity --;
    [dic setObject:@(quantity) forKey:@"quantity"];
    [dic setObject:@"update" forKey:@"operator"];
    [dic setObject:MEMBERID forKey:@"memberId"];
    [self updateGoodsCartDataWithGoodsDictionary:dic];
}
//增加商品数量
-(void)addBtnCallback:(UIButton *)btn{
    NSTimeInterval nowtime = [[NSDate date] timeIntervalSince1970]*1000;
    long long theTime = [[NSNumber numberWithDouble:nowtime] longLongValue];
    if (theTime - lastClickTime <= 300) {
        return;
    }
    lastClickTime = theTime;
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:self.goodsOfCart_array[btn.tag]];
    NSInteger quantity = [dic[@"quantity"] longValue];
    quantity ++;
    [dic setObject:@(quantity) forKey:@"quantity"];
    [dic setObject:@"update" forKey:@"operator"];
    [dic setObject:MEMBERID forKey:@"memberId"];
    [self updateGoodsCartDataWithGoodsDictionary:dic];
}
//更新购物车数据
-(void)updateGoodsCartDataWithGoodsDictionary:(NSDictionary *)goodsDic{
    NSString * interfaceName = @"/shop/cart/getGoods.intf";
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:goodsDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        [self getGoodsOfCartData];
    }];
    /*
     memberId	会员id	数字	是
     cartId	购物车id	数字	是
     productId	产品id	数字	是
     quantity	购买数量	数字	是
     operator	操作	字符串	是
     */
    
}
//重置价格
-(void)reloadPriceWithNumber:(NSInteger)quantity andIndex:(NSInteger)index{
    UILabel * label = self.goodsOfCart_array[index][@"priceLabel"];
    NSDictionary * goodsDic = self.goodsOfCart_array[index];
    float price = [goodsDic[@"price"] floatValue];//单价
    float price_all = quantity*price;
    label.text = [NSString stringWithFormat:@"¥%.2f",price_all];
    if ((int)price_all == price_all) {
        label.text = [NSString stringWithFormat:@"¥%d",(int)price_all];
    }
    label.font = [UIFont systemFontOfSize:18];
    CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
    label.frame = CGRectMake(WIDTH-10-size.width, 93, size.width, 18);
    [self reloadAllPrice];
}
//商品选中按钮或取消选择
-(void)goodsSelectOrDeselectCallback:(UIButton *)btn{
//    NSLog(@"tag:%ld",btn.tag);
    NSInteger state = btn.tag % 10;
    if (state) {//原来为选中状态,改为未选中状态
        btn.tag = btn.tag - 1;
        [btn setImage:[UIImage imageNamed:@"btn_circle_nor"] forState:UIControlStateNormal];
        self.allSelectBtn.tag = 0;
        [self.allSelectBtn setImage:[UIImage imageNamed:@"btn_circle_nor"] forState:UIControlStateNormal];
        [self.goodsOfCart_array[btn.tag/10] setValue:@"0" forKey:@"select"];
    }else{//原来为未选中状态，改为选中状态
        btn.tag = btn.tag + 1;
        [btn setImage:[UIImage imageNamed:@"btn_circle_sel"] forState:UIControlStateNormal];
        [self.goodsOfCart_array[btn.tag/10] setValue:@"1" forKey:@"select"];
    }
    [self reloadAllPrice];
}
//全选按钮回调
-(void)selectAllBtnCallback:(UIButton *)btn{
//    NSLog(@"tag:%ld",btn.tag);
    NSInteger state = btn.tag % 10;
    if (state) {//原来为选中状态,改为未选中状态
        btn.tag = btn.tag - 1;
        [btn setImage:[UIImage imageNamed:@"btn_circle_nor"] forState:UIControlStateNormal];
        for (NSMutableDictionary * dic in self.goodsOfCart_array) {
            [dic setValue:@"0" forKey:@"select"];
        }
    }else{//原来为未选中状态，改为选中状态
        btn.tag = btn.tag + 1;
        [btn setImage:[UIImage imageNamed:@"btn_circle_sel"] forState:UIControlStateNormal];
        for (NSMutableDictionary * dic in self.goodsOfCart_array) {
            [dic setValue:@"1" forKey:@"select"];
        }
    }
    [self.tableView reloadData];
    [self reloadAllPrice];
}
//删除商品按钮回调
-(void)deleteGoodsBtnCallback:(UIButton *)btn{
    [MYTOOL showAlertWithViewController:self andTitle:@"确定删除" andSureTile:@"删除" andSureBlock:^{
        [self deleteGoodsFromGoodsCartWithIndexOfCartArray:btn.tag];
    } andCacel:^{
        
    }];
}
//删除购物车商品
-(void)deleteGoodsFromGoodsCartWithIndexOfCartArray:(NSInteger)index{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:self.goodsOfCart_array[index]];
    NSInteger quantity = [dic[@"quantity"] longValue];
    [dic setObject:@(quantity) forKey:@"quantity"];
    [dic setObject:@"del" forKey:@"operator"];
    [dic setObject:MEMBERID forKey:@"memberId"];
    [self updateGoodsCartDataWithGoodsDictionary:dic];
}
//结算回调
-(void)payCallback{
    NSString * interfaceName = @"/shop/order/confirmOrder.intf";
    NSMutableDictionary * sendDic = [NSMutableDictionary new];
    [sendDic setValue:MEMBERID forKey:@"memberId"];
    //把选择的商品重新放入一个数组
    NSMutableArray * goodsArray = [NSMutableArray new];
    for (NSMutableDictionary * dict in self.goodsOfCart_array) {
        bool isSelect = [dict[@"select"] boolValue];
        if (isSelect) {
            [goodsArray addObject:dict];
        }
    }
    //如果结算时没有商品被选择
    if (goodsArray.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择商品" duration:2];
        return;
    }
    
    NSMutableString * ms = [NSMutableString new];
    NSInteger cartId = [goodsArray[0][@"cartId"] longValue];
    [ms appendString:[NSString stringWithFormat:@"%ld",cartId]];
    if (goodsArray.count> 1) {
        for (int i = 1; i < goodsArray.count; i ++) {
            cartId = [goodsArray[i][@"cartId"] longValue];
            [ms appendString:[NSString stringWithFormat:@",%ld",cartId]];
        }
    }
    [sendDic setValue:ms forKey:@"cartIds"];
    [sendDic setValue:@"0" forKey:@"integral"];
//    NSLog(@"send:%@",sendDic);
    [SVProgressHUD showWithStatus:@"结算中…" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        ConfirmOrderVC * orderVC = [ConfirmOrderVC new];
        orderVC.order = back_dic[@"order"];
        orderVC.goodsList = back_dic[@"goodsList"];
        orderVC.integral = 0;
        orderVC.receiptAddress = back_dic[@"receiptAddress"];
        orderVC.title = @"确认订单";
        NSMutableArray * arr = [NSMutableArray new];
        for (NSMutableDictionary * dict in self.goodsOfCart_array) {
            bool isSelect = [dict[@"select"] boolValue];
            if (isSelect) {
                [arr addObject:dict];
            }
        }
//        orderVC.goodsArray = arr;
//        NSString * priceString = self.allPriceLabel.text;
//        orderVC.goodsPriceAll = [[priceString substringFromIndex:1] floatValue];
        [self.navigationController pushViewController:orderVC animated:true];
    }];
}
//重置总钱及件数
-(void)reloadAllPrice{
    float price_all = 0;
    NSInteger num = 0;
    bool isAllSelect = true;
    for (NSDictionary * dict in self.goodsOfCart_array) {
        bool isSelect = [dict[@"select"] boolValue];
        if (!isSelect) {
            isAllSelect = false;
            continue;
        }
        NSInteger quantity = [dict[@"quantity"] longValue];
        float price = [dict[@"price"] floatValue];//单价
        price_all += quantity * price;
        num += quantity;
    }
    //总钱
    self.allPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",price_all];
    if ((int)price_all == price_all) {
        self.allPriceLabel.text = [NSString stringWithFormat:@"¥%d",(int)price_all];
    }
    //总件数
    self.allCountLabel.text = [NSString stringWithFormat:@"共%ld件",num];
    if (isAllSelect) {
        self.allSelectBtn.tag = 1;
        [self.allSelectBtn setImage:[UIImage imageNamed:@"btn_circle_sel"] forState:UIControlStateNormal];
    }else{
        self.allSelectBtn.tag = 0;
        [self.allSelectBtn setImage:[UIImage imageNamed:@"btn_circle_nor"] forState:UIControlStateNormal];
    }
}

#pragma mark - 网络请求
//加载购物车数组
-(void)getGoodsOfCartData{
    self.goodsOfCart_array = [NSMutableArray new];
    NSString * interfaceName = @"/shop/cart/getCartGoods.intf";
    NSDictionary * sendDic = @{
                               @"memberId":MEMBERID
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"购物车:%@",back_dic);
        NSArray * array = back_dic[@"cartList"];
        if (array == nil || array.count == 0) {
            self.noDateView.hidden = false;
            self.payBtn.enabled = false;
        }else{
            self.noDateView.hidden = true;
            self.payBtn.enabled = true;
        }
        for (NSDictionary * dic in array) {
            NSMutableDictionary * dict = [NSMutableDictionary new];
            for (NSString * key in dic.allKeys) {
                NSObject * object = dic[key];
                [dict setObject:object forKey:key];
            }
            [dict setObject:@"1" forKey:@"select"];
            [self.goodsOfCart_array addObject:dict];
        }
        if (self.goodsOfCart_array.count == 0) {
            self.noDateView.hidden = false;
        }else{
            self.noDateView.hidden = true;
        }
        [self.tableView reloadData];
        [self reloadAllPrice];
    }];
}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    [self getGoodsOfCartData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
}
@end
