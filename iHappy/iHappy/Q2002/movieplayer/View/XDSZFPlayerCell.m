//
//  XDSZFPlayerCell.m
//  iHappy
//
//  Created by Hmily on 2018/11/20.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "XDSZFPlayerCell.h"

#import "ZFUtilities.h"

#import "ZFAVPlayerManager.h"
#import "UIImageView+ZFCache.h"

static NSString *kXDSPlayerCover = @"https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";


@interface XDSZFPlayerCell () <UIWebViewDelegate>
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) UIView *zfContainerView;


@property (strong, nonatomic) UIWebView * webView;
@property (nonatomic,assign)BOOL didWebViewLoadOK;
@end

@implementation XDSZFPlayerCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createPlayerUI];
    }
    return self;
}

#pragma mark - UI相关
- (void)createPlayerUI {

    self.zfContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, XDS_PLAYER_SIZE.width, XDS_PLAYER_SIZE.height)];
    [self.zfContainerView addSubview:self.containerView];
    
    self.webView = [[UIWebView alloc]initWithFrame:self.containerView.bounds];
    self.webView.mediaPlaybackRequiresUserAction = YES;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor blackColor];
}
- (void)configPlayer {
    UICollectionView *collectionView = (UICollectionView *)self.superview;
    
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    // 播放器相关
    self.player = [ZFPlayerController playerWithScrollView:collectionView playerManager:playerManager containerViewTag:self.containerView.tag];
    self.player.containerView = self.containerView;
    self.player.controlView = self.controlView;
    
    self.player.shouldAutoPlay = YES;
    self.player.WWANAutoPlay = YES;
    
    // 1.0是完全消失的时候
    self.player.playerDisapperaPercent = 1.0;
    /// 0.0是刚开始显示的时候
    self.player.playerApperaPercent = 0.0;
    
    /// 设置退到后台继续播放
    self.player.pauseWhenAppResignActive = NO;
    
    @weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self.viewController setNeedsStatusBarAppearanceUpdate];
    };
    
    /// 播放完成
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        NSLog(@"======结束播放");
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"======开始播放了");
    };

    
    /// 以下设置滑出屏幕后不停止播放
    self.player.stopWhileNotVisible = NO;
    CGFloat margin = 20;
    CGFloat w = CGRectGetWidth(collectionView.frame)/2;
    CGFloat h = w * 9/16;
    CGFloat x = CGRectGetWidth(collectionView.frame) - w - margin;
    CGFloat y = CGRectGetHeight(collectionView.frame) - h - margin;
    self.player.smallFloatView.frame = CGRectMake(x, y, w, h);
    self.player.smallFloatView.parentView = self.viewController.view;
}

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.didWebViewLoadOK = YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.didWebViewLoadOK = NO;
}
#pragma mark - event response 事件响应处理
- (void)setPlayerSourceModel:(XDSPlayerSourceModel *)playerSourceModel {
    if (!self.player) {
        [self configPlayer];
    }
    _playerSourceModel = playerSourceModel;
    if (_playerSourceModel.isWebUrl) {
        [self.zfContainerView removeFromSuperview];
        if (!self.webView.superview) {
            [self.contentView addSubview:self.webView];
        }
        NSURL *weburl = [NSURL URLWithString:_playerSourceModel.videoUrl];
        NSURLRequest * request = [NSURLRequest requestWithURL:weburl];
        [_webView loadRequest:request];
    }else{
        [self.webView removeFromSuperview];
        if (![self.zfContainerView superview]) {
            [self.contentView addSubview:self.zfContainerView];
        }
        
        [self playWithZFPlayer];
    }
}
#pragma mark - private method 其他私有方法
- (void)playWithZFPlayer {
    UICollectionView *collectionView = (UICollectionView *)self.superview;
    NSIndexPath *indexPath = [collectionView indexPathForCell:self];
    self.player.assetURLs = @[[NSURL URLWithString:_playerSourceModel.videoUrl]];
    [self.player playTheIndexPath:indexPath scrollToTop:NO];
    [self.controlView showTitle:_playerSourceModel.title
                 coverURLString:kXDSPlayerCover
                 fullScreenMode:ZFFullScreenModeLandscape];
}

#pragma mark - setter & getter
- (UIImageView *)containerView {
    if (!_containerView) {
        _containerView = [UIImageView new];
        _containerView.tag = 100;
        self.containerView.frame = CGRectMake(0, 0, XDS_PLAYER_SIZE.width, XDS_PLAYER_SIZE.height);
        [_containerView setImageWithURLString:kXDSPlayerCover
                                  placeholder:[ZFUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:CGSizeMake(1, 1)]];
    }
    
    return _containerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
        _controlView.fastViewAnimated = YES;
    }
    return _controlView;
}
#pragma mark - memery 内存管理相关

@end
