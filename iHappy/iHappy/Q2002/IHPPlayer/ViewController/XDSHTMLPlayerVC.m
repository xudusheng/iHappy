//
//  XDSHTMLPlayerVC.m
//  iHappy
//
//  Created by xudosom on 2017/5/5.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "XDSHTMLPlayerVC.h"
#import "IHYMovieDetailInfoView.h"
#import "IHYMoviePlayButtonModel.h"
#import "IHYMoviePlayButtonCell.h"

#import "XDSPlayerBannerAdCell.h"
#import "XDSVideoSummaryCell.h"
#import "XDSPlayerSectionHeader.h"
#import "XDSPlayerDisclaimerView.h"

#import "XDSEpisodeCell.h"

#import "AppDelegate.h"
#import "IHYMovieModel.h"


#import "ZFUtilities.h"
#import "ZFPlayerControlView.h"
#import "ZFAVPlayerManager.h"
#import "UIImageView+ZFCache.h"


#import "XDSZFPlayerCell.h"

@interface XDSHTMLPlayerVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIWebViewDelegate
>

@property (strong, nonatomic) NSMutableArray<NSDictionary *> * movieButtonList;
@property (strong, nonatomic) UICollectionView * moviedetailCollectionView;

@property (nonatomic, weak) XDSZFPlayerCell *playerContainer;

@property (strong, nonatomic) IHYMoviePlayButtonModel *selectedMovieModel;

@property (strong, nonatomic) IHYMovieModel *movieModel;

@property (weak, nonatomic) UIButton *hiddenSummaryButton;//隐藏与展开简介按钮

@end
NSInteger const kHTMLPlayerSection = 0;
NSInteger const kHTMLAdSection = 1;
NSInteger const kHTMLSummarySection = 2;

NSInteger const kHTMLPlaceholderSectionNumbers = 3;

@implementation XDSHTMLPlayerVC
- (void)dealloc{
    NSLog(@"%@ ==> dealloc", [self class]);
    [self.playerContainer.player stopCurrentPlayingCell];
    self.moviedetailCollectionView.delegate = nil;
    self.moviedetailCollectionView = nil;
    [[XDSAdManager sharedManager] removeBannerAd];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化广告
    [[XDSAdManager sharedManager] loadBannerAdFromViewController:self];
    
    [self movieDetailViewControllerDataInit];
    [self createMovieDetailViewControllerUI];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        self.moviedetailCollectionView.delegate = nil;
        [self.playerContainer.player stopCurrentPlayingCell];
    }
}
#pragma mark - UI相关
- (void)createMovieDetailViewControllerUI{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.view.backgroundColor = [UIColor whiteColor];

    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 10;

    //创建collectionView 通过一个布局策略layout来创建
    self.moviedetailCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _moviedetailCollectionView.backgroundColor = [UIColor whiteColor];

    //代理设置
    _moviedetailCollectionView.delegate=self;
    _moviedetailCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.view addSubview:_moviedetailCollectionView];

    [_moviedetailCollectionView registerClass:[XDSZFPlayerCell class] forCellWithReuseIdentifier:NSStringFromClass([XDSZFPlayerCell class])];
    [_moviedetailCollectionView registerClass:[IHYMoviePlayButtonCell class] forCellWithReuseIdentifier:NSStringFromClass([IHYMoviePlayButtonCell class])];
    [_moviedetailCollectionView registerClass:[XDSPlayerBannerAdCell class] forCellWithReuseIdentifier:NSStringFromClass([XDSPlayerBannerAdCell class])];
    [_moviedetailCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XDSVideoSummaryCell class]) bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:NSStringFromClass([XDSVideoSummaryCell class])];
    [_moviedetailCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XDSPlayerSectionHeader class]) bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([XDSPlayerSectionHeader class])];

    [_moviedetailCollectionView registerClass:[XDSPlayerDisclaimerView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([XDSPlayerDisclaimerView class])];

    [_moviedetailCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.playerContentView.mas_bottom);
        make.top.left.bottom.right.mas_equalTo(0);
    }];


    [self fetchMovieInfo];

}

#pragma mark - 网络请求
- (void)fetchMovieInfo{

    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:_htmlMovieModel.href
                                         hudController:self
                                               showHUD:YES
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   NSLog(@"utf8 = %@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                   [weakSelf detailHtmlData:htmlData];
                                               } failed:^(NSString *errorDescription) {

                                               }];

}


