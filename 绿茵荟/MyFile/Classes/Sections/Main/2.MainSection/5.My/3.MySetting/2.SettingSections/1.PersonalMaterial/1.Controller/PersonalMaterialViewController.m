//
//  PersonalMaterialViewController.m
//  绿茵荟
//
//  Created by Mac on 17/4/5.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "PersonalMaterialViewController.h"
#import "MyVC.h"
#import "PersonalSignViewController.h"
#import "SettingViewController.h"

@interface PersonalMaterialViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)UITableView * tableView;//主tableView
@property(nonatomic,strong)UIImageView * userImgView;//用户头像框
@property(nonatomic,strong)UIPickerView * picker;//用户选择pickerView
@property(nonatomic,strong)NSArray * view_data_array;//datasource
@property(nonatomic,strong)NSArray * city_code_array;//省市code及名称数组
@property(nonatomic,strong)NSMutableDictionary * title_tf_map;//标题为key，文本框为value
@end

@implementation PersonalMaterialViewController

{
    //picker数据
    NSArray * cityList;//当前省的市数组
    NSArray * regionList;//当前市的区数组
    NSInteger provinceRow;//省的行
    NSInteger regionRow;//市的行
//    NSArray * city_array;//读取的城市数组
    NSArray * region_array;//区数组
    NSArray * sex_array;//性别
    NSDictionary * bir_array;//生日
    NSString * key_picker;//数据源依据
    UITextField * current_tf;//当前正在编辑的文本框
    bool user_icon_change;//头像是否有变化
    NSDictionary * selectAreaDic;//选择的地区信息
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view_data_array = @[
                             @[
                                 @"头像",@"昵称"
                                 ],
                             @[
                                 @"性别",@"出生日期",@"所在地",@"职业",@"个人签名"
                                 ]
                             ];
    self.view.backgroundColor = [UIColor whiteColor];
    //左侧按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(backToMyVC)];
    //右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(submitSaveBtn)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    //加载数据源
    [self loadPickerData];
    //加载主界面
    [self loadMainView];
//    NSLog(@"member_dic:%@",self.member_dic);
    user_icon_change = false;
    [self refreshViewData];
}
//加载主界面
-(void)loadMainView{
    self.title_tf_map = [NSMutableDictionary new];
    UITableView * tableView = [UITableView new];
    tableView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    tableView.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    //不显示分割线
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}
//加载picker数据
-(void)loadPickerData{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"city_code_3" ofType:@"plist"];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    self.city_code_array = data;
    sex_array = @[@"男",@"女"];
    bir_array = @{
                  @"year":[NSMutableArray new],
                  @"month":[NSMutableArray new]
                  };
    
    //年
    for (int i = 1; i < 5555; i ++) {
        [bir_array[@"year"] addObject:[NSString stringWithFormat:@"%d",i]];
    }
    for (int i = 1; i < 5555; i ++) {
        [bir_array[@"month"] addObject:[NSString stringWithFormat:@"%d",i%12 + 1]];
    }
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSString * title = self.view_data_array[indexPath.section][indexPath.row];
    UITextField * tf = [self.title_tf_map objectForKey:title];
    if (tf) {
        [tf becomeFirstResponder];
    }else{//头像
        [MYTOOL hideKeyboard];
        [self submitSelectImage];
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 95/667.0*HEIGHT;
    }else{
        return 60/667.0*HEIGHT;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.view_data_array.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.view_data_array[section] count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [UITableViewCell new];
    float height = indexPath.section == 0 && indexPath.row == 0 ? 95/667.0*HEIGHT : 60/667.0*HEIGHT;
    //标题
    {
        UILabel * title_label = [UILabel new];
        title_label.text = self.view_data_array[indexPath.section][indexPath.row];
        title_label.frame = CGRectMake(14/375.0*WIDTH, height/2-9, WIDTH/4, 18);
        title_label.textColor = [MYTOOL RGBWithRed:46 green:42 blue:42 alpha:1];
        [cell addSubview:title_label];
        
    }
    //头像
    {
        if (indexPath.section == 0 && indexPath.row == 0) {
            UIImageView * imgV = [UIImageView new];
            imgV.image = [UIImage imageNamed:@"cam"];
            imgV.frame = CGRectMake(WIDTH - 30-height*0.65, (height - height*0.65)/2, height*0.65, height*0.65);
            imgV.layer.masksToBounds = true;
            imgV.layer.cornerRadius = height*0.65/2;
            [cell addSubview:imgV];
//            NSLog(@"user:%@",self.member_dic);
            for (NSString * key in self.member_dic) {
                NSObject * obj = self.member_dic[key];
//                NSLog(@"%@:%@",key,obj);
            }
#warning 用户头像
            NSString * url_string = self.member_dic[@"headUrl"][@"smallUrl"];
            NSURL *url = [NSURL URLWithString:url_string];
            
            dispatch_queue_t queue =dispatch_queue_create("loadImage",NULL);
            dispatch_async(queue, ^{
                
                NSData *resultData = [NSData dataWithContentsOfURL:url];
                UIImage *img = [UIImage imageWithData:resultData];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    imgV.image = img;
                });
                
            });
            
            
            self.userImgView = imgV;
            [imgV setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView:)];
            tapGesture.numberOfTapsRequired=1;
            [imgV addGestureRecognizer:tapGesture];
        }
    }
    //文本框
    if (!(indexPath.section == 0 && indexPath.row == 0)) {
        UITextField * tf = [UITextField new];
        tf.frame = CGRectMake(WIDTH/3, height/2-10, WIDTH/3*2-30, 20);
//        tf.backgroundColor = [UIColor redColor];
        [cell addSubview:tf];
        tf.textAlignment = NSTextAlignmentRight;
        tf.placeholder = @"未设置";
        tf.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        tf.font = [UIFont systemFontOfSize:15];
        NSString * title = self.view_data_array[indexPath.section][indexPath.row];
        [self.title_tf_map setObject:tf forKey:title];
        if ([title isEqualToString:@"性别"] || [title isEqualToString:@"出生日期"] || [title isEqualToString:@"所在地"] || [title isEqualToString:@"个人签名"]) {
            tf.delegate = self;
        }
        
    }
    //右侧图标
    {
        UIImageView * imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"arrow_right"];
        imgV.frame = CGRectMake(WIDTH-30, height/2-15, 30, 30);
        [cell addSubview:imgV];
    }
    //分割线
    {
        if (indexPath.row != [self.view_data_array[indexPath.section] count] - 1) {
            UIView * spaceView = [UIView new];
            spaceView.backgroundColor = [DHTOOL RGBWithRed:227 green:227 blue:227 alpha:1];
            spaceView.frame = CGRectMake(14/375.0*WIDTH, height-1, WIDTH-14/375.0*WIDTH*2, 1);
            [cell addSubview:spaceView];
        }
    }
    [self refreshViewData];
    return cell;
}
#pragma mark - cell滚动delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //隐藏键盘
    [MYTOOL hideKeyboard];
}
#pragma mark - 文本框代理
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return false;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    NSLog(@"不让你编辑");
    /*  下边3个文本框用户无法输入，必须用pickerview
     性别
     出生日期
     所在城市
     */
    for (NSString * key_map in self.title_tf_map.allKeys) {
        if ([textField isEqual:self.title_tf_map[key_map]]) {
            key_picker = key_map;
            break;
        }
    }
    //如果是个性签名
    if ([key_picker isEqualToString:@"个人签名"]) {
        PersonalSignViewController * signVC = [PersonalSignViewController new];
        signVC.title = @"个人签名";
        signVC.delegate = self;
        NSString * title = [self.title_tf_map[@"个人签名"] text];
        signVC.content = title;
        [self.navigationController pushViewController:signVC animated:true];
        return false;
    }
    
    
    UIPickerView * pick = [UIPickerView new];
    
    UIView * v = [UIView new];
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
    label.text = [NSString stringWithFormat:@"请选择%@",key_picker];
    label.frame = CGRectMake(WIDTH/2-70, 12, 140, 20);
    label.textAlignment = NSTextAlignmentCenter;
    [v addSubview:label];
    
    textField.inputView = v;
    //默认日期--当天
    if ([key_picker isEqualToString:@"出生日期"]) {
        //先获取今天日期
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        
        int year =(int) [dateComponent year];
        int month = (int) [dateComponent month];
        int day = (int) [dateComponent day];
        
        
        [pick selectRow:year-1 inComponent:0 animated:NO];
        [pick selectRow:month-2+12*100 inComponent:1 animated:NO];
        [pick selectRow:day-1 inComponent:2 animated:NO];
        
        
    }
    
    return true;
}
#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([key_picker isEqualToString:@"性别"]) {
        return 2;
    }else if ([key_picker isEqualToString:@"出生日期"]) {
        if (component == 0) {
            return 2222;
        }
        if (component == 1) {
            return [bir_array[@"month"] count];
        }
        //获取年
        NSInteger year = [pickerView selectedRowInComponent:0];
        //获取月
        NSInteger row_2 = [pickerView selectedRowInComponent:1];
        int month = [bir_array[@"month"][row_2] intValue];
        
        int days = [DHTOOL getDaysInThisYear:(int)year withMonth:month];
//        NSLog(@"%d月--一共%d天",month,days);
        return days;
    }else{
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
    /*
     性别
     出生日期
     所在城市
     */
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if ([key_picker isEqualToString:@"性别"]) {
        return 1;
    }else if ([key_picker isEqualToString:@"出生日期"]) {
        return 3;
    }else{
        return 3;
    }
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if ([key_picker isEqualToString:@"性别"]) {
        switch (row) {
            case 0:
                return @"男";
                break;
            default:
                return @"女";
                break;
        }
        
    }else if ([key_picker isEqualToString:@"出生日期"]) {
        if (component == 0) {
            return [NSString stringWithFormat:@"%@年",bir_array[@"year"][row]];
        }
        if (component == 1) {
            return [NSString stringWithFormat:@"%@月",bir_array[@"month"][row]];
        }
        return [NSString stringWithFormat:@"%@日",[NSString stringWithFormat:@"%ld",row+1]];
        
    }else{//地区
        if (component == 0) {
            NSString * title = self.city_code_array[row][@"provinceName"];
            return title;
        }if (component == 1){
            return cityList[row][@"cityName"];
        }
        return regionList[row][@"regionName"];
    }
}
//pickerView中事件-确定
-(void)clickOkOfPickerView{
    UITextField * tf = self.title_tf_map[key_picker];
    
    if ([key_picker isEqualToString:@"性别"]) {//1
        NSInteger row = [self.picker selectedRowInComponent:0];
        tf.text = (row == 0) ?@"男":@"女";
        
    }else if ([key_picker isEqualToString:@"出生日期"]) {//3
        NSInteger row0 = [self.picker selectedRowInComponent:0];
        NSInteger row1 = [self.picker selectedRowInComponent:1];
        NSInteger row2 = [self.picker selectedRowInComponent:2];
        
        NSString * y = bir_array[@"year"][row0];
        NSString * m = bir_array[@"month"][row1];
        NSString * d = [NSString stringWithFormat:@"%ld",row2+1];
        tf.text = [NSString stringWithFormat:@"%@.%02d.%02d",y,[m intValue],[d intValue]];
    }else{//地区 2
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
        
        tf.text = [NSString stringWithFormat:@"%@%@%@",provinceName,cityName,regionName];
        [MYTOOL setFontWithLabel:(UILabel *)tf];
        selectAreaDic = [NSMutableDictionary new];
        [selectAreaDic setValue:provinceCode forKey:@"provinceId"];
        [selectAreaDic setValue:provinceName forKey:@"provinceName"];
        [selectAreaDic setValue:cityCode forKey:@"cityId"];
        [selectAreaDic setValue:cityName forKey:@"cityName"];
        [selectAreaDic setValue:regionName forKey:@"regionName"];
        [selectAreaDic setValue:regionCode forKey:@"regionCode"];
        provinceRow = 0;
        regionRow = 0;
        [tf resignFirstResponder];
    }
    
    
    
    
    [DHTOOL hideKeyboard];
}
//数据变动
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([key_picker isEqualToString:@"性别"]) {
        //不用用
    }else if ([key_picker isEqualToString:@"出生日期"]) {
        if (component == 1 ||component ==0) {
            //重置第三列
            [pickerView reloadComponent:2];
        }
        
    }else{//地区
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
}
#pragma mark - 用户事件回调
//缩放图片
-(void)showZoomImageView:(UITapGestureRecognizer *)tap{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    
    UIView *bgView = [[UIView alloc] init];
    
    bgView.frame = [UIScreen mainScreen].bounds;
    
    bgView.backgroundColor = [UIColor blackColor];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    UITapGestureRecognizer *tapBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    
    [bgView addGestureRecognizer:tapBgView];
    //必不可少的一步，如果直接把点击获取的imageView拿来玩的话，返回的时候，原图片就完蛋了
    
    UIImageView *tempImageView = (UIImageView*)tap.view;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tempImageView.frame];
    imageView.image = tempImageView.image;
    [bgView addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
    //
    
}
//再次点击取消全屏预览
-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
    [tapBgRecognizer.view removeFromSuperview];
}
//点击更换头像
-(void)submitSelectImage{
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"选择头像" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSLog(@"相册");
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        [self  presentViewController:imagePicker animated:YES completion:^{
        }];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSLog(@"拍照");
        // UIImagePickerControllerCameraDeviceRear 后置摄像头
        // UIImagePickerControllerCameraDeviceFront 前置摄像头
        BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamera) {
            [SVProgressHUD showErrorWithStatus:@"无法打开摄像头" duration:2];
            return ;
        }
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        // 编辑模式
        imagePicker.allowsEditing = YES;
        
        [self  presentViewController:imagePicker animated:YES completion:^{
        }];
        
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:action1];
    [ac addAction:action2];
    [ac addAction:action3];
    
    [self presentViewController:ac animated:YES completion:nil];
    
}
#pragma mark - UIImagePickerController代理
//确定选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑后图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.userImgView.image = image;
    [self.userImgView setImage:image];
    user_icon_change = true;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 自定义事件
