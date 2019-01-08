//
//  XDSSettingsManager.m
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSSettingsManager.h"
#import "XDSConfigItem.h"

#import <UMCommon/UMCommon.h>
#import <BaiduMobAdSDK/BaiduMobAdSetting.h>

#import "IHPPlaceholderSplashViewController.h"

@interface  XDSSettingsManager()

@property (nonatomic,strong) IHPPlaceholderSplashViewController *spashVC;

@end
@implementation XDSSettingsManager
+ (instancetype)sharedManager
{
    static XDSSettingsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}

- (id)init{
    if(self = [super init]){
        
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Launch
- (void)setupAfterLaunch {
    [self addObserverNotification];
}
- (XDSPlaceholdSplashViewController *)customPlaceholdSplashViewController {
    if (self.spashVC == nil) {
        self.spashVC = [[IHPPlaceholderSplashViewController alloc] init];
    }
    return self.spashVC;
}

#pragma mark - UI Style
- (void)setUIStyle{}


#pragma mark  --通知
-(void)addObserverNotification{
    //    //在WebView内点击视频全屏播放,退出后导致状态栏被隐
    //    //监听网页播放器进入和退出全屏的通知
    //    //监听UIWindow显示
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];
    //监听UIWindow隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];
}

-(void)endFullScreen{
    NSLog(@"退出全屏");
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


#pragma mark - Global Settings
- (void)setGlobalSettings {
    
    //友盟统计初始化
    [UMConfigure initWithAppkey:@"5c014f16f1f5560e2d000162" channel:@"App Store"];

    //百度广告联盟设置网络
    [BaiduMobAdSetting sharedInstance].supportHttps = NO;
}
- (void)setOnlyOnceWhenLaunchTaskQueueFinished {}

@end
