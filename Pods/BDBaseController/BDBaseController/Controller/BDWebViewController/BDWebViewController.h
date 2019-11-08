/**
 MIT License
 
 Copyright (c) 2018 Scott Ban (https://github.com/reference/BDBaseController)
 
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
#import "BDBaseViewController.h"
#import <WebKit/WebKit.h>

@interface BDWebViewController : BDBaseViewController
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) NSString *url;

/// 返回按钮
@property (nonatomic,strong) UIImage *backButtonImage;

//
@property (nonatomic,assign) BOOL navigationBarTransparent; //导航栏是否透明
@property (nonatomic,assign) BOOL hideBackButton; //是否显示返回按钮
@property (nonatomic,assign) BOOL isPresented; //是否弹出
@property (nonatomic,assign) BOOL goBackUsingH5; //是否使用h5返回 default NO
@property (nonatomic,assign) BOOL usingH5Title; //是否使用h5 title default NO
@property (nonatomic,assign) BOOL usingCache; //是否启用缓存 Default No
@property (nonatomic,assign) BOOL isFullScreen; //是否全屏 默认NO 全屏以后 导航栏功能不能用
@property (nonatomic,assign) BOOL goToRoot; //
@property (nonatomic,copy) void (^goBackCallback)(void);


/**
 init

 @param url url
 @param usingCache cache
 @return webviewcontroller
 */
- (id)initWithUrl:(NSString *)url usingCache:(BOOL)usingCache;
/**
 js
 
 @param scripts js scripts
 @param callback callback
 */
- (void)addScripts:(NSArray *)scripts callback:(void (^)(WKScriptMessage *message))callback;

@end
