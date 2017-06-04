//
//  PostInfoViewController.m
//  绿茵荟
//
//  Created by mac_hao on 2017/4/9.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "PostInfoViewController.h"
#import "SharedManagerVC.h"
#import "CommunityVC.h"
@interface PostInfoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,assign)UILabel * num_label;//预览图片显示第几张
@property(nonatomic,strong)NSMutableArray * review_array;//评论数组
@property(nonatomic,strong)UITextField * wantToSayField;//即将发送的文本框
@property(nonatomic,strong)UILabel * releaseTimeLabel;//帖子时间label
@property(nonatomic,strong)UILabel * praiseCountLabel;//点赞数
@property(nonatomic,strong)UILabel * commentCountLabel;//消息数
@end

@implementation PostInfoViewController
{
    UIView * show_view;//查看图片的辅助view
    UIImageView * show_img_view;//查看图片的view
    int review_pageNo;//评论数据分页数
    NSMutableArray * imgViewArray;//图片数组
    bool praiseStatus;//是否赞过
}
- (void)viewDidLoad {
    [super viewDidLoad];
    review_pageNo = 1;
    //加载主界面
    [self loadMainView];
}
//加载主界面
-(void)loadMainView{
    self.view.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
    //返回按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popUpViewController)];
    //举报按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_reportReporticon_report"] style:UIBarButtonItemStyleDone target:self action:@selector(reportBtnCallBack)];
//    NSLog(@"postInfo:%@",self.post_dic);
    float left = 0;
    UIView * backView = [UIView new];
    backView.frame = CGRectMake(0, 10, WIDTH, 500);
    backView.backgroundColor = [UIColor whiteColor];
    //用户头像
    {
        UIImageView * userImgView = [UIImageView new];
        userImgView.frame = CGRectMake(14, 15, 41, 41);
        NSString * headUrl = self.post_dic[@"member"][@"headUrl"];
        [userImgView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
        [backView addSubview:userImgView];
        userImgView.layer.masksToBounds = true;
        userImgView.layer.cornerRadius = 20.5;
        [userImgView setUserInteractionEnabled:YES];
        UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView_user_icon:)];
        tapGesture2.numberOfTapsRequired=1;
        [userImgView addGestureRecognizer:tapGesture2];
    }
    //用户名字
    {
        UILabel * label = [UILabel new];
        NSString * nickName = self.post_dic[@"member"][@"nickName"];
        if (nickName == nil || nickName.length == 0) {
            nickName = @"匿名用户";
        }
        label.text = nickName;
        label.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
        label.font = [UIFont systemFontOfSize:18];
        CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
        label.frame = CGRectMake(63, 23, size.width, 18);
        [backView addSubview:label];
        left = 63+size.width+10;
    }
    //时间
    {
        UILabel * label = [UILabel new];
        NSString * releaseTime = self.post_dic[@"releaseTime"];
        label.text = releaseTime;
        label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        label.font = [UIFont systemFontOfSize:12];
        CGSize size = [MYTOOL getSizeWithString:label.text andFont:label.font];
        label.frame = CGRectMake(WIDTH-10-size.width, 25, size.width, 12);
        [backView addSubview:label];
        self.releaseTimeLabel = label;
    }
    
    //个性签名
    float top = 0;
    {
        UILabel * label = [UILabel new];
        NSString * signature = self.post_dic[@"member"][@"signature"];
        if (signature == nil || signature.length == 0) {
            signature = @"这家伙很懒，什么都没留下…";
        }
        label.text = signature;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:signature andFont:label.font];
        int c = size.width/(WIDTH-71) < 1 ? 1 : (size.width/(WIDTH-71) == 1 ? 1 : (int)size.width/(WIDTH-71) + 1);
        if (c > 1) {
            label.numberOfLines = 0;
        }
        label.frame = CGRectMake(61, 45, WIDTH-71, size.height*c);
        [backView addSubview:label];
        top = 45 + size.height*c + 10;
    }
    //内容
    {
        UILabel * label = [UILabel new];
        NSString * content = self.post_dic[@"content"];
        if (content == nil || content.length == 0) {
            content = @"这家伙很懒，什么都没留下…";
        }
        label.text = content;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [MYTOOL RGBWithRed:92 green:92 blue:92 alpha:1];
        CGSize size = [MYTOOL getSizeWithString:content andFont:label.font];
        float width = WIDTH-30;
        int c = size.width/width < 1 ? 1 : (size.width/width == 1 ? 1 : (int)size.width/width + 1);
        if (c > 1) {
            label.numberOfLines = 0;
        }
        label.frame = CGRectMake(14, top, width, size.height*c);
        [backView addSubview:label];
        top += label.frame.size.height + 10;
    }
    //图片预览
    {
        imgViewArray = [NSMutableArray new];
        float width = (WIDTH - 30)/3;
        float height_all = 0;
        for(int i = 0;i < [self.post_dic[@"url"] count]; i ++){
            int row = i / 3;//行
            int col = i % 3;//列
            UIImageView * imgV = [UIImageView new];
            imgV.contentMode = UIViewContentModeScaleAspectFill;
            imgV.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
            [imgV setContentScaleFactor:[[UIScreen mainScreen] scale]];
            imgV.frame = CGRectMake(10+col*(width+5), top+row*(width+5)+10, width, width);
            imgV.layer.masksToBounds = true;
            imgV.layer.cornerRadius = 12;
            imgV.tag = i;
            [imgViewArray addObject:imgV];
            [backView addSubview:imgV];
            NSString * img_url = self.post_dic[@"url"][i][@"smallUrl"];
            [imgV sd_setImageWithURL:[NSURL URLWithString:img_url] placeholderImage:[UIImage imageNamed:@"test_bg"]];
            height_all = (row+1) * (width + 5);
            [imgV setUserInteractionEnabled:YES];
            UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showZoomImageView1:)];
            tapGesture2.numberOfTapsRequired=1;
            [imgV addGestureRecognizer:tapGesture2];
        }
        top += height_all;
    }
    //3个图片按钮
    {
        top += 22;
        
        NSInteger postId = [self.post_dic[@"postId"] longValue];//帖子的用户id
        //点赞
        {
            praiseStatus = [self.post_dic[@"praiseStatus"] boolValue];
            UIButton * btn = [UIButton new];
            [btn setImage:[UIImage imageNamed:@"icon_details_praise"] forState:UIControlStateNormal];
            if (praiseStatus) {
                [btn setImage:[UIImage imageNamed:@"icon_details_praise_press"] forState:UIControlStateNormal];
            }
            btn.frame = CGRectMake(WIDTH/4-15, top, 30, 30);
            [btn addTarget:self action:@selector(praise_callBack:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = postId * 10 + [self.post_dic[@"praiseStatus"] intValue];
            [backView addSubview:btn];
            
            //数字
            UILabel * num_label1 = [UILabel new];
            NSString * praiseCount = [NSString stringWithFormat:@"%ld",[self.post_dic[@"praiseCount"] longValue]];
            num_label1.text = praiseCount;
            num_label1.frame = CGRectMake(WIDTH/6, top + 35, WIDTH/6, 18);
            num_label1.font = [UIFont systemFontOfSize:18];
            num_label1.textAlignment = NSTextAlignmentCenter;
            [backView addSubview:num_label1];
            self.praiseCountLabel = num_label1;
        }
        //消息
        {
            //下边小图标  icon_message
            UIImageView * icon2 = [UIImageView new];
            icon2.image = [UIImage imageNamed:@"icon_message"];
            icon2.frame = CGRectMake(WIDTH/2-15, top, 30, 30);
            [backView addSubview:icon2];
            //绑定监听-点击
            [icon2 setUserInteractionEnabled:YES];
            icon2.tag = postId * 10 + 2;
            UITapGestureRecognizer * tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
            tapGesture2.numberOfTapsRequired=1;
            [icon2 addGestureRecognizer:tapGesture2];
            
            //数字
            UILabel * num_label2 = [UILabel new];
            NSString * commentCount = [NSString stringWithFormat:@"%ld",[self.post_dic[@"commentCount"] longValue]];
            num_label2.text = commentCount;
            num_label2.frame = CGRectMake(WIDTH/2-WIDTH/12, top+35, WIDTH/6, 18);
            num_label2.font = [UIFont systemFontOfSize:18];
            num_label2.textAlignment = NSTextAlignmentCenter;
            [backView addSubview:num_label2];
            self.commentCountLabel = num_label2;
        }
        //分享
        {
            //下边小图标  icon_message
            UIImageView * icon3 = [UIImageView new];
            icon3.image = [UIImage imageNamed:@"icon_share"];
            icon3.frame = CGRectMake(WIDTH*3/4-15, top, 30, 30);
            [backView addSubview:icon3];
            //绑定监听
            [icon3 setUserInteractionEnabled:YES];
            icon3.tag = postId * 10 + 3;
            UITapGestureRecognizer * tapGesture3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(callback_cellForSelectView:)];
            tapGesture3.numberOfTapsRequired=1;
            [icon3 addGestureRecognizer:tapGesture3];
            
            //数字
            UILabel * num_label3 = [UILabel new];
            num_label3.text = @"分享";
            num_label3.frame = CGRectMake(WIDTH*3/4-WIDTH/12, top+35, WIDTH/6-2, 18);
            num_label3.font = [UIFont systemFontOfSize:18];
            num_label3.textAlignment = NSTextAlignmentCenter;
            [backView addSubview:num_label3];
        }
        top += 35+25;
        backView.frame = CGRectMake(0, 0, WIDTH, top);
    }
    //tableView
    {
        UITableView * tableView = [UITableView new];
        self.tableView = tableView;
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        tableView.frame = CGRectMake(0, 10, WIDTH, HEIGHT-64-49-10);
        UIView * backView2 = [UIView new];
        backView2.backgroundColor = [MYTOOL RGBWithRed:242 green:242 blue:242 alpha:1];
        backView2.frame = CGRectMake(0, 0, WIDTH, top+10);
        [backView2 addSubview:backView];
        tableView.tableHeaderView = backView2;
        tableView.rowHeight = 98;
        //不显示分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //解决tableView露白
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
    }
    //底部view
    {
        UIView * white_back_view = [UIView new];
        white_back_view.frame = CGRectMake(0, HEIGHT-49-64, WIDTH, 49);
        white_back_view.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:white_back_view];
        UIImageView * back_imgV = [UIImageView new];
        back_imgV.image = [UIImage imageNamed:@"Comments-Box"];
        back_imgV.frame = CGRectMake(10, 6, WIDTH-20-90, 49-12);
        [white_back_view addSubview:back_imgV];
        //文本框
        UITextField * tf = [UITextField new];
        tf.frame = CGRectMake(25, 6, WIDTH-110-30, 37);
        tf.placeholder = @"想说点什么";
        [white_back_view addSubview:tf];
        self.wantToSayField = tf;
        //按钮
        UIButton * send_btn = [UIButton new];
        [send_btn setBackgroundImage:[UIImage imageNamed:@"btn_sent"] forState:UIControlStateNormal];
        [send_btn setTitle:@"发送" forState:UIControlStateNormal];
        send_btn.titleLabel.font = [UIFont systemFontOfSize:20];
        [send_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        send_btn.frame = CGRectMake(WIDTH-90, 6, 78, 38);
        [white_back_view addSubview:send_btn];
        [send_btn addTarget:self action:@selector(sendReview_callBack) forControlEvents:UIControlEventTouchUpInside];
    }
}
//举报帖子入口
-(void)reportBtnCallBack{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要举报此帖？" preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定举报" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [SVProgressHUD showWithStatus:@"举报中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        NSInteger postId = [self.post_dic[@"postId"] longValue];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/postInform.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
//            NSLog(@"back:%@",back_dic);
            [SVProgressHUD showSuccessWithStatus:@"举报成功" duration:1];
        }];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:action];
    [alert addAction:cancel];
    [self showDetailViewController:alert sender:nil];

}

