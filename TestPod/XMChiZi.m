//
//  XMChiZi.m
//  podAFNetwork
//
//  Created by mifit on 15/9/9.
//  Copyright (c) 2015年 mifit. All rights reserved.
//


#import "XMChiZi.h"

static const CGFloat spaceInterval = 10.0f;

@interface XMChiZi()<UIScrollViewDelegate>
@property (nonatomic,assign) BOOL isInit;
@property (nonatomic,copy) valueChangeBlock block;

/// 背景色
@property (nonatomic,strong) UIColor *colorBG;
/// 视频截背景色
@property (nonatomic,strong) UIColor *colorRuleBG;
/// 视频截颜色
@property (nonatomic,strong) UIColor *colorRule;
/// 中间指标颜色
@property (nonatomic,strong) UIColor *colorIndicate;
/// 刻度颜色
@property (nonatomic,strong) UIColor *colorScale;
/// 显示时间背景颜色
@property (nonatomic,strong) UIColor *colorShowBG;
/// 显示时间颜色
@property (nonatomic,strong) UIColor *colorShow;


/// 滚动scrollview
@property (nonatomic,strong) UIScrollView *scrollView;
/// 显示的文本
@property (nonatomic,strong) UILabel *showText;
/// 进度背景色高度
@property (nonatomic,assign) CGFloat heigth;
///刻度开始位置
@property (nonatomic,assign) CGFloat beginX;

@end


@implementation XMChiZi
#pragma mark - begin
//frame不是实际的frame

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.isInit) {
        [self initData];
        [self initView];
        [self reflesh];
    }
    //NSLog(@"*---");
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initView];
    }
    return self;
}

- (void)initData{
    _colorBG = [UIColor yellowColor];
    _colorRule = [UIColor blueColor];
    _colorRuleBG = [UIColor lightGrayColor];
    _colorIndicate = [UIColor purpleColor];
    _colorScale = [UIColor redColor];
    _colorShowBG = [UIColor greenColor];
    _colorShow = [UIColor redColor];
}

- (void)initView{
    self.backgroundColor = _colorBG;
    CGRect rect = self.frame;
    rect.origin = CGPointMake(0, 0);
    CGFloat ViewWidth = rect.size.width;
    CGFloat ViewHeigth = rect.size.height;
    _heigth = ViewHeigth / 3 * 2;
    _beginX = ViewWidth / 2;
    
    //尺子背景色
    UIView *ruleBG = [[UIView alloc]initWithFrame:CGRectMake(0, 25, ViewWidth, _heigth)];
    ruleBG.backgroundColor = _colorRuleBG;
    [self addSubview:ruleBG];
    
    //scroll view
    UIScrollView *sc = [[UIScrollView alloc]initWithFrame:rect];
    //sc.backgroundColor = [UIColor yellowColor];
    sc.showsHorizontalScrollIndicator = NO;
    [self addSubview:sc];
    _scrollView = sc;
    _scrollView.delegate = self;
    
    /// 初始化尺子刻度和值
    [self initRule];
    
    //中间灰线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(ViewWidth / 2, 20, 1, _heigth + 10)];
    lineView.backgroundColor = _colorIndicate;
    [self addSubview:lineView];
    
    //绿色背景
    CGRect roundRect = CGRectMake(ViewWidth / 2 + 10, ViewHeigth - 40, 70, 40 );
    UIView *roundView = [[UIView alloc]initWithFrame:roundRect];
    roundView.backgroundColor = _colorShowBG;
    roundView.layer.masksToBounds = YES;
    roundView.layer.cornerRadius = 5;
    [self addSubview:roundView];
    
    //显示时间
    UILabel *label = [[UILabel alloc]initWithFrame:roundRect];
    label.text = @"00:00:00";
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:_colorShow];
    [self addSubview:label];
    _showText = label;
    _isInit = YES;
}

/// 初始化刻度尺
- (void)initRule{
    CGFloat beginX = _beginX;
    CGFloat beginY = 10;
    CGFloat width = 14;
    CGFloat heigth = 10;
    for (NSInteger index = 0; index < 145; index++) {
        if (index % 6 == 0) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(beginX + index * spaceInterval - width / 2 + 1, 0, width, heigth)];
            label.text = [NSString stringWithFormat:@"%ld",(long)index / 6];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            [_scrollView addSubview:label];
        } else {
            UIView *tView = [[UIView alloc]initWithFrame:CGRectMake(beginX + index * spaceInterval, beginY, 1, heigth)];
            tView.backgroundColor = _colorScale;
            [_scrollView addSubview:tView];
        }
    }
    _scrollView.contentSize = CGSizeMake(beginX * 2 + 144 * spaceInterval, 0);
}

