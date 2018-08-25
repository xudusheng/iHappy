//
//  XDSFullPlayerVC.m
//  iHappy
//
//  Created by Hmily on 2018/8/25.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSFullPlayerVC.h"

@interface XDSFullPlayerVC ()

@property (strong, nonatomic) UIView *playerContainerView;

@property (assign, nonatomic) CGRect oldFrame;
@property (assign, nonatomic) CGRect newFrame;


@end

@implementation XDSFullPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    self.oldFrame = [_playerContainerView convertRect:_playerContainerView.frame toView:self.view];
    [self.view addSubview:_playerView];
    self.playerView.frame = self.oldFrame;
    
//    CGFloat width = CGRectGetWidth(self.view.bounds);
//    CGRect newFrame = CGRectZero;
//    newFrame.size.width = width;
//    newFrame.size.height = _oldFrame.size.height/_oldFrame.size.width*width;
//    newFrame.origin.x = 0;
//    newFrame.origin.y = CGRectGetHeight(self.view.bounds)/2 - CGRectGetHeight(newFrame)/2;
    CGRect newFrame = self.view.bounds;
    self.newFrame = newFrame;
    [UIView animateWithDuration:0.5 animations:^{
        self.playerView.frame = self.newFrame;
        self.view.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        [self.playerView showButtons];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFullScreenNotification) name:kXDSPlayerViewNotificationNameFullScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)OrientationDidChange:(NSNotification *)notification {
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGSize fullSize = CGSizeMake(CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds));
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect frame = CGRectZero;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        self.playerView.transform = transform;
        if (orientation == UIDeviceOrientationLandscapeRight) {
            transform = CGAffineTransformMakeRotation(-M_PI/2);
        }else {
            transform = CGAffineTransformMakeRotation(M_PI/2);
        }
        
        frame.size = fullSize;
    }else if(orientation == UIDeviceOrientationPortrait) {
        self.playerView.transform = transform;
        transform = CGAffineTransformIdentity;
        frame = self.newFrame;
    }else {
        return;
    }
    
    self.playerView.frame = frame;
    self.playerView.center = self.view.center;
    [UIView animateWithDuration:0.5 animations:^{
        self.playerView.transform = transform;
    }] ;

}

- (void)handleFullScreenNotification {
    [self.playerView hideButtons];
    [UIView animateWithDuration:0.5 animations:^{
        self.playerView.frame = self.oldFrame;
        self.view.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self.playerContainerView addSubview:self.playerView];
        self.playerView.frame = self.playerContainerView.bounds;
        [self.playerView showButtons];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

- (void)setPlayerView:(XDSPlayerView *)playerView {
    _playerView = playerView;
    self.playerContainerView = _playerView.superview;
}
@end
