//
//  XDSSettingVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/4.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSSettingVC.h"

#import "XDSAboutUSVC.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface XDSSettingVC ()
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memeryLabel;

@end

@implementation XDSSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.nicknameLabel.text = [XDSUserInfo shareUser].nickname.length > 0 ? [XDSUserInfo shareUser].nickname : @"游客";
    [self setUsedMemerySize];
}

#pragma mark - UI相关

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([IHPConfigManager shareManager].isIncheck) {
        return 3;
    }
    return 2;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {

    }else if (indexPath.section == 0 && indexPath.row == 1) {
        [self clearMemery];
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        [self shareAction];
    }else if (indexPath.section == 1 && indexPath.row == 1) {
        XDSAboutUSVC *aboutUs = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"XDSAboutUSVC"];
        aboutUs.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aboutUs animated:YES];
    }else if (indexPath.section == 2 && indexPath.row == 0) {
        [self logout];
        
    }
}
#pragma mark - event response 事件响应处理

#pragma mark - private method 其他私有方法
- (void)clearMemery {
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:nil
                                         message:XDSLocalizedString(@"xds.setting.clearmemery.content", nil)
                               cancelButtonTitle:XDSLocalizedString(@"xds.ui.cancel", nil)
                               otherButtonTitles:@[XDSLocalizedString(@"xds.ui.ok", nil)]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            if (controller.cancelButtonIndex != buttonIndex) {
                                                __weak typeof(self)weakSelf = self;
                                                [[SDImageCache sharedImageCache] clearMemory];
                                                [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                                                    [XDSUtilities showHudSuccess:@"缓存清理成功~" rootView:self.view imageName:nil];
                                                    [weakSelf setUsedMemerySize];
                                                }];
                                            }
                                        }];
}

- (void)setUsedMemerySize{
    [[SDImageCache sharedImageCache]calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        long long sizeLength = totalSize;
        NSString *sizeString = @"";
        if (sizeLength < 1024) {// 小于1k
                sizeString = [NSString stringWithFormat:@"%ldB",(long)sizeLength] ;
        }else if (sizeLength < 1024 * 1024){// 小于1m
            CGFloat aFloat = sizeLength/1024;
            sizeString = [NSString stringWithFormat:@"%.0fK",aFloat];
        }else if (sizeLength < 1024 * 1024 * 1024){// 小于1G
            CGFloat aFloat = sizeLength/(1024 * 1024);
                sizeString = [NSString stringWithFormat:@"%.1fM",aFloat];
        }else{
            CGFloat aFloat = sizeLength/(1024*1024*1024);
                sizeString = [NSString stringWithFormat:@"%.1fG",aFloat];
        }
        self.memeryLabel.text = sizeString;
    }];
}
- (void)shareAction {
    NSURL *urlToShare = [NSURL URLWithString:[IHPConfigManager shareManager].forceUpdate.url];
    NSArray *activityItems = @[urlToShare];
    [self shareWithContentArray:activityItems];
}

- (void)shareWithContentArray:(NSArray *)contentArray {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:contentArray applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError) {
        NSLog(@"%@", activityType);
        if (completed) { // 确定分享
            NSLog(@"分享成功");
        } else {
            NSLog(@"分享失败");
        }
    };
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)logout {
    @weakify(self)
    [UIAlertController showAlertInViewController:self
                                       withTitle:nil
                                         message:XDSLocalizedString(@"xds.setting.title.logout", nil)
                               cancelButtonTitle:XDSLocalizedString(@"xds.ui.cancel", nil)
                               otherButtonTitles:@[XDSLocalizedString(@"xds.ui.ok", nil)]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            @strongify(self)
                                            if (controller.cancelButtonIndex != buttonIndex) {
                                                UINavigationController *loginNav = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavi"];
                                                loginNav.navigationBar.translucent = NO;
                                                UIViewController *loginVC = loginNav.cw_rootViewController;
                                                loginVC.hidesTopBarWhenPushed = YES;
                                                [self presentViewController:loginNav animated:YES completion:^{
                                                    [[XDSUserInfo shareUser] clearUserInfo];
                                                    self.tabBarController.selectedIndex = 0;
                                                }];
                                            }
                                        }];
}
#pragma mark - setter & getter

#pragma mark - memery 内存管理相关

@end
