//
//  XDSStartupManager.m
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSStartupManager.h"
#import "XDSSettingsManager.h"
#import "XDSRootViewController.h"
#import "XDSPlaceholdSplashManager.h"
#import "XDSTaskQueue.h"

NSString * const XDSEnterMainViewFinishedNotification = @"XDSEnterMainViewFinishedNotification";

@implementation XDSStartupManager
+ (instancetype)sharedManager
{
    static XDSStartupManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public methods

- (void)startupWithLaunchingOptions:(NSDictionary *)launchOptions
{
    //Global settings
    [[XDSSettingsManager sharedManager] setGlobalSettings];

    //UI style
    [[XDSSettingsManager sharedManager] setUIStyle];

    //
    [[XDSSettingsManager sharedManager] setupAfterLaunch];

    self.launchOptions = launchOptions;

//    [self addReachabilityForInternetNotification];
//
//    [self removeApplicationNotifications];
//    [self addApplicationNotifications];

//    //init root view controller
    XDSRootViewController *rootViewController = [XDSRootViewController sharedRootViewController];
    [UIApplication sharedApplication].delegate.window.rootViewController = rootViewController;
    
    XDSPlaceholdSplashViewController *customPlaceholdSplashVC = [[XDSSettingsManager sharedManager] customPlaceholdSplashViewController];
    if (customPlaceholdSplashVC) {
        [[XDSPlaceholdSplashManager sharedManager] showPlaceholderSplashViewWithViewController:customPlaceholdSplashVC];
    }else {
        [[XDSPlaceholdSplashManager sharedManager] showPlaceholderSplashView];
    }
    [self scheduleLaunchTaskQueue];
}

- (void)enterMainViewWithLaunchingOptions:(NSDictionary *)launchOptions {
    
    if (!self.launchTaskQueueFinished) {
        [[XDSSettingsManager sharedManager] setOnlyOnceWhenLaunchTaskQueueFinished];
        [self initMainViewLaunchingOptions:launchOptions];
        [[XDSPlaceholdSplashManager sharedManager] removePlaceholderSplashView];
        
        self.launchTaskQueueFinished = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:XDSEnterMainViewFinishedNotification object:nil];
    }
    
    
//    //handle url deeplink
//    if ([BXDeepLinkManager sharedManager].urlDeepLinkOpenURL) {
//        [[BXDeepLinkManager sharedManager] handleURLDeepLinkWithOpenURL:[BXDeepLinkManager sharedManager].urlDeepLinkOpenURL];
//        [BXDeepLinkManager sharedManager].urlDeepLinkOpenURL = nil;
//    }
//
//    //handle apns deeplink
//    if ([BXDeepLinkManager sharedManager].apnsDeepLinkInfo) {
//        [[BXDeepLinkManager sharedManager] handleAPNSWithDictionary:[BXDeepLinkManager sharedManager].apnsDeepLinkInfo
//                                                    needShowMessage:[BXDeepLinkManager sharedManager].apnsDeepLinkNeedShowMessage];
//        [BXDeepLinkManager sharedManager].apnsDeepLinkInfo = nil;
//        [BXDeepLinkManager sharedManager].apnsDeepLinkNeedShowMessage = NO;
//    }
    
}


- (void)initMainViewLaunchingOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s", __FUNCTION__);
    
    //demo
//    BSNLTabBarViewController *tabbar = [[BSNLTabBarViewController alloc]init];
//    [XDSRootViewController sharedRootViewController].mainViewController = tabbar;
}

- (void)scheduleLaunchTaskQueue {
    self.launchTaskQueue = [XDSTaskQueue taskQueue];
    
    //Demo
    XDSTask *fetchConfigTask = [XDSTask task];
    fetchConfigTask.taskId = @"fetchConfigTask";
    fetchConfigTask.taskContentBlock = ^(XDSTask *task) {
        [task taskHasFinished];
    };
    
    XDSTask *updateLocalizableTask = [XDSTask task];
    updateLocalizableTask.taskId = @"updateLocalizableTask";
    updateLocalizableTask.taskContentBlock = ^(XDSTask * task) {
        [task taskHasFinished];
    };

    
    [_launchTaskQueue addTask:fetchConfigTask];
    [_launchTaskQueue addTask:updateLocalizableTask];

    [_launchTaskQueue goWithFinishedBlock:^(XDSTaskQueue *taskQueue) {
        //enter main page
        [self enterMainViewWithLaunchingOptions:nil];
    }];
    
}

@end

