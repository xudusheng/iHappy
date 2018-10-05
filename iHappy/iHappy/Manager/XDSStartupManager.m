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
#import "IHPMenuViewController.h"

#import "IHYMainViewController.h"
#import "XDSMainReaderVC.h"
#import "AppDelegate.h"
NSString * const kXDSEnterMainViewFinishedNotification = @"XDSEnterMainViewFinishedNotification";

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
        [[NSNotificationCenter defaultCenter] postNotificationName:kXDSEnterMainViewFinishedNotification object:nil];
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


- (void)initMainViewLaunchingOptions:(NSDictionary *)launchOptions {
    
    NSArray<IHPMenuModel*> *menus = [IHPConfigManager shareManager].menus;
    
    IHPMenuViewController *leftMenu = [[IHPMenuViewController alloc] init];
    leftMenu.menus = menus;
    
    IHPMenuModel *theMenu = menus.firstObject;
    
    XDSSideMenu *mainmeunVC = [[XDSSideMenu alloc] initWithContentViewController:theMenu.contentViewController
                                                          leftMenuViewController:leftMenu
                                                         rightMenuViewController:nil];
    
    mainmeunVC.contentViewInLandscapeOffsetCenterX = -480;
    mainmeunVC.contentViewShadowColor = [UIColor lightGrayColor];
    mainmeunVC.contentViewShadowOffset = CGSizeMake(0, 0);
    mainmeunVC.contentViewShadowOpacity = 0.6;
    mainmeunVC.contentViewShadowRadius = 12;
    mainmeunVC.contentViewShadowEnabled = NO;
    mainmeunVC.scaleMenuView = NO;
    mainmeunVC.scaleContentView = NO;
    mainmeunVC.parallaxEnabled = NO;
    mainmeunVC.bouncesHorizontally = NO;
    
    mainmeunVC.panGestureEnabled = YES;
    mainmeunVC.panFromEdge = YES;
    mainmeunVC.panMinimumOpenThreshold = 60.0;
    //    mainmeunVC.bouncesHorizontally = NO;    
    mainmeunVC.delegate = leftMenu;
    [XDSRootViewController sharedRootViewController].mainViewController = mainmeunVC;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.leftMenu = leftMenu;
    appDelegate.mainmeunVC = mainmeunVC;
}

NSString *const kXDSFetchConfigTaskID = @"XDSFetchConfigTask";
NSString *const kXDSFetchUnavailibleUrlListTaskID = @"XDSFetchUnavailibleUrlListTaskID";
NSString *const kXDSUpdateLocalizableTaskID = @"XDSUpdateLocalizableTask";

- (void)scheduleLaunchTaskQueue {
    self.launchTaskQueue = [XDSTaskQueue taskQueue];
    
    //Demo
    XDSTask *fetchConfigTask = [XDSTask task];
    fetchConfigTask.taskId = kXDSFetchConfigTaskID;
    fetchConfigTask.taskContentBlock = ^(XDSTask *task) {
        [self fetchConfigData];
    };

    XDSTask *fetchUnavailibleUrlListTask = [XDSTask task];
    fetchUnavailibleUrlListTask.taskId = kXDSFetchUnavailibleUrlListTaskID;
    fetchUnavailibleUrlListTask.taskContentBlock = ^(XDSTask *task) {
        [self fetchUnavailibleUrlList];
    };
    
    XDSTask *updateLocalizableTask = [XDSTask task];
    updateLocalizableTask.taskId = kXDSUpdateLocalizableTaskID;
    updateLocalizableTask.taskContentBlock = ^(XDSTask * task) {
        [task taskHasFinished];
    };

    
    [_launchTaskQueue addTask:fetchConfigTask];
    [_launchTaskQueue addTask:fetchUnavailibleUrlListTask];
    [_launchTaskQueue addTask:updateLocalizableTask];

    [fetchUnavailibleUrlListTask addDependency:fetchConfigTask];
    [updateLocalizableTask addDependency:fetchUnavailibleUrlListTask];
    
    [_launchTaskQueue goWithFinishedBlock:^(XDSTaskQueue *taskQueue) {
        //enter main page
        [self enterMainViewWithLaunchingOptions:nil];
    }];
    
}


