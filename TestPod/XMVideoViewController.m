//
//  XMVideoViewController.m
//  TestPod
//
//  Created by mifit on 15/9/24.
//  Copyright © 2015年 mifit. All rights reserved.
//
#define NLSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS7 NLSystemVersionGreaterOrEqualThan(7.0)

#import "XMVideoViewController.h"
#import "XMVideoView.h"
#import "AppDelegate.h"

@interface XMVideoViewController ()
/// 视频总时间
@property (nonatomic,assign) CGFloat totalDuration;
/// 当前播放时间进度
@property (nonatomic,assign) CGFloat currentTime;
/// 是否在播放
@property (nonatomic,assign) BOOL isPlaying;

/// frame是否改变,3击放大
@property (nonatomic,assign) BOOL isFrameChange;
/// 改变后的frame
@property (nonatomic,assign) CGRect frameChanged;

/// 是否横屏
@property (nonatomic,assign) BOOL isHorizontal;
/// 旋转角度
@property (nonatomic,assign) CGFloat angle;

@property (nonatomic,strong) XMVideoView *xmView;
@property (nonatomic,strong) AVPlayerItem *item;

@property (weak, nonatomic) IBOutlet UIView *controlView;
- (IBAction)before:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)playOrPause:(id)sender;
- (IBAction)fullOrOrigon:(id)sender;


@end

@implementation XMVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _interval = 15;
    
    //self.navigationController.hidesBarsOnTap = YES;
    
    // 不加无声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];

    CGRect rect = self.view.frame;
    XMVideoView *xmView = [[XMVideoView alloc]initWithFrame:rect];
    xmView.backgroundColor = [UIColor darkGrayColor];
    [self.view insertSubview:xmView belowSubview:self.controlView];
    
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"]];
    //player是视频播放的控制器，可以用来快进播放，暂停等
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [xmView setPlayer:player];
    self.item = playerItem;
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _xmView = xmView;
    
    [xmView touchForward:^(BOOL isForward,BOOL isLong) {
        if (isLong) {
            [self moveNext:isForward];
        } else {
            [self moveForward:isForward];
        }
    }];
    
    [xmView touchUp:^(BOOL isUp, BOOL isLong) {
        if (isLong) {
            [self hideNavigationAndControl:isUp];
        }
    }];
    
    if (!IOS7) {
        //计算视频总时间
        CMTime totalTime = playerItem.duration;
        //因为slider的值是小数，要转成float，当前时间和总时间相除才能得到小数,因为5/10=0
        _totalDuration = (CGFloat)totalTime.value / totalTime.timescale;
        NSDate *d = [NSDate dateWithTimeIntervalSince1970:_totalDuration];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if (_totalDuration / 3600 >= 1) {
            [formatter setDateFormat:@"HH:mm:ss"];
        } else {
            [formatter setDateFormat:@"mm:ss"];
        }
        NSString *showtimeNew = [formatter stringFromDate:d];
        NSLog(@"totalMovieDuration:%@",showtimeNew);
        //在totalTimeLabel上显示总时间
    }
    
    //检测视频加载状态，加载完成隐藏风火轮
    [xmView.player.currentItem addObserver:self forKeyPath:@"status"
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
    [xmView.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges"
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
    
    //添加视频播放完成的notifation
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:xmView.player.currentItem];
    
    //添加app进入非激活
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iApplicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];
    
    /*
     视频播放时，控制手势，双击放大缩小播放比例
     双指缩放播放比例
     */
    //轻触手势（单击，双击）
    UITapGestureRecognizer *oneTap=nil;
    oneTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneTap:)];
    oneTap.numberOfTapsRequired = 1;
    [xmView addGestureRecognizer:oneTap];
    
    UITapGestureRecognizer *towCgr=nil;
    towCgr=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(twoTap:)];
    towCgr.numberOfTapsRequired = 2;
    [xmView addGestureRecognizer:towCgr];
    
    [oneTap requireGestureRecognizerToFail:towCgr]; //防止：双击被单击拦截
    
    UITapGestureRecognizer *thrCgr=nil;
    thrCgr=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(thrTap:)];
    thrCgr.numberOfTapsRequired = 3;
    [xmView addGestureRecognizer:thrCgr];
    
    [towCgr requireGestureRecognizerToFail:thrCgr]; //防止：3击被双击拦截
    
}

//状态栏显示状态
- (BOOL)prefersStatusBarHidden{
    if (self.angle < 0.000001 && self.angle > -0.000001) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [self.xmView.player play];
    //[self.updateTimer setFireDate:[NSDate distantPast]];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_xmView.player.currentItem removeObserver:self forKeyPath:@"status"];
    [_xmView.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];

    //添加app进入非激活
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_xmView.player.currentItem];
    [_xmView.player pause];
    _xmView = nil;
    _videoURL = nil;
    _videoURLs = nil;
    _item = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - private
