//
//  XDSImageItemAdCell.m
//  iHappy
//
//  Created by Hmily on 2018/11/30.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "XDSImageItemAdCell.h"

@implementation XDSImageItemAdCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0, 1);//偏移距离
        self.contentView.layer.shadowOpacity = 0.5;//不透明度
        self.contentView.layer.shadowRadius = 3.f;//半径
    }
    return self;
}

- (void)p_loadCell {
    if (self.contentView.subviews.count > 0) {
        return;
    }
    [self updateAd];
}

- (void)updateAd {
    if (self.contentView.subviews.count == 0) {
        CGFloat width = CGRectGetWidth(self.contentView.bounds) - self.adMargin*2;
        CGFloat height = width*XDS_NATIVE_EXPRESS_AD_RETIO_HEIGHT_WIDTH;
        [[XDSAdManager sharedManager] loadNativeExpressAdInView:self.contentView adSize:CGSizeMake(width, height)];
        NSInteger refresh_duration = [IHPConfigManager shareManager].adInfo.refresh_duration;
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(updateAd) withObject:nil afterDelay:MAX(refresh_duration, 10)];
    } else {
        UICollectionView *collec = (UICollectionView *)self.superview;
        NSArray *visibleCell = collec.visibleCells;
        NSInteger refresh_duration = [IHPConfigManager shareManager].adInfo.refresh_duration;
        if ([visibleCell containsObject:self]) {
            [self.contentView removeAllSubViews];
            CGFloat width = CGRectGetWidth(self.contentView.bounds) - self.adMargin*2;
            CGFloat height = width*XDS_NATIVE_EXPRESS_AD_RETIO_HEIGHT_WIDTH;
            [[XDSAdManager sharedManager] loadNativeExpressAdInView:self.contentView adSize:CGSizeMake(width, height)];
            [[self class] cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(updateAd) withObject:nil afterDelay:MAX(refresh_duration, 10)];
        }else {
            NSLog(@"滚出去了==============");
        }
    }
}


@end
