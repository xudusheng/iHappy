//
//  XDSZoomingScrollView.m
//  YBImageBrowserDemo
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "XDSZoomingScrollView.h"
#import "XDSGestureDetectingImageView.h"

@interface XDSZoomingScrollView ()<UIScrollViewDelegate, XDSGestureDetectingImageViewDelegate>

@property (nonatomic,strong) XDSGestureDetectingImageView *mImageView;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;//视频加载提示器

@end


@implementation XDSZoomingScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.zoomable = YES;
    self.backgroundColor = [UIColor blackColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.clipsToBounds = NO;
    self.mImageView = ({
        XDSGestureDetectingImageView *imageView = [[XDSGestureDetectingImageView alloc] initWithFrame:self.bounds];
        imageView.gDelegate = self;
        [self addSubview:imageView];
        imageView;
    });
    
    self.loadingView = ({
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [self addSubview:activityIndicator];
        //设置小菊花的frame
        activityIndicator.frame= self.bounds;
        //设置小菊花颜色
        activityIndicator.color = [UIColor redColor];
        //刚进入这个界面会显示控件，并且停止旋转也会显示，只是没有在转动而已，没有设置或者设置为YES的时候，刚进入页面不会显示
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator;
    });
}

- (void)displayImage {
    if (self.mediaModel.image) {
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        // Setup image
        self.mImageView.image = self.mediaModel.image;
        
        UIImage *image = self.mediaModel.image;
        // Setup image frame
        CGRect imageFrame;
        imageFrame.origin = CGPointZero;
        imageFrame.size = image.size;
        self.mImageView.frame = imageFrame;
        self.contentSize = imageFrame.size;
        [self setMaxMinZoomScalesForCurrentBounds];
    }else {
        
        [self.loadingView startAnimating];
        self.mImageView.image = self.mediaModel.placeholderImage;//设置缺省图
        
        [self.mediaModel downloadImage:self.mediaModel.mediaURL
                              progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                  NSLog(@"xxxx=%ld = %ld", receivedSize, expectedSize);
                              } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSURL * _Nullable imageURL) {
                                  NSLog(@"image = %@, error = %@", image, error);
                                  [self.loadingView stopAnimating];
                                  if (self.mediaModel.image) { //避免死循环
                                      [self displayImage];
                                  }
                              }];
    }
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _mImageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setupImageViewFrame];
}


#pragma mark - XDSGestureDetectingImageViewDelegate

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITapGestureRecognizer *)tap {
    [[NSNotificationCenter defaultCenter] postNotificationName:kXDSPlayerViewNotificationNameSingleTap object:nil];

}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITapGestureRecognizer *)tap {
    if (_zoomable) {
        [self handleDoubleTap:[tap locationInView:imageView]];
    }
}

#pragma mark - event
- (void)handleDoubleTap:(CGPoint)touchPoint {
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
    
    // Delay controls
//    [_photoBrowser hideControlsAfterDelay];
}


#pragma mark - Setup
- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail
    if (_mImageView.image == nil) return;
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _mImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    // If image is smaller than the screen then ensure we show it at
    // min scale of 1
    if (xScale > 1 && yScale > 1) {
        minScale = 1.0;
    }
    
    // Calculate Max
    CGFloat maxScale = 3;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Let them go a bit bigger on a bigger screen!
        maxScale = 4;
    }
    
    // Set
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = [self initialZoomScaleWithMinScale];

    // Reset position
    _mImageView.frame = CGRectMake(0, 0, _mImageView.frame.size.width, _mImageView.frame.size.height);
    [self setupImageViewFrame];
    [self setNeedsLayout];
}

- (void)setupImageViewFrame {
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _mImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_mImageView.frame, frameToCenter))
        _mImageView.frame = frameToCenter;
    
}

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_mImageView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _mImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}


- (void)setZoomable:(BOOL)zoomable {
    _zoomable = zoomable;
    //设置捏合手势
    self.pinchGestureRecognizer.enabled = _zoomable;
}
- (void)setMediaModel:(XDSMediaModel *)mediaModel {
    _mediaModel = mediaModel;
    self.mImageView.frame = self.bounds;
    self.mImageView.image = nil;
    [self displayImage];
}

@end
NSString *const kXDSPlayerViewNotificationNameSingleTap = @"XDSPlayerViewNotificationNameSingleTap";
