//
//  XDSGetVerificationCodeButton.h
//  Laomoney
//
//  Created by zhengda on 15/12/21.
//  Copyright © 2015年 zhengda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDSGetVerificationCodeButton : UIButton

- (void)getVerificationCodeButtonWithTitle:(NSString *)title
                     enableStateTitleColor:(UIColor *)enableStateTitleColor
                    disableStateTitleColor:(UIColor *)disableStateTitleColor
                enableStateBackgroundColor:(UIColor *)enableStateBackgroundColor
               disableStateBackgroundColor:(UIColor *)disableStateBackgroundColor
                             countDownTime:(NSInteger)time
                               buttonClick:(void(^)(void))click
                         countDownFinished:(void (^)(void))countDownFinished;

- (void)countDownStart;
- (void)countDownStop;
@end
