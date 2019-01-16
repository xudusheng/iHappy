//
//  XDSUserInfo.h
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDSUserInfo : NSObject

+ (instancetype)shareUser;

@property (strong, nonatomic) NSString *head_img;
@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString *nickname;

@property (readonly, nonatomic) BOOL isLogin;//是否登录状态

//APP启动时加载保存好的用户信息
- (void)loadLastLoginUserInfo;

- (void)saveUserInfo:(XDSUserInfo *)userInfo;

- (void)clearUserInfo;


@end

NS_ASSUME_NONNULL_END
