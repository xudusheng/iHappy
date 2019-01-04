//
//  UISearchBar+XDSAdd.h
//  Demo
//
//  Created by Hmily on 2018/10/30.
//  Copyright © 2018年 dusheng.xu All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UISearchBar (XDSAdd)

- (void)insertBGColor:(UIColor *)backgroundColor;
- (UITextField *)searchTextField;
- (void)setPlaceholderColor:(UIColor *)color;
- (void)setSearchIcon:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
