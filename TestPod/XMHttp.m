//
//  XMHttp.m
//  podAFNetwork
//
//  Created by mifit on 15/9/14.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import "XMHttp.h"

@implementation XMHttp
+ (void)http_rechablityChanged:(void(^)(AFNetworkReachabilityStatus status))block
{
    NSURL *baseURL = [NSURL URLWithString:@"www.apple.com"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        block(status);
    }];
}

+ (void)setRequestSerializer:(AFHTTPRequestSerializer *)rs{
    [XMHttp requestManager].requestSerializer = rs;
}

+ (void)setResponseSerializer:(AFHTTPResponseSerializer *)rs{
    [XMHttp requestManager].responseSerializer = rs;
}

+ (AFHTTPRequestOperationManager *)requestManager
{
    static dispatch_once_t onceToken;
    static AFHTTPRequestOperationManager *ma;
    dispatch_once(&onceToken, ^{
        ma = [AFHTTPRequestOperationManager manager];
        ma.responseSerializer = [AFJSONResponseSerializer serializer];
    });
    return ma;
}

+ (AFURLSessionManager *)sessionManager
{
    static dispatch_once_t onceToken;
    static AFURLSessionManager *ma;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        ma = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    });
    return ma;
}
#pragma mark - get
/// Get
+ (void)http_Get:(NSString *)urlStr
         success:(successBlock)blockS
         failure:(failureBlock)blockF
{
    AFHTTPRequestOperationManager *manager = [XMHttp requestManager];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        blockF(operation,error);
    }];
}

/// Get
+ (void)http_Get:(NSString *)urlStr
      parameters:(NSDictionary *)params
         success:(successBlock)blockS
         failure:(failureBlock)blockF
{
    AFHTTPRequestOperationManager *manager = [XMHttp requestManager];
    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        blockF(operation,error);
    }];
}

#pragma mark - post
+(AFHTTPRequestOperation *)http_RequestWithURL:(NSString *)     url
                                        params:(NSDictionary *) params
                                    httpMethod:(NSString *)     httpMethod
                                      mimeType:(NSString *)     mtype
                                       success:(successBlock)   blockS
                                       failure:(failureBlock)   blockF
{
    //创建request请求管理对象
    AFHTTPRequestOperationManager * manager = [self requestManager];
    AFHTTPRequestOperation * operation = nil;
    //GET请求
    NSComparisonResult comparison1 = [httpMethod caseInsensitiveCompare:@"GET"];
    
    if (comparison1 == NSOrderedSame) {
        operation =[manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (blockS != nil) {
                blockS(responseObject,responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (blockF != nil) {
                blockF(operation,error);
            }
        }];
    }
    
    //POST请求
    NSComparisonResult comparisonResult2 = [httpMethod caseInsensitiveCompare:@"POST"];
    if (comparisonResult2 == NSOrderedSame)
    {
        //标示
        BOOL isFile = NO;
        NSString *dataKey;
        for (NSString * key in params.allKeys)
        {
            id value = params[key];
            //判断请求参数是否是文件数据
            if ([value isKindOfClass:[NSData class]]) {
                isFile = YES;
                dataKey = key;
                break;
            }
        }
        
        if (!isFile) {
            //参数中没有文件，则使用简单的post请求
            operation = [manager POST:url
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if (blockS != nil) {
                                     blockS(operation,responseObject);
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 if (blockF != nil) {
                                     blockF(operation,error);
                                 }
                             }];
        } else {
            NSString *fileName = [NSString stringWithFormat:@"uploadFile.%@",[mtype lastPathComponent]];
            operation =[manager POST:url
                          parameters:params
           constructingBodyWithBlock:^(id formData) {
               [formData appendPartWithFileData:params[dataKey]
                                           name:dataKey
                                       fileName:fileName
                                       mimeType:mtype];
           } success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (blockS != nil) {
                   blockS(operation,responseObject);
               }
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (blockF != nil) {
                   blockF(operation,error);
               }
           }];
        }
    }
    //设置返回数据的解析方式
    operation.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    return operation;
}

