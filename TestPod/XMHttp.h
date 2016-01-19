//
//  XMHttp.h
//  podAFNetwork
//
//  Created by mifit on 15/9/14.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

/** 常用json格式
 NSArray *g = @[@"fds",@"fds",@"fds"];
 NSDictionary *d = @{@"10":@"type"};
 BOOL b = @YES;
 NSNumber n = @1;
 
 备注：参数不对返回错误；
 */

/**
 @param operation       请求
 @param responseObject  请求返回的数据
 */
typedef void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject);

/**
 @param operation       请求
 @param error           请求错误信息
 */
typedef void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface XMHttp : NSObject
#pragma mark - setting
/**
 设置请求的格式，只对post，get有用
 @param block  网络变化：AFNetworkReachabilityStatusReachableViaWWAN、AFNetworkReachabilityStatusReachableViaWiFi、AFNetworkReachabilityStatusNotReachable
 */
+ (void)http_rechablityChanged:(void(^)(AFNetworkReachabilityStatus status))block;

/**
 设置请求的格式，只对post，get使用AFHTTPRequestOperationManager
 @param rs  请求格式:AFHTTPRequestSerializer AFJSONRequestSerializer等
 */
+ (void)setRequestSerializer:(AFHTTPRequestSerializer *)rs;

/**
 设置响应的格式，只对post，get使用AFHTTPRequestOperationManager
 @param rs  响应格式:AFHTTPResponseSerializer AFImageResponseSerializer AFXMLParserResponseSerializer AFJSONResponseSerializer等
 php->AFHTTPResponseSerializer  html->GET
 */
+ (void)setResponseSerializer:(AFHTTPResponseSerializer *)rs;

#pragma mark - get or post
/**
 发送GET、POST请求,使用AFHTTPRequestOperationManager
 @param urlStr      请求url
 @param params      请求参数
 @param mtype       文件类型参数，POST请求时候，params有NSData数据需写,上传通道为对应NSData的key,具体值下面有
 @param httpMethod  请求方法:GET POST
 @param blockS      请求成功block
 @param blockF      请求失败block
 */
+ (AFHTTPRequestOperation *)http_RequestWithURL:(NSString *)     url
                                        params:(NSDictionary *) params
                                    httpMethod:(NSString *)     httpMethod
                                      mimeType:(NSString *)     mtype
                                       success:(successBlock)   blockS
                                       failure:(failureBlock)   blockF;
/**
 简单发送GET、POST发送请求
 @param urlStr      请求url
 @param params      请求参数
 @param httpMethod  请求方法:GET POST
 @param blockS      请求成功block
 @param blockF      请求失败block
 */
+ (AFHTTPRequestOperation *)http_RequestWithURL:(NSString *)        url
                                         params:(NSDictionary *)    params
                                     httpMethod:(NSString *)        httpMethod
                                        success:(successBlock)      blockS
                                        failure:(failureBlock)      blockF;

/**
 发送GET、POST发送请求，可设置请求头
 @param urlStr      请求url
 @param header      请求头，可为nil。key:URL、Connection、"Content-Type"、Date、"Set-Cookie"、"Transfer-Encoding"
 @param params      请求参数
 @param httpMethod  请求方法:GET POST
 @param blockS      请求成功block
 @param blockF      请求失败block
 */
+ (AFHTTPRequestOperation *)http_RequestWithURL:(NSString *)        url
                                  requestHeader:(NSDictionary *)    header
                                         params:(NSDictionary *)    params
                                     httpMethod:(NSString *)        httpMethod
                                        success:(successBlock)      blockS
                                        failure:(failureBlock)      blockF;

/**
 发送Get请求,使用AFHTTPRequestOperationManager
 @param urlStr  请求url
 @param blockS  请求成功block
 @param blockF  请求失败block
 */
+ (void)http_Get:(NSString *)   urlStr
         success:(successBlock) blockS
         failure:(failureBlock) blockF;

/**
 发送Get请求,使用AFHTTPRequestOperationManager
 @param urlStr  请求url
 @param params  请求参数
 @param blockS  请求成功block
 @param blockF  请求失败block
 */
+ (void)http_Get:(NSString *)       urlStr
      parameters:(NSDictionary *)   params
         success:(successBlock)     blockS
         failure:(failureBlock)     blockF;

