//
//  IHYAdManager.h
//  iHappy
//
//  Created by Hmily on 2018/8/24.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSBaseManager.h"

@interface XDSAdManager : XDSBaseManager

+ (instancetype)sharedManager;

//展示开屏广告
- (void)showSplashAd;


@end
