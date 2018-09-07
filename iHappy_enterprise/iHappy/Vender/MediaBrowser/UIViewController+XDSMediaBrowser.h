//
//  UIViewController+XDSMediaBrowser.h
//  iHappy
//
//  Created by Hmily on 2018/8/25.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (XDSMediaBrowser)


/**
 是否以透明的形式弹出视图

 @param viewControllerToPresent 目标视图
 @param translucent 是否以透明的形式
 @param flag 是否动画
 @param completion 回调函数
 */
- (void)presentViewController:(UIViewController *)viewControllerToPresent
                  translucent:(BOOL)translucent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion;

@end
