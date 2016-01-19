//
//  XMLoadProgress.m
//  TestPod
//
//  Created by mifit on 15/10/6.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "XMLoadProgress.h"
@interface XMLoadProgress()
/// 加载
@property (nonatomic,strong) CAShapeLayer *loadLayer;
/// 显示
@property (nonatomic,strong) CAShapeLayer *frontLayer;
@end

@implementation XMLoadProgress
#pragma mark - public
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initLayer];
    }
    return self;
}

- (void)resetView{
    [self initData];
    [self initLayer];
}

- (void)setLineWidth:(CGFloat)lineWidth{
    if (self.frame.size.height < lineWidth) {
        lineWidth = self.frame.size.height;
    }
    _lineWidth = lineWidth;
    _loadLayer.lineWidth = lineWidth;
    _frontLayer.lineWidth = lineWidth;
}

- (void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    self.layer.backgroundColor = bgColor.CGColor;
}

- (void)setLoadColor:(UIColor *)loadColor{
    _loadLayer.strokeColor = loadColor.CGColor;
    _loadColor = loadColor;
}

- (void)setProgressColor:(UIColor *)progressColor{
    _frontLayer.strokeColor = progressColor.CGColor;
    _progressColor = progressColor;
}

- (void)setLoadProgress:(CGFloat)loadProgress{
    if (loadProgress < 0.0f) {
        loadProgress = 0.0f;
    }
    if (loadProgress > 1.0f) {
        loadProgress = 1.0f;
    }
    
    if (self.isAnimation) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 1;
        animation.fromValue = @(_loadProgress / loadProgress);
        animation.toValue = @(1);
        [_loadLayer addAnimation:animation forKey:@"strokeEnd"];
    }
    _loadLayer.path = [self linePath:loadProgress].CGPath;
    _loadProgress = loadProgress;
}

- (void)setProgress:(CGFloat)progress{
    if (progress < 0.0f) {
        progress = 0.0f;
    }
    if (progress > 1.0f) {
        progress = 1.0f;
    }
    
    if (self.isAnimation) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.duration = 1;
        animation.fromValue = @( _progress / progress);
        animation.toValue = @(1);
        [_frontLayer addAnimation:animation forKey:@"strokeEnd"];
    }
    _frontLayer.path = [self linePath:progress].CGPath;
    _progress = progress;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - private
- (void)initData{
    _lineWidth = 2;
    _isAnimation = YES;
    _bgColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _loadColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _progressColor = [UIColor blueColor];
}

- (void)initLayer{
    CGRect rect = self.frame;
    rect.origin = CGPointMake(0, 0);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2;
    self.layer.backgroundColor = _bgColor.CGColor;
    
    //加载
    _loadLayer = [CAShapeLayer layer];
    _loadLayer.frame = rect;
    _loadLayer.lineCap = @"round";
    _loadLayer.strokeColor  =  self.loadColor.CGColor;
    _loadLayer.fillColor =  [[UIColor clearColor] CGColor];
    _loadLayer.lineWidth = _lineWidth;
    [self.layer addSublayer:_loadLayer];
    
    //进度
    _frontLayer = [CAShapeLayer layer];
    _frontLayer.frame = rect;
    _frontLayer.strokeColor  =  self.progressColor.CGColor;
    _frontLayer.lineCap = @"round";
    _frontLayer.fillColor =  [[UIColor clearColor] CGColor];
    _frontLayer.lineWidth = _lineWidth;
    [self.layer addSublayer:_frontLayer];
}

- (UIBezierPath *)linePath:(CGFloat)progress{
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    [path moveToPoint:CGPointMake(self.lineWidth / 2 + 1, h / 2)];
    [path addLineToPoint:CGPointMake(w * progress - self.lineWidth / 2 - 2, h / 2 )];
    return path;
}
@end
