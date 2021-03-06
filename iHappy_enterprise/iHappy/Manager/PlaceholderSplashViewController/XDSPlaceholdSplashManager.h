//
//  XDSPlaceholdSplashManager.h
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSBaseManager.h"
@class XDSPlaceholdSplashViewController;
@interface XDSPlaceholdSplashManager : XDSBaseManager

+ (instancetype)sharedManager;

//Placeholder Splash View
- (void)showPlaceholderSplashView;
- (void)showPlaceholderSplashViewWithViewController:(XDSPlaceholdSplashViewController *)viewController;
- (void)removePlaceholderSplashView;

@end
