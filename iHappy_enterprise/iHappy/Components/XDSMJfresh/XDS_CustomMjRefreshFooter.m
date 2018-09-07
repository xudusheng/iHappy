//
//  XDS_CustomMjRefreshFooter.m
//  iHappy
//
//  Created by Hmily on 2018/8/9.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDS_CustomMjRefreshFooter.h"

@interface XDS_CustomMjRefreshFooter ()

@property (nonatomic, strong) UILabel *mTitleLabel;
@property (nonatomic, strong) UIView *leftLine;
@property (nonatomic, strong) UIView *rightLine;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation XDS_CustomMjRefreshFooter
CGFloat const kCustomMJRefreshFooterHeight = 44.f;

- (void)prepare{
    [super prepare];
    
    self.mj_h = kCustomMJRefreshFooterHeight;
    
    self.mTitleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkTextColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        [self addSubview:label];
        label;
    });
    
    
    // loading
//    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self addSubview:loading];
//    self.loadingView = loading;
    
    
    self.leftLine = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:view];
        view;
    });
    self.rightLine = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor lightTextColor];
        [self addSubview:view];
        view;
    });
    
}

- (void)placeSubviews{
    [super placeSubviews];
    
    
    [self.mTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mTitleLabel.mas_centerY);
        make.right.equalTo(self.mTitleLabel.mas_left).offset(-10);
    }];
    
    
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.mas_equalTo(25);
        make.height.mas_equalTo(0.5f);
        make.right.equalTo(self.mTitleLabel.mas_left).offset(-15);
    }];
    
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.mas_equalTo(-25);
        make.left.equalTo(self.mTitleLabel.mas_right).offset(15);
        make.height.mas_equalTo(0.5f);
    }];
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
- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    self.leftLine.hidden = YES;
    self.rightLine.hidden = YES;
    switch (state) {
        case MJRefreshStateIdle:
            [self.loadingView stopAnimating];
            self.mTitleLabel.text = [self isFullContent]?XDSLocalizedString(@"xds.loading.footer.normal", nil):@"";
            break;
        case MJRefreshStatePulling:
            [self.loadingView stopAnimating];
            self.mTitleLabel.text = XDSLocalizedString(@"xds.loading.footer.pulling", nil);
            break;
        case MJRefreshStateRefreshing:
            [self.loadingView startAnimating];
            self.mTitleLabel.text = XDSLocalizedString(@"xds.loading.footer.refreshing", nil);
            break;
        case MJRefreshStateNoMoreData:
            [self.loadingView stopAnimating];
            self.mTitleLabel.text = [self isFullContent]? XDSLocalizedString(@"xds.loading.footer.nomoredata", nil) : @"";
            if ([self isFullContent]) {
//                self.leftLine.hidden = NO;
//                self.rightLine.hidden = NO;
            }
            break;
        default:
            break;
    }
}

- (BOOL)isFullContent {
    UIView *supterView = self.superview;
    if ([supterView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)supterView;
        CGSize contentSize = scrollView.contentSize;
        if (contentSize.height > scrollView.frame.size.height*2) {
            return YES;
        }
    }
    return NO;
    
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent {
    [super setPullingPercent:pullingPercent];
}

@end
