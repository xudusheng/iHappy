//
//  UIButton+XDSAddition.h
//  MaiMkt
//
//  Created by ayi on 2018/5/15.
//  Copyright © 2018 ayi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (XDSAddition)

- (void)btnTitleLeftImg;
- (void)btnTitleUnderImgWithHeight:(CGFloat )height;

/**
 扩大按钮点击区域

 @param size 需要扩大多少传多少 (CGFloat)
 */
- (void)expandSize:(CGFloat)size;


- (void)bx_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state;
- (void)bx_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder;
- (void)bx_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable void(^)(UIImage *image))completedBlock;


@end
