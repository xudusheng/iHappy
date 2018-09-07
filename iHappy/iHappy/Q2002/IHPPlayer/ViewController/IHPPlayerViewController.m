//
//  IHPPlayerViewController.m
//  iHappy
//
//  Created by xudosom on 2017/5/5.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPPlayerViewController.h"
#import "IHYMovieInfoHeaderView.h"
#import "IHYMoviePlayButtonModel.h"
#import "XDSEpisodeCell.h"
#import "AppDelegate.h"
#import "XDSepisodeModel.h"
//#import "IHYMoviePlayerViewController.h"
#import "ZFPlayer.h"

#import "XDSPlayerView.h"
@interface IHPPlayerViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIWebViewDelegate
>
@property (strong, nonatomic) NSMutableArray<NSArray<XDSEpisodeModel*> *> *episodeModelList;
@property (strong, nonatomic) UICollectionView *mCollectionView;

@property (strong, nonatomic) ZFPlayerView *playerView;
//@property (strong, nonatomic) XDSPlayerView *playerView;
@property (strong, nonatomic) UIView *playerContentView;

@property (strong, nonatomic) UIWebView * webView;
@property (nonatomic,assign)BOOL didWebViewLoadOK;

@property (strong, nonatomic) XDSEpisodeModel *selectedEpisodeModel;

@end

@implementation IHPPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self movieDetailViewControllerDataInit];
    [self createMovieDetailViewControllerUI];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(begainFullScreen:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification" object:nil];// 播放器即将播放通知

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen:) name:@"UIMoviePlayerControllerDidExitFullscreenNotification" object:nil];// 播放器即将退出通知

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(begainFullScreen:) name:UIWindowDidBecomeVisibleNotification object:nil];//进入全屏
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen:) name:UIWindowDidBecomeHiddenNotification object:nil];//退出全屏

}
#pragma - mark  进入全屏
-(void)begainFullScreen:(NSNotification *)noti {
    if(!self.didWebViewLoadOK) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;

    [[UIDevice currentDevice] setValue:@"UIInterfaceOrientationLandscapeLeft" forKey:@"orientation"];

    //强制转屏：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeLeft;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


#pragma - mark 退出全屏
-(void)endFullScreen:(NSNotification *)noti {
    if(!self.didWebViewLoadOK) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;

    //强制归正：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}
#pragma mark - UI相关
- (void)createMovieDetailViewControllerUI{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.view.backgroundColor = [UIColor whiteColor];

    self.playerContentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, DEVIECE_SCREEN_WIDTH, IHYMovieDetailInfoViewInitialHeight)];
    self.playerContentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.playerContentView];
    
//    self.playerView = [[XDSPlayerView alloc] initWithFrame:self.playerContentView.bounds];
    NSURL *videoURL = [NSURL URLWithString:@""];
    ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
    playerModel.title            = self.selectedEpisodeModel.title;
    playerModel.videoURL         = videoURL;
    playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
    playerModel.fatherView       = self.playerContentView;
    
    
    
    
    
    
    
    self.webView = [[UIWebView alloc]initWithFrame:self.playerContentView.bounds];
    self.webView.mediaPlaybackRequiresUserAction = YES;
    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor blackColor];
    
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    CGFloat width = 60;
//    layout.itemSize = CGSizeMake(width, 30);
    layout.sectionInset = UIEdgeInsetsMake(20, 10, 20, 10);
    layout.minimumLineSpacing = 10;
    layout.estimatedItemSize = CGSizeMake(30, width);

    //创建collectionView 通过一个布局策略layout来创建
    self.mCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _mCollectionView.backgroundColor = [UIColor whiteColor];

    //代理设置
    _mCollectionView.delegate=self;
    _mCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.view addSubview:_mCollectionView];

    [_mCollectionView registerClass:[XDSEpisodeCell class] forCellWithReuseIdentifier:@"cell"];
    [_mCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerContentView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];



    [self fetchEpisodeList];

}

#pragma mark - 网络请求
- (void)fetchEpisodeList{
//    NSString *url = @"http://134.175.54.80/ihappy/video/query.php";
    NSString *url = @"http://172.16.8.81/ihappy/video/query.php";
    NSString *md5key = self.movieModel.md5key?self.movieModel.md5key:@"";
    NSDictionary *params = @{
                             @"md5key":md5key
                             };
    
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] GETWithURLString:url
                                           reqParam:params
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:YES
                                            success:^(BOOL success, NSDictionary *successResult) {
                                                XDSBaseResponseModel *responseModel = [XDSBaseResponseModel mj_objectWithKeyValues:successResult];
                                                for (NSArray *episodeList in responseModel.result) {
                                                    NSArray *episodeModelList = [XDSEpisodeModel mj_objectArrayWithKeyValuesArray:episodeList];
                                                    episodeModelList = [episodeModelList sortedArrayUsingComparator:^NSComparisonResult(XDSEpisodeModel* _Nonnull obj1, XDSEpisodeModel* _Nonnull obj2) {
                                                        return obj1.sort > obj2.sort;
                                                    }];
                                                    [weakSelf.episodeModelList addObject:episodeModelList];
                                                }
                                                if (weakSelf.episodeModelList.count && [weakSelf.episodeModelList.firstObject count]) {
                                                    weakSelf.selectedEpisodeModel = weakSelf.episodeModelList[0][0];
                                                }
                                                [weakSelf.mCollectionView reloadData];
                                            } failed:^(NSString *errorDescription) {
                                                
                                            }];
    
}