#pragma mark - 上拉、下拉刷新
-(void)headerRefresh{
    review_pageNo = 1;
    [self loadAllReviewData];
}
-(void)footerRefresh{
    review_pageNo ++;
    [self loadAllReviewData];
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [MYTOOL hideKeyboard];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [MYTOOL hideKeyboard];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.review_array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary * reviewDic = self.review_array[indexPath.row];
    UITableViewCell * cell = [UITableViewCell new];
    //头像
    {
        UIImageView * userIcon = [UIImageView new];
        userIcon.frame = CGRectMake(14, 13, 40, 40);
        userIcon.image = [UIImage imageNamed:@"logo"];
        userIcon.layer.masksToBounds = true;
        userIcon.layer.cornerRadius = 20;
        NSString * headUrl = reviewDic[@"headUrl"];
        if (headUrl && headUrl.length) {
            [userIcon sd_setImageWithURL:[NSURL URLWithString:headUrl]];
        }
        [cell addSubview:userIcon];
    }
    //名字
    float left = 0;
    {
        UILabel * nameLabel = [UILabel new];
        nameLabel.font = [UIFont systemFontOfSize:15];
        NSString * name = reviewDic[@"nickName"];
        if (name == nil || name.length == 0) {
            name = @"匿名用户";
        }
        nameLabel.text = name;
        CGSize size = [MYTOOL getSizeWithString:nameLabel.text andFont:nameLabel.font];
        nameLabel.frame = CGRectMake(63, 27, size.width, 16);
        nameLabel.textColor = [MYTOOL RGBWithRed:30 green:28 blue:28 alpha:1];
        [cell addSubview:nameLabel];
        left += 63+size.width+10;
    }
    //时间
    {
        UILabel * label = [UILabel new];
        NSString * releaseTime = reviewDic[@"releaseTime"];
        label.font = [UIFont systemFontOfSize:12];
        label.text = releaseTime;
        CGSize size = [MYTOOL getSizeWithString:releaseTime andFont:label.font];
        label.frame = CGRectMake(left, 30, size.width, 12);
        label.textColor = [MYTOOL RGBWithRed:170 green:170 blue:170 alpha:1];
        [cell addSubview:label];
    }
    //小图标
    {
        UIImageView * right_icon = [UIImageView new];
        right_icon.frame = CGRectMake(WIDTH-38, 12, 33, 33);
        right_icon.image = [UIImage imageNamed:@"icon_reportReporticon_report"];
        [cell addSubview:right_icon];
//        NSInteger postCommentId = [self.review_array[indexPath.row][@"postCommentId"] longValue];
        right_icon.tag = indexPath.row;
        right_icon.userInteractionEnabled = true;
        UITapGestureRecognizer * tapGesture4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reportReviewBtnCallBack:)];
        tapGesture4.numberOfTapsRequired=1;
        [right_icon addGestureRecognizer:tapGesture4];
    }
    //内容
    {
        NSString * byNickName = reviewDic[@"byNickName"];
        float by_left = 0;
        if (byNickName && byNickName.length) {
            NSString * title = [NSString stringWithFormat:@"@%@",byNickName];
            UILabel * label = [UILabel new];
            label.text = title;
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [MYTOOL RGBWithRed:115 green:158 blue:52 alpha:1];
            CGSize size = [MYTOOL getSizeWithString:title andFont:label.font];
            label.frame = CGRectMake(61, 60, size.width, size.height);
            [cell addSubview:label];
            by_left = size.width+5;
        }
        UILabel * label = [UILabel new];
        NSString * comment = reviewDic[@"comment"];
        label.text = comment;
        label.font = [UIFont systemFontOfSize:16];
        label.textColor = [MYTOOL RGBWithRed:91 green:91 blue:91 alpha:1];
        float width = WIDTH-by_left-50-63;
        label.frame = CGRectMake(61 + by_left, 60, width, 16);
        CGSize size = [MYTOOL getSizeWithString:comment andFont:label.font];
        int c = size.width/width < 1 ? 1 : (size.width/width == 1 ? 1 : (int)size.width/width + 1);
        if (c > 1) {
            for (NSInteger i = comment.length ; i > 0 ; i -- ) {
                NSString * left = [comment substringToIndex:i];
                size = [MYTOOL getSizeWithString:left andFont:label.font];
                if (size.width <= width) {
                    label.text = left;
                    NSString * right = [comment substringFromIndex:i];
                    UILabel * rightLabel = [UILabel new];
                    rightLabel.font = [UIFont systemFontOfSize:16];
                    rightLabel.textColor = [MYTOOL RGBWithRed:91 green:91 blue:91 alpha:1];
                    rightLabel.text = right;
                    [cell addSubview:rightLabel];
                    rightLabel.frame = CGRectMake(61, 79, WIDTH-61-50, 16);
                    break;
                }
            }
            
        }
        [cell addSubview:label];
    }
    //回复按钮
    {
        UIButton * btn = [UIButton new];
        btn.frame = CGRectMake(WIDTH-44, 61, 32, 15);
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        NSInteger postCommentId = [reviewDic[@"postCommentId"] longValue];
        btn.tag = postCommentId;
        [btn setTitle:@"回复" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(answerBtnCallBack:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[MYTOOL RGBWithRed:114 green:158 blue:52 alpha:1] forState:UIControlStateNormal];
        [cell addSubview:btn];
    }
    //分割线
    {
        UIView * space = [UIView new];
        space.frame = CGRectMake(14, tableView.rowHeight-1, WIDTH-28, 1);
        space.backgroundColor = MYCOLOR_181_181_181;
        [cell addSubview:space];
    }
    /**
     byNickName = "";
     comment = "\U54c8\U54c8";
     headUrl = "";
     memberId = 37;
     nickName = Mike;
     releaseTime = "1\U5c0f\U65f6\U524d";
     */
    return cell;
}
//先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return false;
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
//        NSLog(@"删除啦");
        NSInteger postCommentId = [self.review_array[indexPath.row][@"postCommentId"] longValue];
        NSString * interfaceName = @"/community/delPostComment.intf";
        [SVProgressHUD showWithStatus:@"正在删除" maskType:SVProgressHUDMaskTypeClear];
        [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"postCommentId":[NSString stringWithFormat:@"%ld",postCommentId]} andSuccess:^(NSDictionary *back_dic) {
//            NSLog(@"back:%@",back_dic);
            [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
            review_pageNo = 1;
            [self loadAllReviewData];
            [self loadUpViewOfPost];
        }];
        
    }
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
//缩放图片
-(void)showZoomImageView_user_icon:(UITapGestureRecognizer *)tap
{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    
    UIView *bgView = [[UIView alloc] init];
    
    bgView.frame = [UIScreen mainScreen].bounds;
    
    bgView.backgroundColor = [UIColor blackColor];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgView];
    
    UITapGestureRecognizer *tapBgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView_userIcon:)];
    
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
-(void)tapBgView_userIcon:(UITapGestureRecognizer *)tapBgRecognizer{
    [tapBgRecognizer.view removeFromSuperview];
}
//举报评论入口
-(void)reportReviewBtnCallBack:(UITapGestureRecognizer *)tap{
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:true];
        return ;
    }
    NSDictionary * comment = self.review_array[tap.view.tag];
