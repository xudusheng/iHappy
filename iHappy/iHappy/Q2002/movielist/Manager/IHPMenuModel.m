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
#import "IHPShuaigeListViewController.h"

#import "XDSWelfareVCTableViewController.h"//小微福利

#import "XDSSettingVC.h"//设置

@interface IHPMenuModel (){
    UINavigationController *_contentViewController;//这个model下的controller，单例
}
@end

@implementation IHPMenuModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"subMenus":@"IHPSubMenuModel"
             };
}


- (UINavigationController *)contentViewController {
    if (!_contentViewController) {        
        UIViewController *contentController;

        if (self.type == IHPMenuTypeReader) {
            contentController = [[XDSMainReaderVC alloc] init];
        }else if (self.type == IHPMenuTypeBizhi){
            contentController = [[IHPMeituListViewController alloc] init];
            ((IHPMeituListViewController *)contentController).rootUrl = self.rooturl;
        }else if (self.type == IHPMenuTypeShuaige){
            contentController = [[IHPShuaigeListViewController alloc] init];
            ((IHPShuaigeListViewController *)contentController).rootUrl = self.rooturl;
        }else if(self.type == IHPMenuTypeWelfare){
            contentController = [[XDSWelfareVCTableViewController alloc] init];
        }else if(self.type == IHPMenuTypeSetting){
            contentController = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([XDSSettingVC class])];
        } else {
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
