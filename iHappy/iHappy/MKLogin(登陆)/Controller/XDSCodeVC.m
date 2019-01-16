//
//  XDSCodeVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/16.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSCodeVC.h"
#import "UIButton+Login_Animation.h"
#import "LoginViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
@interface XDSCodeVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *codeBgView;//存放验证码视图
@property (weak, nonatomic) IBOutlet UITextField *codeTextf;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;//提示语
@property (weak, nonatomic) IBOutlet UIButton *sendNewCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIView *customCodeView;
@property (nonatomic, strong) RACDisposable *disposable;

@end

@implementation XDSCodeVC

#pragma mark - UI相关

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法

#pragma mark - event response 事件响应处理

#pragma mark - private method 其他私有方法

#pragma mark - setter & getter

#pragma mark - memery 内存管理相关

- (void)dealloc{
    if (_disposable != nil) [_disposable dispose];
    _disposable= nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.codeTextf.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTextf.delegate = self;
    self.showNoNavShadow = YES;
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 25;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"nav_return_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    NSMutableAttributedString *tipsStr = [[NSMutableAttributedString alloc]initWithString:@"我们向您手机号发送了验证码" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    NSString *pstr = self.phoneStr.length > 7?[self.phoneStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]:self.phoneStr;
    NSMutableAttributedString *phoneStr = [[NSMutableAttributedString alloc]initWithString:pstr attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor darkGrayColor]}];
    [tipsStr insertAttributedString:phoneStr atIndex:4];
    self.tipsLab.attributedText = tipsStr;
    [self.sendNewCodeBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    @weakify(self);
    [self.codeTextf.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        if (((NSString *)x).length>=6) {
            self.loginBtn.enabled = YES;
            self.loginBtn.backgroundColor = [UIColor appThemeColor];
        }else{
            self.loginBtn.enabled = NO;
            self.loginBtn.backgroundColor = [UIColor colorWithHexString:@"#C8C7CC"];
        }
        [self resetTwinkleLine:6 andText:x];
        
    }];
    [self resetTimer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    [_customCodeView addGestureRecognizer:tap];
    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        @strongify(self);
        [self.codeTextf becomeFirstResponder];
    }];
    [self createTextfListInViewWithCount:6];
    [self.codeTextf becomeFirstResponder];
    
    self.loginBtn.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        RACSignal *sign = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [self.view endEditing:YES];
            NSMutableDictionary *param = @{
                                           @"region_code":self.region_code,
                                           @"mobile":self.phoneStr,
                                           @"sms_code":self.codeTextf.text,
                                           }.mutableCopy;

            [self.loginBtn addLoginTypeAnimation];
            @weakify(self);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [LoginViewModel loginMobileAPIActionWithParam:param andSuccess:^(id response) {
                    @strongify(self);
                    [self.loginBtn btnremoveAllAnimations];
                    [subscriber sendCompleted];
                    
                    NSDictionary *result = response;
                    if ([result[@"code"] integerValue] == 0) {
                        NSDictionary *user = result[@"data"][@"user"];
                        
                        XDSUserInfo *userModel = [XDSUserInfo shareUser];
                        userModel.head_img = user[@"head_img"];
                        userModel.mobile = user[@"mobile"];
                        userModel.nickname = user[@"nickname"];
                        [userModel saveUserInfo:userModel];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        
                    }else {
                        NSString *message = result[@"msg"];
                        [SVProgressHUD showInfoWithStatus:message];
                    }
                } andFail:^(NSString *errorDescription) {
                    [self.loginBtn btnremoveAllAnimations];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showInfoWithStatus:errorDescription];
                    });
                    [subscriber sendCompleted];
                }];
            });
            
            return nil;
        }];
        return sign;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)resetTimer{
    @weakify(self);
    __block NSInteger time = 61;
    self.disposable = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self);
        time --;
        NSString * title = time > 0 ? [NSString stringWithFormat:@"%lds后重新发送验证码",(long)time] : @"重新发送验证码";
        self.sendNewCodeBtn.titleLabel.text = title;
        [self.sendNewCodeBtn setTitle:title forState:UIControlStateNormal | UIControlStateDisabled];
        self.sendNewCodeBtn.enabled = (time==0)? YES : NO;
        if (time == 0) {
            [self.disposable dispose];
        }
    }];
}

