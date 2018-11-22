//
//  BaiduAdManager.h
//  iHappy
//
//  Created by Hmily on 2018/11/22.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "XDSBaseManager.h"

#define kBannerSize_20_3 @"3722589"
#define kBannerSize_3_2 @"3722694"
#define kBannerSize_7_3 @"3722704"
#define kBannerSize_2_1 @"3722709"

NS_ASSUME_NONNULL_BEGIN

@interface BaiduAdManager : XDSBaseManager

+ (instancetype)sharedManager;

//banner广告
- (void)startAdViewInView:(UIView *)inView adUnitTag:(NSString *)adUnitTag;


//视频贴片
- (void)loadPrerollAdInView:(UIView *)InView;

@end

NS_ASSUME_NONNULL_END
