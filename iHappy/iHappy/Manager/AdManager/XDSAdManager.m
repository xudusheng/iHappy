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

NSString *const kGDTMobSDKAppId = @"1105344611";
NSString *const kGDTMobSDKSplashAdId = @"9040714184494018";
NSString *const kGDTMobSDKBannerAdId = @"4090812164690039";
@interface XDSAdManager () <GDTSplashAdDelegate>

//开屏广告
@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) BOOL showAdWhenEnterForground;

//banner广告
@property (nonatomic, strong) GDTMobBannerView *bannerView;



@end

@implementation XDSAdManager

+ (instancetype)sharedManager {
    static XDSAdManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

//开屏广告
- (void)showSplashAd {

    self.splashAd = [[GDTSplashAd alloc] initWithAppId:kGDTMobSDKAppId placementId:kGDTMobSDKSplashAdId];
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 5;
    UIImage *splashImage = [UIImage imageNamed:@"SplashNormal"];
    if (IS_IPHONEX) {
        splashImage = [UIImage imageNamed:@"SplashX"];
    } else if ([UIScreen mainScreen].bounds.size.height == 480) {
        splashImage = [UIImage imageNamed:@"SplashSmall"];
    }
    self.splashAd.backgroundImage = splashImage;
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height * 0.25)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SplashLogo"]];
    logo.frame = CGRectMake(0, 0, 311, 47);
    logo.center = self.bottomView.center;
    [self.bottomView addSubview:logo];
    
    UIWindow *fK = [[UIApplication sharedApplication] keyWindow];
    [self.splashAd loadAdAndShowInWindow:fK withBottomView:self.bottomView skipView:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAppDidBecomeActiveNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
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
        _bannerView.isGpsOn = NO;//是否添加GPS
//        _bannerView.delegate = self;
    }
    return _bannerView;
}
//移除banner广告
- (void)removeBannerAd {
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
}

@end
