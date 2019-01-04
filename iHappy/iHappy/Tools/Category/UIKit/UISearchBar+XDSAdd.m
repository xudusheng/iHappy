//
//  UISearchBar+XDSAdd.m
//  Demo
//
//  Created by Hmily on 2018/10/30.
//  Copyright © 2018年 dusheng.xu All rights reserved.
//

#import "UISearchBar+XDSAdd.h"

@implementation UISearchBar (XDSAdd)

- (void)insertBGColor:(UIColor *)backgroundColor{
    static NSInteger customBgTag = 999;
    UIView *realView = [[self subviews] firstObject];
    [[realView subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == customBgTag) {
            [obj removeFromSuperview];
        }
    }];
    if (backgroundColor) {
        UIImageView *customBg = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:backgroundColor inRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + 20)]];
        [customBg setY:-20];
        customBg.tag = customBgTag;
        [[[self subviews] firstObject] insertSubview:customBg atIndex:1];
    }
}

- (UITextField *)eaTextField{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIView *candidateView, NSDictionary *bindings) {
        return [candidateView isMemberOfClass:NSClassFromString(@"UISearchBarTextField")];
    }];
    return [self.subviews.firstObject.subviews filteredArrayUsingPredicate:predicate].lastObject;
}
- (void)setPlaceholderColor:(UIColor *)color{
    [[self valueForKey:@"_searchField"] setValue:[UIColor darkGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}
- (void)setSearchIcon:(UIImage *)image{
    [self setImage:image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}

@end
