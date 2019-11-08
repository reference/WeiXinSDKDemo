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
#import "WXOauth2Model.h"
#import <BDBaseController/BDBaseController.h>

@implementation WXOauth2Model

+ (void)requestAccessTokenWithAppId:(NSString *)appId secret:(NSString *)appSecret code:(NSString *)code completion:(void (^)(WXOauth2Model *m,NSError *error))completion
{
    NSString *url = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    
    [BDHTTP requestWithURL:url
                    params:@{@"appid":appId,@"secret":appSecret,@"code":code,@"grant_type":@"authorization_code"}
                    body:nil
           responseClass:WXOauth2Model.class
       responseDataClass:nil
              completion:^(id responseObject, NSError *error)
    {
        WXOauth2Model *oauth = responseObject;
        
        if (oauth && [oauth.errcode integerValue]) {
            error = [NSError errorWithDomain:@"HTTP" code:[oauth.errcode integerValue] userInfo:@{NSLocalizedDescriptionKey:oauth.errmsg?:@""}];
        }
        if (completion) {
            completion(oauth,error);
        }
    }];
}
@end
