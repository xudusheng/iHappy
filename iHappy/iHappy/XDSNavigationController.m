//
//  XDSNavigationController.m
//  iHappy
//
//  Created by Hmily on 2019/2/13.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSNavigationController.h"

@interface XDSNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation XDSNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = YES;
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

@end
