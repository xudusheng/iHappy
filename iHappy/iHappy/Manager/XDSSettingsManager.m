//
//  XDSSettingsManager.m
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSSettingsManager.h"
#import "XDSConfigItem.h"
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

#pragma mark - Launch
- (void)setupAfterLaunch {}

- (XDSPlaceholdSplashViewController *)customPlaceholdSplashViewController {
    return nil;
}

#pragma mark - UI Style
- (void)setUIStyle{}

#pragma mark - Global Settings
- (void)setGlobalSettings {}
- (void)setOnlyOnceWhenLaunchTaskQueueFinished {}

@end
