//
//  XDSGestureDetectingImageView.h
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XDSGestureDetectingImageViewDelegate;

@interface XDSGestureDetectingImageView : UIImageView

@property (nonatomic, weak) id <XDSGestureDetectingImageViewDelegate> gDelegate;

@end

@protocol XDSGestureDetectingImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITapGestureRecognizer *)tap;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITapGestureRecognizer *)tap;
- (void)imageView:(UIImageView *)imageView longPressDetected:(UILongPressGestureRecognizer *)longPress;

@end
