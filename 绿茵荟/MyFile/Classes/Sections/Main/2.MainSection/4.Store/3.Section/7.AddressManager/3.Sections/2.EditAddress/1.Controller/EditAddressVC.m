//
//  EditAddressVC.m
//  绿茵荟
//
//  Created by Mac on 17/4/21.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "EditAddressVC.h"
#import "SubmitPostTV.h"

@interface EditAddressVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,strong)NSMutableDictionary * key_views;//字段及对应的文本框
@property(nonatomic,strong)UIButton * defaultBtn;//默认地址按钮
@property(nonatomic,strong)UIImageView * icon;//默认地址图标
@property(nonatomic,strong)NSArray * city_code_array;//省市code及名称数组
@property(nonatomic,strong)UIPickerView * picker;//地区选择器

@end

@implementation EditAddressVC
{
    NSArray * cityList;//当前省的市数组
    NSArray * regionList;//当前市的区数组
    NSInteger provinceRow;//省的行
    NSInteger regionRow;//市的行
    NSMutableDictionary * sendDict;//保存发送的数据
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载主界面
    [self loadMainView];
    provinceRow = 0;
    sendDict = [NSMutableDictionary dictionaryWithDictionary:self.addressDic];
    self.city_code_array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city_code_3" ofType:@"plist"]];
//    NSLog(@"地址信息:%@",self.addressDic);
}
//加载主界面
-(void)loadMainView{
    self.key_views = [NSMutableDictionary new];
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //保存按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveAddress)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    //上部view
    {
        UIView * upView = [UIView new];
        {
            upView.frame = CGRectMake(0, 10, WIDTH, 300);
            upView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:upView];
        }
        //收货人姓名
        {
            //文本框
            {
                UITextField * tf = [UITextField new];
                tf.placeholder = @"收货人姓名";
                tf.font = [UIFont systemFontOfSize:18];
                tf.frame = CGRectMake(14, 10, WIDTH/2, 33);
                [upView addSubview:tf];
                [self.key_views setObject:tf forKey:@"name"];
                tf.text = self.addressDic[@"name"];
            }
            //分割线
            {
                UIView * spaceView = [UIView new];
                spaceView.frame = CGRectMake(14, 53, WIDTH-28, 1);
                spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
                [upView addSubview:spaceView];
            }
        }
        //联系电话
        {
            //文本框
            {
                UITextField * tf = [UITextField new];
                tf.placeholder = @"联系电话";
                tf.font = [UIFont systemFontOfSize:18];
                tf.frame = CGRectMake(14, 64, WIDTH/2, 33);
                [upView addSubview:tf];
                [self.key_views setObject:tf forKey:@"mobile"];
                NSObject * mobile = self.addressDic[@"mobile"];
                if (mobile) {
                    if ([mobile isKindOfClass:[NSString class]]) {
                        tf.text = (NSString *)mobile;
                    }else{
                        NSInteger mo = [self.addressDic[@"mobile"] longValue];
                        tf.text = [NSString stringWithFormat:@"%ld",mo];
                    }
                }
            }
            //分割线
            {
                UIView * spaceView = [UIView new];
                spaceView.frame = CGRectMake(14, 107, WIDTH-28, 1);
                spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
                [upView addSubview:spaceView];
            }
        }
        //省份、城市
        {
            //文本框
            {
                UITextField * tf = [UITextField new];
                tf.placeholder = @"省份、城市";
                tf.font = [UIFont systemFontOfSize:18];
                tf.frame = CGRectMake(14, 118, WIDTH/2, 33);
                [upView addSubview:tf];
                [self.key_views setObject:tf forKey:@"city"];
                NSString * provinceName = self.addressDic[@"provinceName"];
                if (provinceName && provinceName.length) {
                    NSString * cityName = self.addressDic[@"cityName"];
                    NSString * regionName = self.addressDic[@"regionName"];
                    tf.text = [NSString stringWithFormat:@"%@%@%@",provinceName,cityName,regionName];
                }
                [MYTOOL setFontWithLabel:(UILabel *)tf];
                //输入
                {
                    UIPickerView * pick = [UIPickerView new];
                    
                    UIView * v = [UIView new];
                    tf.inputView = v;
                    v.frame = CGRectMake(0, 500, WIDTH, 271);
                    pick.frame = CGRectMake(0, 44, WIDTH, 271-44);
                    pick.dataSource = self;
                    pick.delegate = self;
                    [v addSubview:pick];
                    self.picker = pick;
                    //toolbar
                    UIToolbar * bar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
                    [v addSubview:bar];
                    [bar setBarStyle:UIBarStyleDefault];
                    NSMutableArray *buttons = [[NSMutableArray alloc] init];
                    
                    UIBarButtonItem *myDoneButton = [[ UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                                                   target: self action: @selector(clickOkOfPickerView)];
                    myDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(clickOkOfPickerView)];
                    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                    
                    [buttons addObject:flexibleSpace];
                    [buttons addObject: myDoneButton];
                    
                    
                    [bar setItems:buttons animated:TRUE];
                    
                    //toolbar加个label
                    UILabel * label = [UILabel new];
                    label.text = [NSString stringWithFormat:@"请选择省、市"];
                    label.frame = CGRectMake(WIDTH/2-70, 12, 140, 20);
                    label.textAlignment = NSTextAlignmentCenter;
                    [v addSubview:label];
                    
                    
                }
            }
            //分割线
            {
                UIView * spaceView = [UIView new];
                spaceView.frame = CGRectMake(14, 161, WIDTH-28, 1);
                spaceView.backgroundColor = [MYTOOL RGBWithRed:220 green:220 blue:220 alpha:1];
                [upView addSubview:spaceView];
            }
        }
        //详细地址
        {
            SubmitPostTV * tv = [[SubmitPostTV alloc]initWithFrame:CGRectMake(14, 171, WIDTH-28, 100)];
            tv.placeholderLabel.text = @"请填写详细地址,不少于5个字";
            tv.placeholderLabel.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
            tv.font = [UIFont systemFontOfSize:18];
            [upView addSubview:tv];
            [self.key_views setObject:tv forKey:@"addr"];
            NSString * addr = self.addressDic[@"addr"];
            if (addr && addr.length) {
                tv.text = addr;
                tv.placeholderLabel.hidden = true;
            }
        }
    }
    //下部view
    {
        UIView * view = [UIView new];
        {
            view.frame = CGRectMake(0, 320, WIDTH, 50);
            view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view];
        }
        //图标
        {
            UIImageView * icon = [UIImageView new];
            icon.frame = CGRectMake(10, 10, 30, 30);
            icon.image = [UIImage imageNamed:@"btn_circle_sel"];
            [view addSubview:icon];
            self.icon = icon;
        }
        //文字
        {
            UILabel * label = [UILabel new];
            label.text = @"设为默认地址";
            label.frame = CGRectMake(40, 16, WIDTH/2, 18);
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
            [view addSubview:label];
        }
        //设为默认地址按钮
        {
            UIButton * btn = [UIButton new];
            btn.frame = view.bounds;
            btn.tag = 1;
            self.defaultBtn = btn;
            [btn addTarget:self action:@selector(setDefaultAddressBtnCallback:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btn];
        }
        bool default_addr = [self.addressDic[@"default_addr"] boolValue];
        if (!default_addr) {
            self.defaultBtn.tag = 0;
            self.icon.image = [UIImage imageNamed:@"btn_circle_nor"];
        }
    }
}
//设为默认地址
-(void)setDefaultAddressBtnCallback:(UIButton *)btn{
    //图标-btn_circle_sel-btn_circle_nor
    if (btn.tag == 1) {
        self.defaultBtn.tag = 0;
        self.icon.image = [UIImage imageNamed:@"btn_circle_nor"];
    }else{
        self.defaultBtn.tag = 1;
        self.icon.image = [UIImage imageNamed:@"btn_circle_sel"];
    }
}
#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        cityList = self.city_code_array[provinceRow][@"cityList"];
        return self.city_code_array.count;
    }else if (component == 1){
        regionList = self.city_code_array[provinceRow][@"cityList"][regionRow][@"regionList"];
        return cityList.count;
    }else{
        return regionList.count;
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        NSString * title = self.city_code_array[row][@"provinceName"];
        return title;
    }if (component == 1){
        return cityList[row][@"cityName"];
    }
    return regionList[row][@"regionName"];
}
//数据变动
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        provinceRow = row;
        cityList = self.city_code_array[row][@"cityList"];
        [pickerView reloadComponent:1];
        [pickerView selectRow:0 inComponent:1 animated:true];
        //
        regionRow = 0;
        regionList = self.city_code_array[provinceRow][@"cityList"][0][@"regionList"];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:true];
    }if (component == 1) {
        regionRow = row;
        regionList = self.city_code_array[provinceRow][@"cityList"][row][@"regionList"];
        [pickerView reloadComponent:2];
        [pickerView selectRow:0 inComponent:2 animated:true];
    }
    
}
//pickerView中事件-确定
-(void)clickOkOfPickerView{
    NSInteger row0 = [self.picker selectedRowInComponent:0];
    NSInteger row1 = [self.picker selectedRowInComponent:1];
    NSInteger row2 = [self.picker selectedRowInComponent:2];
    NSDictionary * provinceDic = self.city_code_array[row0];
    NSArray * array = provinceDic[@"cityList"];
    NSDictionary * cityDic = array[row1];
    NSArray * arr_region = cityDic[@"regionList"];
    NSDictionary * regionDic = arr_region[row2];
    
    NSString * provinceCode = provinceDic[@"provinceCode"];//省id
    NSString * provinceName = provinceDic[@"provinceName"];//省名字
    NSString * cityCode = cityDic[@"cityCode"];//城市id
    NSString * cityName = cityDic[@"cityName"];//城市名字
    NSString * regionName = regionDic[@"regionName"];//区名字
    NSString * regionCode = regionDic[@"regionCode"];//区id
    //    NSLog(@"provinceCode:%@",provinceCode);
    //    NSLog(@"provinceName:%@",provinceName);
    //    NSLog(@"cityCode:%@",cityCode);
    //    NSLog(@"cityName:%@",cityName);
    
    UITextField * tf = self.key_views[@"city"];
    tf.font = [UIFont systemFontOfSize:18];
    tf.text = [NSString stringWithFormat:@"%@%@%@",provinceName,cityName,regionName];
    [MYTOOL setFontWithLabel:(UILabel *)tf];
    [sendDict setValue:provinceCode forKey:@"provinceId"];
    [sendDict setValue:provinceName forKey:@"provinceName"];
    [sendDict setValue:cityCode forKey:@"cityId"];
    [sendDict setValue:cityName forKey:@"cityName"];
    [sendDict setValue:regionName forKey:@"regionName"];
    [sendDict setValue:regionCode forKey:@"regionCode"];
    [tf resignFirstResponder];
}



