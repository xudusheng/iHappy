//
//  BaiduAdManager.m
//  iHappy
//
//  Created by Hmily on 2018/11/22.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "BaiduAdManager.h"
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>
#import <BaiduMobAdSDK/BaiduMobAdPreroll.h>

NSString *const kBaiduMobSDKAppId = @"e0caf3b2";
NSString *const kBaiduMobSDKSplashAdId = @"5968641";//开屏广告id
NSString *const kBaiduMobSDKNativeAdId = @"5968637";//视频贴片广告id
//NSString *const kBaiduMobSDKBannerAdId = @"5968061";//banner广告id
NSString *const kBaiduMobSDKInterstitialAdId = @"5968638";//插屏广告id


//测试
//NSString *const kBaiduMobSDKAppId = @"ccb60059";
//NSString *const kBaiduMobSDKSplashAdId = @"5968641";//开屏广告id
//NSString *const kBaiduMobSDKNativeAdId = @"2058633";//视频贴片广告id
////NSString *const kBaiduMobSDKBannerAdId = @"5968061";//banner广告id
//NSString *const kBaiduMobSDKInterstitialAdId = @"5968638";//插屏广告id

@interface BaiduAdManager ()<BaiduMobAdViewDelegate, BaiduMobAdPrerollDelegate>

@property(nonatomic, strong) BaiduMobAdView* bannerAdView;//banner广告
@property (nonatomic, retain) BaiduMobAdPreroll *prerollAd;//视频贴片

@end


@implementation BaiduAdManager

+ (instancetype)sharedManager {
    static BaiduAdManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
        [sharedInstance addNotificationsObservers];
        
    });
    return sharedInstance;
}
- (void)addNotificationsObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppDidBecomeActiveNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kXDSEnterMainViewFinishedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSplashAd)
                                                 name:kXDSEnterMainViewFinishedNotification
                                               object:nil];
}

//TODO: banner广告
- (void)startAdViewInView:(UIView *)inView adUnitTag:(NSString *)adUnitTag {
    //lp颜色配置
    [BaiduMobAdSetting setLpStyle:BaiduMobAdLpStyleDefault];
    
    [self.bannerAdView removeFromSuperview];
    self.bannerAdView.delegate = nil;
    self.bannerAdView = nil;
    
    //使用嵌入广告的方法实例。
    self.bannerAdView = [[BaiduMobAdView alloc] init];
    self.bannerAdView.AdUnitTag = adUnitTag;
    self.bannerAdView.AdType = BaiduMobAdViewTypeBanner;

    self.bannerAdView.frame = inView.bounds;
    [inView addSubview:self.bannerAdView];

    self.bannerAdView.delegate = self;
    [self.bannerAdView start];
}

//视频贴片
- (void)loadPrerollAdInView:(UIView *)InView {
    self.prerollAd.delegate = nil;
    self.prerollAd = nil;
    
    self.prerollAd = [[BaiduMobAdPreroll alloc]init];
    self.prerollAd.publisherId = kBaiduMobSDKAppId;
    self.prerollAd.adId = kBaiduMobSDKNativeAdId;//需要为视频贴片广告位
    self.prerollAd.renderBaseView = InView;
    self.prerollAd.delegate = self;
    // 是否有倒计时和点击描述按钮
    self.prerollAd.supportActImage = NO;
    //    self.prerollAd.supportTimeLabel = NO;
    [self.prerollAd request];
}
//开屏广告
- (void)showSplashAd {}

- (void)handleAppDidBecomeActiveNotification {}

#pragma mark - BaiduMobAdViewDelegate
- (NSString *)publisherId {
    //@"your_own_app_id";注意，iOS和android的app请使用不同的app ID
    return  kBaiduMobSDKAppId;
}
-(BOOL)enableLocation {
    //启用location会有一次alert提示
    return YES;
}

#pragma mark - BaiduMobAdPrerollDelegate
- (void)didAdFailed:(BaiduMobAdPreroll *)preroll withError:(BaiduMobFailReason)reason {
    [self.prerollAd.renderBaseView removeFromSuperview];
    self.prerollAd.delegate = nil;
    self.prerollAd = nil;
}

//点击关闭的时候移除广告
- (void)didAdClose {
    NSLog(@"delegate: didAdClose");
}

- (void)dealloc {
    [self.bannerAdView removeFromSuperview];
    self.bannerAdView.delegate = nil;
    self.bannerAdView = nil;
    
    self.prerollAd.delegate = nil;
    self.prerollAd = nil;
}
@end
