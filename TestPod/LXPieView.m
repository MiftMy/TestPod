//
//  LXPieView.m
//  TestPod
//
//  Created by mifit on 15/9/29.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "LXPieView.h"
static const NSInteger textHeigth = 22;

@interface LXPieView()
@property (nonatomic,strong) CAShapeLayer *layerRed;//红色layer
@property (nonatomic,strong) CAShapeLayer *layerBlue;//蓝色layer
@property (nonatomic,strong) CAShapeLayer *layerShowBG;//红蓝背景layer
@property (nonatomic,strong) CAShapeLayer *layerBG;//白色底layer

@property (nonatomic,assign) CGFloat persentBlue;//蓝色原始百分比
@property (nonatomic,assign) CGFloat persentRed;//红色百分比

// 中间显示内容上、中、下
@property (nonatomic,strong) UILabel *labTitle;
@property (nonatomic,strong) UILabel *labPersent;
@property (nonatomic,strong) UILabel *labUnit;
@end

@implementation LXPieView
#pragma mark - public
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initLayer];
    }
    return self;
}

- (void)setUnit:(NSString *)unit{
    self.labUnit.text = unit;
    _unit = unit;
}

- (void)setTitle:(NSString *)title{
    self.labTitle.text = title;
    _title = title;
}

- (void)setPersent:(CGFloat)persent{
    self.labPersent.text = [NSString stringWithFormat:@"%.2f",persent];
    _persent = persent;
}

- (void)addBlue:(CGFloat)persentBlue red:(CGFloat)persentRed{
    CGFloat angleBlue = persentBlue * M_PI * 2;
    CGFloat angleRed = persentRed * M_PI * 2;
    self.layerBlue.path = [self circleArcRadius:(self.radiusIn + self.radiusOut) / 2 startAngle:0 endAngel:angleBlue].CGPath;
    self.layerRed.path = [self circleArcRadius:(self.radiusIn + self.radiusOut) / 2 startAngle:angleBlue endAngel:angleBlue + angleRed].CGPath;
    _persentBlue = persentBlue;
    _persentRed = persentRed;
}

- (void)startAnimation:(CGFloat)duration{
    CGFloat endBlueAngle = M_PI * 2 * (1 - self.persentRed);
    
    //旋转
    CABasicAnimation *animationRed = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animationRed.duration = duration;
    animationRed.fromValue = [NSNumber numberWithFloat:0];
    animationRed.toValue = [NSNumber numberWithFloat:M_PI * 2.0 * (1 - self.persentRed - self.persentBlue)];
    animationRed.removedOnCompletion = NO;
    animationRed.fillMode = kCAFillModeForwards;
    [self.layerRed addAnimation:animationRed forKey:@"nil"];
    
    //动画的内容--慢慢增长
    CABasicAnimation *animationBlue = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animationBlue.duration = duration;
    animationBlue.fromValue = [NSNumber numberWithFloat:self.persentBlue / (1 - self.persentRed)];
    animationBlue.toValue = [NSNumber numberWithFloat:1];
    [self.layerBlue addAnimation:animationBlue forKey:@"strokeEnd"];
    self.layerBlue.path = [self circleArcRadius:(self.radiusIn + self.radiusOut) / 2 startAngle:0 endAngel:endBlueAngle].CGPath;
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
    self.backgroundColor = [UIColor clearColor];
    _radiusOut = self.frame.size.width / 2;
    _radiusIn = _radiusOut - 20;
}

- (void)initLayer{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.lineWidth = width / 2;
    bgLayer.path = [self bgCirclePath:width / 2].CGPath;
    bgLayer.fillColor = [UIColor whiteColor].CGColor;
    [self.layer addSublayer:bgLayer];
    _layerBG = bgLayer;
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, height / 2 - textHeigth / 2 * 3, width, textHeigth)];
    title.text = @"title";
    title.textColor = [UIColor blueColor];
    title.font = [UIFont systemFontOfSize:12];
    title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:title];
    _labTitle = title;
    
    UILabel *persent = [[UILabel alloc]initWithFrame:CGRectMake(0, height / 2 - textHeigth / 2, width, textHeigth)];
    persent.text = @"2.00";
    persent.font = [UIFont systemFontOfSize:12];
    persent.textAlignment = NSTextAlignmentCenter;
    [self addSubview:persent];
    _labPersent = persent;
    
    UILabel *unit = [[UILabel alloc]initWithFrame:CGRectMake(0, height / 2 + textHeigth / 2, width, textHeigth)];
    unit.text = @"GB";
    unit.textColor = [UIColor blueColor];
    unit.font = [UIFont systemFontOfSize:12];
    unit.textAlignment = NSTextAlignmentCenter;
    [self addSubview:unit];
    _labUnit = unit;
    
    CAShapeLayer *showBGLayer = [CAShapeLayer layer];
    showBGLayer.lineWidth = self.radiusOut - self.radiusIn;
    showBGLayer.fillColor = [UIColor clearColor].CGColor;
    showBGLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    showBGLayer.path = [self bgCirclePath:(self.radiusIn + self.radiusOut) / 2].CGPath;
    [self.layer addSublayer:showBGLayer];
    _layerShowBG = showBGLayer;
    
    CAShapeLayer *showBlueLayer = [CAShapeLayer layer];
    showBlueLayer.lineWidth = self.radiusOut - self.radiusIn;
    showBlueLayer.fillColor = [UIColor clearColor].CGColor;
    showBlueLayer.strokeColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:showBlueLayer];
    _layerBlue = showBlueLayer;
    
    CAShapeLayer *showRedLayer = [CAShapeLayer layer];
    showRedLayer.lineWidth = self.radiusOut - self.radiusIn;
    showRedLayer.fillColor = [UIColor clearColor].CGColor;
    showRedLayer.strokeColor = [UIColor redColor].CGColor;
    showRedLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:showRedLayer];
    _layerRed = showRedLayer;

}

- (UIBezierPath *)bgCirclePath:(CGFloat)radius{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
}

- (UIBezierPath *)circleArcRadius:(CGFloat)radius startAngle:(CGFloat)sAngel endAngel:(CGFloat)eAngle{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(width / 2, height / 2) radius:radius startAngle:sAngel endAngle:eAngle clockwise:YES];
}
@end