//保存
-(void)saveAddress{
    for (NSString * key in self.key_views.allKeys) {
        id tf = self.key_views[key];
        NSString * string = [tf text];
        if (string == nil || string.length == 0) {
            [SVProgressHUD showErrorWithStatus:@"不可有空数据" duration:1];
            return;
        }
        if ([key isEqualToString:@"addr"]) {
            if (string.length < 5) {
                [SVProgressHUD showErrorWithStatus:@"详细地址\n长度不小于5" duration:2];
                return;
            }
        }
        [sendDict setValue:string forKey:key];
    }
    [sendDict setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
    [sendDict setValue:[NSString stringWithFormat:@"%ld",(long)self.defaultBtn.tag] forKey:@"defaultAddr"];
    [sendDict setValue:self.addressDic[@"addressId"] forKey:@"addressId"];
//    NSLog(@"send:%@",sendDict);
//    NSLog(@"%@",self.addressDic);
    NSString * interfaceName = @"/shop/address/updateAddress.intf";
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDict andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        [self popUpViewController];
        [SVProgressHUD showSuccessWithStatus:back_dic[@"msg"] duration:1];
    }];
    
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 键盘出现及消失通知
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //键盘高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    //文本框
    id someOne = nil;
    for (NSString * key in self.key_views.allKeys) {
        id tv = [self.key_views objectForKey:key];
        if ([tv isFirstResponder]) {
            someOne = tv;
            break;
        }
    }
    //UITextField相对屏幕上侧位置
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[someOne convertRect: [someOne bounds] toView:window];
    //UITextField底部坐标
    float tf_y = rect.origin.y + [someOne frame].size.height;
    if (height + tf_y > HEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, HEIGHT - height - tf_y + 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
}
//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [MYTOOL hiddenTabBar];
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MYTOOL showTabBar];
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
