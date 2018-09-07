//
//  XDSMediaBrowserCell.m
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMediaBrowserCell.h"

//#import <Masonry/Masonry.h>

@interface XDSMediaBrowserCell ()

@property (nonatomic,strong) XDSZoomingScrollView *mScrollView;
@property (nonatomic,strong) XDSPlayerView *mPlayerView;

@end


@implementation XDSMediaBrowserCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.mScrollView = ({
        XDSZoomingScrollView *scrollView = [[XDSZoomingScrollView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:scrollView];
        scrollView;
    });
    
    self.mPlayerView = ({
        XDSPlayerView *playerView = [[XDSPlayerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds))];
        [self.contentView addSubview:playerView];
        playerView;
    });
}

- (void)resetZoomScale {
    self.mScrollView.zoomScale = self.mScrollView.minimumZoomScale;
}

- (void)setZoomable:(BOOL)zoomable {
    _zoomable = zoomable;
    self.mScrollView.zoomable = zoomable;
    if (!_zoomable) {
        [self resetZoomScale];
    }
    
}
- (void)setMediaModel:(XDSMediaModel *)mediaModel {
    _mediaModel = mediaModel;
    if (_mediaModel.mediaType == XDSMediaTypeVideo) {
        self.mScrollView.hidden = YES;
        self.mPlayerView.hidden = NO;
        self.mPlayerView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        self.mPlayerView.mediaModel = _mediaModel;
    }else {
        self.mScrollView.hidden = NO;
        self.mPlayerView.hidden = YES;
        self.mScrollView.frame = self.bounds;
        self.mScrollView.mediaModel = _mediaModel;
    }
}

- (void)cellWillDisappear {
    if (self.mediaModel.mediaType == XDSMediaTypeVideo) {
        [self.mPlayerView playerDisappear];
    }
}
- (void)cellWillAppear {
    if (self.mediaModel.mediaType == XDSMediaTypeVideo) {
        [self.mPlayerView playerAppear];
    }
}

- (void)dealloc {
    [self.mPlayerView destroyPlayer];
}
@end