#pragma mark - method public
- (void)setTimePosition:(NSString *)timeStr{
    CGFloat xPosition = [self xFromTime:timeStr];
    xPosition -= self.frame.size.width / 2;
    _scrollView.contentOffset = CGPointMake(xPosition, 0);
    _showText.text = [self dateStringFromSecond:[self secondsFromTime:timeStr]];
}

- (void)addTimeSection:(NSString *)timeStr{
    CGRect rect = [self rectFromTime:timeStr];
    UIView *showView = [[UIView alloc]initWithFrame:rect];
    showView.tag = _times.count + 1;
    showView.backgroundColor = [UIColor blueColor];
    [_scrollView addSubview:showView];
    [_times addObject:timeStr];
}

- (void)timeChanged:(valueChangeBlock)block{
    self.block = block;
}

- (void)setTimes:(NSMutableArray *)times{
    if (!_times) {
        _times = [NSMutableArray array];
    }
    for (NSInteger index = 0; index < _times.count; index++) {
        UIView *temView = [_scrollView viewWithTag:index + 1];
        [temView removeFromSuperview];
    }
    NSInteger index = 1;
    for (NSString *strTime in times) {
        CGRect rect = [self rectFromTime:strTime];
        UIView *showView = [[UIView alloc]initWithFrame:rect];
        showView.tag = index;
        showView.backgroundColor = _colorRule;
        [_scrollView addSubview:showView];
        index++;
    }
    _times = times;
}

#pragma mark - method privte
- (void)reflesh{
    self.times = _times;
}
//时间格式不同，自己改
/// 传入字符串格式2015-09-08 12:30:20 ~ 2015-09-08 14:20:30
- (CGRect)rectFromTime:(NSString *)str{
    NSArray *temArr = [str componentsSeparatedByString:@"~"];
    CGFloat beginX = [self xFromTime:[temArr objectAtIndex:0]];
    CGFloat endX = [self xFromTime:[[temArr objectAtIndex:1] substringFromIndex:1]];
    CGRect re = CGRectMake(beginX , 25, endX - beginX, _heigth);
    return re;
}

/// 传入字符串格式:2015-09-08 12:30:20
//1s的宽度：间隔10，代表10分钟，所以1s的宽度是1/60
- (CGFloat)xFromTime:(NSString *)str{
    NSInteger total = [self secondsFromTime:str];
    return total / 60 + _beginX;
}

/// scrollview偏移量对应的秒数
- (NSInteger)secondsFromPoint:(CGPoint)point{
    NSInteger total = point.x * 60;
    return total;
}

/// 依据时间，返回总秒数；传入字符串格式:2015-09-08 12:30:20
- (NSInteger)secondsFromTime:(NSString *)timeStr{
    NSArray *temArr = [timeStr componentsSeparatedByString:@" "];
    NSString *t = [temArr objectAtIndex:1];
    NSArray *tArr = [t componentsSeparatedByString:@":"];
    NSString *h = [tArr objectAtIndex:0];
    NSString *m = [tArr objectAtIndex:1];
    NSString *s = [tArr objectAtIndex:2];
    NSInteger total = [h intValue] * 3600 + [m intValue] * 60 + [s intValue];
    return total;
}

/// 依据秒数转为字符串时间格式
- (NSString *)dateStringFromSecond:(NSInteger)second{
    NSInteger h = second / 3600;
    NSInteger m = (second - h * 3600) / 60;
    NSInteger s = second % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)h,(long)m,(long)s];
}

/// 更新显示的时间
- (void)updateShowText:(CGPoint)point isEnd:(BOOL)isEnd{
    _showText.text = [self dateStringFromSecond:[self secondsFromPoint:point]];
    if (self.block) {
        self.block(_showText.text,isEnd);
    }
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint p = scrollView.contentOffset;
    [self updateShowText:p isEnd:NO];
    //NSLog(@"%f",p.x);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint p = scrollView.contentOffset;
    [self updateShowText:p isEnd:YES];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
@end
