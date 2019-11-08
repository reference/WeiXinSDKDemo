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
#import <UIKit/UIKit.h>
#import <BDToolKit/BDToolKit.h>
#import <ZXToolbox/ZXToolbox.h>
#import <FFToast/FFToast.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "BDBaseDefine.h"

/// pick image callback
typedef void (^BDAlbumPickBlock)(UIImage *image);

@interface BDBaseCollectionViewController : BDCollectionViewController
@property (nonatomic,strong) ZXPopoverWindow *window;
@property (nonatomic,strong) UIImage *backButtonImage;
@property (nonatomic,copy) BDAlbumPickBlock albumPickBlock;

//no data view data
@property (nonatomic,assign) BOOL displayNoDataView;    //default is NO
@property (nonatomic,strong) UIImage *noDataImage;
@property (nonatomic,strong) NSString *noDataText;

- (void)warning:(NSString *)text;
- (void)error:(id)err;
- (void)info:(NSString *)text;
- (void)success:(NSString *)text;
- (FFToast *)showActiveWithText:(NSString *)text;
- (void)dismissActiveToast:(FFToast *)t;

- (void)alertText:(NSString *)text;
- (void)alertText:(NSString *)text sureTitle:(NSString *)sure sureAction:(void (^)(void))handler;

- (void)popView:(UIView *)view;
- (void)popView:(UIView *)view position:(Position)position;
- (IBAction)onWindowDismiss:(id)sender;

//pick image
- (void)pickImageFromAlbumWithCanEditImage:(BOOL)editable block:(BDAlbumPickBlock)block;

/// judge
- (BOOL)passJudgeOfUITextField:(UITextField *)textField failureText:(NSString *)text;
- (BOOL)passJudgeOfUITextView:(UITextView *)textView failureText:(NSString *)text;
- (BOOL)passJudgeOfUILabel:(UILabel *)label failureText:(NSString *)text;
- (BOOL)passJudgeOfNSError:(NSError *)error;
@end
