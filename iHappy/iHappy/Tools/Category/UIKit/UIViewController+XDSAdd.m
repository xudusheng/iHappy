//
//  UIViewController+XDSAdd.m
//  Demo
//
//  Created by Hmily on 2018/10/23.
//  Copyright © 2018年 BX. All rights reserved.
//

#import "UIViewController+XDSAdd.h"

@implementation UIViewController (XDSAdd)

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated: (BOOL)flag
            inRransparentForm:(BOOL)inRransparentForm
                   completion:(void (^ __nullable)(void))completion
{
    if (!inRransparentForm) {
        [self presentViewController:viewControllerToPresent animated:flag completion:completion];
        return;
    }
    viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        viewControllerToPresent.providesPresentationContextTransitionStyle = YES;
        viewControllerToPresent.definesPresentationContext = YES;
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:viewControllerToPresent animated:flag completion:completion];
    } else {
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self presentViewController:viewControllerToPresent animated:flag completion:completion];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}



@end