/**
 发送Post请求,使用AFHTTPRequestOperationManager
 @param urlStr  请求url
 @param params  请求参数
 @param blockS  请求成功block
 @param blockF  请求失败block
 */
+ (void)http_Post:(NSString *)      urlStr
       parameters:(NSDictionary *)  params
          success:(successBlock)    blockS
          failure:(failureBlock)    blockF;

/**
 发送Post请求，body带二进制文件数据，可供用户上传图片之类,使用AFHTTPRequestOperationManager
 @param urlStr  请求url
 @param params  请求参数
 @param path    文件路径
 @param type    文件类型
 @param blockS  请求成功block
 @param blockF  请求失败block
 */
+ (void)http_Posts:(NSString *)     urlStr
        parameters:(NSDictionary *) params
          filePath:(NSString *)     path
          fileType:(NSString *)     type
           success:(successBlock)   blockS
           failure:(failureBlock)   blockF;

/**
 发送Post请求，body带二进制文件数据，可供用户上传图片之类,使用AFHTTPRequestOperationManager
 @param urlStr      请求url
 @param params      请求参数
 @param data        文件数据
 @param type        文件类型
 @param fileName    文件名字，必须带后缀，不能空
 @param mimeType    文件mimeType：text/html（HTML文档）
                                 application/xhtml+xml（XHTML文档）
                                 image/gif（GIF图像）
                                 image/jpeg（JPEG图像）【PHP中为：image/pjpeg】
                                 image/png（PNG图像）【PHP中为：image/x-png】
                                 video/mpeg（MPEG动画）
                                 application/octet-stream（任意的二进制数据）
                                 application/pdf（PDF文档）
                                 application/msword（Microsoft Word文件）
                                 message/rfc822（RFC 822形式）
                                 multipart/alternative（HTML邮件的HTML形式和纯文本形式，相同内容使用不同形式表示）
                                 application/x-www-form-urlencoded（使用HTTP的POST方法提交的表单）
                                 multipart/form-data（同上，但主要用于表单提交时伴随文件上传的场合）
 @param blockS      请求成功block
 @param blockF      请求失败block
 */
+ (void)http_Posts:(NSString *)     urlStr
        parameters:(NSDictionary *) params
          fileData:(NSData *)       data
          fileType:(NSString *)     type
          fileName:(NSString *)     fileName
          mimeType:(NSString *)     mimeType
           success:(successBlock)   blockS
           failure:(failureBlock)   blockF;

#pragma mark - down or up load

/**
 下载文件，没进度,缓存本地
 @param urlStr              请求url
 @param path                文件路径，不包含文件名;path为nil，文件下载到沙河的Document目录下
 @param completionHandler   响应block。response：请求；responseObject：相应数据；error：错误信息
 */
+ (void)http_Down:(NSString *)  urlStr
         savePath:(NSString *)  path
   completedBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/**
 下载文件，有进度,缓存本地
 @param urlStr      请求url
 @param path        文件完整路径;path为nil，文件下载到沙河的Document目录下
 @param progress    进度回调百分比
 @param blockS      请求成功block
 @param blockF      请求失败block
 */
+ (void)http_Down:(NSString *)      urlStr
         savePath:(NSString *)      path
         progress:(void (^)(CGFloat progress))progress
          success:(successBlock)    blockS
          failure:(failureBlock)    blockF;

/**
 下载文件，没进度,不缓存本地
 @param urlImage    图片url
 @param blockS      请求成功block，responseObject就是UIImage图片
 @param blockF      请求失败block
 */
+ (void)http_DownImage:(NSString *)     urlImage
               success:(successBlock)   blockS
               failure:(failureBlock)   blockF;

/**
 下载文件，有进度,缓存本地
 @param urlImage    图片url
 @param blockS      请求成功block，responseObject就是UIImage图片
 @param blockF      请求失败block
 */
+ (void)http_DownImage:(NSString *)     urlImage
              progress:(void (^)(CGFloat progress))progress
               success:(successBlock)   blockS
               failure:(failureBlock)   blockF;


/**
 上传文件，没进度
 @param urlStr              上传url
 @param path                文件路径，包含文件名
 @param completionHandler   响应block。response：请求；responseObject：相应数据；error：错误信息
 */
+ (void)http_Upload:(NSString *)    url
               path:(NSString *)    path
     completedBlock:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler;
@end
