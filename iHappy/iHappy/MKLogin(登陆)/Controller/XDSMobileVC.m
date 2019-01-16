//
//  XDSMobileVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSMobileVC.h"
#import "UIButton+Login_Animation.h"

#import "LoginViewModel.h"

#import "XDSGetVerificationCodeButton.h"

#import "XDSCodeVC.h"
@interface XDSMobileVC ()
@property (weak, nonatomic) IBOutlet UILabel *areaCodeNumberLab;//区号
@property (weak, nonatomic) IBOutlet UITextField *phoneTextf;//手机号码
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;//下一步
@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@property (weak, nonatomic) IBOutlet XDSGetVerificationCodeButton *getCodeButton;//获取验证码

@end

@implementation XDSMobileVC
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configMobileVCUI];
}
#pragma mark - UI相关
- (void)configMobileVCUI {
    self.showNoNavShadow = YES;
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.layer.cornerRadius = 25;
    self.nextBtn.layer.masksToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textValueDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法

#pragma mark - event response 事件响应处理
- (IBAction)nextAction:(UIButton *)sender {

    [self.view endEditing:YES];

    if ([self.areaCodeNumberLab.text isEqualToString:@"+86"]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^1[0-9]{10}$"];
        if (![predicate evaluateWithObject:self.phoneTextf.text]) {
            [SVProgressHUD showInfoWithStatus:@"请输入正确手机号码"];
            return;
        }
    }
    
    sender.enabled = NO;
    [sender addLoginTypeAnimation];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [LoginViewModel smsSendAPIActionWithParam:@{
                                                    @"region_code":self.areaCodeNumberLab.text,
                                                    @"mobile":self.phoneTextf.text.trimString}
                                       andSuccess:^(id response) {
                                           NSDictionary *result = response;

                                           sender.enabled = YES;
                                           [sender btnremoveAllAnimations];
                                           
                                           if ([result[@"code"] integerValue] == 0) {
                                               XDSCodeVC *codeVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"XDSCodeVC"];
                                               codeVC.phoneStr = self.phoneTextf.text.trimString;
                                               codeVC.region_code = @"+86";
                                               [self.navigationController pushViewController:codeVC animated:YES];
                                           }else {
                                               NSString *message = result[@"msg"];
                                               [SVProgressHUD showInfoWithStatus:message];
                                           }

                                           
                                       } andFail:^(NSString *errorDescription) {
                                           [sender btnremoveAllAnimations];
                                           sender.enabled = YES;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [SVProgressHUD showInfoWithStatus:errorDescription];
                                           });
                                       }];
    });
}

- (void)textValueDidChange {
    if (self.phoneTextf.text.length > 0) {
        self.nextBtn.userInteractionEnabled = YES;
        self.nextBtn.backgroundColor = [UIColor appThemeColor];
    }else {
        self.nextBtn.userInteractionEnabled = NO;
        self.nextBtn.backgroundColor = [UIColor colorWithHexString:@"#C8C7CC"];
    }
}
#pragma mark - private method 其他私有方法

#pragma mark - setter & getter

#pragma mark - memery 内存管理相关

@end
