//
//  XDSLoginVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSLoginVC.h"

@interface XDSLoginVC ()

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet UIButton *phoneLoginBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *returnBackButtonTop;

@end

@implementation XDSLoginVC
- (void)awakeFromNib {
    [super awakeFromNib];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configLoginUI];
}
#pragma mark - UI相关
- (void)configLoginUI {

    self.showNoNavShadow = YES;
    [self.phoneLoginBtn setTitleColor:[UIColor appThemeColor] forState:UIControlStateNormal];
    self.phoneLoginBtn.layer.cornerRadius = 25;
    self.phoneLoginBtn.layer.masksToBounds = YES;
    self.phoneLoginBtn.layer.borderColor = [UIColor appThemeColor].CGColor;
    self.phoneLoginBtn.layer.borderWidth = .5f;
    
    self.logoImageView.layer.cornerRadius = 15;
    self.logoImageView.layer.masksToBounds = YES;
    
    self.returnBackButtonTop.constant = DEVICE_NAVBAR_HEIGHT - 44;
    
}
#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法

#pragma mark - event response 事件响应处理

- (IBAction)goPhoneVC:(id)sender {
    [self performSegueWithIdentifier:@"gotoPhoneLogin" sender:nil];
}
- (IBAction)returnButtonClick:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - private method 其他私有方法

#pragma mark - setter & getter

#pragma mark - memery 内存管理相关
@end
