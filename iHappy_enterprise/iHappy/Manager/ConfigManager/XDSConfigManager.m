//
//  XDSConfigManager.m
//  Kit
//
//  Created by Hmily on 2018/7/22.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSConfigManager.h"
#import "UIAlertController+XDS.h"

@interface XDSConfigManager ()
@property (nonatomic, strong) NSString * storeLink;
@property (nonatomic, strong) UIAlertController * welcomeAlertController;
@property (nonatomic, strong) UIAlertController * versionAlertController;
@property (nonatomic, strong) UIAlertController * offlineAlertController;

@end

@implementation XDSConfigManager
+ (XDSConfigManager *)sharedManager
{
    static XDSConfigManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}

- (void)fetchAppConfigWithURL:(NSString *)urlString {
//    NSString *returnStr = [[NSString alloc] initWithData:package.responseDataBuffer encoding:NSUTF8StringEncoding];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"appConfig.txt" ofType:nil];
    NSString *returnStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    XDSConfigItem *item = [[XDSConfigItem alloc] initConfigItemBySystemLanguageWithJsonStr:returnStr];
    BOOL fetchFail = NO;
    if (!item) {
        fetchFail = YES;
    }else {
        
        self.configItem = item;
        
        [self configTaskFinished];
        
    }
    
    if (fetchFail && !self.configItem) {
        //error
//        NSString *msg = XDLocalizedString(@"xd.message.offline", nil);
        NSString *msg = @"网络异常";
        if (self.offlineAlertController.visible) {
            [self.offlineAlertController dismissViewControllerAnimated:NO completion:nil];
            self.offlineAlertController = nil;
        }
        
        UIAlertController * alertController = [UIAlertController showAlertInViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                                                                                 withTitle:@"标题名称"
                                                                                   message:msg
                                                                         cancelButtonTitle:@"xd.ui.reconnect"
                                                                         otherButtonTitles:nil
                                                                                  tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                                                      if (controller.cancelButtonIndex == buttonIndex) {
                                                                                          
#warning message
//                                                                                          NSString * configURL = [[XDSLocalConfigManager sharedManager] configURLString];
//                                                                                          [self fetchAppConfigWithURL:[self.configItem getConfigurlFromTest].length?[self.configItem getConfigurlFromTest]:configURL userInfo:nil];
                                                                                          [self fetchAppConfigWithURL:nil];
                                                                                          
                                                                                      }
                                                                                  }];
        
        self.offlineAlertController = alertController;
        
    }
}


-(void)configTaskFinished
{
//    [[XDSSettingsManager sharedManager] configItemRefreshed:self.configItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:XDSConfigItemRefreshNotification object:self.configItem];
    
    //check version
    if ([self versionLogic:self.configItem]) {
        return;
    }
    
    //check welcome
    NSDictionary *welcomeDic = [self.configItem urlItemByXdid:@"xd.app.info" paramPath:@"welcome"];
    BOOL welcomeEnable = [[welcomeDic valueForKey:@"enable"] boolValue];
    if (welcomeEnable) {
        
        if (self.welcomeAlertController.visible) {
            [self.welcomeAlertController dismissViewControllerAnimated:NO completion:nil];
            self.welcomeAlertController = nil;
        }
        
        NSString * msg = [welcomeDic valueForKey:@"message"];
//        NSString *buttonTitle = LLocalizedString(@"xd.ui.ok", nil);
        NSString *buttonTitle = @"xd.ui.ok";
        UIAlertController * alertController = [UIAlertController showAlertInViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                                                                                 withTitle:@"标题名称"
                                                                                   message:msg
                                                                         cancelButtonTitle:buttonTitle
                                                                         otherButtonTitles:nil
                                                                                  tapBlock:nil];
        
        self.welcomeAlertController = alertController;
        
        
    }
    
    //task finished
//    XDSTask * fetchConfigTask = [[XDEStartupManager sharedManager].launchTaskQueue taskWithTaskId:XDEFetchConfigTaskIdKey];
//    [fetchConfigTask taskHasFinished];
    
}



- (BOOL)versionLogic:(XDSConfigItem *) configItem
{
    BOOL isNeedUpdate =  NO;
    if (configItem) {
        XDSUrlItem *greeting = [configItem urlItemByXdid:@"xd.app.greeting"];
        
        if (!greeting.enable) {
            return NO;
        }
        
        NSString * updateLink = nil;
        NSString * okTitle = nil;
        NSInteger alertTag = 0;
        
        if ([[greeting paramsValueBykey:@"forceUpgrade"] boolValue]) {
//            updateLink = XDLocalizedString(@"xd.ui.updatenow", nil);
//            okTitle = XDLocalizedString(@"xd.ui.quitapp", nil);
            updateLink = @"xd.ui.updatenow";
            okTitle = @"xd.ui.quitapp";

            isNeedUpdate = YES;
            alertTag = 100;
        }else {
//            okTitle = NLLocalizedString(@"xd.ui.ok", nil);
            okTitle = @"xd.ui.ok";
        }
        
        self.storeLink = [greeting paramsValueBykey:@"upgradeUrl"];
        
        if (!self.storeLink || [self.storeLink isEqualToString:@""]) {
            updateLink = nil;
        }
        
        NSString *msgTitle = [greeting paramsValueBykey:@"title"];
        NSString *msgBody = [greeting paramsValueBykey:@"message"];
        
        if ((!msgTitle && !msgBody) || ([msgTitle isEqualToString:@""] && [msgBody isEqualToString:@""])) {
            return NO;
        }
        
        if (self.versionAlertController.visible) {
            [self.versionAlertController dismissViewControllerAnimated:NO completion:nil];
            self.versionAlertController = nil;
        }
        
        if (isNeedUpdate) {
            
            __weak typeof(self)weakself = self;
            UIAlertController * alertController = [UIAlertController showAlertInViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                                                                                     withTitle:msgTitle
                                                                                       message:msgBody
                                                                             cancelButtonTitle:okTitle
                                                                             otherButtonTitles:updateLink?@[updateLink]:nil
                                                                                      tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                                                          if (buttonIndex == controller.cancelButtonIndex) {
                                                                                              NSLog(@"Quit App");
                                                                                              exit(0);
                                                                                          }else if (buttonIndex == controller.firstOtherButtonIndex) {
                                                                                              NSURL *url = [[NSURL alloc] initWithString:weakself.storeLink];
                                                                                              [[UIApplication sharedApplication] openURL:url];
                                                                                              weakself.storeLink = nil;
                                                                                              exit(0);
                                                                                          }
                                                                                      }];
            
            
            self.versionAlertController = alertController;
            
        }else {
            
            UIAlertController * alertController = [UIAlertController showAlertInViewController:[UIApplication sharedApplication].delegate.window.rootViewController
                                                                                     withTitle:msgTitle
                                                                                       message:msgBody
                                                                             cancelButtonTitle:okTitle
                                                                             otherButtonTitles:nil
                                                                                      tapBlock:nil];
            
            self.versionAlertController = alertController;
            
        }
        
    }
    return isNeedUpdate;
}
@end

NSString * const XDSConfigItemRefreshNotification = @"XDSConfigItemRefreshNotification";