#pragma mark - 网络请求
//TODO: 请求播放页面
- (void)fetchMoviePlayer{
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:self.selectedMovieModel.playerHref
                                         hudController:self
                                               showHUD:YES
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   [weakSelf dealPlayerData:htmlData];
                                               } failed:^(NSString *errorDescription) {

                                               }];

}

#pragma mark - 代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _movieButtonList.count + kHTMLPlaceholderSectionNumbers;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (section < kHTMLPlaceholderSectionNumbers) {
        return 1;
    }
    NSDictionary * buttonList_section = _movieButtonList[section-kHTMLPlaceholderSectionNumbers];
    return [buttonList_section[@"buttonList"] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section < kHTMLPlaceholderSectionNumbers) {
        if (indexPath.section == kHTMLPlayerSection) {
            XDSZFPlayerCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSZFPlayerCell class]) forIndexPath:indexPath];
            self.playerContainer = cell;
            return cell;
        }else if (indexPath.section == kHTMLAdSection) {
            XDSPlayerBannerAdCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSPlayerBannerAdCell class]) forIndexPath:indexPath];
            return cell;
        }else {
            XDSVideoSummaryCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSVideoSummaryCell class]) forIndexPath:indexPath];
            cell.summary = self.movieModel.summary;
            self.hiddenSummaryButton = cell.hiddenButton;
            return cell;
        }
        
    }else {
        IHYMoviePlayButtonCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([IHYMoviePlayButtonCell class]) forIndexPath:indexPath];
        NSDictionary * buttonList_section = _movieButtonList[indexPath.section - kHTMLPlaceholderSectionNumbers];
        NSArray * buttonList = buttonList_section[@"buttonList"];
        IHYMoviePlayButtonModel * buttonModel = buttonList[indexPath.row];
        cell.titleLabel.text = buttonModel.title;
        
        cell.backgroundColor = [UIColor colorWithHexString:@"#eeeeee"];
        cell.layer.cornerRadius = 3;
        cell.layer.masksToBounds = YES;
        cell.titleLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        if (buttonModel == self.selectedMovieModel) {
            cell.titleLabel.textColor = [UIColor redColor];
        }
        return cell;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < kHTMLPlaceholderSectionNumbers) {
        if (indexPath.section == kHTMLPlayerSection) {
          return XDS_PLAYER_SIZE;
            
        }else if (indexPath.section == kHTMLAdSection) {
            return XDS_PLAYER_BANNER_AD_CELL_SIZE;
        }else {
            NSString *summary = self.movieModel.summary;
            if (summary.length < 1) {
                CGSize itemSize = CGSizeMake(DEVIECE_SCREEN_WIDTH, 0.5);
                return itemSize;
            }
            CGSize size = [summary sizeWithFont:VIDEO_SUMMARY_FONT maxSize:VIDEO_SUMMARY_MAX_SIZE];
            if (size.height < 60) {
                CGSize itemSize = CGSizeMake(DEVIECE_SCREEN_WIDTH, VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY + size.height);
                return itemSize;
            }else {
                CGSize itemSize = CGSizeMake(DEVIECE_SCREEN_WIDTH, VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY + 60);
                if (self.hiddenSummaryButton.selected) {//展开剧情简介
                    itemSize.height = VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY + size.height;
                }
                return itemSize;
            }
        }

    }else {
        NSDictionary * buttonList_section = _movieButtonList[indexPath.section-kHTMLPlaceholderSectionNumbers];
        IHYMoviePlayButtonModel *episodeModel = buttonList_section[@"buttonList"][indexPath.row];
        NSString *title = episodeModel.title;
        CGSize size = [title sizeWithFont:EPISODE_CELL_FONT maxSize:EPISODE_CELL_MAX_SIZE];
        return CGSizeMake(size.width + EPISODE_CELL_HEIGHT_EXCEPT_CONTENT, EPISODE_CELL_HEIGHT);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets edgeInset = UIEdgeInsetsZero;
    if (section < kHTMLPlaceholderSectionNumbers) {
        edgeInset = UIEdgeInsetsZero;

    }else {
        edgeInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    return edgeInset;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section < kHTMLPlaceholderSectionNumbers) {
        return CGSizeZero;
    }else {
        return CGSizeMake(DEVIECE_SCREEN_WIDTH, 25);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section < kHTMLPlaceholderSectionNumbers) {
        return CGSizeZero;
    }else {
        return CGSizeMake(DEVIECE_SCREEN_WIDTH, 200);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        XDSPlayerSectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([XDSPlayerSectionHeader class]) forIndexPath:indexPath];
        if (indexPath.section == kHTMLPlaceholderSectionNumbers) {
            if (self.htmlMovieModel.name.length) {
                headerView.titleLabel.text = [NSString stringWithFormat:@"《%@》- 在线播放 - 如果不能播放先刷新试试", self.htmlMovieModel.name];
            }else {
                headerView.titleLabel.text = @"在线播放 - 如果不能播放先刷新试试";
            }
        }else {
            if (self.htmlMovieModel.name.length) {
                headerView.titleLabel.text = [NSString stringWithFormat:@"《%@》- @备用 - 在线播放 - 如果不能播放先刷新试试", self.htmlMovieModel.name];
            }else {
                headerView.titleLabel.text = @"@备用 - 在线播放 - 如果不能播放先刷新试试";
            }
        }
        
        return headerView;
    }else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        XDSPlayerDisclaimerView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([XDSPlayerDisclaimerView class]) forIndexPath:indexPath];
        return footerView;
    }

    return nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section < kHTMLPlaceholderSectionNumbers) {
        return;
    }
    
    NSDictionary * buttonList_section = _movieButtonList[indexPath.section - kHTMLPlaceholderSectionNumbers];
    NSArray * buttonList = buttonList_section[@"buttonList"];
    IHYMoviePlayButtonModel * buttonModel = buttonList[indexPath.row];
    self.selectedMovieModel = buttonModel;
}

