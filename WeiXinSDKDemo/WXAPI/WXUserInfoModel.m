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
#import "WXUserInfoModel.h"
#import <BDBaseController/BDBaseController.h>

@implementation WXUserInfoModel

+ (void)requestUserInfoWithAccessToken:(NSString *)access_token openId:(NSString *)openId completion:(void (^)(WXUserInfoModel *m,NSError *error))completion
{
    NSString *url = @"https://api.weixin.qq.com/sns/userinfo";
    
    [BDHTTP requestWithURL:url
                  params:@{@"access_token":access_token,@"openid":openId,@"lang":@"zh_CN"}
                    body:nil
           responseClass:WXUserInfoModel.class
       responseDataClass:nil
              completion:^(id responseObject, NSError *error)
    {
        WXUserInfoModel *info = responseObject;
        
        if (info && [info.errcode integerValue]) {
            error = [NSError errorWithDomain:@"HTTP" code:[info.errcode integerValue] userInfo:@{NSLocalizedDescriptionKey:info.errmsg?:@""}];
        }
        if (completion) {
            completion(info,error);
        }
    }];
}
@end
