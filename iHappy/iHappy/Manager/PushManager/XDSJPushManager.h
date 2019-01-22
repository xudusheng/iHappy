//
//  XDSJPushManager.h
//  iHappy
//
//  Created by Hmily on 2018/8/16.
//  Copyright © 2018年 碧斯诺兰. All rights reserved.
//

#import "XDSBaseManager.h"

@interface XDSJPushManager : XDSBaseManager 

@property (nonatomic, strong) NSDictionary *userinfo;//临时缓存一次推送过来的消息

+ (instancetype)sharedManager;

- (void)registerAppKey:(NSDictionary *)launchOptions;

- (void)registerDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (void)applicationDidBecomeActive:(UIApplication *)application;




- (void)launchOptionsWithNotice:(NSDictionary *)launchOptions;
- (void)registerAliasAndTags;//设置标签，别名
- (void)deleteAliasAndTags;//移除所有的标签，别名

@end



@interface BXNoticeModel : NSObject

@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, copy) NSString *subtitle;//副标题
@property (nonatomic, copy) NSString *pic;//图片
@property (nonatomic, assign) NSInteger type;//类型，0 h5，1商品，2套餐，3专题详情4专题列表5活动
@property (nonatomic, copy) NSString *type_val;//值，配合类型使用，如类型为h5，则值为URL地址
@property (nonatomic, assign) NSInteger msg_type;//1.活动消息，2系统消息3订单消息，4.商学院消息5.动态消息，6.佣金消息，7.客服消息

@end
