//
//  IHPMeituListViewController.m
//  iHappy
//
//  Created by dusheng.xu on 2017/5/13.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPMeituListViewController.h"
#import "YSERequestFetcher.h"
#import "INSImageItemCollectionViewCell.h"
#import "XDSMediaBrowserVC.h"

#import "XDSMeituModel.h"

//图片浏览器
#import "YBImageBrowser.h"


@interface IHPMeituListViewController ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
YBImageBrowserDataSource,
YBImageBrowserDelegate
>
@property (strong, nonatomic) NSMutableArray<XDSMeituModel *> * meituList;
@property (strong, nonatomic) UICollectionView * collectionView;
@property (copy, nonatomic) NSString * nextPageUrl;

@property (copy, nonatomic) NSArray* imageUrlList;

@property (strong, nonatomic) XDSMediaBrowserVC *mediaBrowserVC;

@end

@implementation IHPMeituListViewController
CGFloat const kBiZhiCollectionViewMinimumLineSpacing = 10.0;
CGFloat const kBiZhiCollectionViewMinimumInteritemSpacing = 10.0;
CGFloat const kBiZhiCollectionViewCellsGap = 10.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self biZhiListViewControllerDataInit];
    [self createBiZhiListViewControllerUI];
}

#pragma mark - UI相关
- (void)createBiZhiListViewControllerUI{

    self.view.backgroundColor = [UIColor brownColor];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = kBiZhiCollectionViewMinimumLineSpacing;//纵向间距
    flowLayout.minimumInteritemSpacing = kBiZhiCollectionViewMinimumInteritemSpacing;//横向内边距
    
    self.collectionView = ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.translatesAutoresizingMaskIntoConstraints = false;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[INSImageItemCollectionViewCell class]
           forCellWithReuseIdentifier:kImageItemCollectionViewCellIdentifier];
        
        collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:collectionView];

        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(collectionView);
        NSArray *constraints_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[collectionView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDict];
        NSArray *constraints_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[collectionView]|" options:NSLayoutFormatAlignAllLeft metrics:nil views:viewsDict];
        
        [self.view addConstraints:constraints_H];
        [self.view addConstraints:constraints_V];
        
        collectionView;
    });

    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                 refreshingAction:@selector(headerRequest)];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(footerRequest)];
    [_collectionView.mj_header beginRefreshing];

}

#pragma mark - 网络请求
#pragma mark - 网络请求
- (void)headerRequest{
    [_collectionView.mj_footer resetNoMoreData];
    [self fetchImageList:YES];
}
- (void)footerRequest{
    [self fetchImageList:NO];
}

- (void)fetchImageList:(BOOL)isTop{
    [self loadLocalData:isTop];
    return;
    
    
    NSString *url = self.rootUrl;
    NSInteger size = 20;
    NSInteger page = isTop?0:(self.meituList.count/size);
    NSDictionary *params = @{
                             @"size":@(size),
                             @"page":@(page),
                             };
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] GETWithURLString:url
                                           reqParam:params
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:YES
                                            success:^(BOOL success, NSDictionary *successResult) {
                                                
                                                [weakSelf.collectionView.mj_header endRefreshing];
                                                [weakSelf.collectionView.mj_footer endRefreshing];
                                                
                                                XDSMeiziResponseModel *responseModel = [XDSMeiziResponseModel mj_objectWithKeyValues:successResult];
                                                NSArray *meiziList = responseModel.meiziList;
                                                [self.meituList addObjectsFromArray:meiziList];
                                                [self.collectionView.collectionViewLayout invalidateLayout];
                                                [self.collectionView reloadData];
                                                
                                            } failed:^(NSString *errorDescription) {
                                                [weakSelf.collectionView.mj_header endRefreshing];
                                                [weakSelf.collectionView.mj_footer endRefreshing];
                                            }];
}

- (void)loadLocalData:(BOOL)isTop {
    
    NSInteger page_size = 20;
    NSInteger page_no = isTop?0:(self.meituList.count/page_size);
    
    isTop?[self.meituList removeAllObjects]:NULL;

    NSArray *imageList = [self.imageUrlList subarrayWithRange:NSMakeRange(page_size*page_no, page_size)];
    for (NSString *imgUrl in imageList) {
        XDSMeituModel *model = [[XDSMeituModel alloc] init];
        model.image_src = imgUrl;
        [self.meituList addObject:model];
    }

    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}


- (void)fetchDetailImageListWithMd5key:(NSString *)md5key{
    
    NSString *url = @"http://134.175.54.80/ihappy/meizi/querydetail.php";
    NSDictionary *params = @{
                             @"md5key":md5key?md5key:@"",
                             };
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] GETWithURLString:url
                                           reqParam:params
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:YES
                                            success:^(BOOL success, NSDictionary *successResult) {
                                                XDSDetaimImageResponseModel *responseModel = [XDSDetaimImageResponseModel mj_objectWithKeyValues:successResult];
                                                NSArray *imageArray = responseModel.imageList;
                                                if (imageArray.count) {
                                                    [weakSelf showMediaBrowserView:imageArray];
                                                }
                                            } failed:nil];
    
    
    
}

