//
//  XDS_CustomMjRefreshHeader.m
//  iHappy
//
//  Created by Hmily on 2018/8/9.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDS_CustomMjRefreshHeader.h"

@interface XDS_CustomMjRefreshHeader()

@property (nonatomic, weak) UILabel *freshTitleLab;
@property (nonatomic, weak) UIView *line;
@property (nonatomic, weak) UIImageView *freshImgv;
@property (nonatomic, weak) UIActivityIndicatorView *loading;

@end

@implementation XDS_CustomMjRefreshHeader

- (void)prepare{
    [super prepare];
    
    UIView *line = [[UIView alloc]init];
    [self addSubview:line];
    self.line = line;
    
    
    UILabel *freshTitleLab = [[UILabel alloc]init];
    freshTitleLab.font = [UIFont systemFontOfSize:12];
    freshTitleLab.textColor = [UIColor darkTextColor];
    freshTitleLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:freshTitleLab];
    self.freshTitleLab = freshTitleLab;
    
    UIImageView *freshImgv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"down.png"]];
    [self addSubview:freshImgv];
    self.freshImgv = freshImgv;
    
    // loading
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:loading];
    self.loading = loading;
}

- (void)placeSubviews{
    [super placeSubviews];

    self.line.frame = CGRectMake(self.mj_w * 0.5, 10 - DEVIECE_SCREEN_HEIGHT , 1, DEVIECE_SCREEN_HEIGHT);
    [self drawLineOfDashByCAShapeLayer:self.line lineLength:1 lineSpacing:2 lineColor:[UIColor colorWithRed:237.f/255 green:169.f/255 blue:181.f/255 alpha:1]];
    
    self.freshImgv.frame = CGRectMake(0, 0, 16, 16);
    self.freshImgv.center = CGPointMake(self.mj_w * 0.5, 20);
    
    self.freshTitleLab.frame = CGRectMake(0, 0, 100, 16);
    self.freshTitleLab.center = CGPointMake(self.mj_w * 0.5, 40);
    
    self.loading.frame = CGRectMake(0, 0, 16, 16);
    self.loading.center = CGPointMake(self.mj_w * 0.5, self.freshImgv.center.y);
    
}

- (void)setHideLineImgBool:(BOOL)hideLineImgBool{
    _hideLineImgBool = hideLineImgBool;
    self.line.hidden = YES;
}

- (void)setTitleColor:(UIColor *)titleColor{
    _titleColor = titleColor;
    self.freshTitleLab.textColor = _titleColor;
}


#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{
    [super scrollViewContentSizeDidChange:change];
}
#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    switch (state) {
        case MJRefreshStateIdle:
            [self.loading stopAnimating];
            self.freshImgv.hidden = NO;
            self.freshImgv.transform = CGAffineTransformMakeRotation(M_PI_2*2);//CGAffineTransformRotate(self.freshImgv.transform, M_PI_2)
            self.freshTitleLab.text = @"拉下可以刷新";
            break;
        case MJRefreshStatePulling:
            [self.loading stopAnimating];
            self.freshImgv.hidden = NO;
            self.freshImgv.transform = CGAffineTransformMakeRotation(0);
            self.freshTitleLab.text = @"松开立即刷新";
            break;
        case MJRefreshStateRefreshing:
            [self.loading startAnimating];
            self.freshImgv.hidden = YES;
            self.freshTitleLab.text = @"正在刷新数据中...";
            break;
        default:
            break;
    }
}
#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    
}




/**
 *  通过 CAShapeLayer 方式绘制虚线
 *
 *  param lineView:       需要绘制成虚线的view
 *  param lineLength:     虚线的宽度
 *  param lineSpacing:    虚线的间距
 *  param lineColor:      虚线的颜色
 **/
- (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame)/2)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end
