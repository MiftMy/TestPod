//
//  XMVideoView.h
//  TestPod
//
//  Created by mifit on 15/9/24.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XMVideoView : UIView
/// 音量 0 ~ 1
@property(nonatomic,assign) CGFloat volume;
/// player
@property(nonatomic,strong) AVPlayer *player;

/// 屏幕滑动，isForward：左滑/右滑    isLong：划动长（YES）/短(NO)
- (void)touchForward:(void (^)(BOOL isForward,BOOL isLong))block;

/// 屏幕划动，isUp:向上(YES)/向下（NO）划动  iisLong：划动长（YES）/短(NO)
- (void)touchUp:(void (^)(BOOL isUp,BOOL isLong))block;
@end