#pragma mark - 事件处理
- (void)orientChange:(NSNotification *)notification {
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;

    NSLog(@"notification = %@", notification.userInfo);
    NSLog(@"orient = %@", @(orient));
}
#pragma mark - 其他私有方法
//TODO:解析视频信息与选集
- (void)detailHtmlData:(NSData *)htmlData{
    self.movieModel = [[IHYMovieModel alloc] init];
    
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray * img_lazy_elments = [hpp searchWithXPathQuery:@"//img[@class=\"lazy\"]"];
    NSString * movieImage = @"";
    if (img_lazy_elments.count > 0) {
        TFHppleElement * img_lazy_elment = img_lazy_elments.firstObject;
        movieImage = [img_lazy_elment objectForKey:@"src"];
        self.movieModel.image_src = movieImage;
    }

    NSArray * dt_dd_elements = [hpp searchWithXPathQuery:@"//dl//dt|//dd"];
    NSMutableArray * titleAndContentModels = [NSMutableArray arrayWithCapacity:0];
    for (TFHppleElement * dt_dd_element in dt_dd_elements) {
        NSString * content = dt_dd_element.text;
        NSString * title = [dt_dd_element firstChildWithTagName:@"span"].text;
        NSLog(@"%@ = %@\n", title, content);
        IHYMovieDetailInfoTitleAndContentModel * model = [[IHYMovieDetailInfoTitleAndContentModel alloc] init];
        model.title = title;
        model.content = content;
        [titleAndContentModels addObject:model];
    }


    TFHppleElement * sumary_element = [hpp searchWithXPathQuery:@"//div[@class=\"tab-jq ctc\"]"].firstObject;
    NSString * sumary = sumary_element.text;
    self.movieModel.summary = sumary;
    
    NSArray * show_player_gogo_elements = [hpp searchWithXPathQuery:@"//div[@class=\"show_player_gogo\"]//ul"];
    NSArray * bofangqi_elements = [hpp searchWithXPathQuery:@"//li[@class=\"on bofangqi\"]"];
    NSMutableArray * bofangqi = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < show_player_gogo_elements.count; i ++) {
        TFHppleElement * show_player_gogo_element = show_player_gogo_elements[i];
        NSString * playerDesc = @"";
        if (i < bofangqi_elements.count) {
            TFHppleElement * bofangqi_element = bofangqi_elements[i];
            playerDesc = bofangqi_element.text;
        }
        NSLog(@"%@", playerDesc);
        NSMutableArray * buttonArray = [NSMutableArray arrayWithCapacity:0];
        NSArray * button_li_elements = [show_player_gogo_element childrenWithTagName:@"li"];
        for (TFHppleElement * button_li_element in button_li_elements) {
            TFHppleElement * button_a_element = [button_li_element firstChildWithTagName:@"a"];
            NSString * href = [button_a_element objectForKey:@"href"];
            NSString * buttonTitle = button_a_element.text;
            NSLog(@"%@ = %@", buttonTitle, href);
            if (!href || !buttonTitle || [buttonTitle containsString:@"更多"]) {
                continue;
            }
            IHYMoviePlayButtonModel * buttonModel = [[IHYMoviePlayButtonModel alloc] init];
            [buttonModel setValuesForKeysWithDictionary:@{@"title":buttonTitle, @"playerHref":href}];
            [buttonArray addObject:buttonModel];
        }

        [bofangqi addObject:@{@"title":playerDesc, @"buttonList":buttonArray}];
    }

    NSArray * footer_elements = [hpp searchWithXPathQuery:@"//div[@class=\"footer clearfix\"]//p"];
    NSMutableString * footerDisc = [NSMutableString string];
    for (TFHppleElement * p_element in footer_elements) {
        NSString * text = p_element.text;
        [footerDisc appendString:text];
        [footerDisc appendString:@"\n"];
    };
    NSLog(@"%@", footerDisc);


    if (bofangqi.count > 0) {
        [_movieButtonList removeAllObjects];
        [_movieButtonList addObjectsFromArray:bofangqi];
    }


    if (_movieButtonList.count) {
        NSDictionary * buttonList_section = _movieButtonList.firstObject;
        NSArray * buttonList = buttonList_section[@"buttonList"];
        if (buttonList.count) {
            IHYMoviePlayButtonModel * buttonModel = buttonList.firstObject;
            self.selectedMovieModel = buttonModel;
        }
    }
    
}