//返回我的  页面
-(void)backToMyVC{
    [self.navigationController popViewControllerAnimated:YES];
}
//提交保存按钮
-(void)submitSaveBtn{
    [MYTOOL hideKeyboard];
    
    if (user_icon_change) {//先上传图片
        //截取图片
        NSData * imageData = UIImageJPEGRepresentation(self.userImgView.image,0.2);
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
        // 参数@"image":@"image",
        NSDictionary * parameter = @{@"imageType":@"faceFile"};
        // 访问路径
        NSString *stringURL = [NSString stringWithFormat:@"%@%@",SERVER_URL,@"/community/uploadImage.intf"];
        [manager POST:stringURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            // 上传文件
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat            = @"yyyyMMddHHmmss";
            NSString * str                         = [formatter stringFromDate:[NSDate date]];
            NSString * fileName               = [NSString stringWithFormat:@"%@_hao.jpg", str];
            
            [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/png"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"上传进度:%.2f%%",uploadProgress.fractionCompleted*100] maskType:SVProgressHUDMaskTypeClear];
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"上传返回:%@",responseObject);
            if ([responseObject[@"code"] boolValue]) {
                NSString * url = responseObject[@"imageUrl"];
                [self updateUserInfo:url];
            }else{
                [SVProgressHUD showErrorWithStatus:responseObject[@"msg"] duration:2];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"上传失败:%@",error);
            [SVProgressHUD showErrorWithStatus:@"上传失败" duration:2];
        }];
    }else{
        //图片不改，改变其他的
        
        [self updateUserInfo:nil];
    }
}
//上传其他参数
-(void)updateUserInfo:(NSString *)user_icon_url_string{
//    NSLog(@"准备上传:%@",user_icon_url_string);
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];//会员id

    NSString * headUrl = user_icon_url_string;//头像	字符串	否
    if (headUrl&&headUrl.length) {
        [send_dic setValue:headUrl forKey:@"headUrl"];
    }
    NSString * nickName	= [self.title_tf_map[@"昵称"] text];//昵称	字符串	否
    if (nickName&&nickName.length) {
        [send_dic setValue:nickName forKey:@"nickName"];
    }
    NSString * signature = [self.title_tf_map[@"个人签名"] text];//个人签名	字符串	否
    if (signature&&signature.length) {
        [send_dic setValue:signature forKey:@"signature"];
    }
    NSString * gender = [self.title_tf_map[@"性别"] text]	;//性别	数字	否
    int gender_num = [gender isEqualToString:@"男"] ? 1 : 0;
    [send_dic setValue:[NSString stringWithFormat:@"%d",gender_num] forKey:@"gender"];
    NSString * birthday	= [self.title_tf_map[@"出生日期"]text];//生日	字符串	否
    if (birthday&&birthday.length) {
        [send_dic setValue:birthday forKey:@"birthday"];
    }
    NSString * job = [self.title_tf_map[@"职业"]text];//职业	字符串	否
    if (job&&job.length) {
        [send_dic setValue:job forKey:@"job"];
    }
    if (selectAreaDic) {
        [send_dic setValue:selectAreaDic[@"provinceName"] forKey:@"province"];
        [send_dic setValue:selectAreaDic[@"provinceId"] forKey:@"provinceId"];
        [send_dic setValue:selectAreaDic[@"cityName"] forKey:@"city"];
        [send_dic setValue:selectAreaDic[@"cityId"] forKey:@"cityId"];
        [send_dic setValue:selectAreaDic[@"regionCode"] forKey:@"regionId"];
        [send_dic setValue:selectAreaDic[@"regionName"] forKey:@"region"];
        
    }