- (void)fetchConfigData{
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"json"];
//    NSData *menuData = [NSData dataWithContentsOfFile:path];
//    NSLog(@"%@", [[NSString alloc] initWithData:menuData encoding:NSUTF8StringEncoding]);
//
//    IHPConfigManager *manager = [IHPConfigManager shareManager];
//    [manager configManagerWithJsondData:menuData];
//    [self finishTaskWithTaksID:kXDSFetchConfigTaskID];
//
//    return;
    
    NSString *requesturl = @"http://134.175.54.80/ihappy/menu.json";
    
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:requesturl
                                         hudController:nil
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                   
                                                   IHPConfigManager *manager = [IHPConfigManager shareManager];
                                                   [manager configManagerWithJsondData:htmlData];
                                                   if (manager.forceUpdate.enable) {
                                                       if (manager.forceUpdate.isForce) {
                                                           [XDSUtilities alertViewWithPresentingController:[XDSRootViewController sharedRootViewController]
                                                                                                     title:nil
                                                                                                   message:manager.forceUpdate.updateMessage
                                                                                              buttonTitles:@[@"退出", @"立即更新"]
                                                                                                     block:^(NSInteger index) {
                                                                                                         if (index == 0) {
                                                                                                             exit(0);
                                                                                                         }else{
                                                                                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:manager.forceUpdate.url]];
                                                                                                         }
                                                                                                     }];
                                                       }else{
                                                           [XDSUtilities alertViewWithPresentingController:[XDSRootViewController sharedRootViewController]
                                                                                                     title:nil
                                                                                                   message:manager.forceUpdate.updateMessage
                                                                                              buttonTitles:@[@"稍后再说", @"立即更新"]
                                                                                                     block:^(NSInteger index) {
                                                                                                         if (index == 0) {
                                                                                                         }else{
                                                                                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:manager.forceUpdate.url]];
                                                                                                         }
                                                                                                         [weakSelf finishTaskWithTaksID:kXDSFetchConfigTaskID];
                                                                                                     }];
                                                           
                                                       }
                                                       
                                                   }else{
                                                       [weakSelf finishTaskWithTaksID:kXDSFetchConfigTaskID];
                                                   }
                                                   
                                               } failed:^(NSString *errorDescription) {
                                                   errorDescription = errorDescription?errorDescription:kLoadFailed;
                                                   [XDSUtilities alertViewWithPresentingController:[XDSRootViewController sharedRootViewController]
                                                                                             title:nil
                                                                                           message:errorDescription
                                                                                      buttonTitles:@[@"退出", @"重新连接"]
                                                                                             block:^(NSInteger index) {
                                                                                                 if (index == 0) {
                                                                                                     exit(0);
                                                                                                 }else{
                                                                                                     [weakSelf fetchConfigData];
                                                                                                 }
                                                                                             }];
                                                   
                                               }];
}

- (void)fetchUnavailibleUrlList {
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"unavailible_url" ofType:@"json"];
//    NSData *hiddenModelData = [NSData dataWithContentsOfFile:path];
//    NSLog(@"%@", [[NSString alloc] initWithData:hiddenModelData encoding:NSUTF8StringEncoding]);
//
//    IHPConfigManager *manager = [IHPConfigManager shareManager];
//    [manager configHiddenModelWithJsondData:hiddenModelData];
//    [self finishTaskWithTaksID:kXDSFetchUnavailibleUrlListTaskID];
//
//    return;
    
    NSString *requesturl = @"http://134.175.54.80/ihappy/unavailible_url.json";
    
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:requesturl
                                         hudController:nil
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                   
                                                   IHPConfigManager *manager = [IHPConfigManager shareManager];
                                                   [manager configHiddenModelWithJsondData:htmlData];
                                                   [weakSelf finishTaskWithTaksID:kXDSFetchUnavailibleUrlListTaskID];

                                                   
                                               } failed:^(NSString *errorDescription) {
                                                   errorDescription = errorDescription?errorDescription:kLoadFailed;
                                                   [XDSUtilities alertViewWithPresentingController:[XDSRootViewController sharedRootViewController]
                                                                                             title:nil
                                                                                           message:errorDescription
                                                                                      buttonTitles:@[@"退出", @"重新连接"]
                                                                                             block:^(NSInteger index) {
                                                                                                 if (index == 0) {
                                                                                                     exit(0);
                                                                                                 }else{
                                                                                                     [weakSelf fetchUnavailibleUrlList];
                                                                                                 }
                                                                                             }];
                                                   
                                               }];
}



- (void)finishTaskWithTaksID:(NSString *)taskID{
    XDSTask *task = [self.launchTaskQueue taskWithTaskId:taskID];
    [task taskHasFinished];
}
@end

