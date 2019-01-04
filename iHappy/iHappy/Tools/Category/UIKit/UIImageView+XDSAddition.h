//
//  UIImageView+XDSAddition.h
//  BiXuan
//
//  Created by bsnl on 2018/7/25.
//  Copyright © 2018年 BSNL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (XDSAddition)

@property(nonatomic, assign) NSInteger badgeValue;    // default is nil

- (void)bx_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable void(^)(UIImage *image))completedBlock ;
- (void)bx_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder ;
- (void)bx_setImageWithURL:(nullable NSURL *)url;

@end
