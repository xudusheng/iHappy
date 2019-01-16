//
//  XDSUserInfo.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSUserInfo.h"

@interface XDSUserInfo ()

@property (assign, nonatomic) BOOL isLogin;//是否登录状态

@end

@implementation XDSUserInfo

XDS_SYNTHESIZE_SINGLETON_FOR_CLASS(XDSUserInfo)

+ (instancetype)shareUser {
    XDSUserInfo *user = [self sharedXDSUserInfo];
    return user;
}

- (void)saveUserInfo:(XDSUserInfo *)userInfo {
    if (userInfo == nil) {
        return;
    }
    self.head_img = userInfo.head_img;
    self.mobile = userInfo.mobile;
    self.nickname = self.nickname;
    self.isLogin = YES;
    
    NSDictionary *userInfoDic = [self mj_keyValues];
    [[NSUserDefaults standardUserDefaults] setObject:userInfoDic forKey:NSStringFromClass([XDSUserInfo class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearUserInfo {
    self.head_img = @"";
    self.mobile = @"";
    self.nickname = @"";
    self.isLogin = NO;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:NSStringFromClass([XDSUserInfo class])];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLastLoginUserInfo {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:NSStringFromClass([XDSUserInfo class])];
    if (user) {
        XDSUserInfo *userModel = [XDSUserInfo alloc];
        [userModel setValuesForKeysWithDictionary:user];
        [self saveUserInfo:userModel];
    }
}

- (BOOL)isLogin {
    return _isLogin;
}

@end
