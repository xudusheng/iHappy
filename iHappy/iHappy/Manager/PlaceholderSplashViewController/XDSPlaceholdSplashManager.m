//
//  XDSPlaceholdSplashManager.m
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSPlaceholdSplashManager.h"
#import "XDSPlaceholdSplashViewController.h"
#import "XDSRootViewController.h"

@interface XDSPlaceholdSplashManager ()
@property (weak, nonatomic) XDSPlaceholdSplashViewController *placeholdSplashViewController;
@end

@implementation XDSPlaceholdSplashManager

+ (instancetype)sharedManager {
    static XDSPlaceholdSplashManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}


- (void)showPlaceholderSplashViewWithViewController:(XDSPlaceholdSplashViewController *)viewController
{
    viewController.isCustomView = YES;
    
    [self displayPlaceholderSplashView:viewController];
}

- (void)removePlaceholderSplashView {
    [self.placeholdSplashViewController willMoveToParentViewController:nil];
    if (self.placeholdSplashViewController.view.superview) {
        [self.placeholdSplashViewController.view removeFromSuperview];
    }
    [self.placeholdSplashViewController removeFromParentViewController];
    
    self.placeholdSplashViewController = nil;
}

- (void)showPlaceholderSplashView {
    XDSPlaceholdSplashViewController *placeholdSplashViewController = [[XDSPlaceholdSplashViewController alloc] init];
    [self displayPlaceholderSplashView:placeholdSplashViewController];
}

- (void)displayPlaceholderSplashView:(XDSPlaceholdSplashViewController *)viewController; {
    [[XDSRootViewController sharedRootViewController] addChildViewController:viewController];
    [[XDSRootViewController sharedRootViewController].view addSubview:viewController.view];
    [viewController didMoveToParentViewController:[XDSRootViewController sharedRootViewController]];
    self.placeholdSplashViewController = viewController;
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}


@end
