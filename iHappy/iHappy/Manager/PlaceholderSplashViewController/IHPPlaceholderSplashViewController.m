//
//  IHPPlaceholderSplashViewController.m
//  BiXuan
//
//  Created by Hmily on 2018/9/11.
//  Copyright © 2018年 碧斯诺兰. All rights reserved.
//

#import "IHPPlaceholderSplashViewController.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import "XDSPlaceholdSplashManager.h"
#import "UIAlertController+XDS.h"

#import "XDSSkipModel.h"

@interface IHPPlaceholderSplashViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIButton *timeCount;
@property (nonatomic, strong) UIButton *touchButton;//全屏按钮
@property (nonatomic,assign) NSTimeInterval timeInterval;//用于倒计时
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,strong) XDSSkipModel *launchAdModel;//启动广告

@end

@implementation IHPPlaceholderSplashViewController

NSInteger const kSplashVCWaitingTime = 2;
NSInteger const kLaunchAdShowTime = 3;

- (void)dealloc
{
    NSLog(@"IHPPlaceholderSplashViewController =====================");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // loading
    UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loading.hidesWhenStopped = YES;
    CGPoint center = self.view.center;
    center.y = center.y * 1.2;
    loading.center = center;
//    [self.view addSubview:loading];
    self.loadingView = loading;
    [_loadingView startAnimating];
    
    self.timeCount = ({
        CGRect frame = CGRectMake(ScreenWidth - 80, DEVICE_NAVBAR_HEIGHT-44, 60, 25);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        [button addTarget:self action:@selector(timeCountButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 12.5f;
        button.layer.masksToBounds = YES;
        [self.view addSubview:button];
        button;
    });
    self.timeInterval = kSplashVCWaitingTime;
    
    self.timeCount.hidden = YES;
    
    self.touchButton = ({
        CGRect frame = self.view.bounds;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button addTarget:self action:@selector(touchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    self.touchButton.hidden = YES;
    
    [self.view bringSubviewToFront:self.timeCount];
}

- (void)configLaunch {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleCountDown) userInfo:nil repeats:YES];
    [self.timer fire];
    [self handleUpdate];
}

- (void)timeCountButtonClick:(UIButton *)button {
    //收起页面
    [self hiddenSplashVC];
}
- (void)handleCountDown {
    if (self.timeInterval < 1) {
        [self timeCountButtonClick:nil];
    }
    [self.timeCount setTitle:[NSString stringWithFormat:@" 跳过 %ld ", (NSInteger)self.timeInterval] forState:UIControlStateNormal];
    self.timeInterval --;
}

- (void)touchButtonClick:(UIButton *)button {
    XDSSkipModel *launchModel = self.launchAdModel;

    if (launchModel.type_val.length) {
        [self hiddenSplashVC];
        UIViewController *vc = APP_DELEGATE.mainmeunVC.contentViewController;
        [vc showViewControllerWithSkipModel:launchModel];
    }
}

- (void)hiddenSplashVC {
    [self.timer invalidate];
    self.timer = nil;
    [[XDSPlaceholdSplashManager sharedManager] removePlaceholderSplashView];
    [[XDSPlaceholdSplashManager sharedManager] showHomePop];
}

- (void)handleUpdate{
    //    xds.update.title = 新版本提示
    //    xds.update.update = 立即更新
    //    xds.update.cancel = 稍后再说
    IHPForceUpdateModel *updateModel = [IHPConfigManager shareManager].forceUpdate;
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([updateModel.version compare:appVersion options:NSNumericSearch] == NSOrderedDescending) {
        [self.timer invalidate];
        self.timer = nil;
        //        IHP.update.content.force = 发现新版本，请前往下载最新版本！
        //        IHP.update.content = 发现新版本！是否升级？
        __weak typeof(self)weakself = self;
        [UIAlertController showAlertInViewController:self
                                           withTitle:(updateModel.isForce > 0)?XDSLocalizedString(@"xds.update.content.force", nil):XDSLocalizedString(@"xds.update.title", nil)
                                             message:updateModel.updateMessage.length?updateModel.updateMessage:XDSLocalizedString(@"xds.update.content", nil)
                                   cancelButtonTitle:(updateModel.isForce > 0)?nil:XDSLocalizedString(@"xds.update.cancel", nil)
                                   otherButtonTitles:@[XDSLocalizedString(@"xds.update.update", nil)]
                                            tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                                if (controller.cancelButtonIndex == buttonIndex) {
                                                    [[IHPConfigManager shareManager] downloadPopImage];
                                                }else {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateModel.ios_download_url]];
                                                }
                                                if (updateModel.isForce > 0) {
                                                    
                                                } else {
                                                    [weakself timeCountButtonClick:nil];
                                                }
                                            }];
    }else {
        [[IHPConfigManager shareManager] downloadPopImage];
        [self downloadLaunchImageAndShow];
    }
}


- (void)downloadLaunchImageAndShow {

    XDSSkipModel *launchModel =[IHPConfigManager shareManager].launch_pop;
    if (launchModel.pic.length < 1) {
        [self hiddenSplashVC];
        return;
    }
    
    self.launchAdModel = launchModel;
    if (launchModel.pic.length < 1) {
        return ;
    }

    __weak typeof(self)weakself = self;
//    imageU = launch.pic;
    [self.splashImageView sd_setImageWithURL:[NSURL URLWithString:launchModel.pic]
                            placeholderImage:[UIImage imageNamed:[self getCurrentLaunchImageName]]
                                   completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                       [weakself.loadingView stopAnimating];
                                       if (image) {
                                           weakself.timeInterval = kLaunchAdShowTime;
                                           [weakself.timeCount setTitle:[NSString stringWithFormat:@" 跳过 %ld ", (NSInteger)weakself.timeInterval] forState:UIControlStateNormal];
                                           weakself.timeCount.hidden = NO;
                                           weakself.touchButton.hidden = NO;
                                       }else {
                                           [weakself hiddenSplashVC];
                                       }
                                   }];
}

@end
