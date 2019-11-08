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

#import "BDHTTP.h"

@implementation BDHTTP

+ (void)requestWithURL:(NSString *)url
                params:(NSDictionary *)params
                  body:(id)body
         responseClass:(Class)responseClass
     responseDataClass:(NSDictionary *)responseDataClass
            completion:(void(^)(id responseObject, NSError *error))completion {
    [BDHTTP requestWithURL:url params:params body:body completion:^(id responseObject, NSError *error) {
        id response = responseObject;
        if (response && responseClass && ![response isKindOfClass:UIImage.class]) {
            if ([response isKindOfClass:[NSArray class]]) {
                response = [NSArray yy_modelArrayWithClass:responseClass json:responseObject];
            } else {
                response = [responseClass yy_modelWithJSON:responseObject];
            }
            if (response) {
                NSArray *keys = [responseDataClass allKeys];
                for (NSString *key in keys) {
                    if ([response respondsToSelector:NSSelectorFromString(key)]) {
                        id data = [response valueForKey:key];
                        Class dataClass = [responseDataClass objectForKey:key];
                        if (data && dataClass) {
                            if ([data isKindOfClass:[NSArray class]]) {
                                data = [NSArray yy_modelArrayWithClass:dataClass json:data];
                            } else {
                                data = [dataClass yy_modelWithJSON:data];
                            }
                            if (data) {
                                [response setValue:data forKey:key];
                            }
                        }
                    }
                }
            }
        }
        if (completion) {
            completion(response, error);
        }
    }];
}

+ (void)requestWithURL:(NSString *)url
                params:(NSDictionary *)params
                  body:(id)body
            completion:(void(^)(id responseObject, NSError *error))completion {
    
    // manager
    static AFHTTPSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc] init];
        // 客户端是否信任非法证书
        manager.securityPolicy.allowInvalidCertificates = YES;
        // 是否在证书域字段中验证域名
        manager.securityPolicy.validatesDomainName = NO;
    });
    
    // params
    NSString *query = AFQueryStringFromParameters(params);
    if (params && query) {
        if ([url containsString:@"?"]) {
            url = [url stringByAppendingFormat:@"&%@", query];
        } else {
            url = [url stringByAppendingFormat:@"?%@", query];
        }
    }
    
    // request
    if (body == nil || [JSONObject isValidJSONObject:body]) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        if ([body isKindOfClass:NSData.class]) {
            params = [JSONObject JSONObjectWithData:body];
        } else if ([body isKindOfClass:NSString.class]) {
            params = [JSONObject JSONObjectWithString:body];
        }
    }
    if (params == nil) {
        params = body;
    }
    
    // response
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    if ([params isKindOfClass:NSDictionary.class] &&
        [params[@"contentType"] isEqualToString:@"image/*"]) {
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        [contentTypes addObject:@"image/jpeg"];
    } else {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        [contentTypes addObject:@"application/json"];
        [contentTypes addObject:@"charset=UTF-8"];
        [contentTypes addObject:@"text/html"];
        [contentTypes addObject:@"text/plain"];
    }
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    
    // success
    void (^success)(NSURLSessionDataTask * _Nonnull, id _Nullable) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    };
    
    // failure
    void (^failure)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(task.response, error);
        }
    };

    if (body == nil) {
        // GET
        [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([JSONObject isValidJSONObject:responseObject]) {
                NSLogD(@"GET %@\n参数: %@\n响应: %@", url, [params yy_modelToJSONObject], [JSONObject stringWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted]);
            } else {
//                id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLogD(@"GET %@\n参数: %@\n响应: %@", url, [params yy_modelToJSONObject], [responseObject yy_modelToJSONObject]);

            }
            success(task, responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLogA(@"GET %@\n%@", url, error.localizedDescription);
            failure(task, error);
        }];
        
    } else {
        // POST
        [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            // nothing
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([JSONObject isValidJSONObject:responseObject]) {
                NSLogD(@"POST %@\n参数: %@\n响应: %@", url, [params yy_modelToJSONObject], [JSONObject stringWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted]);
            } else {
                NSLogD(@"POST %@\n参数: %@\n响应: %@", url, [params yy_modelToJSONObject], [responseObject yy_modelToJSONObject]);
            }
            success(task, responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLogA(@"POST %@\n%@", url, error.localizedDescription);
            failure(task, error);
        }];
    }
}

+ (void)uploadWithURL:(NSString *)url params:(NSDictionary *)params data:(NSArray<ZXHTTPFormData *> *)data responseClass:(Class)responseClass completion:(void (^)(id, NSError *))completion {
    [ZXHTTPClient POST:url params:params formData:data requestHandler:^(NSMutableURLRequest *request) {
        //
    } completionHandler:^(NSURLSessionDataTask *task, NSData *data, NSError *error) {
        id response = task.response;
        if (data && responseClass) {
            if ([response isKindOfClass:[NSArray class]]) {
                response = [NSArray yy_modelArrayWithClass:responseClass json:data];
            } else {
                response = [responseClass yy_modelWithJSON:data];
            }
        }
        if (completion) {
            completion(response, error);
        }
    }];
}


@end
