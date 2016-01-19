//
//  LXPieView.h
//  TestPod
//
//  Created by mifit on 15/9/29.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 fff
 */
@interface LXPieView : UIView
/// 圆环内径,默认比out小20
@property (nonatomic,assign) NSInteger radiusIn;

/// 圆环外径,默认frame一半
@property (nonatomic,assign) NSInteger radiusOut;

/// 显示文本，title
@property (nonatomic,strong) NSString *title;

/// 显示文本，百分比
@property (nonatomic,assign) CGFloat persent;

/// 显示文本，单位
@property (nonatomic,strong) NSString *unit;

/// 初始化
- (id)initWithFrame:(CGRect)frame;

/**
 添加蓝红比例
 */
- (void)addBlue:(CGFloat)persentBlue red:(CGFloat)persentRed;

/// 开始动画
- (void)startAnimation:(CGFloat)duration;
@end