- (void)backAction{
    
    @weakify(self);
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"是否确认返回"
                                         message:nil
                               cancelButtonTitle:XDSLocalizedString(@"xds.ui.cancel", nil)
                               otherButtonTitles:@[XDSLocalizedString(@"xds.ui.ok", nil)]
                                        tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                                            @strongify(self);
                                            if (controller.cancelButtonIndex != buttonIndex) {
                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                        }];
}


- (void)resetTextFieldText{
    for (int i = 0; i < 6; i++) {
        UIView *line = [_customCodeView viewWithTag:i+100];
        if (i != 0) {
            [self removeAnimationTwinkleWithView:line];
        }else{
            [self addAnimationTwinkleWithView:line];
        }
        UILabel *lab = [_customCodeView viewWithTag:i + 1000];
        lab.text = @"";
    }
}

- (IBAction)sendCodeAction:(UIButton *)sender {
    self.codeTextf.text = @"";
    [self resetTextFieldText];
    
    if (![self.disposable isDisposed]) {
        return;
    }
    @weakify(self);
    sender.enabled = NO;
    [LoginViewModel smsSendAPIActionWithParam:@{
                                                @"region_code":self.region_code,
                                                @"mobile":self.phoneStr
                                                } andSuccess:^(id response) {
                                                    @strongify(self);
                                                    [self resetTimer];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [SVProgressHUD showInfoWithStatus:@"发送成功"];
                                                        [SVProgressHUD dismissWithDelay:1.35];
                                                    });
                                                } andFail:^(NSString *errorDesction) {
                                                    sender.enabled = YES;
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [SVProgressHUD showErrorWithStatus:errorDesction];
                                                        [SVProgressHUD dismissWithDelay:1.35];
                                                    });
                                                }];
    
}

- (void)createTextfListInViewWithCount:(NSInteger )count{
    [_customCodeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat width = 40;
    CGFloat space = (DEVIECE_SCREEN_WIDTH - 60 - count * 40)/(count - 1);
    
    for (int i = 0; i < count; i++) {

        UILabel *textLab = [[UILabel alloc]init];
        textLab.font = [UIFont systemFontOfSize:29];
        textLab.textColor = self.codeTextf.textColor;
        textLab.textAlignment = NSTextAlignmentCenter;
        textLab.layer.masksToBounds = YES;
        
        textLab.tag = i + 1000;
        UIView *lineView = [[UIView alloc]init];lineView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
        
        textLab.frame = CGRectMake(30 + i*(width+space), 0, width, width);
        lineView.frame = CGRectMake(CGRectGetMinX(textLab.frame), CGRectGetMaxY(textLab.frame) + 14, CGRectGetWidth(textLab.frame), 1);
        lineView.tag = i + 100;
        
        [[RACObserve(textLab, text) takeUntil:textLab.rac_willDeallocSignal]subscribeNext:^(id  _Nullable x) {
            if (((NSString *)x).length <= 0) {
                lineView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
            }else{
                lineView.backgroundColor = [UIColor appThemeColor];
            }
        }];
        
        [_customCodeView addSubview:textLab];
        [_customCodeView addSubview:lineView];
        //        [_customCodeView addSubview:textfUpView];
        //
        //        if (i == 0) {
        //            [textf becomeFirstResponder];
        //        }
    }
    
}
//
///**
// UITextFieldDelegate
//
// */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""]) {
        UILabel *lab = [_customCodeView viewWithTag:self.codeTextf.text.length -1 + 1000];
        lab.text = @"";
        return YES;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.codeTextf.text.length == 6) {
            [self.view endEditing:YES];
            [self.loginBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
        }
    });
    
    if (self.codeTextf.text.length >= 6) {
        return NO;
    }
    UILabel *lab = [_customCodeView viewWithTag:self.codeTextf.text.length + 1000];
    lab.text = string;
    return YES;
}

- (void)resetTwinkleLine:(NSInteger )count andText:(NSString *)str{
    for (int i = 0; i < count; i++) {
        UIView *line = [_customCodeView viewWithTag:i+100];
        [self removeAnimationTwinkleWithView:line];
    }
    if (str.length < count) {
        UIView *line = [_customCodeView viewWithTag:str.length + 100];
        [self addAnimationTwinkleWithView:line];
    }
}

- (void)addAnimationTwinkleWithView:(UIView *)view{
    if (view == nil) {
        return;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//
    animation.autoreverses = YES;
    animation.duration = 0.5;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];//
    [view.layer addAnimation:animation forKey:@"twinkle"];
}
- (void)removeAnimationTwinkleWithView:(UIView *)view{
    [view.layer removeAllAnimations];
}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
//    return YES;
//}
@end
