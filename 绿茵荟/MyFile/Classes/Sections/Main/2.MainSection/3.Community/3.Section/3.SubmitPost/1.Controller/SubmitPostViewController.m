//
//  SubmitPostViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/3/29.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "SubmitPostViewController.h"
#import "SubmitPostTV.h"
@interface SubmitPostViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)UITextView * tv;//发表的内容
@property(nonatomic,strong)NSMutableArray * img_arr;//图片view数组
@property(nonatomic,strong)UIScrollView * scrollView;//主界面
@property(nonatomic,strong)UIView * selectTypeView;//选择帖子种类view
@property(nonatomic,strong)NSMutableArray * upload_array;//上传辅助数组-图片url
@property(nonatomic,strong)UILabel * num_label;//预览图片时显示的图片序号
@end

@implementation SubmitPostViewController
{
    UIImageView * currentImgView;//当前编辑的图片框
    UIButton * current_postsType_button;//当前选择的类别
    NSMutableArray * postsType_button_arr;//所有选择类别按钮
    int current_upload_img_index;//当前上传图片序号
    NSArray * type_array;//发帖type数组
    UIView * show_view;//查看图片的辅助view
    UIImageView * show_img_view;//查看图片的view
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * interface = @"/sys/getDictInfo.intf";
    NSDictionary * send = @{@"type":@"community"};
    [MYNETWORKING getWithInterfaceName:interface andDictionary:send andSuccess:^(NSDictionary *back_dic) {
        NSArray * communityList = back_dic[@"dictEntities"][@"community_for_post"];
        NSMutableArray * nameArray = [NSMutableArray new];//名字数组
        for (int i = 0; i < communityList.count; i ++) {
            NSDictionary * dict = communityList[i];
            NSString * name = dict[@"label"];//名字
            NSString * value = [NSString stringWithFormat:@"%d",[dict[@"value"] intValue]];
            [nameArray addObject:@{@"name":name,@"value":value}];
        }
        type_array = nameArray;
        //加载主界面
        [self loadMainView];
    }];
}
//加载主界面
-(void)loadMainView{
    self.scrollView = [UIScrollView new];
    self.scrollView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-64);
    [self.view addSubview:self.scrollView];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    //解决tableView露白
    self.automaticallyAdjustsScrollViewInsets = false;
    //添加手势
    //添加点按击手势监听器
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchAtScrollView:)];
    //设置手势属性
    tapGesture.numberOfTapsRequired=1;//设置点按次数，默认为1，注意在iOS中很少用双击操作
    tapGesture.numberOfTouchesRequired=1;//点按的手指数
    [self.scrollView addGestureRecognizer:tapGesture];
    //上侧灰色背景
    UIView * up_spaceView = [UIView new];
    up_spaceView.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    [self.view addSubview:up_spaceView];
    up_spaceView.frame = CGRectMake(0, 0, WIDTH, 10);
    
    //发表的内容
    SubmitPostTV * tv = [[SubmitPostTV alloc]initWithFrame:CGRectMake(10, 10, WIDTH-20, 220/736.0*HEIGHT)];