+ (AFHTTPRequestOperation *)http_RequestWithURL:(NSString *)        url
                                         params:(NSDictionary *)    params
                                     httpMethod:(NSString *)        httpMethod
                                        success:(successBlock)      blockS
                                        failure:(failureBlock)      blockF
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    //get请求
    NSComparisonResult compResult1 =[httpMethod caseInsensitiveCompare:@"GET"];
    if (compResult1 == NSOrderedSame) {
        [request setHTTPMethod:@"GET"];
        if(params != nil)
        {
            //添加参数，将参数拼接在url后面
            NSMutableString *paramsString = [NSMutableString string];
            NSArray *allkeys = [params allKeys];
            for (NSString *key in allkeys) {
                NSString *value = [params objectForKey:key];
                [paramsString appendFormat:@"&%@=%@", key, value];
            }
            
            if (paramsString.length > 0) {
                [paramsString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
                //重新设置url
                [request setURL:[NSURL URLWithString:[url stringByAppendingString:paramsString]]];
            }
        }
    }
    //post请求
    NSComparisonResult compResult2 = [httpMethod caseInsensitiveCompare:@"POST"];
    if (compResult2 == NSOrderedSame) {
        [request setHTTPMethod:@"POST"];
        for (NSString *key in params) {
            NSString *v = params[key];
            [request setHTTPBody:[v dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        }
    }
    //发送请求
    AFHTTPRequestOperation *requstOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //设置返回数据的解析方式(这里暂时只设置了json解析)
    requstOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requstOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (blockS != nil) {
            blockS(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (blockF != nil) {
            blockF(operation,error);
        }
    }];
    [requstOperation start];
    return requstOperation;
}
/// url为请求地址，params是请求体，传字典进去，，httpMethod 是请求方式，block是请求完成做得工作，header是请求头，也是传字典过去（发送请求获得json数据）,如果没有则传nil,如果只有value而没有key，则key可以设置为anykey

+ (AFHTTPRequestOperation *)http_RequestWithURL:(NSString *)        url
                                  requestHeader:(NSDictionary *)    header
                                         params:(NSDictionary *)    params
                                     httpMethod:(NSString *)        httpMethod
                                        success:(successBlock)      blockS
                                        failure:(failureBlock)      blockF
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    //添加请求头
    for (NSString *key in header.allKeys) {
        [request addValue:header[key] forHTTPHeaderField:key];
    }
    
    //get请求
    NSComparisonResult compResult1 =[httpMethod caseInsensitiveCompare:@"GET"];
    if (compResult1 == NSOrderedSame) {
        [request setHTTPMethod:@"GET"];
        if(params != nil)
        {
            //添加参数，将参数拼接在url后面
            NSMutableString *paramsString = [NSMutableString string];
            NSArray *allkeys = [params allKeys];
            for (NSString *key in allkeys) {
                NSString *value = [params objectForKey:key];
                [paramsString appendFormat:@"&%@=%@", key, value];
            }
            
            if (paramsString.length > 0) {
                [paramsString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
                //重新设置url
                [request setURL:[NSURL URLWithString:[url stringByAppendingString:paramsString]]];
            }
        }
    }
    //post请求
    NSComparisonResult compResult2 = [httpMethod caseInsensitiveCompare:@"POST"];
    if (compResult2 == NSOrderedSame) {
        [request setHTTPMethod:@"POST"];
        for (NSString *key in params) {
            [request setHTTPBody:[params[key] dataUsingEncoding:NSASCIIStringEncoding]];
        }
    }
    //发送请求
    AFHTTPRequestOperation *requstOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //设置返回数据的解析方式(这里暂时只设置了json解析)
    requstOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requstOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (blockS != nil) {
            blockS(operation,responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (blockF != nil) {
            blockF(operation,error);
        }
    }];
    [requstOperation start];
    return requstOperation;
}

/// Post
+ (void)http_Post:(NSString *)urlStr
       parameters:(NSDictionary *)params
          success:(successBlock)blockS
          failure:(failureBlock)blockF
{
    AFHTTPRequestOperationManager *manager = [XMHttp requestManager];
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"JSON: %@", responseObject);
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        blockF(operation,error);
    }];
}

/// Posts  带body，可用于上传文件
+ (void)http_Posts:(NSString *)urlStr
        parameters:(NSDictionary *)params
          filePath:(NSString *)path
          fileType:(NSString *)type
           success:(successBlock)blockS
           failure:(failureBlock)blockF
{
    AFHTTPRequestOperationManager *manager = [XMHttp requestManager];
    NSURL *filePath = [NSURL fileURLWithPath:path];
    [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:type error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Success: %@", responseObject);
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        blockF(operation,error);
    }];
}

+ (void)http_Posts:(NSString *)urlStr
        parameters:(NSDictionary *)params
          fileData:(NSData *)data
          fileType:(NSString *)type
          fileName:(NSString *)fileName
          mimeType:(NSString *)mimeType
           success:(successBlock)blockS
           failure:(failureBlock)blockF
{
    AFHTTPRequestOperationManager *manager = [XMHttp requestManager];
    [manager POST:urlStr parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:type fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Success: %@", responseObject);
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //NSLog(@"Error: %@", error);
        blockF(operation,error);
    }];
}

#pragma mark - down load
/// Down
+ (void)http_Down:(NSString *)urlStr
         savePath:(NSString *)path
   completedBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    AFURLSessionManager *manager = [XMHttp sessionManager];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL;
        if (path == nil) {
            documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        } else {
            // URLWithString返回的是网络的URL,如果使用本地URL,需要注意
            documentsDirectoryURL = [NSURL fileURLWithPath:path];
        }
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        //NSLog(@"File downloaded to: %@", filePath);
        completionHandler(response,filePath,error);
    }];
    [downloadTask resume];
}

+ (void)http_Down:(NSString *)urlStr
         savePath:(NSString *)path
         progress:(void (^)(CGFloat progress))progress
          success:(successBlock)blockS
          failure:(failureBlock)blockF
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:YES];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float prog = ((float)totalBytesRead) / (totalBytesExpectedToRead);
        progress(prog);
    }];    //成功和失败回调
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockF(operation,error);
    }];
    [operation start];
}

+ (void)http_DownImage:(NSString *)urlImage
               success:(successBlock)blockS
               failure:(failureBlock)blockF
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlImage]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockF(operation,error);
    }];
    [operation start];
}

+ (void)http_DownImage:(NSString *)urlImage
              progress:(void (^)(CGFloat progress))progress
               success:(successBlock)blockS
               failure:(failureBlock)blockF
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlImage]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat pro = totalBytesRead / (double)totalBytesExpectedToRead;
        progress(pro);
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        blockS(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        blockF(operation,error);
    }];
    [operation start];
}

#pragma mark - up load
//-------------------------------------------------
/// Upload
+ (void)http_Upload:(NSString *)url
               path:(NSString *)path
     completedBlock:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    AFURLSessionManager *manager = [XMHttp sessionManager];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURL *filePath = [NSURL fileURLWithPath:path];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        completionHandler(response,responseObject,error);
    }];
    [uploadTask resume];
}

/// Upload with progress
+ (void)http_UploadProgress{}

#pragma mark - task
+ (void)http_Task
{
    AFURLSessionManager *manager = [XMHttp sessionManager];
    NSURL *URL = [NSURL URLWithString:@"http://example.com/upload"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}

@end
