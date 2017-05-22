//
//  StoreNetWorking.m
//  绿茵荟
//
//  Created by Mac on 17/4/17.
//  Copyright © 2017年 徐州野马软件. All rights reserved.
//

#import "StoreNetWorking.h"

@implementation StoreNetWorking
//获取商品分类数据
-(void)getGoodsCategory:(void(^)(NSDictionary* backDict))success{
    NSString * interfaceName = @"/shop/goods/getGoodsCat.intf";
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:nil andSuccess:^(NSDictionary *back_dic) {
        success(back_dic);
    }];
    /*
     8.3获取商品分类
     Ø接口地址：/shop/goods/getGoodsCat.intf
     Ø接口描述：获取商品分类
     Ø特殊说明：如传入goodsCatId则是查出这个分类下的子集，不传则查出所有父类
     44.45.46.46.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     goodsCatId	商品分类id	数字	否
     Ø输出参数：
     参数名称	子节点	参数含义	参数类型
     code		响应编码	数字
     msg		响应描述	字符串
     goodsCatList	goodsCatId	商品分类id	数字
     name	分类名称	字符串
     image	照片链接	字符串
     */
}
//获取轮播图数据
-(void)getCarouselImageData:(void(^)(NSDictionary* backDict))success{
    NSString * interfaceName = @"/sys/getBanner.intf";
    NSDictionary * sendDic = @{
                               @"key":@"goods"
                               };
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:sendDic andSuccess:^(NSDictionary *back_dic) {
        success(back_dic);
    }];
    
    /*
     10.5获取横幅图
     Ø接口地址：/sys/getBanner.intf
     Ø接口描述：获取所有含有横幅图的信息
     Ø特殊说明：
     key：wallpaper 壁纸横图 community 社区精选横图 goods 商城头部横图
     Category：导航类别(1：富文本 2：商品 3：帖子 4:商品组)
     98.99.99.1Ø输入参数：
     参数名称	参数含义	参数类型	是否必录
     key	类型	string	是
     Ø输出参数：
     参数名称	子节点	参数含义	参数类型
     code		响应编码	数字
     msg		响应描述	字符串
     bannerList	bannerId	横幅Id	数字
     bannerUrl	横图url	字符串
     category	导航类别	数字
     */
}
//加载要显示的页面数据
-(void)getViewData:(void(^)(NSDictionary* backDict))success{
    NSString * interfaceName = @"/shop/goods/getGoodsHome.intf";
    [MYNETWORKING getWithInterfaceName:interfaceName andDictionary:nil andSuccess:^(NSDictionary *back_dic) {
//        NSLog(@"back:%@",back_dic);
        success(back_dic);
    }];
    /**
     8.1获取商城首页
     Ø接口地址：/shop/goods/getGoodsHome.intf
     Ø接口描述：获取商城首页
     Ø特殊说明：
     showType：1 商品(goodsList)  2商品组(bannerList)  3 导航(bannerList)
     category ：1 富文本 2 商品 3 帖子 4 商品组
     Ø输入参数：
     无
     Ø输出参数：
     参数名称	子节点	子节点	参数含义	参数类型
     code			响应编码	数字
     msg			响应描述	字符串
     tagsList	tagId		标签id	数字
     tagName		标签名称	字符串
     showType		展示类型	数字
     goodsList	goodsId	商品id	数字
     goodsName	商品名称	字符串
     bannerList	bannerId	导航id	数字
     bannerUrl	导航图片	字符串
     category	具体类型	数字
     categoryId	类型id	字符串
     */
}
@end
