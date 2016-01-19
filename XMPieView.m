//
//  XMPieView.m
//  TestPod
//
//  Created by mifit on 15/9/29.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import "XMPieView.h"
@interface XMPieView()
/// 百分比
@property (nonatomic,strong) NSMutableArray *persents;
/// 颜色
@property (nonatomic,strong) NSMutableArray *colors;
@end

@implementation XMPieView
#pragma mark - public
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
    }
    return self;
}

- (void)setRadiusIn:(NSInteger)radiusIn{
    _radiusIn = radiusIn;
    [self reload];
}

- (void)setRadiusOut:(NSInteger)radiusOut{
    _radiusOut = radiusOut;
    [self reload];
}

- (void)addPersent:(CGFloat)persent color:(UIColor *)color{
    if (persent <= 0.000001) {
        return;
    }
    UIColor *addColor = color;
    if (addColor == nil) {
        [self.colors addObject:[UIColor blueColor]];
    }
    [self.persents addObject:[NSNumber numberWithFloat:persent]];
    [self.colors addObject:color];
    [self reload];
}

- (void)startRotation{
    [self.layer removeAllAnimations];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;///可调节转速
    rotationAnimation.cumulative = YES;
    if (_isRepeat) {
        rotationAnimation.repeatCount = CGFLOAT_MAX;
    }
    
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopRotation{
    [self.layer removeAllAnimations];
}
#pragma mark - private
- (void)initData{
    self.backgroundColor = [UIColor clearColor];
//    self.layer.shadowColor = [[UIColor blackColor] CGColor];
//    self.layer.shadowOffset = CGSizeMake(0.0f, 2.5f);
//    self.layer.shadowRadius = 1.9f;
//    self.layer.shadowOpacity = 0.9f;
    _radiusIn = self.frame.size.width / 2 - 22;
    _radiusOut = self.frame.size.width / 2 - 2;
    _isRepeat = YES;
    _title = @"title";
    _unit = @"GB";
    _persent = 10;
}

- (NSMutableArray *)persents{
    if (!_persents) {
        _persents = [NSMutableArray array];
    }
    return _persents;
}

- (NSMutableArray *)colors{
    if (!_colors) {
        _colors = [NSMutableArray array];
    }
    return _colors;
}

- (void)reload{
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect{
    //准备
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat centerX = rect.size.width / 2;
    CGFloat centerY = rect.size.height / 2;
    CGFloat lineWidth = _radiusOut - _radiusIn;
    CGFloat radius = (_radiusOut + _radiusIn) / 2;
    
    //绘画
    // 底色
    CGContextAddArc(context, centerX, centerY, _radiusIn / 2, 0, M_PI * 2, false);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, _radiusIn);
    CGContextStrokePath(context);
    
    // 环底色
    CGContextAddArc(context, centerX, centerY, radius, 0, M_PI * 2, false);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, lineWidth);
    CGContextStrokePath(context);
    
    //文本
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[UIFont systemFontOfSize:12.0f], NSFontAttributeName,paragraphStyle,NSParagraphStyleAttributeName,[UIColor blackColor],NSStrokeColorAttributeName, nil];
    if (self.title) {
        [self.title drawInRect:CGRectMake(10, centerY - 31, 100, 21) withAttributes:dic];
    }
    if (self.unit) {
        [self.unit drawInRect:CGRectMake(10, centerY + 11, 100, 21) withAttributes:dic];
    }
    if (self.persents) {
        NSString *tem = [NSString stringWithFormat:@"%.2f",self.persent];
        [tem drawInRect:CGRectMake(10, centerY - 10, 100, 21) withAttributes:dic];
    }
    
    //环显示颜色
    CGFloat startAngle = - M_PI_2;
    CGFloat currentEndAngle = 0.0f;
    NSInteger count = self.persents.count;
    for (NSInteger index = 0; index < count; index++){
        currentEndAngle = [[self.persents objectAtIndex:index]floatValue] * M_PI * 2;
        CGContextAddArc(context, centerX, centerY, radius, startAngle, startAngle + currentEndAngle, false);
        UIColor  *drawColor = [self.colors objectAtIndex:index];
        CGContextSetStrokeColorWithColor(context, drawColor.CGColor);
        CGContextStrokePath(context);
        startAngle += currentEndAngle;
    }
}
@end