//    tv.backgroundColor = [UIColor redColor];
    tv.placeholderLabel.text = @"说点什么吧...(最多140字)";
    tv.placeholderLabel.textColor = [MYTOOL RGBWithRed:190 green:190 blue:190 alpha:1];
    [self.scrollView addSubview:tv];
    tv.delegate = self;
    self.tv = tv;
    //分割线
    UIView * space_view = [UIView new];
    space_view.frame = CGRectMake(10, 220/736.0*HEIGHT+21, WIDTH-20, 1);
    space_view.backgroundColor = [MYTOOL RGBWithRed:247 green:247 blue:247 alpha:1];
    [self.scrollView addSubview:space_view];
    
    //加载图片选择区域
    [self loadImgViews];
    //加载帖子类别选择view
    [self loadSelectTypeView];
}
//加载帖子类别选择view
-(void)loadSelectTypeView{
    UIView * view = [UIView new];
    view.frame = CGRectMake(0, 253/736.0*HEIGHT+ 32 + (WIDTH - 40)/3 , WIDTH, 150);
    self.selectTypeView = view;
    [self.scrollView addSubview:view];
    //view.backgroundColor = [UIColor redColor];
    //绿色view
    UIView * spaceView = [UIView new];
    spaceView.frame = CGRectMake(10, 10, 5, 20);
    spaceView.backgroundColor = [MYTOOL RGBWithRed:114 green:156 blue:59 alpha:1];
    [view addSubview:spaceView];
    //提示文字
    UILabel * label = [UILabel new];
    label.frame = CGRectMake(20, 10, WIDTH - 30, 20);
    label.text = @"选择帖子分类";
    label.font = [UIFont systemFontOfSize:20];
    [view addSubview:label];
    
    float top = 40;
    float width_btn = (WIDTH - 100)/4;
    postsType_button_arr = [NSMutableArray new];
    for (int i = 0; i < type_array.count; i ++) {
        if (i == 4) {
            top += width_btn/68.0*28 + 20;
        }
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(20 + (width_btn + 20)*(i%4), top, width_btn, width_btn/68.0*28);
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        //btn.titleLabel.textColor = [MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1];
        [btn setTitleColor:[MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_label_nor"] forState:UIControlStateNormal];
        [btn setTitle:type_array[i][@"name"] forState:UIControlStateNormal];
        [view addSubview:btn];
        [btn addTarget:self action:@selector(selectPostsTypeBack:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 100;
        [postsType_button_arr addObject:btn];
//        if (i == 0) {
//            current_postsType_button = btn;
//            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [btn setBackgroundImage:[UIImage imageNamed:@"btn_item_sel"] forState:UIControlStateNormal];
//            btn.tag = 200;
//        }
        
    }
}

//加载图片选择区域
-(void)loadImgViews{
    self.img_arr = [NSMutableArray new];
    float top = 253/736.0*HEIGHT+ 22;
    float width_img = (WIDTH - 40)/3;
    for (int i = 0; i < 1; i ++) {
        UIImageView * imgV = [UIImageView new];
        imgV.frame = CGRectMake(10+(width_img+10)*i, top, width_img, width_img);
        imgV.image = [UIImage imageNamed:@"Rounded-Rectangle-34-copy-2"];
        [self.scrollView addSubview:imgV];
        imgV.userInteractionEnabled = true;
        imgV.layer.masksToBounds = true;
        imgV.layer.cornerRadius = 10;
        imgV.tag = i;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(submitSelectImage:)];
        [imgV addGestureRecognizer:tapGesture];
        NSMutableDictionary * dic = [NSMutableDictionary new];
        [dic setObject:@"0" forKey:@"have_image"];
        [dic setObject:imgV forKey:@"imgV"];
        [self.img_arr addObject:dic];
    }
}
//
-(void)touchAtScrollView:(UITapGestureRecognizer *)tap{
    [MYTOOL hideKeyboard];
}

//选择帖子类型回调
-(void)selectPostsTypeBack:(UIButton *)button{
    if ([button isEqual:current_postsType_button]) {
        return;
    }
    for (UIButton * btn in postsType_button_arr) {
        if ([btn isEqual:button]) {
            current_postsType_button = btn;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_item_sel"] forState:UIControlStateNormal];
            btn.tag = 200;
        }else{
            [btn setTitleColor:[MYTOOL RGBWithRed:181 green:181 blue:181 alpha:1] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_label_nor"] forState:UIControlStateNormal];
            btn.tag = 100;
        }
    }

}
//点击增加图片
-(void)submitSelectImage:(UITapGestureRecognizer *)tap{
//    NSLog(@"目前数组:%@",self.img_arr);
    NSInteger tag = tap.view.tag;
    //判断当前点击的是否有图片
    if ([self.img_arr[tag][@"have_image"] boolValue]) {
        [self showZoomImageView2:(UIImageView *)tap.view];
        return;
    }
    UIImageView * imageV = (UIImageView *)tap.view;
    currentImgView = imageV;
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"增加图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
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
#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length >= 140) {
        [SVProgressHUD showErrorWithStatus:@"字数太多了" duration:0.6];
        return NO;
    }
    return true;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
#pragma mark - 发布按钮回调 - rightbarbutton
-(void)submitBack{
    if (current_postsType_button == nil) {
        [SVProgressHUD showErrorWithStatus:@"请选择分类" duration:2];
        return;
    }
    if ([self getCountOfImgV_arr] == 0) {
        [SVProgressHUD showErrorWithStatus:@"没有图片哦" duration:1];
        return;
    }
    NSString * content = self.tv.text;
    if (content.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"说点什么吧" duration:1];
        return;
    }
    //首先上传所有图片,将所有返回的url放到self.upload_array中
    self.upload_array = [NSMutableArray new];
    current_upload_img_index = 0;//上传标志位
    //开始上传
    [self upLoadAllImage];
    
}
//上传所有图片
-(void)upLoadAllImage{
    if (self.img_arr.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"没有图片" duration:1];
        return;
    }
    int count_img = 0;
    for (int i =  0; i < self.img_arr.count ; i ++){
        NSDictionary * dic = self.img_arr[i];
        count_img += [dic[@"have_image"] boolValue];
    }
    NSDictionary * dic = self.img_arr[current_upload_img_index];
    if (![dic[@"have_image"] boolValue]) {
        current_upload_img_index ++;
        [self upLoadAllImage];
    }
    //上传图片
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain", nil];
    // 参数@"image":@"image",
    NSDictionary * parameter = @{@"imageType":@"posts"};
    // 访问路径
    NSString *stringURL = [NSString stringWithFormat:@"%@%@",SERVER_URL,@"/community/uploadImage.intf"];
    [manager POST:stringURL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // 上传文件
        NSDictionary * dic = self.img_arr[current_upload_img_index];
        UIImageView * imgV = dic[@"imgV"];
        //截取图片
        float change = 1.0;
        [SVProgressHUD showWithStatus:@"%d/%d\n上传进度:%0" maskType:SVProgressHUDMaskTypeClear];
        UIImage * img = [self fixOrientation:imgV.image];
        NSData * imageData = UIImageJPEGRepresentation(img,change);
        while (imageData.length > 1.0 * 1024 * 1024) {
            change -= 0.1;
            imageData = UIImageJPEGRepresentation(img,change);
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat            = @"yyyyMMddHHmmss";
        NSString * str                         = [formatter stringFromDate:[NSDate date]];
        NSString * fileName               = [NSString stringWithFormat:@"%@_hao_%d.jpg", str,current_upload_img_index];
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%d/%d\n上传进度:%.2f%%",current_upload_img_index+1,count_img,uploadProgress.fractionCompleted*100] maskType:SVProgressHUDMaskTypeClear];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] boolValue]) {
            NSString * img_url = responseObject[@"imageUrl"];
            [self.upload_array addObject:img_url];
            current_upload_img_index ++;
            if (current_upload_img_index >= count_img) {
                //帖子类别
                NSString * posts_type = current_postsType_button.currentTitle;
                NSString * type = @"";
                for (NSDictionary * dictt in type_array) {
                    NSString * name = dictt[@"name"];
                    NSString * value = dictt[@"value"];
                    if ([name isEqualToString:posts_type]) {
                        type = value;
                        break;
                    }
                }
                //发布帖子
                NSString * interfaceName = @"/community/addPost.intf";
                NSString * imageUrl = self.upload_array[0];
                if (self.upload_array.count > 1) {
                    for (int i = 1; i < self.upload_array.count; i ++) {
                        NSString * url = self.upload_array[i];
                        imageUrl = [NSString stringWithFormat:@"%@,%@",imageUrl,url];
                    }
                }
                
                NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
                NSString * content = self.tv.text;
                NSDictionary * sendDic = @{
                                           @"imageUrl":imageUrl,
                                           @"memberId":memberId,
                                           @"content":content,
                                           @"type":type
                                           };
//                NSLog(@"上传send:%@",sendDic);
                [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//                    NSLog(@"发布back:%@",back_dic);
                    [SVProgressHUD showSuccessWithStatus:back_dic[@"msg"] duration:1];
                    [self.navigationController popViewControllerAnimated:true];
                }];
                /*
                 发帖子
                 Ø接口地址：/community/addPost.intf
                 imageUrl：多张图片，链接已逗号形式隔开
                 type：获取帖子类型直接调取字典表接口
                 19.20.21.21.1Ø输入参数：
                 参数名称	参数含义	参数类型	是否必录
                 memberId	会员id	数字	是
                 imageUrl	图片Url	字符串	是
                 type	帖子类型	数字	是
                 content	内容	字符串	是
                 */
            }else{
                [self upLoadAllImage];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:responseObject[@"msg"] duration:2];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"上传失败:%@",error);
        [SVProgressHUD showErrorWithStatus:@"上传失败" duration:2];
    }];
}
#pragma mark - 返回按钮回调 - leftbarbutton
-(void)back_pop{
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - UIImagePickerController代理
//确定选择图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    // UIImagePickerControllerOriginalImage 原始图片
    // UIImagePickerControllerEditedImage 编辑后图片
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    for (NSMutableDictionary * dic in self.img_arr) {
        NSString * have_image = dic[@"have_image"];
        if (![have_image boolValue]) {
            [dic setValue:@"1" forKey:@"have_image"];
            UIImageView * imgV = dic[@"imgV"];
            imgV.image = image;
            break;
        }
        
    }
    [self refreshImgView];//重新刷新界面
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//取消选择
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//缩放图片
-(void)showZoomImageView2:(UIImageView *)tap_view{
    if (![tap_view image]) {
        return;
    }
    UIView *bgView = [[UIView alloc] init];
    bgView.tag = tap_view.tag;
    show_view = bgView;
    bgView.frame = [UIScreen mainScreen].bounds;
    bgView.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    UITapGestureRecognizer *tapBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView:)];
    [bgView addGestureRecognizer:tapBgView];
    //滑动事件-下一张
    UISwipeGestureRecognizer * swipeGest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextImageView:)];
    swipeGest.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeGest.numberOfTouchesRequired = 1;
    [bgView addGestureRecognizer:swipeGest];
    //滑动事件-上一张
    UISwipeGestureRecognizer * swipeGest_up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showUpImageView:)];
    swipeGest_up.direction = UISwipeGestureRecognizerDirectionRight;
    swipeGest_up.numberOfTouchesRequired = 1;
    [bgView addGestureRecognizer:swipeGest_up];
    //必不可少的一步，如果直接把点击获取的imageView拿来玩的话，返回的时候，原图片就完蛋了
    
    UIImageView *tempImageView = tap_view;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tempImageView.frame];
    imageView.image = tempImageView.image;
    show_img_view = imageView;
    imageView.tag = tap_view.tag;
    [bgView addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
    
//    NSLog(@"tag:%ld",tap_view.tag);
    //增加-1/2-序号
    if (!self.num_label) {
        UILabel * label = [UILabel new];
        [bgView addSubview:label];
        self.num_label = label;
        self.num_label.frame = CGRectMake(WIDTH/4, 30, WIDTH/2, 20);
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:20];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    self.num_label.text = [NSString stringWithFormat:@"%ld / %ld",tap_view.tag+1,[self getCountOfImgV_arr]];
    //删除按钮
    UIButton * btn = [UIButton new];
    [btn addTarget:self action:@selector(deleteImgWithBtn:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(WIDTH-35-15, 34, 35, 18);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"删除" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [bgView addSubview:btn];
    
}
//删除图片事件
-(void)deleteImgWithBtn:(UIButton *)btn{
//    NSLog(@"delete:%ld",show_view.tag);
    /*
     1.
     */
    //清除要删除的图片框
    [self.img_arr[show_view.tag][@"imgV"] removeFromSuperview];
    [self.img_arr removeObjectAtIndex:show_view.tag];
    
    //需要添加空的图片view
    float top = 253/736.0*HEIGHT+ 22;
    float width_img = (WIDTH - 40)/3;
    //下边的type选择view往下移动
    [UIView animateWithDuration:0.3 animations:^{
        self.selectTypeView.frame = CGRectMake(0, top+((self.img_arr.count-1)/3)*width_img+20 + width_img, WIDTH, 150);
    }];
    self.scrollView.contentSize = CGSizeMake(0, top+(self.img_arr.count/3)*width_img+20 + width_img + 150);
    
    //取消全屏
    {
        self.num_label = nil;
        [show_view removeFromSuperview];
    }
    //刷新
    [self refreshImgView];
}
//判断是否有空的图片框，如果没有，则新增
-(void)refreshImgView{
    
    BOOL have_nil_imgV = false;//是否还有空的图片框
    for (NSMutableDictionary * dic in self.img_arr) {
        NSString * have_image = dic[@"have_image"];
        if (![have_image boolValue]) {
            have_nil_imgV = true;
        }
    }
    //如果没有空的
    if (!have_nil_imgV) {
        //加一个
        [self addImgViewToImg_arr];
    }else{//有空的
//        if (self.img_arr.count < 3) {
//            [self addImgViewToImg_arr];
//        }
    }
    //刷新所有图片框位置
    for(int i = 0; i < self.img_arr.count ; i ++){
        float top = 253/736.0*HEIGHT+ 22;
        float width_img = (WIDTH - 40)/3;
        UIImageView * imgV = self.img_arr[i][@"imgV"];
        imgV.tag = i;
        [UIView animateWithDuration:0.3 animations:^{
            imgV.frame = CGRectMake(10+(width_img+10)*(i%3), top+(i/3)*(width_img+10), width_img, width_img);
        }];
    }
//    NSLog(@"---------------------");
    for (int i = 0; i < self.img_arr.count ; i ++) {
        NSDictionary * dic = self.img_arr[i];
        bool flag = [dic[@"have_image"] boolValue];
        UIImageView * imgV = dic[@"imgV"];
//        NSLog(@"第%d个图片框是否有图片:%d,图片size:[%.2f,%.2f]",i+1,flag,imgV.image.size.width,imgV.image.size.height);
    }
    self.scrollView.contentSize = CGSizeMake(0, 253/736.0*HEIGHT+ 22+((int)(self.img_arr.count/3))*(WIDTH - 40)/3+20 + (WIDTH - 40)/3 + 150);
}
-(void)addImgViewToImg_arr{
    //需要添加空的图片view
    float top = 253/736.0*HEIGHT+ 22;
    float width_img = (WIDTH - 40)/3;
    if (self.img_arr.count < 9) {
        //动态增加
        UIImageView * imgV = [UIImageView new];
        imgV.frame = CGRectMake(10+(width_img+10)*(self.img_arr.count%3), top+(self.img_arr.count/3)*(width_img+10), width_img, width_img);
        imgV.image = [UIImage imageNamed:@"Rounded-Rectangle-34-copy-2"];
        [self.scrollView addSubview:imgV];
        imgV.userInteractionEnabled = true;
        imgV.tag = [self getCountOfImgV_arr];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(submitSelectImage:)];
        [imgV addGestureRecognizer:tapGesture];
        NSMutableDictionary * dic = [NSMutableDictionary new];
        [dic setObject:@"0" forKey:@"have_image"];
        [dic setObject:imgV forKey:@"imgV"];
        [self.img_arr addObject:dic];
        imgV.layer.masksToBounds = true;
        imgV.layer.cornerRadius = 10;
        
        //下边的type选择view往下移动
        [UIView animateWithDuration:0.3 animations:^{
            self.selectTypeView.frame = CGRectMake(0, top+((self.img_arr.count-1)/3)*width_img+20 + width_img, WIDTH, 150);
        }];
        self.scrollView.contentSize = CGSizeMake(0, top+(self.img_arr.count/3)*width_img+20 + width_img + 150);
    }
}
-(NSInteger)getCountOfImgV_arr{
    NSInteger count = 0;
    for (NSDictionary * dic in self.img_arr) {
        bool flag = [dic[@"have_image"] boolValue];
        if (flag) {
            count ++;
        }
    }
    return count;
}
//再次点击取消全屏预览
-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
    self.num_label = nil;
    [tapBgRecognizer.view removeFromSuperview];
}
//处理旋转问题
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;  
    }  
    
    // And now we just create a new UIImage from the drawing context  
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);  
    UIImage *img = [UIImage imageWithCGImage:cgimg];  
    CGContextRelease(ctx);  
    CGImageRelease(cgimg);  
    return img;  
}
//查看上一张
-(void)showUpImageView:(UISwipeGestureRecognizer *)tapBgRecognizer{
    NSInteger tag = tapBgRecognizer.view.tag;
//    NSLog(@"上一张:%ld",tag);
    if (tag > 0) {//可以显示上一张
        UIImageView * imgV = [UIImageView new];
        [show_view insertSubview:imgV atIndex:0];
        UIImageView * img_view = self.img_arr[tag - 1][@"imgV"];
        imgV.image = img_view.image;
        show_view.tag = tag - 1;
        CGRect frame1 = img_view.frame;
        frame1.size.width = WIDTH;
        frame1.size.height = WIDTH * (img_view.image.size.height / img_view.image.size.width);
        frame1.origin.x = -WIDTH;
        frame1.origin.y = (show_view.frame.size.height - frame1.size.height) * 0.5;
        imgV.frame = frame1;
        [UIView animateWithDuration:0.3 animations:^{
            show_img_view.frame = CGRectMake(WIDTH, show_img_view.frame.origin.y, WIDTH, show_img_view.frame.size.height);
            imgV.frame = CGRectMake(0, frame1.origin.y, frame1.size.width, frame1.size.height);
            show_img_view = imgV;
            self.num_label.text = [NSString stringWithFormat:@"%ld / %ld",show_view.tag+1,[self getCountOfImgV_arr]];
        }];
    }
}
//查看下一张
-(void)showNextImageView:(UISwipeGestureRecognizer *)tapBgRecognizer{
    NSInteger tag = tapBgRecognizer.view.tag;
//    NSLog(@"下一张:%ld",tag);
    //总图片个数
    NSInteger count = [self getCountOfImgV_arr];
    if (tag < count - 1) {//可以显示下一张
        UIImageView * imgV = [UIImageView new];
        [show_view insertSubview:imgV atIndex:0];
        UIImageView * img_view = self.img_arr[tag + 1][@"imgV"];
        imgV.image = img_view.image;
        show_view.tag = tag + 1;
        CGRect frame1 = img_view.frame;
        frame1.size.width = WIDTH;
        frame1.size.height = WIDTH * (img_view.image.size.height / img_view.image.size.width);
        frame1.origin.x = WIDTH;
        frame1.origin.y = (show_view.frame.size.height - frame1.size.height) * 0.5;
        imgV.frame = frame1;
        [UIView animateWithDuration:0.3 animations:^{
            show_img_view.frame = CGRectMake(-WIDTH, show_img_view.frame.origin.y, WIDTH, show_img_view.frame.size.height);
            imgV.frame = CGRectMake(0, frame1.origin.y, frame1.size.width, frame1.size.height);
            show_img_view = imgV;
            self.num_label.text = [NSString stringWithFormat:@"%ld / %ld",show_view.tag+1,[self getCountOfImgV_arr]];
        }];
    }
}
#pragma mark - view显示及消失
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MYTOOL hiddenTabBar];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发布" style:UIBarButtonItemStyleDone target:self action:@selector(submitBack)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back_pop)];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MYTOOL showTabBar];
}

@end
