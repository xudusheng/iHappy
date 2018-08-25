//
//  UIViewController+XDSMediaBrowser.m
//  iHappy
//
//  Created by Hmily on 2018/8/25.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "UIViewController+XDSMediaBrowser.h"

@implementation UIViewController (XDSMediaBrowser)

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                  translucent:(BOOL)translucent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion {
    if (translucent == NO) {
        [self presentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    
    viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    UIViewController* controller = self.view.window.rootViewController;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        viewControllerToPresent.providesPresentationContextTransitionStyle = YES;
        viewControllerToPresent.definesPresentationContext = YES;
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [controller presentViewController:viewControllerToPresent animated:YES completion:nil];
    } else {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:viewControllerToPresent animated:YES completion:nil];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    
    
}
@end
