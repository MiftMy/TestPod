//
//  XMBaseViewController.h
//  podAFNetwork
//
//  Created by mifit on 15/9/14.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMBaseViewController : UIViewController
/// 获取到相片缓存
@property (nonatomic,strong) NSString *savePath;

/**
 上传图片，通道默认image
 @param url     上传地址
 @param dic     上传参数
 @param size    图片宽度，高度与宽一样。传 <= 0，使用默认大小200*200.
 @param block   获取到图片后回调Block。image:获取到的图片
 */
- (void)uploadImageFromCamera:(NSString *)url paramers:(NSDictionary *)dic imageWidth:(NSInteger)width completed:(void (^)(UIImage *image))block;
@end