//    NSLog(@"comment:%@",comment);
    NSInteger postCommentId = [self.review_array[tap.view.tag][@"postCommentId"] longValue];
    NSInteger byMemberId = [comment[@"memberId"] longValue];
    if (byMemberId == [MEMBERID intValue]) {//自己的评论，删除
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要删除此评论？" preferredStyle:(UIAlertControllerStyleActionSheet)];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定删除" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            NSString * interfaceName = @"/community/delPostComment.intf";
            [SVProgressHUD showWithStatus:@"正在删除" maskType:SVProgressHUDMaskTypeClear];
            [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:@{@"postCommentId":[NSString stringWithFormat:@"%ld",postCommentId]} andSuccess:^(NSDictionary *back_dic) {
                //            NSLog(@"back:%@",back_dic);
                [SVProgressHUD showSuccessWithStatus:@"删除成功" duration:1];
                review_pageNo = 1;
                [self loadAllReviewData];
                [self loadUpViewOfPost];
            }];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:action];
        [alert addAction:cancel];
        [self showDetailViewController:alert sender:nil];
    }else{//别人的评论，举报
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要举报此评论？" preferredStyle:(UIAlertControllerStyleActionSheet)];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定举报" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            
            //        [SVProgressHUD showWithStatus:@"举报中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
            //拼接上传参数
            NSMutableDictionary * send_dic = [NSMutableDictionary new];
            [send_dic setValue:[NSString stringWithFormat:@"%ld",postCommentId] forKey:@"postCommentId"];
            [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
            //开始上传
            [MYNETWORKING getWithInterfaceName:@"/community/postCommentInform.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
                //            NSLog(@"back:%@",back_dic);
                [SVProgressHUD showSuccessWithStatus:@"举报成功" duration:1];
            }];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:action];
        [alert addAction:cancel];
        [self showDetailViewController:alert sender:nil];
    }
    
    
}
//回复消息回调
-(void)answerBtnCallBack:(UIButton *)btn{
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:true];
        return ;
    }
