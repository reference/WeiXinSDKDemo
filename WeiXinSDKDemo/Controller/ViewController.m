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

#import "ViewController.h"
#import "WXOauth2Model.h"
#import "WXUserInfoModel.h"
#import "WXAPIManager.h"

@interface ViewController ()<WXAuthDelegate>

@end

@implementation ViewController

- (IBAction)onWXLogin:(UIButton *)b
{
    [[WXAPIManager sharedManager] sendAuthRequestWithController:self delegate:self];
}

#pragma mark - WXAuthDelegate

- (void)wxAuthSucceed:(NSString *)code {
    //获取access_token
    [WXOauth2Model requestAccessTokenWithAppId:WX_APP_KEY secret:WX_SECRET_CODE code:code completion:^(WXOauth2Model * _Nonnull oauth2, NSError * _Nonnull error) {
        if (error) {
            [self showTextHUD:error.localizedDescription];
        }else{
            /// 获取微信个人用户信息
            [WXUserInfoModel requestUserInfoWithAccessToken:oauth2.access_token openId:oauth2.openid completion:^(WXUserInfoModel * _Nonnull wxUser, NSError * _Nonnull error) {
                if (error) {
                    [self showTextHUD:error.localizedDescription];
                }
                else {
                    NSLog(@"微信个人信息：%@",wxUser);
                }
            }];
        }
    }];
}

- (void)wxAuthDenied {
    NSLog(@"denied");
}

@end