- (void)fetchPlayerInfo {
    static NSInteger reloadTimes = 0;
    NSString *url = @"http://172.16.8.81/ihappy/video/queryplayer.php";
    NSString *ekey = self.selectedEpisodeModel.ekey?self.selectedEpisodeModel.ekey:@"";
    NSDictionary *params = @{
                             @"ekey":ekey
                             };
    
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] GETWithURLString:url
                                           reqParam:params
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:YES
                                            success:^(BOOL success, NSDictionary *successResult) {
                                                NSString *player = successResult[@"player"];
                                                NSString *player_alter = successResult[@"player_alter"];
                                                if (!player.length && !player_alter.length) {
                                                    if (reloadTimes < 3) {
                                                        [self fetchPlayerInfo];
                                                        reloadTimes += 1;
                                                        return;
                                                    }
                                                    
                                                }else {
                                                    weakSelf.selectedEpisodeModel.player = player;
                                                    weakSelf.selectedEpisodeModel.player_alter = player_alter;
                                                }
                                                [weakSelf startPlay];
                                                
                                            } failed:^(NSString *errorDescription) {
                                            }];
}

#pragma mark - 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _episodeModelList.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_episodeModelList[section] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSEpisodeCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    XDSEpisodeModel *episodeModel = _episodeModelList[indexPath.section][indexPath.row];
    [cell setEpisodeModel:episodeModel isSelected:episodeModel == self.selectedEpisodeModel];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSEpisodeModel *episodeModel = _episodeModelList[indexPath.section][indexPath.row];
    self.selectedEpisodeModel = episodeModel;
}



-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.didWebViewLoadOK = YES;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.didWebViewLoadOK = NO;
}

#pragma mark - 事件处理
- (void)orientChange:(NSNotification *)notification {
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;

    NSLog(@"notification = %@", notification.userInfo);
    NSLog(@"orient = %@", @(orient));
}
#pragma mark - 其他私有方法
- (void)startPlay {
    
    BOOL hasNoPlayUrl = self.selectedEpisodeModel.player.length < 1 && self.selectedEpisodeModel.player_alter.length < 1 && self.selectedEpisodeModel.vedio.length < 1;

    if (self.selectedEpisodeModel.vedio.length || hasNoPlayUrl) {
        [self.webView removeFromSuperview];
        [self playWithZPPLayer:self.selectedEpisodeModel];
    }else {
        [self.playerView removeFromSuperview];
        if (!self.webView.superview) {
            [self.playerContentView addSubview:self.webView];
        }
        
        NSURL * url = [NSURL URLWithString:self.selectedEpisodeModel.player_alter.length?self.selectedEpisodeModel.player_alter:self.selectedEpisodeModel.player];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
        
    }


    self.title = [NSString stringWithFormat:@"%@-%@", self.movieModel.name, self.selectedEpisodeModel.title];
    [self.mCollectionView cw_scrollToTopAnimated:YES];
    [self.mCollectionView reloadData];
}

//- (void)playWithXDSPlayer:(NSString *)videoSrc {
//    XDSMediaModel *mediaModel = [[XDSMediaModel alloc] init];
//    mediaModel.mediaURL = [NSURL URLWithString:videoSrc];
//    mediaModel.mediaType = XDSMediaTypeVideo;
//    self.playerView.mediaModel = mediaModel;
//}

- (void)playWithZPPLayer:(XDSEpisodeModel *)episodeModel{

    NSURL *videoURL = [NSURL URLWithString:episodeModel.player];
    ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
    playerModel.title            = episodeModel.title;
    playerModel.videoURL         = videoURL;
    playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
    playerModel.fatherView       = self.playerContentView;
    [self.playerView playerControlView:nil playerModel:playerModel];
}

- (void)setSelectedEpisodeModel:(XDSEpisodeModel *)selectedEpisodeModel {
    _selectedEpisodeModel = selectedEpisodeModel;
    //    [self.playerView resetPlayer];
    //    [self fetchMoviePlayer];
    
    if (_selectedEpisodeModel.player.length) {
        [self startPlay];
    }else {
        [self fetchPlayerInfo];
    }
    [self.mCollectionView reloadData];
}


- (ZFPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[ZFPlayerView alloc] init];

        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
//        [_playerView playerControlView:nil playerModel:playerModel];

        // 设置代理
        //    playerView.delegate = self;

        //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResize;

        // 打开下载功能（默认没有这个功能）
        _playerView.hasDownload    = YES;

        // 打开预览图
        _playerView.hasPreviewView = YES;
    }
    return _playerView;

}
#pragma mark - 内存管理相关
- (void)movieDetailViewControllerDataInit{
    self.episodeModelList = [[NSMutableArray alloc] init];

}

@end
