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
#import "BDScanController.h"

@interface BDScanController ()
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UIImageView *scanLine;
@property (nonatomic, strong) ZXQRCodeScanner *scanner;
@end

@implementation BDScanController

+ (id)presentScanInController:(UIViewController *)vc
{
    NSBundle *bundle = [NSBundle bundleWithBundleName:@"BDBaseController" podName:@"BDBaseController"];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BDScan" bundle:bundle];
    ZXNavigationController *nv = [sb instantiateViewControllerWithIdentifier:@"BDScanNaviController"];
    [vc presentViewController:nv animated:YES completion:nil];
    return nv.rootViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scanner = [[ZXQRCodeScanner alloc] initWithPreview:self.view captureRect:self.scanView.frame];
    [self.buttons.firstObject addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 自定导航栏颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    // 导航栏透明并取消分隔线
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[[UIColor blackColor] colorWithAlphaComponent:.6]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startScanning) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopScanning) name:UIApplicationWillResignActiveNotification object:nil];
    // 开始捕获
    [self startScanning];
    
    //description
    if (self.desc) {
        self.labels.firstObject.text = self.desc;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 自定导航栏颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    // 导航栏透明并取消分隔线
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    [self stopScanning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //
    __weak typeof(self) weakSelf = self;
    [ZXAuthorizationHelper requestAuthorizationForCamera:^(AVAuthorizationStatus status) {
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            ZXAlertAction *cancel = [ZXAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) handler:^(ZXAlertAction *action) {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
            ZXAlertAction *settting = [ZXAlertAction actionWithTitle:NSLocalizedString(@"设置", nil) handler:^(ZXAlertAction *action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            ZXAlertView *alertView = [[ZXAlertView alloc] initWithTitle:NSLocalizedString(@"获取相机权限失败", nil) message:NSLocalizedString(@"请为此应用打开相机权限", nil) style:ZXAlertViewStyleAlert cancelAction:cancel otherAction:settting, nil];
            [alertView showInViewController:weakSelf];
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startScanning {
    if (!self.scanner.isScanning) {
        [self startAnimating];
        __weak typeof(self) weakSelf = self;
        [self.scanner startScanning:^(NSArray<NSString *> *outputs) {
            // 停止扫描
            [weakSelf stopScanning];
            // 输出扫描字符串
            NSString *str = [outputs componentsJoinedByString:@"\n\n"];
            if (weakSelf.scannerOutput) {
                weakSelf.scannerOutput(str);
            }
            [weakSelf onBack:nil];
        }];
    }
}

- (void)stopScanning {
    [self.scanner stopScanning];
    self.scanLine.hidden = YES;
}

- (void)startAnimating {
    static CGFloat x = 2;
    static CGFloat y = 2;
    //
    self.scanLine.frame = CGRectMake(x, y, self.scanView.frame.size.width - x * 2, self.scanLine.frame.size.height);
    self.scanLine.alpha = 0.f;
    self.scanLine.hidden = NO;
    //
    __weak typeof(self) wself = self;
    [UIView animateKeyframesWithDuration:3.0 delay:0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
            wself.scanLine.alpha = 1.f;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
            wself.scanLine.frame = CGRectMake(x, wself.scanView.frame.size.height - wself.scanLine.frame.size.height - y,
                                              wself.scanView.frame.size.width - x * 2, wself.scanLine.frame.size.height);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
            wself.scanLine.alpha = 0.f;
        }];
    } completion:^(BOOL finished) {
        
    }];
}
@end
