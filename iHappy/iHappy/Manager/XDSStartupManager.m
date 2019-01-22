//
//  XDSStartupManager.m
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSStartupManager.h"
#import "XDSSettingsManager.h"
#import "XDSJPushManager.h"
#import "XDSRootViewController.h"
#import "XDSPlaceholdSplashManager.h"
#import "XDSTaskQueue.h"
#import "IHPMenuViewController.h"


#import "IHPPlaceholderSplashViewController.h"
#import "IHYMainViewController.h"
#import "XDSMainReaderVC.h"
#import "AppDelegate.h"

#import "XDSMainTabBarVC.h"
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

    //注册极光推送
    [[XDSJPushManager sharedManager] registerAppKey:launchOptions];
    
    self.launchOptions = launchOptions;

    //
//    [self removeApplicationNotifications];
//    [self addApplicationNotifications];

//    //init root view controller
    [XDSRootViewController needAdjustPageLevel:YES];
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
        [[XDSUserInfo shareUser] loadLastLoginUserInfo];
        [[XDSSettingsManager sharedManager] setOnlyOnceWhenLaunchTaskQueueFinished];
        [self initMainViewLaunchingOptions:launchOptions];
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
    
    if ([IHPConfigManager shareManager].isIncheck) {
        XDSMainTabBarVC *tabBarVC = [[XDSMainTabBarVC alloc] init];
        [XDSRootViewController sharedRootViewController].mainViewController = tabBarVC;
        return;
    }
    
    
    NSArray<IHPMenuModel*> *menus = [IHPConfigManager shareManager].menus;
    
    IHPMenuViewController *leftMenu = [[IHPMenuViewController alloc] init];
    
    IHPMenuModel *theMenu = menus.firstObject;
    
    XDSSideMenu *mainmeunVC = [[XDSSideMenu alloc] initWithContentViewController:theMenu.contentViewController
                                                          leftMenuViewController:leftMenu
                                                         rightMenuViewController:nil];
    
    mainmeunVC.contentViewInLandscapeOffsetCenterX = -420;
//    mainmeunVC.animationDuration = 2.f;
    mainmeunVC.contentViewShadowColor = [UIColor blackColor];
    mainmeunVC.contentViewShadowOffset = CGSizeMake(0, 0);
    mainmeunVC.contentViewShadowOpacity = 0.6;
    mainmeunVC.contentViewShadowRadius = 12;
    mainmeunVC.contentViewShadowEnabled = YES;
    mainmeunVC.scaleMenuView = NO;
    mainmeunVC.scaleContentView = NO;
    mainmeunVC.contentViewScaleValue = 0.9;
    mainmeunVC.panGestureEnabled = YES;
    mainmeunVC.panFromEdge = YES;
    mainmeunVC.panMinimumOpenThreshold = 60.0;
    mainmeunVC.bouncesHorizontally = NO;
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
    [_launchTaskQueue addTask:updateLocalizableTask];

    
#if DEBUG
    [updateLocalizableTask addDependency:fetchConfigTask];

#else
    [_launchTaskQueue addTask:fetchUnavailibleUrlListTask];
    [fetchUnavailibleUrlListTask addDependency:fetchConfigTask];
    [updateLocalizableTask addDependency:fetchUnavailibleUrlListTask];
#endif
    
    [_launchTaskQueue goWithFinishedBlock:^(XDSTaskQueue *taskQueue) {
        IHPPlaceholderSplashViewController *splashVC = [XDSSettingsManager sharedManager].customPlaceholdSplashViewController;
        [splashVC configLaunch];
        //enter main page
        [self enterMainViewWithLaunchingOptions:nil];
        [self fetchMeiziFileContent];
        [self fetchShuaigeFileContent];
    }];
    
}


- (void)fetchConfigData{

//    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"json"];
//    NSData *menuData = [NSData dataWithContentsOfFile:path];
//    NSLog(@"%@", [[NSString alloc] initWithData:menuData encoding:NSUTF8StringEncoding]);
//    IHPConfigManager *manager = [IHPConfigManager shareManager];
//    [manager configManagerWithJsondData:menuData];
//    [self finishTaskWithTaksID:kXDSFetchConfigTaskID];
//    return;
    
#if DEBUG
    NSString *requesturl = @"http://129.204.47.207/ihappy/config/menu_dev.json";
#else
    NSString *requesturl = @"http://129.204.47.207/ihappy/config/menu_1.0.6.json";
#endif
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:requesturl
                                         hudController:nil
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);

                                                   if (htmlData != nil) {
                                                       [[NSUserDefaults standardUserDefaults] setValue:htmlData forKey:[UIApplication sharedApplication].appBundleID];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                   }
                                                   [weakSelf handleConfigData:htmlData];

                                               } failed:^(NSString *errorDescription) {
//                                                   errorDescription = errorDescription?errorDescription:kLoadFailed;
//                                                   [XDSUtilities alertViewWithPresentingController:[XDSRootViewController sharedRootViewController]
//                                                                                             title:nil
//                                                                                           message:errorDescription
//                                                                                      buttonTitles:@[@"退出", @"重新连接"]
//                                                                                             block:^(NSInteger index) {
//                                                                                                 if (index == 0) {
//                                                                                                     exit(0);
//                                                                                                 }else{
//                                                                                                     [weakSelf fetchConfigData];
//                                                                                                 }
//                                                                                             }];
                                                   NSData *configData = [[NSUserDefaults standardUserDefaults] valueForKey:[UIApplication sharedApplication].appBundleID];
                                                   [weakSelf handleConfigData:configData];
                                               }];
}

- (void)handleConfigData:(NSData *)configData {
    if (configData == nil || ![configData isKindOfClass:[NSData class]]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"json"];
        configData = [NSData dataWithContentsOfFile:path];
    }
    IHPConfigManager *manager = [IHPConfigManager shareManager];
    [manager configManagerWithJsondData:configData];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([manager.forceUpdate.version compare:appVersion  options:NSNumericSearch] == NSOrderedDescending &&
        manager.forceUpdate.enable) {
        
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
                                                          [self finishTaskWithTaksID:kXDSFetchConfigTaskID];
                                                      }];
        }
    }else{
        [self finishTaskWithTaksID:kXDSFetchConfigTaskID];
    }
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
    
//    NSString *requesturl = @"http://134.175.54.80/ihappy/unavailible_url.json";
    NSString *requesturl = @"http://129.204.47.207/ihappy/config/unavailible_url.json";

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

#pragma mark - 下载图片链接文件--妹子
- (void)fetchMeiziFileContent {

    NSString *requesturl = @"http://129.204.47.207/ihappy/source/meizi.txt";
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:requesturl
                                         hudController:nil
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                   IHPConfigManager *manager = [IHPConfigManager shareManager];
                                                   manager.meizi = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                                               } failed:^(NSString *errorDescription) {
                                                   NSLog(@"妹子图片链接文件下载失败 = %@", errorDescription);
                                               }];
}


#pragma mark - 下载图片链接文件--帅哥
- (void)fetchShuaigeFileContent {
    
    NSString *requesturl = @"http://129.204.47.207/ihappy/source/shuaige.txt";
    
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:requesturl
                                         hudController:nil
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                   IHPConfigManager *manager = [IHPConfigManager shareManager];
                                                   manager.shuaige = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                                               } failed:^(NSString *errorDescription) {
                                                   NSLog(@"帅哥图片链接文件下载失败 = %@", errorDescription);
                                               }];
}


- (void)finishTaskWithTaksID:(NSString *)taskID{
    XDSTask *task = [self.launchTaskQueue taskWithTaskId:taskID];
    [task taskHasFinished];
}
@end

