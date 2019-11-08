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
#import "BDWebViewController.h"
#import <ZXToolbox/ZXToolbox.h>
#import <BDToolKit/UIView+BDCDS.h>

@interface BDWebViewController ()<WKNavigationDelegate, WKUIDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) ZXScriptMessageHandler *scriptMessageHandler;
@end

@implementation BDWebViewController
@dynamic backButtonImage;

- (id)initWithUrl:(NSString *)url usingCache:(BOOL)usingCache
{
    /**@see https://www.jianshu.com/p/6177d09a7d61
     **@brief why does webview should set in viewdidload
     **/
    if (self = [super init]) {
        self.url = url;
        self.usingCache = usingCache;
        [self setupUI];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    [[NSBundle mainBundle] pathForResource:@"jquery.main" ofType:@"js"];
    
    NSString *js = @" $('meta[name=description]').remove(); $('head').append( '<meta name=\"viewport\" content=\"width=device-width, initial-scale=1,user-scalable=no\">' );";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [config.userContentController addUserScript:script];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.tintColor = [UIColor whiteColor];
    self.webView.scrollView.delegate = self;
    [self.view addSubview:self.webView];
    self.webView.frame = self.view.frame;
    
    //
    self.progressView = [[UIProgressView alloc] initWithFrame:self.view.frame];
    self.progressView.height = 1;
    self.progressView.progressTintColor = [UIColor redColor];
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    //n监听
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    //
//    [[self.webView rac_valuesForKeyPath:@"estimatedProgress" observer:self] subscribeNext:^(id  _Nullable x) {
//        self.progressView.progress = [x floatValue];
//    }];
    //
    self.scriptMessageHandler = [[ZXScriptMessageHandler alloc] initWithUserContentController:self.webView.configuration.userContentController];
    self.scriptMessageHandler.scriptMessageNames = [NSMutableArray array];
    
    //
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10.0];
    //是否启用缓存
    if (_usingCache) {
        request.HTTPMethod = @"HEAD";
        //获取记录的response headers
        NSDictionary *cachedHeaders = [[NSUserDefaults standardUserDefaults] objectForKey:[NSURL URLWithString:self.url].absoluteString];
        //设置request headers
        if (cachedHeaders) {
            NSString *etag = [cachedHeaders objectForKey:@"Etag"];
            if (etag) {
                [request setValue:etag forHTTPHeaderField:@"If-None-Match"];
            }
            NSString *lastModified = [cachedHeaders objectForKey:@"Last-Modified"];
            if (lastModified) {
                [request setValue:lastModified forHTTPHeaderField:@"If-Modified-Since"];
            }
        }
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            //        NSLog(@"statusCode == %@", @(httpResponse.statusCode));
            // 判断响应的状态码
            if (httpResponse.statusCode == 304 || httpResponse.statusCode == 0) {
                //如果状态码为304或者0(网络不通?)，则设置request的缓存策略为读取本地缓存
                [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
            }else {
                //如果状态码为200，则保存本次的response headers，并设置request的缓存策略为忽略本地缓存，重新请求数据
                [[NSUserDefaults standardUserDefaults] setObject:httpResponse.allHeaderFields forKey:request.URL.absoluteString];
                //如果状态码为200，则设置request的缓存策略为忽略本地缓存
                [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            }
            
            //未更新的情况下读取缓存
            dispatch_async(dispatch_get_main_queue(), ^{
                //判断结束之后，修改请求方式，加载网页
                request.HTTPMethod = @"GET";
                [self.webView loadRequest:request];
            });
        }] resume];
    }else {
        [self.webView loadRequest:request];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //导航栏是否透明
    if (_navigationBarTransparent) {
        //
        if (@available(iOS 11.0, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        // 自定导航栏颜色
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        // 导航栏透明并取消分隔线
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        // 透明
        self.navigationController.navigationBar.translucent = YES;
        
        //返回按钮变颜色
        UIBarButtonItem *b = self.navigationItem.leftBarButtonItems.firstObject;
        [b setImage:self.backButtonImage];
        
    }
    //是否显示返回按钮
    if (_hideBackButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    //是否全屏
    if (_isFullScreen) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setUsingH5Title:(BOOL)usingH5Title
{
    _usingH5Title = usingH5Title;
}

- (void)setNavigationBarTransparent:(BOOL)navigationBarTransparent
{
    _navigationBarTransparent = navigationBarTransparent;
    if (_navigationBarTransparent) {
        //
        if (@available(iOS 11.0, *)) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        // 自定导航栏颜色
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        // 导航栏透明并取消分隔线
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        // 透明
        self.navigationController.navigationBar.translucent = YES;
    }else{
        // 不透明
        self.navigationController.navigationBar.translucent = NO;
    }
}

- (void)setHideBackButton:(BOOL)hideBackButton
{
    _hideBackButton = hideBackButton;
    if (_hideBackButton) {
        self.navigationItem.leftBarButtonItem = nil;
    }else{
        UIImage *image = [self.backButtonImage imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(onBack:)]];
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (_isFullScreen) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isFullScreen) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.scriptMessageHandler removeScriptMessageHandlers];
    [ZXURLProtocol unregisterSchemes];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.navigationBarTransparent && !self.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
}

- (IBAction)onBack:(id)sender
{
    if (self.goToRoot) {
        if (self.isPresented) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else{
        if (self.goBackUsingH5) {
            if ([self.webView canGoBack]) {
                [self.webView goBack];
            }else if(self.isPresented){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            if (self.goBackCallback) {
                self.goBackCallback();
            }
        }else {
            if(self.isPresented){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            if (self.goBackCallback) {
                self.goBackCallback();
            }
        }
    }
}

- (void)addScripts:(NSArray *)scripts callback:(void (^)(WKScriptMessage *message))callback
{
    //
    [self.scriptMessageHandler addScriptMessageNames:scripts];
    self.scriptMessageHandler.didReceiveScriptMessage = ^(WKScriptMessage *message) {
        if (callback) {
            callback(message);
        }
    };
}

#pragma mark Actions
#pragma mark <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    self.progressView.hidden = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = YES;
    self.webView.y = 0;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.webView.y = 0;
    self.progressView.hidden = YES;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"错误", nil)
                                                                             message:error.localizedDescription
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          [weakSelf.navigationController popViewControllerAnimated:YES];
                                                      }]];
}

#pragma mark <WKUIDelegate>

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    //  js 里面的alert实现，如果不实现，网页的alert函数无效  ,
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action){
                                                          completionHandler(NO);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}


@end
