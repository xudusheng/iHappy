//
//  IHPMenuModel.m
//  iHappy
//
//  Created by dusheng.xu on 2017/4/23.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPMenuModel.h"
#import "IHPSubMenuModel.h"
#import "IHYMainViewController.h"
#import "XDSMainReaderVC.h"
#import "IHPMeituListViewController.h"
@interface IHPMenuModel (){
    UINavigationController *_contentViewController;//这个model下的controller，单例
}
@end

@implementation IHPMenuModel

- (UINavigationController *)contentViewController {
    if (!_contentViewController) {        
        UIViewController *contentController;

        if (self.type == IHPMenuTypeReader) {
            contentController = [[XDSMainReaderVC alloc] init];
        }else if (self.type == IHPMenuTypeBizhi){
            contentController = [[IHPMeituListViewController alloc] init];
            ((IHPMeituListViewController *)contentController).rootUrl = self.rooturl;
            contentController.title = self.title;
        }else {
            contentController = [[IHYMainViewController alloc] init];
            ((IHYMainViewController *)contentController).menuModel = self;
        }
        
        contentController.title = self.title;
        UINavigationController *nav;
        if ([IHPConfigManager shareManager].menus.count == 1) {
            nav = [[UINavigationController alloc] initWithRootViewController:contentController];
        }else {
            nav = [[XDSBaseContentNavigationController alloc] initWithRootViewController:contentController];
        }
        nav.navigationBar.translucent = NO;
        _contentViewController = nav;
    }
    return _contentViewController;
}

@end
