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
#import "GDTNativeAd.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"

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
NSString *const kGDTMobSDKAppId = @"1107811445";
NSString *const kGDTMobSDKSplashAdId = @"6080544112424254";//开屏广告id
NSString *const kGDTMobSDKBannerAdId = @"6070346162629225";//banner广告id
NSString *const kGDTMobSDKNativeAdId = @"8020945710303246";//原生广告id
NSString *const kGDTMobSDKNativeExpressAdId = @"4080444629286916";//原生模板广告id
NSString *const kGDTMobSDKInterstitialAdId = @"3010544152029233";//插屏广告id


//com.onlinecredit.laomoneyUAT
//NSString *const kGDTMobSDKAppId = @"1107811445";
//NSString *const kGDTMobSDKSplashAdId = @"6080544112424254";
//NSString *const kGDTMobSDKBannerAdId = @"6070346162629225";
//NSString *const kGDTMobSDKNativeAdId = @"2030749182423129";//原生广告id
//NSString *const kGDTMobSDKInterstitialAdId = @"3010544152029233";//插屏广告id

@interface XDSAdManager ()
<GDTSplashAdDelegate,
GDTNativeAdDelegate,
GDTNativeExpressAdDelegete,
GDTMobInterstitialDelegate>

//开屏广告
@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) BOOL showAdWhenEnterForground;

//banner广告
@property (nonatomic, strong) GDTMobBannerView *bannerView;

//原生广告
@property (nonatomic, strong) GDTNativeAd *nativeAd;
@property (nonatomic, strong) UIView *nativeAdView;
@property (nonatomic, copy) NSArray *nativeAdArray;
@property (nonatomic, strong) UIView *nativeAdContainer;
@property (nonatomic, strong) GDTNativeAdData *currentAdData;


//原生模板广告
@property (nonatomic, strong) NSArray *expressAdViews;
@property (nonatomic, weak) UIView *nativeExpressAdContainer;
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;

//插屏广告
@property (nonatomic, strong) GDTMobInterstitial *interstitial;

@end

@implementation XDSAdManager

+ (instancetype)sharedManager {
    static XDSAdManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
//        [sharedInstance addNotificationsObservers];
    });
    return sharedInstance;
}
- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIApplicationWillEnterForegroundNotification
//                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kXDSEnterMainViewFinishedNotification
                                                  object:nil];
}

- (void)addNotificationsObservers {
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIApplicationWillEnterForegroundNotification
//                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleAppDidBecomeActiveNotification)
//                                                 name:UIApplicationWillEnterForegroundNotification
//                                               object:nil];
//
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kXDSEnterMainViewFinishedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSplashAd)
                                                 name:kXDSEnterMainViewFinishedNotification
                                               object:nil];
}

- (BOOL)isAdAvailible {
    return [IHPConfigManager shareManager].adInfo.enable;
}
//TODO: 开屏广告
- (void)showSplashAd {
    if (self.isAdAvailible == NO) {
        return;
    }
    if ([IHPConfigManager shareManager].launch_pop != nil) {
        return;
    }
    self.splashAd = [[GDTSplashAd alloc] initWithAppId:kGDTMobSDKAppId placementId:kGDTMobSDKSplashAdId];
    self.splashAd.delegate = self;
    self.splashAd.fetchDelay = 5;
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


//TODO: banner广告
- (void)loadBannerAdFromViewController:(UIViewController *)fromViewController{
    if (self.isAdAvailible == NO) {
        return;
    }
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
        _bannerView.interval = 30;//刷新间隔
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


//TODO: 原生广告
- (void)loadNativeAdInView:(UIView *)inView {
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    self.currentAdData = nil;
    self.nativeAdContainer = inView;
    self.nativeAd = nil;
    /*
    * 本原生广告位ID在联盟系统中创建时勾选的详情图尺寸为1280*720，开发者可以根据自己应用的需要
    * 创建对应的尺寸规格ID
    *
    * 这里详情图以800*1200为例
    */
    self.nativeAd = [[GDTNativeAd alloc] initWithAppId:kGDTMobSDKAppId placementId:kGDTMobSDKNativeAdId];
    self.nativeAd.controller = [UIViewController xds_visiableViewController];
    self.nativeAd.delegate = self;
    /*
     * 拉取广告,传入参数为拉取个数。
     * 发起拉取广告请求,在获得广告数据后回调delegate
     */
    [self.nativeAd loadAd:1]; //这里以一次拉取一条原生广告为例
}

// GDTNativeAdDelegate
-(void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    NSLog(@"%s",__FUNCTION__);
    /*广告数据拉取成功，存储并展示*/
    self.nativeAdArray = nativeAdDataArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableString *result = [NSMutableString string];
        [result appendString:@"原生广告返回数据:\n"];
        for (GDTNativeAdData *data in nativeAdDataArray) {
            NSData *d = [[data.properties description] dataUsingEncoding:NSUTF8StringEncoding];
            NSString *decodevalue = [[NSString alloc] initWithData:d encoding:NSNonLossyASCIIStringEncoding];;
            [result appendFormat:@"%@",decodevalue];
            [result appendFormat:@"\nisAppAd:%@",data.isAppAd ? @"YES":@"NO"];
            [result appendFormat:@"\nisThreeImgsAd:%@",data.isThreeImgsAd ? @"YES":@"NO"];
            [result appendString:@"\n------------------------"];
        }
        
        [self showNativeAdInView:self.nativeAdContainer];
    });
}

