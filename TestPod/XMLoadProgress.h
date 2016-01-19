//
//  XMLoadProgress.h
//  TestPod
//
//  Created by mifit on 15/10/6.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMLoadProgress : UIView
/// 线宽,默认2
@property (nonatomic,assign) CGFloat lineWidth;
/// 是否动画
@property (nonatomic,assign) BOOL isAnimation;

/// 背景色，默认白色0.7
@property (nonatomic,strong) UIColor *bgColor;
/// 加载颜色，默认白色0.5
@property (nonatomic,strong) UIColor *loadColor;
/// 前景色，默认蓝色
@property (nonatomic,strong) UIColor *progressColor;

/// load progress
@property (nonatomic,assign) CGFloat loadProgress;
/// 显示progress
@property (nonatomic,assign) CGFloat progress;

- (id)initWithFrame:(CGRect)frame;

/// 关联sb的可以调用改函数初始化
- (void)resetView;
@end
