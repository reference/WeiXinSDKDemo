/**
MIT License

Copyright (c) 2018 Scott Ban (https://github.com/reference/WeiXinSDKDemo.git)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXUserInfoModel : NSObject
/// 错误时候 返回
@property (nonatomic, strong) NSNumber *errcode;
@property (nonatomic, strong) NSString *errmsg;
///
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *nickname;

/**
 国家，如中国为 CN
 */
@property (nonatomic, strong) NSString *country;

/**
 普通用户的标识，对当前开发者帐号唯一
 */
@property (nonatomic, strong) NSString *openid;

/**
 普通用户性别，1 为男性，2 为女性
 */
@property (nonatomic, strong) NSNumber *sex;
/**
 用户特权信息，json 数组，如微信沃卡用户为（chinaunicom）
 */
@property (nonatomic, strong) NSArray *privilege;

/**
 用户头像，最后一个数值代表正方形头像大小（有 0、46、64、96、132 数值可选，0 代表 640*640 正方形头像），
 用户没有头像时该项为空
 */
@property (nonatomic, strong) NSString *headimgurl;

/**
 用户统一标识。针对一个微信开放平台帐号下的应用，同一用户的 unionid 是唯一的。
 */
@property (nonatomic, strong) NSString *unionid;


/// 获取用户个人信息（UnionID 机制）
/// @param access_token 调用凭证
/// @param openId 普通用户的标识，对当前开发者帐号唯一
/// 国家地区语言版本，zh_CN 简体，zh_TW 繁体，en 英语，默认为 zh-CN
/// @param completion nil
+ (void)requestUserInfoWithAccessToken:(NSString *)access_token openId:(NSString *)openId completion:(void (^)(WXUserInfoModel *userInfo,NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