//TODO:保存下一页的链接 
- (void)saveNextPageInfo:(NSDictionary *)result{
    
    NSString *nextPageHref = result[kBiZhiNextPageHrefKey];
    self.nextPageUrl = nextPageHref;

    BOOL isLastPage = [result[kBiZhiIsLastPageKey] boolValue];
    if (isLastPage){
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }else{
        [self.collectionView.mj_footer resetNoMoreData];
    }
    
}

//MARK: - Delegate
//TODO:UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.meituList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    INSImageItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageItemCollectionViewCellIdentifier forIndexPath:indexPath];
    XDSMeituModel *model = _meituList[indexPath.row];
    cell.imageModel = model;
    [cell p_loadCell];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    XDSMeituModel *model = _meituList[indexPath.row];
    
    if (model.md5key.length > 0) {
        [self fetchDetailImageListWithMd5key:model.md5key];
    }else if (model.image_src.length > 0) {
//        XDSDetailImageModel *imageModel = [[XDSDetailImageModel alloc] init];
//        imageModel.image_src = model.image_src;
//        [self showMediaBrowserView:@[imageModel]];
        [self showBrowserForSimpleCaseWithIndex:indexPath.row];
    }

}

//TODO:UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellWidth  = (DEVIECE_SCREEN_WIDTH - 3*kBiZhiCollectionViewCellsGap)/2;
    CGFloat cellHeight = cellWidth+25;
    return CGSizeMake(cellWidth, cellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(kBiZhiCollectionViewCellsGap, kBiZhiCollectionViewCellsGap, 0, kBiZhiCollectionViewCellsGap);
}

#pragma mark - <YBImageBrowserDataSource>

- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView {
    return self.meituList.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
//    PHAsset *asset = (PHAsset *)self.dataArray[index];
    XDSMeituModel *model = self.meituList[index];
    YBImageBrowseCellData *data = [YBImageBrowseCellData new];
    data.url = [NSURL URLWithString:model.image_src];
    data.sourceObject = [self sourceObjAtIdx:index];
    return data;
}

#pragma mark - 点击事件处理
//TODO: showPhotoBrowser
- (void)showMediaBrowserView:(NSArray <XDSDetailImageModel*> *)imageArray {
    NSMutableArray *mediaModelArray = [NSMutableArray arrayWithCapacity:0];
    for (XDSDetailImageModel *mediaModel in imageArray) {
        XDSMediaModel *videoModel = [[XDSMediaModel alloc] init];
        videoModel.mediaURL = [NSURL URLWithString:mediaModel.image_src];
        videoModel.mediaType = XDSMediaTypeImage;
//      videoModel.placeholderImage = [UIImage placeholderImage:frame];
        [mediaModelArray addObject:videoModel];
    }
    
    XDSMediaBrowserVC *mediaBrowserVC = [[XDSMediaBrowserVC alloc] init];
    mediaBrowserVC.mediaModelArray = mediaModelArray;
    self.mediaBrowserVC = mediaBrowserVC;
    [self presentViewController:mediaBrowserVC animated:YES completion:nil];
}



#pragma mark - Show 'YBImageBrowser'
- (void)showBrowserForSimpleCaseWithIndex:(NSInteger)index {
//    NSMutableArray *browserDataArr = [NSMutableArray array];
//    XDSMeituModel *model = self.meituList[index];
//    YBImageBrowseCellData *data = [YBImageBrowseCellData new];
//    data.url = [NSURL URLWithString:model.image_src];
//    data.sourceObject = [self sourceObjAtIdx:index];
//    [browserDataArr addObject:data];
//    YBImageBrowser *browser = [YBImageBrowser new];
//    browser.dataSourceArray = browserDataArr;
//    browser.currentIndex = 0;
//    [browser show];

    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSource = self;
    browser.currentIndex = index;
    [browser show];
}
#pragma mark - 其他私有方法
- (id)sourceObjAtIdx:(NSInteger)idx {
    INSImageItemCollectionViewCell *cell = (INSImageItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    return cell ? cell.bgImageView : nil;
}
#pragma mark - 内存管理相关
- (void)biZhiListViewControllerDataInit{
    
    NSBundle* bundle = [NSBundle bundleForClass:self.class];
    NSString *filePath = [bundle pathForResource:@"meizi_zipai" ofType:@"txt"];
    NSData *imgListData = [NSData dataWithContentsOfFile:filePath];
    NSString *imgListString = [[NSString alloc] initWithData:imgListData encoding:NSUTF8StringEncoding];
    NSArray *imgList = [imgListString componentsSeparatedByString:@";"];
    self.imageUrlList = imgList;
    self.meituList = [NSMutableArray arrayWithCapacity:0];
}

@end



