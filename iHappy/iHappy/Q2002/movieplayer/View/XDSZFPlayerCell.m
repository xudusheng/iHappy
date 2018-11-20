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

//    self.playerContainerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, XDS_PLAYER_SIZE.width, XDS_PLAYER_SIZE.height)];
//    self.playerContainerView.backgroundColor = [UIColor blackColor];

    [self configPlayer];
    
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
        [self.player.currentPlayerManager replay];
        //        [self.player playTheNext];
        //        if (!self.player.isLastAssetURL) {
        //            NSString *title = [NSString stringWithFormat:@"视频标题%zd",self.player.currentPlayIndex];
        //            [self.controlView showTitle:title coverURLString:kVideoCover fullScreenMode:ZFFullScreenModeLandscape];
        //        } else {
        //            [self.player stop];
        //        }
        //        [self.player stop];
    };
    
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"======开始播放了");
    };
    
    
    NSArray *assetURLs = @[[NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
                           [NSURL URLWithString:@"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"]];
    
    self.player.assetURLs = assetURLs;
    
    
    /// 以下设置滑出屏幕后不停止播放
    self.player.stopWhileNotVisible = NO;
    CGFloat margin = 20;
    CGFloat w = ZFPlayer_ScreenWidth/2;
    CGFloat h = w * 9/16;
    CGFloat x = ZFPlayer_ScreenWidth - w - margin;
    CGFloat y = ZFPlayer_ScreenHeight - h - margin;
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
    _playerSourceModel = playerSourceModel;
    if (_playerSourceModel.isWebUrl) {
        [self.containerView removeFromSuperview];
        if (!self.webView.superview) {
            [self.contentView addSubview:self.webView];
        }
        NSURL *weburl = [NSURL URLWithString:_playerSourceModel.videoUrl];
        NSURLRequest * request = [NSURLRequest requestWithURL:weburl];
        [_webView loadRequest:request];
    }else{
        [self.webView removeFromSuperview];
        if (![self.containerView superview]) {
            [self.contentView addSubview:self.containerView];
        }
        
        [self playWithZFPlayer];
    }
}
#pragma mark - private method 其他私有方法
- (void)playWithZFPlayer {
    UICollectionView *collectionView = (UICollectionView *)self.superview;
    NSIndexPath *indexPath = [collectionView indexPathForCell:self];
    self.player.assetURL = [NSURL URLWithString:_playerSourceModel.videoUrl];
    [self.player playTheIndexPath:indexPath scrollToTop:NO];
    [self.controlView showTitle:_playerSourceModel.title
                 coverURLString:kXDSPlayerCover
                 fullScreenMode:ZFFullScreenModeLandscape];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self playWithZFPlayer];
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
