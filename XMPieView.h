//
//  XMPieView.h
//  TestPod
//
//  Created by mifit on 15/9/29.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMPieView : UIView
/// 圆环内径,默认比out小20
@property (nonatomic,assign) NSInteger radiusIn;

/// 圆环外径,默认frame一半
@property (nonatomic,assign) NSInteger radiusOut;

/// 循环是否重复
@property (nonatomic,assign) BOOL isRepeat;

/// title
@property (nonatomic,strong) NSString *title;

/// 显示百分比
@property (nonatomic,assign) CGFloat persent;

/// 单位
@property (nonatomic,strong) NSString *unit;

/// 初始化
- (id)initWithFrame:(CGRect)frame;

/// 添加百分比，颜色
- (void)addPersent:(CGFloat)persent color:(UIColor *)color;

/// 开始旋转
- (void)startRotation;

/// 停止旋转
- (void)stopRotation;
@end
