//
//  UIView+XDSAdd.h
//  Demo
//
//  Created by Hmily on 2018/10/23.
//  Copyright © 2018年 BX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XDSAdd)

// 如果@property在分类里面使用只会自动声明get,set方法,不会实现,并且不会帮你生成成员属性
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;

- (void)removeAllSubViews;

- (UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END