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
#import "XDSPlayerBannerAdCell.h"
#import "XDSVideoSummaryCell.h"
#import "XDSPlayerSectionHeader.h"

#import "AppDelegate.h"
#import "XDSepisodeModel.h"
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
@property (nonatomic,assign)ZFPlayerState playerState;

//@property (strong, nonatomic) XDSPlayerView *playerView;
@property (strong, nonatomic) UIView *playerContentView;

@property (weak, nonatomic) UIButton *hiddenSummaryButton;//隐藏与展开简介按钮


@property (strong, nonatomic) UIWebView * webView;
@property (nonatomic,assign)BOOL didWebViewLoadOK;

@property (strong, nonatomic) XDSEpisodeModel *selectedEpisodeModel;

@end

@implementation IHPPlayerViewController

NSInteger const kPlaceholderSectionNumbers = 2;

- (void)dealloc
{
    [self.playerView removeObserver:self forKeyPath:@"state"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化广告
    [[XDSAdManager sharedManager] loadBannerAdFromViewController:self];
    
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
    
    
    [self.playerView addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
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
//    CGFloat width = DEVIECE_SCREEN_WIDTH;
////    layout.itemSize = CGSizeMake(width, 30);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 10;
//    layout.estimatedItemSize = CGSizeMake(width, 50);
    
    //创建collectionView 通过一个布局策略layout来创建
    self.mCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _mCollectionView.backgroundColor = [UIColor whiteColor];
    
    //代理设置
    _mCollectionView.delegate=self;
    _mCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.view addSubview:_mCollectionView];
    
    [_mCollectionView registerClass:[XDSEpisodeCell class] forCellWithReuseIdentifier:NSStringFromClass([XDSEpisodeCell class])];
    [_mCollectionView registerClass:[XDSPlayerBannerAdCell class] forCellWithReuseIdentifier:NSStringFromClass([XDSPlayerBannerAdCell class])];
    [_mCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XDSVideoSummaryCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([XDSVideoSummaryCell class])];
    [_mCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XDSPlayerSectionHeader class]) bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([XDSPlayerSectionHeader class])];
    
    [_mCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playerContentView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    
    
    
    [self fetchEpisodeList];
    
}

#pragma mark - 网络请求
- (void)fetchEpisodeList{
    NSString *url = @"http://134.175.54.80/ihappy/video/query.php";
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

//TODO: 请求播放页面
- (void)fetchPlayerInfo{
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:self.selectedEpisodeModel.href
                                         hudController:self
                                               showHUD:YES
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   [weakSelf dealPlayerData:htmlData];
                                               } failed:^(NSString *errorDescription) {
                                                   
                                               }];
    
}

- (void)fetchDeepPlayerInfo {
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:self.selectedEpisodeModel.player
                                         hudController:self
                                               showHUD:YES
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                   [weakSelf stripVideoSrc:htmlData];
                                               } failed:^(NSString *errorDescription) {
                                                   
                                               }];
}

//TODO:解析播放器代码
- (void)dealPlayerData:(NSData *)PlayerData{
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:PlayerData];
    TFHppleElement * iframe = [hpp searchWithXPathQuery:@"//iframe"].firstObject;
    if (iframe != nil) {
        NSString * playerSrc = [iframe objectForKey:@"src"];
        self.selectedEpisodeModel.player = playerSrc;
        [self fetchDeepPlayerInfo];
    }else {
        [self startPlay];
    }
}

//TODO:解析获取视频地址
- (void)stripVideoSrc:(NSData *)data{
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:data];
    TFHppleElement *video = [hpp searchWithXPathQuery:@"//video"].firstObject;
    TFHppleElement *iframe = [hpp searchWithXPathQuery:@"//iframe"].firstObject;
    
    NSString *videoUrl = video?[video objectForKey:@"src"]:@"";
    NSString *player_alter = iframe?[iframe objectForKey:@"src"]:@"";
    
    self.selectedEpisodeModel.video = videoUrl;
    self.selectedEpisodeModel.player_alter = player_alter;
    [self updatePlayerSource];
    [self startPlay];
    
}

