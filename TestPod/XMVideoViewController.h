//
//  XMVideoViewController.h
//  TestPod
//
//  Created by mifit on 15/9/24.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XMVideoView;

@interface XMVideoViewController : UIViewController
@property (nonatomic,strong) NSArray *videoURLs;
/// 音/视频url
@property (nonatomic,strong) NSURL *videoURL;
/// 快进/快退间隔（秒）
@property (nonatomic,assign) NSInteger interval;
@end
