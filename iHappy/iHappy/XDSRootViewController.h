//
//  XDSRootViewController.h
//  Kit
//
//  Created by Hmily on 2018/7/23.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDSRootViewController : UIViewController

@property (nonatomic, strong) UIViewController *mainViewController;

+ (instancetype)sharedRootViewController;

+ (void)needAdjustPageLevel:(BOOL)flag;

@end