- (void)updatePlayerSource {
    NSString *url = @"http://134.175.54.80/ihappy/update.php";
    NSString *ekey = self.selectedEpisodeModel.ekey?self.selectedEpisodeModel.ekey:@"";
    NSString *player = self.selectedEpisodeModel.player?self.selectedEpisodeModel.player:@"";

    NSString *player_alter = self.selectedEpisodeModel.player_alter?self.selectedEpisodeModel.player_alter:@"";
    NSString *video = self.selectedEpisodeModel.video?self.selectedEpisodeModel.video:@"";

    
    
    NSDictionary *params = @{
                             @"ekey":ekey,
                             @"player":player,
                             @"player_alter":player_alter,
                             @"video":video,
                             };

    [[[XDSHttpRequest alloc] init] GETWithURLString:url
                                           reqParam:params
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:NO
                                            success:^(BOOL success, NSDictionary *successResult) {

                                                
                                            } failed:^(NSString *errorDescription) {
                                            }];
}

#pragma mark - 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _episodeModelList.count + kPlaceholderSectionNumbers;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section < kPlaceholderSectionNumbers) {
        return 1;
    }
    return [_episodeModelList[section-kPlaceholderSectionNumbers] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < kPlaceholderSectionNumbers) {
        if (indexPath.section == 0) {
            XDSVideoSummaryCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSVideoSummaryCell class]) forIndexPath:indexPath];
            cell.summary = self.movieModel.summary;
            self.hiddenSummaryButton = cell.hiddenButton;
            return cell;
        }else {
            XDSPlayerBannerAdCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSPlayerBannerAdCell class]) forIndexPath:indexPath];
            return cell;
        }

    }else {
        XDSEpisodeCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSEpisodeCell class]) forIndexPath:indexPath];
        XDSEpisodeModel *episodeModel = _episodeModelList[indexPath.section - kPlaceholderSectionNumbers][indexPath.row];
        [cell setEpisodeModel:episodeModel isSelected:episodeModel == self.selectedEpisodeModel];
        return cell;
    }

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < kPlaceholderSectionNumbers) {
        if (indexPath.section == 0) {
            NSString *summary = self.movieModel.summary;
            CGSize size = [summary sizeWithFont:VIDEO_SUMMARY_FONT maxSize:VIDEO_SUMMARY_MAX_SIZE];
            if (size.height < 60) {
                CGSize itemSize = CGSizeMake(DEVIECE_SCREEN_WIDTH, VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY + size.height - VIDEO_SUMMARY_CELL_HIDDEN_BUTTON_HEIGHT);
                return itemSize;
            }else {
                CGSize itemSize = CGSizeMake(DEVIECE_SCREEN_WIDTH, VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY + 60);
                if (self.hiddenSummaryButton.selected) {//展开剧情简介
                    itemSize.height = VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY + size.height;
                }
                return itemSize;
            }

        }else {
            return CGSizeMake(DEVIECE_SCREEN_WIDTH, 50);

        }

    }else {
        XDSEpisodeModel *episodeModel = _episodeModelList[indexPath.section-kPlaceholderSectionNumbers][indexPath.row];
        NSString *title = episodeModel.title;
        CGSize size = [title sizeWithFont:EPISODE_CELL_FONT maxSize:EPISODE_CELL_MAX_SIZE];
        return CGSizeMake(size.width + EPISODE_CELL_HEIGHT_EXCEPT_CONTENT, EPISODE_CELL_HEIGHT);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInset = UIEdgeInsetsZero;
    if (section < kPlaceholderSectionNumbers) {
        edgeInset = UIEdgeInsetsZero;
    }else {
        edgeInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    return edgeInset;

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section < kPlaceholderSectionNumbers) {
        return CGSizeZero;
    }else {
        return CGSizeMake(DEVIECE_SCREEN_WIDTH, 25);
    }
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        XDSPlayerSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([XDSPlayerSectionHeader class]) forIndexPath:indexPath];
        if (indexPath.section == kPlaceholderSectionNumbers) {
            if (self.movieModel.name.length) {
                headerView.titleLabel.text = [NSString stringWithFormat:@"《%@》- 在线播放 - 如果不能播放先刷新试试", self.movieModel.name];
            }else {
                headerView.titleLabel.text = @"在线播放 - 如果不能播放先刷新试试";
            }
        }else {
            if (self.movieModel.name.length) {
                headerView.titleLabel.text = [NSString stringWithFormat:@"《%@》- @备用 - 在线播放 - 如果不能播放先刷新试试", self.movieModel.name];
            }else {
                headerView.titleLabel.text = @"@备用 - 在线播放 - 如果不能播放先刷新试试";
            }
        }

        return headerView;
    }
    return nil;

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < kPlaceholderSectionNumbers) {
        return;
    }
    XDSEpisodeModel *episodeModel = _episodeModelList[indexPath.section-kPlaceholderSectionNumbers][indexPath.row];
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
    BOOL hasNoPlayUrl = self.selectedEpisodeModel.player.length < 1 && self.selectedEpisodeModel.player_alter.length < 1 && self.selectedEpisodeModel.video.length < 1;
    
    if (self.selectedEpisodeModel.video.length || hasNoPlayUrl) {
    
//        hasNoPlayUrl = NO;
//    if (hasNoPlayUrl) {
        self.playerState = self.selectedEpisodeModel.video.length?ZFPlayerStateBuffering:ZFPlayerStateFailed;
        [self.webView removeFromSuperview];
        [self playWithZPPLayer:self.selectedEpisodeModel];
    }else {
        [self.playerView removeFromSuperview];
        if (!self.webView.superview) {
            [self.playerContentView addSubview:self.webView];
        }
        
        NSURL * url = [NSURL URLWithString:self.selectedEpisodeModel.player_alter.length?self.selectedEpisodeModel.player_alter:self.selectedEpisodeModel.player];
//        NSURL * url = [NSURL URLWithString:self.selectedEpisodeModel.player];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
        
    }
}
//http://api.tianxianle.com/jx/dapi.php?id=mKB1naKhqaajm7J3xstmjICBdoKggLWCjJ2bh6GMqqo000olYKGloH1qqZYO0O0O
//http://api.tianxianle.com/jx/sapi.php?id=mKB1naKhqaajm7J3xstmjICBdoKggLWCjJ2bh6GMqqo000olYKGloH1qqZYO0O0O

