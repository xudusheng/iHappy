//
//  XDSGestureDetectingImageView.m
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSGestureDetectingImageView.h"

@implementation XDSGestureDetectingImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        [self addGesture];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        self.userInteractionEnabled = YES;
        [self addGesture];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
        self.userInteractionEnabled = YES;
        [self addGesture];
    }
    return self;
}


- (void)addGesture {
    UITapGestureRecognizer *tapSingle = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapSingle.numberOfTapsRequired = 1;
    UITapGestureRecognizer *tapDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tapDouble.numberOfTapsRequired = 2;
    [tapSingle requireGestureRecognizerToFail:tapDouble];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:tapSingle];
    [self addGestureRecognizer:tapDouble];
    [self addGestureRecognizer:longPress];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    if ([_gDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
        [_gDelegate imageView:self singleTapDetected:tap];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if ([_gDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
        [_gDelegate imageView:self doubleTapDetected:tap];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    if ([_gDelegate respondsToSelector:@selector(imageView:longPressDetected:)])
        [_gDelegate imageView:self longPressDetected:longPress];
}


//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    NSUInteger tapCount = touch.tapCount;
//    switch (tapCount) {
//        case 1:
//            [self handleSingleTap:touch];
//            break;
//        case 2:
//            [self handleDoubleTap:touch];
//            break;
//        case 3:
//            [self handleTripleTap:touch];
//            break;
//        default:
//            break;
//    }
//    [[self nextResponder] touchesEnded:touches withEvent:event];
//}
//
//- (void)handleSingleTap:(UITouch *)touch {
//    if ([_gDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
//        [_gDelegate imageView:self singleTapDetected:touch];
//}
//
//- (void)handleDoubleTap:(UITouch *)touch {
//    if ([_gDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
//        [_gDelegate imageView:self doubleTapDetected:touch];
//}
//
//- (void)handleTripleTap:(UITouch *)touch {
//    if ([_gDelegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
//        [_gDelegate imageView:self tripleTapDetected:touch];
//}



@end
