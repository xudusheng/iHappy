//
//  IHYAdManager.h
//  iHappy
//
//  Created by Hmily on 2018/8/24.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSBaseManager.h"
#import "GDTMobBannerView.h"

#define XDS_NATIVE_EXPRESS_AD_RETIO_HEIGHT_WIDTH (1200.f/800.f)
@interface XDSAdManager : XDSBaseManager

+ (instancetype)sharedManager;

- (BOOL)isAdAvailible;

//展示开屏广告
- (void)showSplashAd;


//banner广告
- (void)loadBannerAdFromViewController:(UIViewController *)fromViewController;
- (GDTMobBannerView *)bannerView;
//移除banner广告
- (void)removeBannerAd;



//原生广告
- (void)loadNativeAdInView:(UIView *)inView;

//TODO: 原生模板广告
- (void)loadNativeExpressAdInView:(UIView *)inView adSize:(CGSize)adSize;

//插屏广告
- (void)showInterstitialAD;
@end
