
/**
 *  4.商城
 *  地址相关
 *
 */



/*

 8.15会员地址列表
 Ø接口地址：/shop/address/getAddress.intf
 Ø接口描述：获取会员地址列表
 Ø特别说明：
 default：0 不默认 1 默认
 80.81.82.82.1Ø输入参数：
 参数名称	参数含义	参数类型	是否必录
 memberId	会员id	数字	是
 Ø输出参数：
 参数名称	子节点	参数含义	参数类型
 code		响应编码	数字
 msg		响应描述	字符串
 addressList	addressId	地址id	数字
	name	收货人姓名	字符串
	mobile	手机号	字符串
	cityId	城市id	数字
	cityName	城市名称	字符串
	provinceId	省份id	数字
	provinceName	省份名称	字符串
	addr	详细地址	字符串
	Default_addr	是否默认	数字

*/