//- (void)playWithXDSPlayer:(NSString *)videoSrc {
//    XDSMediaModel *mediaModel = [[XDSMediaModel alloc] init];
//    mediaModel.mediaURL = [NSURL URLWithString:videoSrc];
//    mediaModel.mediaType = XDSMediaTypeVideo;
//    self.playerView.mediaModel = mediaModel;
//}

- (void)playWithZPPLayer:(XDSEpisodeModel *)episodeModel{
    
    NSURL *videoURL = [NSURL URLWithString:episodeModel.video];
    ZFPlayerModel *playerModel = [[ZFPlayerModel alloc] init];
    playerModel.title            = episodeModel.title;
    playerModel.videoURL         = videoURL;
    playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
    playerModel.fatherView       = self.playerContentView;
    [self.playerView playerControlView:nil playerModel:playerModel];
    [self.playerView resetToPlayNewVideo:playerModel];
    [self.playerView autoPlayTheVideo];
}

- (void)setSelectedEpisodeModel:(XDSEpisodeModel *)selectedEpisodeModel {
    _selectedEpisodeModel = selectedEpisodeModel;
    //    [self.playerView resetPlayer];
    //    [self fetchMoviePlayer];
    
    self.title = [NSString stringWithFormat:@"%@-%@", self.movieModel.name, self.selectedEpisodeModel.title];
    [self.mCollectionView cw_scrollToTopAnimated:YES];
    [self.mCollectionView reloadData];
    
    if (_selectedEpisodeModel.player.length) {
        if (_selectedEpisodeModel.player_alter.length || _selectedEpisodeModel.video.length) {
            [self startPlay];
        }else {
            [self fetchDeepPlayerInfo];
        }
    }else {
        [self fetchPlayerInfo];
    }
}


- (ZFPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[ZFPlayerView alloc] init];
        
        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *    ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
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

//监听播放器的播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSNumber *newState = change[NSKeyValueChangeNewKey];
    NSNumber *oldState = change[NSKeyValueChangeOldKey];
    
    NSLog(@"old = %@, new = %@ state = %@", oldState, newState, @(self.playerState));
//    ZFPlayerStateFailed,     // 播放失败
//    ZFPlayerStateBuffering,  // 缓冲中
//    ZFPlayerStatePlaying,    // 播放中
//    ZFPlayerStateStopped,    // 停止播放
//    ZFPlayerStatePause       // 暂停播放
    
    static NSInteger tryTimes = 0;//尝试刷新次数
    if (newState.integerValue == ZFPlayerStatePlaying) {
        self.playerState = ZFPlayerStatePlaying;
        tryTimes = 0;
    }
    
    if (self.playerState == ZFPlayerStateBuffering && newState.integerValue == ZFPlayerStateFailed) {
        if (tryTimes < 1) {
            [self fetchDeepPlayerInfo];
        }
        tryTimes ++;
    }
    
    
}
#pragma mark - 内存管理相关
- (void)movieDetailViewControllerDataInit{
    self.episodeModelList = [[NSMutableArray alloc] init];
    
}

@end
