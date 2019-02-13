//
//  XDSBaseContentNavigationController.m
//  iHappy
//
//  Created by Hmily on 2018/9/26.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSBaseContentNavigationController.h"
#import "AppDelegate.h"
@interface XDSBaseContentNavigationController ()

@end

@implementation XDSBaseContentNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        [self createMenuButton];
    }
    return self;
}


- (void)createMenuButton {
    UIViewController *rootController = self.viewControllers.firstObject;
    UIBarButtonItem *barButtonitem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showMenu)];
    barButtonitem.tintColor = [UIColor lightGrayColor];
    rootController.navigationItem.leftBarButtonItem = barButtonitem;
}

#pragma mark - 点击事件处理
//TODO:菜单
- (void)showMenu{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.mainmeunVC presentLeftMenuViewController];
}

-(BOOL)shouldAutorotate{
    return self.topViewController.shouldAutorotate;
}
@end
