//
//  XDSPlayerBannerAdCell.m
//  iHappy
//

//  Created by Hmily on 2018/9/8.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSPlayerBannerAdCell.h"


@implementation XDSPlayerBannerAdCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        UIView *bannerView = (UIView *)[[XDSAdManager sharedManager] bannerView];
//        [self.contentView addSubview:bannerView];

        [[BaiduAdManager sharedManager] startAdViewInView:self.contentView adUnitTag:kBannerSize_20_3];
    }
    return self;
}

- (void)layoutSubviews {
//    [[XDSAdManager sharedManager] bannerView].frame = self.contentView.bounds;
    
//    [[BaiduAdManager sharedManager] startAdViewInView:self.contentView adUnitTag:kBannerSize_20_3];

}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    return [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
}


- (void)dealloc {
//    [[XDSAdManager sharedManager] removeBannerAd];
}


@end
