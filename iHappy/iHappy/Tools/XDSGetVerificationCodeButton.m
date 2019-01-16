//
//  XDSGetVerificationCodeButton.m
//  Laomoney
//
//  Created by zhengda on 15/12/21.
//  Copyright © 2015年 zhengda. All rights reserved.
//

#import "XDSGetVerificationCodeButton.h"
@interface XDSGetVerificationCodeButton(){
    NSTimer * _countDownTimer;
    NSInteger _countDownTimeSeconds;
}
@property (strong, nonatomic)NSString * getVerificationCodeButtonTitle;
@property (strong, nonatomic)UIColor * enableStateTitleColor;
@property (strong, nonatomic)UIColor * disableStateTitleColor;
@property (strong, nonatomic)UIColor * enableStateBackgroundColor;
@property (strong, nonatomic)UIColor * disableStateBackgroundColor;
@property (assign, nonatomic)NSInteger countDownTotalTime;
@property (copy, nonatomic) void(^getVerificationCodeButtonClick)(void);
@property (copy, nonatomic) void(^countDownFinished)(void);

@end

@implementation XDSGetVerificationCodeButton
- (void)getVerificationCodeButtonWithTitle:(NSString *)title
                     enableStateTitleColor:(UIColor *)enableStateTitleColor
                    disableStateTitleColor:(UIColor *)disableStateTitleColor
                enableStateBackgroundColor:(UIColor *)enableStateBackgroundColor
               disableStateBackgroundColor:(UIColor *)disableStateBackgroundColor
                             countDownTime:(NSInteger)time
                               buttonClick:(void(^)(void))click
                         countDownFinished:(void (^)(void))countDownFinished {
    self.exclusiveTouch = YES;
    self.showsTouchWhenHighlighted = YES;
    self.countDownTotalTime = time;
    self.getVerificationCodeButtonTitle = title;
    self.enableStateTitleColor = enableStateTitleColor;
    self.disableStateTitleColor = disableStateTitleColor;
    self.enableStateBackgroundColor = enableStateBackgroundColor;
    self.disableStateBackgroundColor = disableStateBackgroundColor;
    self.countDownFinished = countDownFinished;
    self.getVerificationCodeButtonClick = click;
    [self setBackgroundColor:enableStateBackgroundColor];
    [self setTitle:_getVerificationCodeButtonTitle forState:UIControlStateNormal];
    [self setTitleColor:_enableStateTitleColor forState:UIControlStateNormal];
    [self setTitleColor:_disableStateTitleColor forState:UIControlStateDisabled];
    [self addTarget:self action:@selector(getVerificationCodeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)getVerificationCodeButtonClick:(UIButton *)button{
    NSLog(@"countDownTotalTime = %zd", _countDownTotalTime);
    if (self.getVerificationCodeButtonClick) {
        self.getVerificationCodeButtonClick();
    }
}

- (void)countDownStart{
    _countDownTimeSeconds = _countDownTotalTime;
    NSString *title = [NSString stringWithFormat:@"  %ld秒后重发  ", (long)_countDownTimeSeconds--];
    [self setTitle:title  forState:UIControlStateDisabled];
    _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    [self setBackgroundColor:_disableStateBackgroundColor];
    self.enabled = NO;
}

- (void)countDownStop{
    [self invalidTimer];
}
#pragma mark - 其他私有方法
-(void)onTimer{
    NSString *title = [NSString stringWithFormat:@"  %ld秒后重发  ", (long)_countDownTimeSeconds--];
    [self setTitle:title  forState:UIControlStateDisabled];
    if (_countDownTimeSeconds < 0){
        [self invalidTimer];
        if (_countDownFinished) {
            _countDownFinished();
        }
    }
}
- (void)invalidTimer{
    [_countDownTimer invalidate];
    _countDownTimer = nil;
    self.enabled = YES;
    [self setBackgroundColor:_enableStateBackgroundColor];
    
}@end
