//
//  IHYAdManager.m
//  iHappy
//
//  Created by Hmily on 2018/8/24.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSAdManager.h"
#import "GDTSplashAd.h"

NSString *const kGDTMobSDKAppId = @"1105344611";
NSString *const kGDTMobSDKSplashAdId = @"9040714184494018";
@interface XDSAdManager () <GDTSplashAdDelegate>

@property (nonatomic, strong) GDTSplashAd *splashAd;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) BOOL showAdWhenEnterForground;


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

@end
