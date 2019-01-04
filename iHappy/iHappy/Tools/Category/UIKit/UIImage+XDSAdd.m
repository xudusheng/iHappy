//
//  UIImage+XDSAdd.m
//  iHappy
//
//  Created by Hmily on 2019/1/4.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "UIImage+XDSAdd.h"

@implementation UIImage (XDSAdd)

+ (UIImage *)imageWithColor:(UIColor *)color inRect:(CGRect)rect {
    if (rect.size.width * rect.size.height == 0) {
        rect.size = CGSizeMake(10, 10);
    }
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


@end