//    NSLog(@"准备回复");
    //弹出的回复界面
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"请回复" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [SVProgressHUD showWithStatus:@"回复中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        NSString * msg = alert.textFields.firstObject.text;
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:msg forKey:@"comment"];
        NSInteger postId = [self.post_dic[@"postId"] longValue];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",btn.tag] forKey:@"parentPostCommentId"];
//        NSLog(@"send:%@",send_dic);
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/postRevert.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
//            NSLog(@"back:%@",back_dic);
            [self loadUpViewOfPost];
            [self loadAllReviewData];
            [self.delegate updateData];
        }];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:action];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf){
        tf.placeholder = @"请输入回复消息";
    }];
    [alert addAction:cancel];
    [self showDetailViewController:alert sender:nil];
    
    
    
    
}
//缩放图片
-(void)showZoomImageView1:(UITapGestureRecognizer *)tap
{
    if (![(UIImageView *)tap.view image]) {
        return;
    }
    UIView *bgView = [[UIView alloc] init];
    bgView.tag = tap.view.tag;
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
    
    UIImageView *tempImageView = (UIImageView*)tap.view;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:tempImageView.frame];
    NSString * url_string = self.post_dic[@"url"][tempImageView.tag][@"normalUrl"];
    [imageView sd_setImageWithURL:[NSURL URLWithString:url_string] placeholderImage:[UIImage imageNamed:@"logo"]];
    show_img_view = imageView;
    imageView.tag = tap.view.tag;
    
    [bgView addSubview:imageView];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = imageView.frame;
        frame.size.width = bgView.frame.size.width;
        frame.size.height = frame.size.width * (imageView.image.size.height / imageView.image.size.width);
        frame.origin.x = 0;
        frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5;
        imageView.frame = frame;
    }];
    