- (void)showNativeAdInView:(UIView *)InView {
    if (self.nativeAdArray.count > 0) {
        /*选择展示广告*/
        self.currentAdData = self.nativeAdArray[0];
        
        /*广告详情图*/
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(2, 70, 316, 176)];
        [self.nativeAdView addSubview:imgV];
        NSURL *imageURL = [NSURL URLWithString:[self.currentAdData.properties objectForKey:GDTNativeAdDataKeyImgUrl]];
        [imgV sd_setImageWithURL:imageURL];
        
        /*广告Icon*/
        UIImageView *iconV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        [self.nativeAdView addSubview:iconV];
        NSURL *iconURL = [NSURL URLWithString:[self.currentAdData.properties objectForKey:GDTNativeAdDataKeyIconUrl]];
        [iconV sd_setImageWithURL:iconURL];
        
        /*广告标题*/
        UILabel *txt = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 220, 35)];
        txt.text = [self.currentAdData.properties objectForKey:GDTNativeAdDataKeyTitle];
        [self.nativeAdView addSubview:txt];
        
        /*广告描述*/
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 220, 20)];
        desc.text = [self.currentAdData.properties objectForKey:GDTNativeAdDataKeyDesc];
        [self.nativeAdView addSubview:desc];
        
        CGRect adviewFrame = self.nativeAdView.frame;
        adviewFrame.origin.x = [[UIScreen mainScreen] bounds].size.width + adviewFrame.origin.x;
        self.nativeAdView.frame = adviewFrame;
        [InView addSubview:self.nativeAdView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        [self.nativeAdView addGestureRecognizer:tap];
        
            self.nativeAdView.center = CGPointMake(CGRectGetMidX(InView.bounds), CGRectGetMidY(InView.bounds));
        
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。
         */
        [self.nativeAd attachAd:self.currentAdData toView:self.nativeAdView];
    }
}
- (void)viewTapped:(UITapGestureRecognizer *)gr {
    /*点击发生，调用点击接口*/
    [self.nativeAd clickAd:self.currentAdData];
}

-(void)nativeAdFailToLoad:(NSError *)error{
    NSLog(@"%s = %@", __FUNCTION__, error);
    self.currentAdData = nil;
}
- (void)nativeAdWillPresentScreen{}
- (void)nativeAdApplicationWillEnterBackground{}
- (void)nativeAdClosed{}

//TODO: 原生模板广告
- (void)loadNativeExpressAdInView:(UIView *)inView adSize:(CGSize)adSize{
    self.nativeExpressAdContainer = inView;
    [inView cw_removeAllSubviews];
    self.expressAdViews = nil;
    self.nativeExpressAd = nil;
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:kGDTMobSDKAppId placementId:kGDTMobSDKNativeExpressAdId adSize:adSize];
    self.nativeExpressAd.delegate = self;
    // 配置视频播放属性
    self.nativeExpressAd.videoAutoPlayOnWWAN = NO;
    self.nativeExpressAd.videoMuted = NO;
    [self.nativeExpressAd loadAd:1];
}
#pragma mark - GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    self.expressAdViews = [NSMutableArray arrayWithArray:views];
    if (self.expressAdViews.count) {
        [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
            expressView.controller = [UIViewController xds_visiableViewController];
            [expressView render];
        }];
    }
    
    if (self.expressAdViews.count > 0) {
        UIView *expressAdView = self.expressAdViews.firstObject;
        expressAdView.center = CGPointMake(CGRectGetMidX(self.nativeExpressAdContainer.bounds), CGRectGetMidY(self.nativeExpressAdContainer.bounds));
        [self.nativeExpressAdContainer addSubview:expressAdView];
    }
}
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView{}
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error{
    NSLog(@"Express Ad Load Fail : %@",error);
}
- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView{}
- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView{}
- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView{}



//TODO: 插屏广告
- (void)showInterstitialAD{
    if (self.isAdAvailible == NO) {
        return;
    }
    if ([IHPConfigManager shareManager].home_pop != nil) {
        return;
    }
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
- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error{
    NSLog(@"error = %@", error);
}
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




- (UIView *)nativeAdView {
    if (!_nativeAdView) {
        _nativeAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
        _nativeAdView.layer.borderWidth = 1;
        _nativeAdView.backgroundColor = [UIColor whiteColor];
    }
    return _nativeAdView;
}
@end
