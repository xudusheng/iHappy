//
//  XDSRootViewController.m
//  Jurongbao
//
//  Created by wangrongchao on 15/10/17.
//  Copyright © 2015年 truly. All rights reserved.
//

#import "XDSBaseViewController.h"

@interface XDSBaseViewController ()
@property (nonatomic, strong) UIImage *shadowImg;

@end

@implementation XDSBaseViewController
- (void)dealloc
{
    NSLog(@"=============%@", NSStringFromClass(self.class));
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"nav_return_gray"] style:UIBarButtonItemStyleDone target:self action:@selector(popBack:)];
    barButtonItem.tintColor = [UIColor whiteColor];
    barButtonItem.tintColor = [UIColor brownColor];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = self.shadowImg;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark - UI相关

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法

#pragma mark - event response 事件响应处理
- (void)popBack:(UIBarButtonItem *)barButtonItem{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if(self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}
#pragma mark - private method 其他私有方法

#pragma mark - setter & getter
- (void)setShowNoNavShadow:(BOOL)showNoNavShadow{
    _showNoNavShadow = showNoNavShadow;
    if (_showNoNavShadow) {
        self.shadowImg = [[UIImage alloc]init];
    }else{
        self.shadowImg = [UIImage imageWithColor:UIColor.clearColor inRect:CGRectMake(0, 0, 100, 60)];
    }
    self.navigationController.navigationBar.shadowImage = self.shadowImg;
}

#pragma mark - memery 内存管理相关



@end