//    NSLog(@"tag:%ld",tap.view.tag);
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
    self.num_label.text = [NSString stringWithFormat:@"%ld / %ld",tap.view.tag+1,[self.post_dic[@"url"] count]];
    
}
//再次点击取消全屏预览
-(void)tapBgView:(UITapGestureRecognizer *)tapBgRecognizer{
    show_view = nil;
    show_img_view = nil;
    self.num_label = nil;
    [tapBgRecognizer.view removeFromSuperview];
}
//查看上一张
-(void)showUpImageView:(UISwipeGestureRecognizer *)tapBgRecognizer{
    NSInteger tag = tapBgRecognizer.view.tag;
//    NSLog(@"上一张:%ld",tag);
    if (tag > 0) {//可以显示上一张[imgV sd_setImageWithURL:[NSURL URLWithString:self.post_dic[@"url"][tag-1][@"normalUrl"]]];
        UIImageView * imgV = [UIImageView new];
        [show_view insertSubview:imgV atIndex:0];
        UIImageView * img_view = imgViewArray[tag-1];
        [imgV sd_setImageWithURL:[NSURL URLWithString:self.post_dic[@"url"][tag-1][@"normalUrl"]]];
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
            self.num_label.text = [NSString stringWithFormat:@"%ld / %ld",show_view.tag+1,[self.post_dic[@"url"] count]];
        }];
    }
}
//查看下一张
-(void)showNextImageView:(UISwipeGestureRecognizer *)tapBgRecognizer{
    NSInteger tag = tapBgRecognizer.view.tag;
//    NSLog(@"下一张:%ld",tag);
    //总图片个数
    NSInteger count = [self.post_dic[@"url"] count];
    if (tag < count - 1) {//可以显示下一张
        UIImageView * imgV = [UIImageView new];
        [show_view insertSubview:imgV atIndex:0];
        UIImageView * img_view = imgViewArray[tag+1];
        [imgV sd_setImageWithURL:[NSURL URLWithString:self.post_dic[@"url"][tag+1][@"normalUrl"]]];
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
            self.num_label.text = [NSString stringWithFormat:@"%ld / %ld",show_view.tag+1,[self.post_dic[@"url"] count]];
        }];
    }
}
//发送评论
-(void)sendReview_callBack{
    [MYTOOL hideKeyboard];
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:true];
        return ;
    }
    [SVProgressHUD showWithStatus:@"回复中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
    NSString * msg = self.wantToSayField.text;
    if (msg.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"没有内容呀" duration:1];
        return;
    }
    //拼接上传参数
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    [send_dic setValue:msg forKey:@"comment"];
    NSInteger postId = [self.post_dic[@"postId"] longValue];
    [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
    [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
    //开始上传
    [MYNETWORKING getWithInterfaceName:@"/community/postRevert.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        [SVProgressHUD dismiss];
//        NSLog(@"back:%@",back_dic);
        review_pageNo = 1;
        self.wantToSayField.text = @"";
        [self loadAllReviewData];
        [self loadUpViewOfPost];
        [self.delegate updateData];
    }];
}
#pragma mark - 重写返回按钮事件
#pragma mark - cell 中小图标回调 点赞、回复、分享
-(void)callback_cellForSelectView:(UITapGestureRecognizer *)tap{
    UIImageView * imgV = (UIImageView *)tap.view;
    if (!imgV) {
        return;
    }
    NSInteger tag = imgV.tag;
    //帖子id
    NSInteger postId = tag / 10;
//    NSLog(@"postId:%ld",postId);
    if (tag % 10 == 1) {//点赞
        
    }else if(tag % 10 == 2) {//回复
        [self reply_callBack:postId];
    }else if(tag % 10 == 3) {//分享
        [self share_callBack];
    }
}
//点赞事件
-(void)praise_callBack:(UIButton *)btn{
    NSInteger postId = btn.tag / 10;
    if (![MYTOOL isLogin]) {
        //跳转至登录页
        LoginViewController * loginVC = [LoginViewController new];
        [self.navigationController pushViewController:loginVC animated:true];
        return;
    }
    if (praiseStatus) {//取消
        [SVProgressHUD showWithStatus:@"取消中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/delPostPraise.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            praiseStatus = false;
            [btn setImage:[UIImage imageNamed:@"icon_details_praise"] forState:UIControlStateNormal];
            if (praiseStatus) {
                [btn setImage:[UIImage imageNamed:@"icon_details_praise_press"] forState:UIControlStateNormal];
            }
            [self loadUpViewOfPost];
            [self.delegate updateData];
        }];
    }else{//赞帖
        [SVProgressHUD showWithStatus:@"点赞中\n请稍等…" maskType:SVProgressHUDMaskTypeClear];
        //拼接上传参数
        NSMutableDictionary * send_dic = [NSMutableDictionary new];
        [send_dic setValue:[NSString stringWithFormat:@"%ld",postId] forKey:@"postId"];
        [send_dic setValue:[MYTOOL getProjectPropertyWithKey:@"memberId"] forKey:@"memberId"];
        //开始上传
        [MYNETWORKING getWithInterfaceName:@"/community/postPraise.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
            praiseStatus = true;
            [btn setImage:[UIImage imageNamed:@"icon_details_praise"] forState:UIControlStateNormal];
            if (praiseStatus) {
                [btn setImage:[UIImage imageNamed:@"icon_details_praise_press"] forState:UIControlStateNormal];
            }
            [self loadUpViewOfPost];
            [self.delegate updateData];
        }];
    }
}
//消息图标点击事件
-(void)reply_callBack:(NSInteger)postId{
    //暂时不用
    
}
//分享事件
-(void)share_callBack{
    
    SharedManagerVC * share = [SharedManagerVC new];
    
    share.sharedDictionary = @{
                               @"title":self.post_dic[@"shareTitle"],
                               @"shareDescribe":self.post_dic[@"shareDescribe"],
                               @"img_url":self.post_dic[@"url"][0][@"smallUrl"],
                               @"shared_url":self.post_dic[@"postDetailUrl"]
                               };
    [share show];
}
//更新帖子上半部分信息
-(void)loadUpViewOfPost{
    NSMutableDictionary * send_dic = [NSMutableDictionary new];
    NSString * memberId = [MYTOOL getProjectPropertyWithKey:@"memberId"];
    if (memberId) {
        [send_dic setValue:memberId forKey:@"memberId"];
    }
    [send_dic setValue:_post_dic[@"postId"] forKey:@"postId"];
    
    
    //开始请求
    [SVProgressHUD showWithStatus:@"获取帖子" maskType:SVProgressHUDMaskTypeClear];
    [MYNETWORKING getWithInterfaceName:@"/community/getPostInfo.intf" andDictionary:send_dic andSuccess:^(NSDictionary * back_dic) {
        bool flag = [back_dic[@"code"] boolValue];
        if (flag) {
            //更新赞的数量及回复的数量
            NSDictionary * post_dic = back_dic[@"post"];
            //更新时间
            self.releaseTimeLabel.text = post_dic[@"releaseTime"];
            CGSize size = [MYTOOL getSizeWithString:self.releaseTimeLabel.text andFont:self.releaseTimeLabel.font];
            self.releaseTimeLabel.frame = CGRectMake(WIDTH-10-size.width, 25, size.width, 12);
            //更新赞的数量
            self.praiseCountLabel.text = [NSString stringWithFormat:@"%ld",[post_dic[@"praiseCount"] longValue]];
            //消息的数量
            self.commentCountLabel.text = [NSString stringWithFormat:@"%ld",[post_dic[@"commentCount"] longValue]];
        }else{
            [SVProgressHUD showErrorWithStatus:back_dic[@"msg"] duration:2];
        }
    }];

}
//返回上一个页面
-(void)popUpViewController{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [MYTOOL hideKeyboard];
}
//加载所有评论消息
-(void)loadAllReviewData{
    
//    NSLog(@"加载中");
    NSString * interfaceName = @"/community/getPostInfoComment.intf";
    NSInteger postId = [self.post_dic[@"postId"] longValue];
    NSDictionary * sendDic = @{
                               @"postId":[NSString stringWithFormat:@"%ld",postId],
                               @"pageNo":[NSString stringWithFormat:@"%d",review_pageNo]
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        NSArray * arr = back_dic[@"postCommentList"];
        if (review_pageNo > 1) {
            if (arr == nil || arr.count == 0) {
                if (review_pageNo > 1) {
                    review_pageNo --;
                }
                if (arr.count == 0) {
                    [SVProgressHUD showErrorWithStatus:@"到底了" duration:1];
                }
            }else{
                [self.review_array addObjectsFromArray:arr];
            }
        }else{
            self.review_array = [NSMutableArray arrayWithArray:arr];
        }
        
        [self.tableView reloadData];
    } andFailure:^(NSError *error_failure) {
        if (review_pageNo > 1) {
            review_pageNo --;
        }else{
            [self.review_array removeAllObjects];
            [self.tableView reloadData];
        }
    }];
    /*
     接口地址：/community/getPostInfoComment.intf
     Ø接口描述：获取帖子详细信息
     27.28.28.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     pageNo	页数	数字	是
     postId	帖子id	数字	是
     */
    
}
#pragma mark - 键盘出现及消失通知
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //键盘高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    //UITextField相对屏幕上侧位置
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect=[self.wantToSayField convertRect: [self.wantToSayField bounds] toView:window];
    //UITextField底部坐标
    float tf_y = rect.origin.y + self.wantToSayField.frame.size.height;
    if (height + tf_y > HEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 64-height, self.view.frame.size.width, self.view.frame.size.height);
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
    [self loadAllReviewData];
}
//此view消失时还原tabBar
- (void)viewWillDisappear: (BOOL)animated{
    [MYTOOL showTabBar];
    //删除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
