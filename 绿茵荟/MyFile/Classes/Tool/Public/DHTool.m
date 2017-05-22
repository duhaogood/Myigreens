//
//  DHTool.m
//  移动票务
//
//  Created by 杜浩 on 16/7/26.
//  Copyright © 2016年 杜浩. All rights reserved.
//
#import <objc/runtime.h>
#import "DHTool.h"
#import "AFNetworking.h"
static id instance;
@interface DHTool()

@end
@implementation DHTool

+(instancetype)sharedDHTool{
    if (!instance) {
        instance = [[self alloc]init];
    }
    return instance;
}
+(instancetype)alloc{
    if (!instance) {
        instance = [[super alloc]init];
    }
    return instance;
}
-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}
-(void)hideKeyboard{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
-(NSArray *)getAllPropertyOfObject:(NSObject *)obj{
    if (!obj) {
        return nil;
    }
    // 获取当前类的所有属性
    unsigned int count;// 记录属性个数
    objc_property_t * properties = class_copyPropertyList([obj class], &count);
    // 遍历 - 将所有的属性都加入到数组中
    NSMutableArray * mArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        // objc_property_t 属性类型
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char * cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString * name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [mArray addObject:name];
    }
    return mArray;
}
-(void)setAllPropertyWithDictionary:(NSDictionary *)dictionary toObject:(NSObject *)object{
    if (!object) {
        return;
    }
    NSArray * properies = [self getAllPropertyOfObject:object];
    for (NSString * key in properies) {
        NSString * value = [dictionary valueForKey:key];
        [object setValue:value forKey:key];
    }
}
-(CGSize)getSizeWithLabel:(UILabel *)label{
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    NSDictionary * attrs = @{NSFontAttributeName : label.font};
    CGSize size = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}
-(CGSize)getSizeWithString:(NSString *)string andFont:(UIFont *)font{
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    NSDictionary * attrs = @{NSFontAttributeName : font};
    CGSize size = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size;
}
-(void)setFontWithLabel:(UILabel *)label{
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    float width = [label frame].size.width;
    UIFont * font = label.font;
    NSDictionary * attrs = @{NSFontAttributeName : font};
    CGSize size = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    while (size.width > width) {
        font = [UIFont systemFontOfSize:font.pointSize-1];
        attrs = @{NSFontAttributeName : font};
        size = [label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    }
    label.font = font;
}
-(void)setFontOfPart:(id)part withTitle:(NSString *)title{
    CGSize maxSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
    float width = [part frame].size.width;
    if ([part isMemberOfClass:[UILabel class]] || [part isMemberOfClass:[UITextField class]]) {
        UILabel * label = (UILabel *)part;
        UIFont * font = label.font;
        NSDictionary * attrs = @{NSFontAttributeName : font};
        CGSize size = [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        while (size.width > width) {
            font = [UIFont systemFontOfSize:font.pointSize-1];
            attrs = @{NSFontAttributeName : font};
            size = [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        }
        label.font = font;
    }
    if ([part isMemberOfClass:[UIButton class]]) {
        UIButton * btn = (UIButton *)part;
        UIFont * font = btn.titleLabel.font;
        NSDictionary * attrs = @{NSFontAttributeName : font};
        CGSize size = [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        while (size.width > width) {
            font = [UIFont systemFontOfSize:font.pointSize-1];
            attrs = @{NSFontAttributeName : font};
            size = [title boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        }
        btn.titleLabel.font = font;
    }
    return;
}
-(UIColor *)RGBWithRed:(int)red green:(int)green blue:(int)blue alpha:(float)alpha{
    UIColor * color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
    return color;
}
-(CGRect)rectWithX:(float)x Y:(float)y width:(float)width height:(float)height{
    return CGRectMake(x*WIDTH/1242.0, y*HEIGHT/2209.0, width * WIDTH/1242.0, height*HEIGHT/2209.0);
}
-(NSString *)getProjectPropertyWithKey:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}
-(void)setProjectPropertyWithKey:(NSString *)key andValue:(NSString *)value{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}
-(NSString *)getDocumentsPath{
    //获取Documents路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}
- (int)getDaysInThisYear:(int)year withMonth:(int)month{
    if((month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12))
        return 31 ;
    
    if((month == 4) || (month == 6) || (month == 9) || (month == 11))
        return 30;
    
    if((year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3))
    {
        return 28;
    }
    
    if(year % 400 == 0)
        return 29;
    
    if(year % 100 == 0)
        return 28;
    
    return 29;
}
-(void)hiddenTabBar{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *views = [app.window.rootViewController.view subviews];
    for(id v in views){
        if([v isKindOfClass:[UITabBar class]]){
            [(UITabBar *)v setHidden:YES];
        }
    }
}
-(void)showTabBar{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *views = [app.window.rootViewController.view subviews];
    for(id v in views){
        if([v isKindOfClass:[UITabBar class]]){
            [(UITabBar *)v setHidden:NO];
        }
    }
}
// 传一个字符串和字体大小来返回一个字符串所占的宽度

-(float)getStringWidth:(NSString*)str andFont:(UIFont*)wordFont{
    
    if (str == nil) return 0;
    
    CGSize measureSize;
    
    if([[UIDevice currentDevice].systemVersion floatValue] < 7.0){
        
        measureSize = [str sizeWithFont:wordFont constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    }else{
        
        measureSize = [str boundingRectWithSize:CGSizeMake(0, 0) options:NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:wordFont, NSFontAttributeName, nil] context:nil].size;
        
    }
    return ceil(measureSize.width);
    
}
-(bool)isLogin{
    return [[self getProjectPropertyWithKey:@"isLogin"] boolValue];
}
-(CGRect)getRectWithIphone_six_X:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height{
    return CGRectMake(x/375.0*WIDTH, y/667.0*HEIGHT, width/375.0*WIDTH, height/667.0*HEIGHT);
}


-(void)setImageIncludePrograssOfImageView:(UIImageView*)imageView withUrlString:(NSString *)imageUrlString{
    __block UIView * pro_view = [UIView new];
    pro_view.frame = imageView.bounds;
    [imageView addSubview:pro_view];
    UIView * upView = [UIView new];
    UIView * downView = [UIView new];
    upView.backgroundColor = [UIColor grayColor];
    downView.backgroundColor = [UIColor clearColor];
    upView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    downView.frame = CGRectMake(0, imageView.frame.size.height, imageView.frame.size.width, 0);
    [pro_view addSubview:upView];
    [pro_view addSubview:downView];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrlString] placeholderImage:nil options:SDWebImageCacheMemoryOnly /*SDWebImageLowPriority|SDWebImageRetryFailed*/ progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        float pro = (float)receivedSize/expectedSize;
        upView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height*(1-pro));
        downView.frame = CGRectMake(0, imageView.frame.size.height*(1-pro), imageView.frame.size.width, imageView.frame.size.height*pro);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [pro_view removeFromSuperview];
        pro_view = nil;
    }];
}
-(void)showAlertWithViewController:(UIViewController *)vc andTitle:(NSString *)title andSureTile:(NSString *)sureTitle andSureBlock:(void(^)(void))sure andCacel:(void(^)(void))cancel{
    //弹出的回复界面
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:sureTitle style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        sure();
    }];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    [alert addAction:action];
    [alert addAction:cancelAction];
    [vc showDetailViewController:alert sender:nil];
}
-(void)netWorkingWithTitle:(NSString *)title{
    [SVProgressHUD showWithStatus:title maskType:SVProgressHUDMaskTypeClear];
}
-(float)getHeightWithIphone_six:(float)height{
    return height/667.0*HEIGHT;
}
@end
