//
//  IHYAdManager.m
//  iHappy
//
//  Created by Hmily on 2018/8/24.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSAdManager.h"
#import "GDTSplashAd.h"
#import "GDTMobBannerView.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "GDTMobInterstitial.h"

#import "AppDelegate.h"
//demo
//NSString *const kGDTMobSDKAppId = @"1105344611";
//NSString *const kGDTMobSDKSplashAdId = @"9040714184494018";
//NSString *const kGDTMobSDKBannerAdId = @"4090812164690039";
//NSString *const kGDTMobSDKNativeAdId = @"5030722621265924";//原生广告id
//NSString *const kGDTMobSDKInterstitialAdId = @"2030814134092814";//插屏广告id

//com.youmi.ihappy
NSString *const kGDTMobSDKAppId = @"1106160564";
NSString *const kGDTMobSDKSplashAdId = @"8060437838106665";//开屏广告id
NSString *const kGDTMobSDKBannerAdId = @"5040221235552630";//banner广告id
NSString *const kGDTMobSDKNativeAdId = @"3020432808501644";//原生广告id
NSString *const kGDTMobSDKInterstitialAdId = @"5010535848806666";//插屏广告id


//com.onlinecredit.laomoneyUAT
//NSString *const kGDTMobSDKAppId = @"1107811445";
//NSString *const kGDTMobSDKSplashAdId = @"6080544112424254";
//NSString *const kGDTMobSDKBannerAdId = @"6070346162629225";
//NSString *const kGDTMobSDKNativeAdId = @"2030749182423129";//原生广告id
//NSString *const kGDTMobSDKInterstitialAdId = @"3010544152029233";//插屏广告id

@interface XDSAdManager () <GDTSplashAdDelegate, GDTNativeExpressAdDelegete, GDTMobInterstitialDelegate>

//开屏广告
@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) BOOL showAdWhenEnterForground;

//banner广告
@property (nonatomic, strong) GDTMobBannerView *bannerView;

//原生广告
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic, strong) NSMutableArray *expressAdViews;

//插屏广告
@property (nonatomic, strong) GDTMobInterstitial *interstitial;

@end

@implementation XDSAdManager

+ (instancetype)sharedManager {
    static XDSAdManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
        [sharedInstance addNotificationsObservers];
        
    });
    return sharedInstance;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kXDSEnterMainViewFinishedNotification
                                                  object:nil];
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

//开屏广告
- (void)showSplashAd {
    self.splashAd = [[GDTSplashAd alloc] initWithAppId:kGDTMobSDKAppId placementId:kGDTMobSDKSplashAdId];
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 5;
//    if (IS_IPHONEX) {
//        splashImage = [UIImage imageNamed:@"SplashX"];
//    } else if ([UIScreen mainScreen].bounds.size.height == 480) {
//        splashImage = [UIImage imageNamed:@"SplashSmall"];
//    }
    
    NSString *currentImageName = nil;
    
    CGSize viewSize = CGSizeMake(DEVIECE_SCREEN_WIDTH, DEVIECE_SCREEN_HEIGHT);
    NSArray *imageDicts = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    
    NSString* viewOrientation = @"Portrait";
    
    for (NSDictionary * dic in imageDicts) {
        CGSize imageSize = CGSizeFromString(dic[@"UILaunchImageSize"]);
        NSString *orientation = dic[@"UILaunchImageOrientation"];
        if(CGSizeEqualToSize(viewSize, imageSize) && [orientation isEqualToString:viewOrientation]){
            currentImageName = dic[@"UILaunchImageName"];
        }
    }
        
    currentImageName = currentImageName.length?currentImageName:@"logo_launch";
    UIImage *splashImage = [UIImage imageNamed:currentImageName];

    self.splashAd.backgroundImage = splashImage;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 55*3)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    UIImage *logo = [UIImage imageNamed:@"logo_launch"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 375, 55)];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.image = logo;
    logoImageView.center = self.bottomView.center;
    [self.bottomView addSubview:logoImageView];
    
    UIWindow *fK = [UIApplication sharedApplication].keyWindow;
    [self.splashAd loadAdAndShowInWindow:fK withBottomView:self.bottomView skipView:nil];
    
    self.showAdWhenEnterForground = NO;
}


- (void)handleAppDidBecomeActiveNotification {
    if (self.showAdWhenEnterForground) {
        [self showSplashAd];
    }
}

#pragma mark - GDTSplashAdDelegate
- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    self.splashAd = nil;
    self.bottomView = nil;
    //取消本类中的performSelector:方法
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(canShowAd) withObject:nil afterDelay:30];
    if (self.interstitial && self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:[XDSRootViewController sharedRootViewController].mainViewController];
    }
}

- (void)canShowAd {
    self.showAdWhenEnterForground = YES;
}


//banner广告
- (void)loadBannerAdFromViewController:(UIViewController *)fromViewController{
    [[self bannerViewWithCurrentViewController:fromViewController] loadAdAndShow];
}
- (GDTMobBannerView *)bannerView {
    return _bannerView;
}
- (GDTMobBannerView *)bannerViewWithCurrentViewController:(UIViewController *)currentViewController{
    if (!_bannerView) {
//        CGRect rect = {CGPointZero, GDTMOB_AD_SUGGEST_SIZE_320x50};
        CGRect rect = {0, 0, DEVIECE_SCREEN_WIDTH, GDTMOB_AD_SUGGEST_SIZE_320x50.height};
        _bannerView = [[GDTMobBannerView alloc] initWithFrame:rect appId:kGDTMobSDKAppId placementId:kGDTMobSDKBannerAdId];
        _bannerView.currentViewController = currentViewController;
        _bannerView.interval = 20;//刷新间隔
        _bannerView.isAnimationOn = NO;//是否添加动画
        _bannerView.showCloseBtn = NO;//是否添加隐藏按钮
        _bannerView.isGpsOn = YES;//是否添加GPS
//        _bannerView.delegate = self;
    }
    return _bannerView;
}
//移除banner广告
- (void)removeBannerAd {
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
}


//原生广告
- (void)loadNativeAdInSize:(CGSize)inSize{
    [self.expressAdViews removeAllObjects];
    self.expressAdViews = nil;
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:kGDTMobSDKAppId
                                                         placementId:kGDTMobSDKNativeAdId
                                                              adSize:inSize];
    self.nativeExpressAd.delegate = self;
    [self.nativeExpressAd loadAd:3];
}
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = [UIViewController xds_visiableViewController];
            [expressView render];
        }];
    }
}

- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView{}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error{}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView{}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView{
    [self.expressAdViews removeObject:nativeExpressAdView];
}


//插屏广告
- (void)showInterstitialAD{
    self.interstitial = [[GDTMobInterstitial alloc] initWithAppId:kGDTMobSDKAppId placementId:kGDTMobSDKInterstitialAdId];
    self.interstitial.delegate = self;
    [self.interstitial loadAd];
}
// 详解:当接收服务器返回的广告数据成功后调用该函数
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial{
    if (self.splashAd == nil) {
        [self.interstitial presentFromRootViewController:[XDSRootViewController sharedRootViewController].mainViewController];
    }
}
//// 详解:当接收服务器返回的广告数据失败后调用该函数
//- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error{}
//// 详解: 插屏广告即将展示回调该函数
//- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial{}
//// 详解: 插屏广告展示成功回调该函数
//- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial{}
//// 详解: 插屏广告展示结束回调该函数
- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial{
    self.interstitial = nil;
}
//// 详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
//- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial{}
@end
