//
//  XMVideoView.m
//  TestPod
//
//  Created by mifit on 15/9/24.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "XMVideoView.h"
#import <MediaPlayer/MediaPlayer.h>

/// 长短分割值
const CGFloat longScratch = 150.0f;
/// 短有效起始值
const CGFloat activeRegion = 50.0f;


@interface XMVideoView()
@property (nonatomic,assign) CGFloat beginX;
@property (nonatomic,assign) CGFloat beginY;
@property (nonatomic,copy) void (^blockForward)(BOOL isForward,BOOL isLong);
@property (nonatomic,copy) void (^blockUp)(BOOL isUp,BOOL isLong);
@end

@implementation XMVideoView
+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (AVPlayer*)player{
    return [(AVPlayerLayer *)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)thePlayer{
    return [(AVPlayerLayer *)[self layer]setPlayer:thePlayer];
}

#pragma mark - public
- (void)touchForward:(void (^)(BOOL isForward,BOOL isLong))block{
    self.blockForward = block;
}

- (void)touchUp:(void (^)(BOOL isUp,BOOL isLong))block{
    self.blockUp = block;
}

- (void)setVolume:(CGFloat)volume{
    if (volume < 0.000001) {
        volume = 0.0f;
    }
    if (volume > 0.999999 ) {
        volume = 1.0f;
    }
    MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
    mpc.volume = volume;
    _volume = volume;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - private
- (CGFloat)sWidth{
    return self.layer.frame.size.width;
}

- (CGFloat)sHeight{
    return self.layer.frame.size.height;
}
#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    //NSLog(@"began %f==%f",touchPoint.x,touchPoint.y);
    _beginX = (touchPoint.x);
    _beginY = (touchPoint.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    CGFloat changeX = touchPoint.x - _beginX;
    CGFloat changeY = touchPoint.y - _beginY;
    CGFloat changeXF = fabs(changeX);
    CGFloat changeYF = fabs(changeY);
    
    BOOL isHorizontal = changeXF > changeYF;// 划动方向
    
    if (isHorizontal) {
        //右短划
        if (changeX >= activeRegion && changeX <= longScratch ) {
            if (self.blockForward) {
                self.blockForward(YES,NO);
            }return;
        }
        //左短划，changeX负数
        if (changeX <= -activeRegion && changeX >= -longScratch ) {
            if (self.blockForward) {
                self.blockForward(NO,NO);
            }return;
        }
        //右长划
        if (changeX >= longScratch) {
            if (self.blockForward) {
                self.blockForward(YES,YES);
            }return;
        }
        //左长划，changeX负数
        if (changeX <= -longScratch  ) {
            if (self.blockForward) {
                self.blockForward(NO,YES);
            }return;
        }
    } else {
        if (changeY >= activeRegion && changeY <= longScratch ) {
            NSLog(@"减小音量 1/20");
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            if ((mpc.volume - 0.1) <= 0) {
                mpc.volume = 0;
            } else {
                mpc.volume = mpc.volume - 0.05;
            }
            _volume = mpc.volume;return;
        }
        //changeY 负数
        if ( -changeY >= activeRegion && -changeY <= longScratch ) {
            NSLog(@"加大音量 1/20");
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            if ((mpc.volume + 0.1) >= 1) {
                mpc.volume = 1;
            } else {
                mpc.volume = mpc.volume + 0.05;
            }
            _volume = mpc.volume;return;
        }
        
        if (changeY >= longScratch ) {
            if (self.blockUp) {
                self.blockUp(NO,YES);
            }return;
        }
        //changeY 负数
        if ( -changeY >= longScratch ) {
            if (self.blockUp) {
                self.blockUp(YES,YES);
            }return;
        }
    }
}

@end