- (void)hideNavigationAndControl:(BOOL)isHide{
    if (isHide) {
        self.controlView.hidden = NO;
        [super.navigationController setNavigationBarHidden:NO animated:YES];
    } else {
        self.controlView.hidden = YES;
        [super.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

//视频播放完成
-(void)moviePlayDidEnd:(NSNotification*)notification{
    NSLog(@"播放完成 可加入广告");
}

// 进入后台
-(void)iApplicationWillResignActive:(NSNotification *)notification{
    _isPlaying = NO;
    [_xmView.player pause];
    NSLog(@"进入后台");
}

// 左旋转
- (void)rotationLeft{
    _xmView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
    CGRect rect = _xmView.frame;
    CGFloat with = rect.size.width;
    CGFloat heigth = rect.size.height;
    _xmView.layer.frame = CGRectMake(0,0, heigth, with);
    self.angle = M_PI_2;
    [self.view setNeedsDisplay];
    [self setNeedsStatusBarAppearanceUpdate];
}

//右旋转
- (void)rotationRigth{
    _xmView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
    CGRect rect = _xmView.frame;
    CGFloat with = rect.size.width;
    CGFloat heigth = rect.size.height;
    _xmView.layer.frame = CGRectMake(0,0, heigth, with);
    self.angle = -M_PI_2;
    [self setNeedsStatusBarAppearanceUpdate];
}

//恢复旋转
- (void)resetRotation{
    _xmView.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
    CGRect rect = self.view.frame;
    CGFloat with = rect.size.width;
    CGFloat heigth = rect.size.height;
    _xmView.layer.frame = CGRectMake(0,0, with, heigth);
    self.angle = 0;
    [self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark - control method
//上/下一个视频
- (void)moveNext:(BOOL)isNext{
    NSLog(@"----next:%d",isNext);
}

// 显示控制按钮
- (void)showControls{
    self.controlView.hidden = NO;
}

// 左右滑动响应函数
- (void)moveForward:(BOOL)isForward{
    NSLog(@"----forward:%d",isForward);
    [self.xmView.player pause];
    //获取当前时间
    CMTime currentTime = self.xmView.player.currentItem.currentTime;
    
    //转成秒数
    _currentTime = (CGFloat)currentTime.value / currentTime.timescale;
    CGFloat newTime;
    if (isForward) {
        newTime = _currentTime + _interval;
    } else {
        newTime = _currentTime - _interval;
    }
    if (newTime >= _totalDuration) {
        if (_isPlaying == YES) {
            [_xmView.player play];
        }
        return;
    }
    if (newTime < 0) {
        newTime = 0;
    }
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(newTime, 1);

    [_xmView.player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish) {
         [_xmView.player play];
     }];
    _isPlaying = YES;
}

// 单击播放/暂停
- (void) oneTap:(UITapGestureRecognizer *)sender{
    if (_isPlaying == YES)  {
        [_xmView.player pause];
    } else {
        [_xmView.player play];
    }
    _isPlaying = !_isPlaying;
}

//双击全屏
- (void) twoTap:(UITapGestureRecognizer *)sender{
    if (_isHorizontal) {
        [self resetRotation];
    } else {
        [self rotationRigth];
    }
    _isHorizontal = !_isHorizontal;
}

//3击放大/缩小播放比例
- (void)thrTap:(UITapGestureRecognizer *)sender{
    if (_isFrameChange == NO) {
        _frameChanged = _xmView.frame;
        _xmView.frame = CGRectInset(self.view.frame, -200, -200);
        _isFrameChange = YES;
    } else {
        _xmView.frame = _frameChanged;
        _isFrameChange = NO;
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSThread *tt = [NSThread currentThread];
    if ([tt isMainThread]) {
        NSLog(@"main-------%@",keyPath);
    }
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            //视频加载完成
            NSLog(@"加载完成");
            if (IOS7) {
                //计算视频总时间
                CMTime totalTime = playerItem.duration;
                _totalDuration = (CGFloat)totalTime.value/totalTime.timescale;
                NSDate *d = [NSDate dateWithTimeIntervalSince1970:_totalDuration];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                if (_totalDuration/3600 >= 1) {
                    [formatter setDateFormat:@"HH:mm:ss"];
                } else {
                    [formatter setDateFormat:@"mm:ss"];
                }
                NSString *showtimeNew = [formatter stringFromDate:d];
                NSLog(@"time:%@",showtimeNew);
            }
        }
        if (playerItem.status == AVPlayerStatusFailed) {
            NSLog(@"加载失败");
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        float bufferTime = [self availableDuration];
        NSLog(@"缓冲进度量%f",bufferTime);
    }
}

//加载进度
- (float)availableDuration{
    NSArray *loadedTimeRanges = [[self.xmView.player currentItem] loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}
#pragma mark - button method
- (IBAction)forward:(id)sender {
    [self moveForward:YES];
}

- (IBAction)back:(id)sender {
    [self moveForward:NO];
}

- (IBAction)playOrPause:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    [self oneTap:nil];
}

- (IBAction)fullOrOrigon:(id)sender {
    [self twoTap:nil];
}

- (IBAction)next:(id)sender {
    [self moveNext:YES];
}

- (IBAction)before:(id)sender {
    [self moveNext:NO];
}
@end
