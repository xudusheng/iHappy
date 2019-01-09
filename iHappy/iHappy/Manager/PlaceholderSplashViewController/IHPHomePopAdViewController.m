//
//  IHPHomePopAdViewController.m
//  BiXuan
//
//  Created by Hmily on 2018/9/12.
//  Copyright © 2018年 碧斯诺兰. All rights reserved.
//

#import "IHPHomePopAdViewController.h"
@interface IHPHomePopAdViewController ()
@property (nonatomic,strong) UIButton *imageButton;
@property (nonatomic,strong) UIButton *closeButton;

@end

@implementation IHPHomePopAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];

    CGFloat maxWidth = ScreenWidth - 80;
    CGFloat maxHeight = maxWidth * 720 / 580.f;
    CGSize size = CGSizeMake(maxWidth, maxHeight);
    UIImage *popImage = [IHPConfigManager shareManager].popImage;
    self.imageButton = ({
        CGRect frame = {CGPointZero, size};
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button setImage:popImage forState:UIControlStateNormal];
        [button setImage:popImage forState:UIControlStateDisabled];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });

    XDSSkipModel *popModel = [IHPConfigManager shareManager].home_pop;
    if (popModel.type_val.length < 1) {
        self.imageButton.enabled = NO;
    }
    
    UIImage *closeImage = [UIImage imageNamed:@"icon_pop_close"];
    self.closeButton = ({
        CGRect frame = {CGPointZero, closeImage.size};
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        [button setImage:closeImage forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    CGPoint center = self.view.center;
    center.y = center.y - 30;
    self.imageButton.center = center;
    
    center.y = CGRectGetMaxY(self.imageButton.frame) + 30 + closeImage.size.height/2;
    self.closeButton.center = center;
}

- (void)imageButtonClick:(UIButton *)imageButton {
    XDSSkipModel *popModel = [IHPConfigManager shareManager].home_pop;
    [IHPConfigManager shareManager].popImage = nil;
    [self dismissViewControllerAnimated:NO completion:^{
        UIViewController *vc = APP_DELEGATE.mainmeunVC.contentViewController;
        [vc showViewControllerWithSkipModel:popModel];
    }];
}

- (void)closeButtonClick:(UIButton *)imageButton {
    [IHPConfigManager shareManager].popImage = nil;
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
