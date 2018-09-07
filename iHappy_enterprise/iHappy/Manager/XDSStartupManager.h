//
//  XDSStartupManager.h
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSBaseManager.h"
#import "XDSTaskQueue.h"
@interface XDSStartupManager : XDSBaseManager

@property (nonatomic, strong) NSDictionary * launchOptions;
@property (nonatomic, assign) BOOL launchTaskQueueFinished;
@property (nonatomic, assign) BOOL isAppGeoBlock;

@property (nonatomic, strong) XDSTaskQueue *launchTaskQueue;

+ (instancetype)sharedManager;
- (void)startupWithLaunchingOptions:(NSDictionary *)launchOptions NS_REQUIRES_SUPER;
- (void)enterMainViewWithLaunchingOptions:(NSDictionary *)launchOptions NS_REQUIRES_SUPER;
- (void)initMainViewLaunchingOptions:(NSDictionary *)launchOptions NS_REQUIRES_SUPER;

- (void)scheduleLaunchTaskQueue NS_REQUIRES_SUPER;


@end
