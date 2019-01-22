//
//  BXJPushManager.m
//  YuYue
//
//  Created by Hmily on 2018/8/16.
//  Copyright © 2018年 碧斯诺兰. All rights reserved.
//

#import "XDSJPushManager.h"
// 引入JPush功能所需头文件

#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface XDSJPushManager() <JPUSHRegisterDelegate>

@end

@implementation XDSJPushManager
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedManager {
    static XDSJPushManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}

- (void)registerAppKey:(NSDictionary *)launchOptions {
    // apn 内容获取：
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"remoteNotification=========%@",remoteNotification);

    if (remoteNotification) {//推送唤醒APP
        [self handleMessageData:remoteNotification];
    }else{//正常启动APP

    }
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    
#ifdef DEBUG
    NSString *appKey = @"ec49ababe86875f0b1ac6fed";
    NSString *channel = @"AppStore";
    BOOL isProduction = NO;
#else
    NSString *appKey = @"ec49ababe86875f0b1ac6fed";
    NSString *channel = @"AppStore";
    BOOL isProduction = YES;
#endif
    
    [JPUSHService setupWithOption:launchOptions
                           appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        NSLog(@"resCode : %d,registrationID: %@",resCode, registrationID);
        [self registerAliasAndTags];
    }];
    
    
    
    
}

- (void)launchOptionsWithNotice:(NSDictionary *)launchOptions{
    //处理通知
    if (launchOptions) {
        if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            NSDictionary *userinfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            self.userinfo = userinfo;
        }
    }
}







- (void)registerDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)registerAliasAndTags{

}
- (void)deleteAliasAndTags{
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        NSLog(@"推送取消设置别名%ld - %@ - %ld",(long)iResCode,iAlias,(long)seq);
    } seq:0];
    [JPUSHService deleteTags:[[NSSet alloc] initWithArray:@[@"common",@"area",@"bluemember",@"director"]] completion:^(NSInteger iResCode, NSSet *iTags, NSInteger seq) {
        NSLog(@"推送取消设置标签%ld - %@ - %ld",(long)iResCode,iTags,(long)seq);
    } seq:0];
    [JPUSHService setMobileNumber:nil completion:^(NSError *error) {
        NSLog(@"推送取消设置手机号码%@",error);
    }];
}



#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self jpushDisposeMessage:userInfo];
    }else {
        //本地通知
    }
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler API_AVAILABLE(ios(10.0)){
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [self jpushDisposeAPNS:userInfo];
    }else {
        //本地通知
    }
    completionHandler();
}
#endif

#pragma mark - 接收消息，处理消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    if (application.applicationState == 0 && userInfo[@"aps"][@"badge"] == nil && userInfo[@"aps"][@"sound"] == nil) {
        [self jpushDisposeMessage:userInfo];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState > 0) {
        [self jpushDisposeMessage:userInfo];
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    [self jpushDisposeAPNS:userInfo];
}


//静默推送，自定义推送,收到消息走这个方法
- (void)networkDidReceiveMessage:(NSNotification *)notification {
//    NSDictionary * userInfo = [notification userInfo];
//    NSString *content = [userInfo valueForKey:@"content"];
//    NSString *messageID = [userInfo valueForKey:@"_j_msgid"];
//    NSDictionary *extras = [userInfo valueForKey:@"extras"];
//    NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的Extras附加字段，key是自己定义的
    
//    [self handleMessageData:userInfo];
//    NSLog(@"静默推送，自定义推送userInfo = %@", userInfo);
//    NSLog(@"-----%s", __FUNCTION__);
//    [BSNLUtil showHudSuccess:content rootView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
    [self jpushDisposeMessage:[notification userInfo]];
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

//uid:19646312805
//registrationID:141fe1da9ef05f97820

#pragma mark - 处理消息内容

- (void)handleMessageData:(NSDictionary *)userInfo {
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    NSLog(@"userInfo = %@", userInfo);
    
    
//#warning 等接口格式确定了造一个model替代Dictionary
//    [[BXDeepLinkManager sharedManager] handleAPNSWithDictionary:userInfo needShowMessage:YES];
  
}

//自定义通知来处理得到的通知
- (void)jpushDisposeAPNSWithNotification:(NSNotification *)notif{
    [self jpushDisposeAPNS:self.userinfo];
    self.userinfo = nil;
}


//处理点击通知
- (void)jpushDisposeAPNS:(NSDictionary *)userInfo{
//    dispatch_queue_t queue =  dispatch_queue_create("jpushqueue", NULL);
//    dispatch_sync(queue, ^{
//
//    });
    [self jpushDisposeAPNSLater:userInfo];
}
- (void)jpushDisposeAPNSLater:(NSDictionary *)userInfo{
    
}
//处理静默消息
- (void)jpushDisposeMessage:(NSDictionary *)userinfo{
    NSLog(@"收到的消息-%@",userinfo);
}

@end




@implementation BXNoticeModel

@end