//    NSLog(@"即将更新用户:%@",send_dic);
    [SVProgressHUD showWithStatus:@"更新信息" maskType:SVProgressHUDMaskTypeClear];
//    NSLog(@"即将发送数据:%@",send_dic);
    [MYNETWORKING getWithInterfaceName:@"/member/updateMember.intf" andDictionary:send_dic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"返回:%@",back_dic);
        [SVProgressHUD showSuccessWithStatus:@"更新成功" duration:1];
        [self.navigationController popToRootViewControllerAnimated:true];
    }];
    
    
}
//刷新界面信息
-(void)refreshViewData{
    //头像
    NSString * headUrl = self.member_dic[@"headUrl"][@"normalUrl"];
    if (headUrl && headUrl.length) {
        BOOL cache  = [[SDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:headUrl]];
        if (!cache) {
            
        }
//        [self.userImgView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    //昵称
    NSString * nickName = self.member_dic[@"nickName"];
    if (nickName && nickName.length) {
        ((UITextField*)self.title_tf_map[@"昵称"]).text = nickName;
    }
    //性别
    NSString * gender = [self.member_dic[@"gender"] intValue] == 1 ? @"男" : @"女";
    if (gender && gender.length) {
        ((UITextField*)self.title_tf_map[@"性别"]).text = gender;
    }
    //出生日期
    NSString * birthday = self.member_dic[@"birthday"];
    if (birthday && birthday.length) {
        ((UITextField*)self.title_tf_map[@"出生日期"]).text = birthday;
    }
    //所在地
    NSString * province = self.member_dic[@"province"];
    NSString * city = self.member_dic[@"city"];
    NSString * region = self.member_dic[@"region"];
    if (province && city) {
        NSString * string = [NSString stringWithFormat:@"%@%@%@",province,city,region];
        if (string.length > 1) {
            ((UITextField*)self.title_tf_map[@"所在地"]).text = string;
        }
    }
    //职业
    NSString * job = self.member_dic[@"job"];
    if (job && job.length) {
        ((UITextField*)self.title_tf_map[@"职业"]).text = job;
    }
    //个人签名
    NSString * signature = self.member_dic[@"signature"];
    if (signature && signature.length) {
        ((UITextField*)self.title_tf_map[@"个人签名"]).text = signature;
    }
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
    for (NSString * key in self.title_tf_map.allKeys) {
        id tv = [self.title_tf_map objectForKey:key];
        if ([tv isFirstResponder]) {
            someOne = tv;
            break;
        }
    }
    //UITextField相对屏幕上侧位置
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[someOne convertRect: [someOne bounds] toView:window];
    //UITextField底部坐标
    float tf_y = rect.origin.y + 20;
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
#pragma mark - 界面回调
-(void)personalSign_callBack:(NSString *)content{
    UITextField * tf = self.title_tf_map[@"个人签名"];
    tf.text = content;
}
#pragma mark - tabbar显示与隐藏
//此view出现时隐藏tabBar
- (void)viewWillAppear: (BOOL)animated{
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
    
//    [self refreshViewData];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
