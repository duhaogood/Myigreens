//
//  DHTool.h
//  移动票务
//
//  Created by 杜浩 on 16/7/26.
//  Copyright © 2016年 杜浩. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DHTool : NSObject
@property(nonatomic,copy)NSString * store_version;//商店版本

/**
 *  获取单例工具类对象
 *
 *  @return 工具对象
 */
+(instancetype)sharedDHTool;
/**
 *  隐藏键盘
 */
-(void)hideKeyboard;
/**
 *  返回所有的属性数组
 *
 *  @param obj 任意OC对象
 *
 *  @return obj对象中所有的属性字符串数组
 */
-(NSArray *)getAllPropertyOfObject:(NSObject *)obj;
/**
 *  dictionary所有key和object的属性相同，value赋值给属性
 *
 *  @param dictionary 包含所有对象属性名为key的字典
 *  @param object     任意对象
 */
-(void)setAllPropertyWithDictionary:(NSDictionary *)dictionary toObject:(NSObject *)object;
/**
 *  只支持UILabel,UIButton,UITextField这3个单行显示的控件
 *  如果超过显示区域，则将字体变小
 *  @param part  需要改变字体的控件
 *  @param title 显示的内容
 */
-(void)setFontOfPart:(id)part withTitle:(NSString *)title;
/**
 *  只支持UILabel控件
 *  如果超过显示区域，则将字体变小,要先设置字体及text
 *  @param label  需要改变字体的控件
 */
-(void)setFontWithLabel:(UILabel *)label;
/**
 *  单行字符串在规定字体的情况下占用的尺寸
 *
 *  @param string 字符串
 *  @param font   字符串的字体
 *
 *  @return 单行字符串在规定字体的情况下占用的尺寸
 */
-(CGSize)getSizeWithString:(NSString *)string andFont:(UIFont *)font;

/**
 *  整形的RGB转成float类型的然后返回颜色
 *
 *  @param red   红色
 *  @param green 绿色
 *  @param blue  蓝色
 *  @param alpha 透明度
 *
 *  @return 颜色
 */
-(UIColor *)RGBWithRed:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;

-(CGRect)rectWithX:(float)x Y:(float)y width:(float)width height:(float)height;

/**
 获取程序存储属性值

 @param key 对应的key
 @return key对应的value
 */
-(NSString *)getProjectPropertyWithKey:(NSString *)key;

/**
 设置程序存储属性值

 @param key 对应的key
 @param value key对应的value
 */
-(void)setProjectPropertyWithKey:(NSString *)key andValue:(NSString *)value;

/**
 获取程序沙盒路径

 @return 路径字符串
 */
-(NSString *)getDocumentsPath;

/**
 获取某年某月一共多少天

 @param year 年
 @param month 月
 @return 一个弄多少天
 */
- (int)getDaysInThisYear:(int)year withMonth:(int)month;
/**
 隐藏底部tabbar
 */
-(void)hiddenTabBar;
/**
 显示tabbar
 */
-(void)showTabBar;

/**
 计算宽度

 @param str 要求的字符串
 @param wordFont 字符串的字体
 @return 宽度
 */
-(float)getStringWidth:(NSString*)str andFont:(UIFont*)wordFont;
/**
 计算宽度
 
 @param label 要求的字符串、字符串的字体 必须设置
 @return 宽度
 */
-(CGSize)getSizeWithLabel:(UILabel *)label;
/**
 用户是否登录

 @return 是否登录
 */
-(bool)isLogin;

/**
 根据4.7寸尺寸算出通用尺寸

 @param x x坐标
 @param y y坐标
 @param width 宽度
 @param height 高度
 @return CGRect
 */
-(CGRect)getRectWithIphone_six_X:(float)x andY:(float)y andWidth:(float)width andHeight:(float)height;

/**
 准备网络访问，不让用户可以操作界面

 @param title 要显示的文字
 */
-(void)netWorkingWithTitle:(NSString *)title;

/**
 根据4.7寸下的高度获取合适高度或者字体大小

 @param height 4.7寸下的高度或字体大小
 @return 当前屏幕尺寸下的尺寸
 */
-(float)getHeightWithIphone_six:(float)height;
/**
 为UIImageView设置网络图片，并加上自下而上的进度条

 @param imageView 要加图片的imageView
 @param imageUrlString 图片的url字符串
 */
-(void)setImageIncludePrograssOfImageView:(UIImageView*)imageView withUrlString:(NSString *)imageUrlString;


-(void)showAlertWithViewController:(UIViewController *)vc andTitle:(NSString *)title andSureTile:(NSString *)sureTitle andSureBlock:(void(^)(void))sure andCacel:(void(^)(void))cancel;
@end
