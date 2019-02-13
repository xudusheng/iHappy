//
//  XDSMainTabBarVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSMainTabBarVC.h"

#import "XDSMainReaderVC.h"
#import "XDSMainNoteVC.h"
#import "XDSSettingVC.h"
#import "XDSUserInfo.h"
@interface XDSMainTabBarVC () <UITabBarControllerDelegate>

@end

@implementation XDSMainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];


    XDSMainReaderVC *reader = [[XDSMainReaderVC alloc] init];
    XDSNavigationController *nav_reader = [self setupChildViewController:reader
                                                                  title:@"书库"
                                                              imageName:@"hw_tabbar_books_none_21x21"
                                                      selectedImageName:@"hw_tabbar_books_selected_21x21"];

    XDSMainNoteVC *note = [[XDSMainNoteVC alloc] initWithStyle:UITableViewStylePlain];
    XDSNavigationController *nav_note = [self setupChildViewController:note
                                                                title:@"笔记"
                                                            imageName:@"hw_tabbar_shelf_none_21x21"
                                                    selectedImageName:@"hw_tabbar_shelf_selected_21x21"];
    
    XDSSettingVC *setting = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([XDSSettingVC class])];
    XDSNavigationController *nav_setting = [self setupChildViewController:setting
                                                                   title:@"设置"
                                                               imageName:@"hw_tabbar_find_none_21x21"
                                                       selectedImageName:@"hw_tabbar_find_selected_21x21"];
    
    self.viewControllers = @[nav_reader, nav_note, nav_setting];

    self.delegate = self;
}

- (XDSNavigationController *)setupChildViewController:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName{
    // 1.设置控制器的属性
    childVc.title = title;
    childVc.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    XDSNavigationController *navi = [[XDSNavigationController alloc] initWithRootViewController:childVc];
    return navi;
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    UINavigationController *nav = (UINavigationController *)viewController;
    if ([nav.viewControllers.firstObject isMemberOfClass:[XDSMainNoteVC class]] ||
        [nav.viewControllers.firstObject isMemberOfClass:[XDSSettingVC class]]) {
        
        if ([XDSUserInfo shareUser].isLogin) {
            if ([nav.viewControllers.firstObject isMemberOfClass:[XDSMainNoteVC class]]) {
                XDSMainNoteVC *noteVC = (XDSMainNoteVC *)nav.viewControllers.firstObject;
                [noteVC loadBooksContainNote];
            }
            return YES;
        }else {
            UINavigationController *loginNav = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavi"];
            loginNav.navigationBar.translucent = NO;
            UIViewController *loginVC = loginNav.cw_rootViewController;
            loginVC.hidesTopBarWhenPushed = YES;
            [self presentViewController:loginNav animated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}

@end
