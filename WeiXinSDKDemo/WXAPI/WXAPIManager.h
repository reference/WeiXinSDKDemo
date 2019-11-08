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
#import "WXApi.h"
#import "WXApiObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WXAuthDelegate <NSObject>

@optional
- (void)wxAuthSucceed:(NSString*)code;
- (void)wxAuthDenied;
- (void)wxAuthCancel;

@end

@interface WXAPIManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXAuthDelegate, NSObject> delegate;

/**
 *  严格单例，唯一获得实例的方法.
 *
 *  @return 实例对象.
 */
+ (instancetype)sharedManager;

/**
 *  发送微信验证请求.
 *
 *  @restrict 该方法支持未安装微信的用户.
 *
 *  @param viewController 发起验证的VC
 *  @param delegate       处理验证结果的代理
 */
- (void)sendAuthRequestWithController:(UIViewController*)viewController
                             delegate:(id<WXAuthDelegate>)delegate;

/**
 *  发送链接到微信.
 *
 *  @restrict 该方法要求用户一定要安装微信.
 *
 *  @param urlString 链接的Url
 *  @param title     链接的Title
 *  @param description      链接的描述
 *  @param scene     发送的场景，分为朋友圈, 会话和收藏
 *
 *  @completion 发送成功返回YES
 */
- (void)sendLinkContent:(NSString *)urlString
                  Title:(NSString *)title
            Description:(NSString *)description
                AtScene:(enum WXScene)scene
             completion:(void (^ __nullable)(BOOL success))completion;
/**
 *  发送文件到微信.
 *
 *  @restrict 该方法要求用户一定要安装微信.
 *
 *  @param fileData   文件的数据
 *  @param extension  文件扩展名
 *  @param title      文件的Title
 *  @param desc       文件的描述
 *  @param thumbImage 文件缩略图
 *  @param scene      发送的场景，分为朋友圈, 会话和收藏
 */
- (void)sendFileData:(NSData *)fileData
       fileExtension:(NSString *)extension
               Title:(NSString *)title
         Description:(NSString *)desc
          ThumbImage:(UIImage *)thumbImage
             AtScene:(enum WXScene)scene
          completion:(void (^ __nullable)(BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
