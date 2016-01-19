//
//  XMChiZi.h
//  podAFNetwork
//
//  Created by mifit on 15/9/9.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 时间变化回调block，time：指示的时间 isEnd：是否停止滚动
typedef void (^valueChangeBlock)(NSString *timeStr ,BOOL isEnd);

@interface XMChiZi : UIView{
    NSMutableArray *_times;
}
/** 
 存放时间截字符串,重置times即可重置显示UI的时间截
 eg:2015-09-08 12:30:20 -- 2015-09-08 14:20:30
 */
@property (nonatomic,strong) NSMutableArray *times;
/// 依据时间定位
- (void)setTimePosition:(NSString *)timeStr;

/// 添加时间截，添加到times后面
- (void)addTimeSection:(NSString *)timeStr;

/// 滚动变化回调block
- (void)timeChanged:(valueChangeBlock)block;
@end
