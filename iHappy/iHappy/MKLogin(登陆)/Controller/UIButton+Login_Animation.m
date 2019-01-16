//
//  UIButton+Login_Animation.m
//  BiXuan
//
//  Created by ayi on 2018/10/9.
//  Copyright © 2018 碧斯诺兰. All rights reserved.
//

#import "UIButton+Login_Animation.h"

@implementation UIButton (Login_Animation)

- (void)addLoginTypeAnimation{
    
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    anima.duration = 0.35;
    anima.keyPath = @"bounds";
    anima.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.size.height, self.size.height)];
    anima.removedOnCompletion = NO;
    anima.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:anima forKey:nil];
    
    UIColor *bgColor = self.backgroundColor;
    objc_setAssociatedObject(self, @"bgColor", bgColor, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, @"oldWith", @(self.frame.size.width), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        UIView *emptyView = [[UIView alloc]init];
        emptyView.tag = 1000;
        UIImage *img1 = [UIImage imageNamed:@"ico_refresh_circle"];
        UIImage *img2 = [UIImage imageNamed:@"ico_refresh_logo"];
        UIImageView *animationImgv = [[UIImageView alloc] initWithImage:img1];
        UIImageView *logoImgv = [[UIImageView alloc] initWithImage:img2];
        
        [emptyView addSubview:animationImgv];
        [emptyView addSubview:logoImgv];
        
        animationImgv.frame = CGRectMake(0, 0, img1.size.width * 0.4, img1.size.height * 0.4);
        animationImgv.center = CGPointMake(self.frame.size.height/2, self.frame.size.height/2);
        logoImgv.frame = CGRectMake(0, 0, img2.size.width * 0.4, img2.size.height * 0.4);
        logoImgv.center = animationImgv.center;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
        animation.duration = 0.35;
        animation.cumulative = YES;
        animation.repeatCount = FLT_MAX;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        
        CABasicAnimation * scaleAnim = [CABasicAnimation animation];
        scaleAnim.keyPath = @"transform.scale";
        scaleAnim.fromValue = @1;
        scaleAnim.toValue = @1.2;
        scaleAnim.removedOnCompletion = NO;
        scaleAnim.fillMode = kCAFillModeForwards;
        scaleAnim.duration = 1;
        scaleAnim.repeatCount = FLT_MAX;
        scaleAnim.autoreverses = YES;
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[animation,scaleAnim];
        group.repeatCount = FLT_MAX;
        group.duration = FLT_MAX;
        [animationImgv.layer addAnimation:group forKey:@"animationimgv"];
        
        self.backgroundColor = UIColor.whiteColor;
        self.clipsToBounds = NO;
        [self addSubview:emptyView];
        emptyView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    });
    
}

- (void)btnremoveAllAnimations{
    
    self.backgroundColor = objc_getAssociatedObject(self, @"bgColor");
    [[self viewWithTag:1000] removeFromSuperview];
    NSNumber *width = objc_getAssociatedObject(self, @"oldWith");
    
    CABasicAnimation *anima = [CABasicAnimation animation];
    anima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    anima.duration = 0.35;
    anima.keyPath = @"bounds";
    anima.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, width.floatValue, self.size.height)];
    anima.removedOnCompletion = NO;
    anima.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:anima forKey:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.layer removeAllAnimations];
    });
}

@end
