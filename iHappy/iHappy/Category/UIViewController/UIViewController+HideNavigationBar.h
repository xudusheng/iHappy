//
//  UIViewController+HideNavigationBar.h
//  XDSSwift
//
//  Created by zhengda on 16/9/9.
//  Copyright © 2016年 zhengda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HideNavigationBar)

@property (assign, nonatomic)BOOL hidesTopBarWhenPushed;

///获取安全区顶部高度
- (CGFloat)getSafeAreaTop;

///获取安全区底部高度
- (CGFloat)getSafeAreaBottom;

@end
