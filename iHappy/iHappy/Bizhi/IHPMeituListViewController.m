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

@interface IHPMeituListViewController ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
@property (strong, nonatomic) NSMutableArray<XDSMeituModel *> * meituList;
@property (strong, nonatomic) UICollectionView * collectionView;
@property (copy, nonatomic) NSString * nextPageUrl;

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
    
    NSString *url = self.rootUrl;
    NSInteger size = 20;
    NSInteger page = self.meituList.count/size;
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
                                                isTop?[self.meituList removeAllObjects]:NULL;
                                                [self.meituList addObjectsFromArray:meiziList];
                                                [self.collectionView.collectionViewLayout invalidateLayout];
                                                [self.collectionView reloadData];
                                                
                                            } failed:^(NSString *errorDescription) {
                                                [weakSelf.collectionView.mj_header endRefreshing];
                                                [weakSelf.collectionView.mj_footer endRefreshing];
                                            }];
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
    [self fetchDetailImageListWithMd5key:model.md5key];
    

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

#pragma mark - 点击事件处理
//TODO: showPhotoBrowser

- (void)showMediaBrowserView:(NSArray <XDSDetailImageModel*> *)imageArray {
    NSMutableArray *mediaModelArray = [NSMutableArray arrayWithCapacity:0];
    for (XDSDetailImageModel *mediaModel in imageArray) {
        XDSMediaModel *videoModel = [[XDSMediaModel alloc] init];
        videoModel.mediaURL = [NSURL URLWithString:mediaModel.image_src];
        videoModel.mediaType = XDSMediaTypeImage;
//        videoModel.placeholderImage = [UIImage placeholderImage:frame];
        [mediaModelArray addObject:videoModel];
    }
    
    XDSMediaBrowserVC *mediaBrowserVC = [[XDSMediaBrowserVC alloc] init];
    mediaBrowserVC.mediaModelArray = mediaModelArray;
    self.mediaBrowserVC = mediaBrowserVC;
    [self presentViewController:mediaBrowserVC animated:YES completion:nil];
}

#pragma mark - 其他私有方法

#pragma mark - 内存管理相关
- (void)biZhiListViewControllerDataInit{
    self.meituList = [NSMutableArray arrayWithCapacity:0];
}

@end