//TODO:解析播放器代码
- (void)dealPlayerData:(NSData *)PlayerData{
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:PlayerData];
    TFHppleElement * iframe = [hpp searchWithXPathQuery:@"//iframe"].firstObject;
    if (iframe != nil) {
        NSString * playerSrc = [iframe objectForKey:@"src"];

        __weak typeof(self)weakSelf = self;
        [[[XDSHttpRequest alloc] init] htmlRequestWithHref:playerSrc
                                             hudController:self
                                                   showHUD:YES
                                                   HUDText:nil
                                             showFailedHUD:YES
                                                   success:^(BOOL success, NSData * htmlData) {
                                                       NSLog(@"%@", [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]);
                                                       [weakSelf stripVideoSrc:htmlData playerUrl:playerSrc];
                                                   } failed:^(NSString *errorDescription) {

                                                   }];
    }
}

//TODO:解析获取视频地址
- (void)stripVideoSrc:(NSData *)data playerUrl:(NSString *)playerUrl{
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:data];
    TFHppleElement * video = [hpp searchWithXPathQuery:@"//video"].firstObject;
    //    TFHppleElement * iframe = [hpp searchWithXPathQuery:@"//iframe"].firstObject;
    
    BOOL playerWebView = YES;
    NSString *videoUrl = @"";
    if (video != nil) {
        videoUrl = [video objectForKey:@"src"];
        if (videoUrl.length) {
            playerWebView = NO;
        }
    }
    
    XDSPlayerSourceModel *model = [[XDSPlayerSourceModel alloc] init];
    model.isWebUrl = playerWebView;
    model.videoUrl = playerWebView?playerUrl:videoUrl;
    model.title = [NSString stringWithFormat:@"%@-%@", self.htmlMovieModel.name, self.selectedMovieModel.title];
    [self.playerContainer setPlayerSourceModel:model];
    
    self.title = model.title;
}


- (void)setSelectedMovieModel:(IHYMoviePlayButtonModel *)selectedMovieModel{
    _selectedMovieModel = selectedMovieModel;

    [self fetchMoviePlayer];
    [_moviedetailCollectionView reloadData];
    
    [_moviedetailCollectionView setContentOffset:CGPointZero];
}

#pragma mark - 内存管理相关
- (void)movieDetailViewControllerDataInit{
    self.movieButtonList = [[NSMutableArray alloc] init];
}


#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate {
    return self.playerContainer.player.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.playerContainer.player.isFullScreen && self.playerContainer.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.playerContainer.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.playerContainer.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}
@end
