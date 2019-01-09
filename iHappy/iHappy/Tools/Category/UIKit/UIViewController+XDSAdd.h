//
//  UIViewController+XDSAdd.h
//  Demo
//
//  Created by Hmily on 2018/10/23.
//  Copyright © 2018年 BX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSSkipModel.h"

//type 页面跳转类型 类型，0h5
typedef NS_ENUM(NSInteger, XDSPageRedirectType) {
    XDSPageRedirectTypeHTML = 0,//HTML
};

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (XDSAdd)

/**
 背景透明的形式显示present
 @param viewControllerToPresent 目标控制器
 @param flag 是否动画
 @param inRransparentForm 是否透明
 @param completion 回调
 */
- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated: (BOOL)flag
            inRransparentForm:(BOOL)inRransparentForm
                   completion:(void (^ __nullable)(void))completion NS_AVAILABLE_IOS(5_0);


/**
 根据type进行页面跳转
 
 @param title 标题
 @param type 跳转类型
 @param value 传值
 @param from_type 来源
 */
- (void)showViewControllerWithSkipModel:(XDSSkipModel *)skipModel;

@end

NS_ASSUME_NONNULL_END
