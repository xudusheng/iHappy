//
//  IHYAdManager.h
//  iHappy
//
//  Created by Hmily on 2018/8/24.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSBaseManager.h"
#import "GDTMobBannerView.h"
@interface XDSAdManager : XDSBaseManager

+ (instancetype)sharedManager;

//展示开屏广告
- (void)showSplashAd;


//banner广告
- (void)loadBannerAdFromViewController:(UIViewController *)fromViewController;
- (GDTMobBannerView *)bannerView;
//移除banner广告
- (void)removeBannerAd;



//原生广告
- (void)loadNativeAdInSize:(CGSize)inSize;


//插屏广告
- (void)showInterstitialAD;
@end
