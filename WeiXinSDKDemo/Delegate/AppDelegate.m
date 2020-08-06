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
#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //注册微信支付
    BOOL registered = [WXApi registerApp:WX_APP_KEY universalLink:@"https://ds.okbile.com/"];
    if (registered) {
        NSLog(@"微信注册成功");
    }else{
        NSLog(@"微信注册失败");
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    self.window = [[UIWindow alloc] init];

    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark wechat openid

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        NSURL *webpageURL = userActivity.webpageURL;
        NSLog(@"Universal links received url is : %@",[NSString stringWithFormat:@"%@",webpageURL]);
        
        //微信授权回掉
        if ([[NSString stringWithFormat:@"%@",webpageURL.absoluteString] rangeOfString:[NSString stringWithFormat:@"%@/oauth",WX_APP_KEY]].location != NSNotFound) {
            //这里是微信授权回调
            NSLog(@"微信授权回调");
            return [WXApi handleOpenURL:webpageURL delegate:[WXAPIManager sharedManager]];
        }
    }
    
    return YES;
}

#pragma mark - 回调
//9.0前的方法，为了适配低版本 保留
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    if ([[NSString stringWithFormat:@"%@",url] rangeOfString:[NSString stringWithFormat:@"%@://oauth",WX_APP_KEY]].location != NSNotFound) {
        //这里是微信授权回调
        NSLog(@"微信授权回调");
        return [WXApi handleOpenURL:url delegate:[WXAPIManager sharedManager]];
    }
    else if ([[NSString stringWithFormat:@"%@",url] rangeOfString:[NSString stringWithFormat:@"%@://pay",WX_APP_KEY]].location != NSNotFound) {
        //这里是微信支付的回调
        NSLog(@"微信支付回调");
        return [WXApi handleOpenURL:url delegate:[WXAPIManager sharedManager]];
    }
    return YES;
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:[WXAPIManager sharedManager]];
}

//ios9.0之后
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [self application:app handleOpenURL:url];
}


@end
