//
//  IHPShuaigeListViewController.m
//  iHappy
//
//  Created by dusheng.xu on 2017/5/13.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPShuaigeListViewController.h"
#import "YSERequestFetcher.h"
#import "INSImageItemCollectionViewCell.h"
#import "XDSImageItemAdCell.h"
#import "XDSMeituModel.h"

//图片浏览器
#import "YBImageBrowser.h"
#import "YBAdBrowserCellData.h"

#import "CHTCollectionViewWaterfallLayout.h"
@interface IHPShuaigeListViewController ()<
UICollectionViewDelegate,
UICollectionViewDataSource,
CHTCollectionViewDelegateWaterfallLayout,
YBImageBrowserDataSource,
YBImageBrowserDelegate
>
@property (strong, nonatomic) UICollectionView * collectionView;

@property (strong, nonatomic) NSMutableArray<XDSMeituModel *> *meituList;//列表数据，配合本地数据模拟上拉下拉刷新
@property (strong, nonatomic) NSMutableArray<XDSMeituModel *> *totalMeituList;//从本地文件读取的所有缓存数据

@end

@implementation IHPShuaigeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createBiZhiListViewControllerUI];
    [XDSUtilities showHud:self.view text:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self biZhiListViewControllerDataInit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self headerRequest];
            [XDSUtilities hideHud:self.view];
        });
    });
}

#pragma mark - UI相关
- (void)createBiZhiListViewControllerUI{
    
    self.view.backgroundColor = [UIColor brownColor];
    
    //    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CHTCollectionViewWaterfallLayout *flowLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    //    flowLayout.minimumLineSpacing = kBiZhiCollectionViewMinimumLineSpacing;//纵向间距
    //    flowLayout.minimumInteritemSpacing = kBiZhiCollectionViewMinimumInteritemSpacing;//横向内边距
    
    self.collectionView = ({
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        collectionView.collectionViewLayout = flowLayout;
        collectionView.translatesAutoresizingMaskIntoConstraints = false;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[INSImageItemCollectionViewCell class]
           forCellWithReuseIdentifier:kImageItemCollectionViewCellIdentifier];
        
        [collectionView registerClass:[XDSImageItemAdCell class]
           forCellWithReuseIdentifier:NSStringFromClass([XDSImageItemAdCell class])];
        
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
    
    [[XDSAdManager sharedManager] showInterstitialAD];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateLayoutForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateLayoutForOrientation:toInterfaceOrientation];
}

- (void)updateLayoutForOrientation:(UIInterfaceOrientation)orientation {
    CHTCollectionViewWaterfallLayout *layout =
    (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = UIInterfaceOrientationIsPortrait(orientation) ? 2 : 3;
}
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
    isTop?[self.meituList removeAllObjects]:NULL;
    
    NSInteger page_size = 40;
    NSInteger page_no = isTop?0:(self.meituList.count/page_size);
    [self.collectionView.mj_header endRefreshing];
    if (page_size*page_no+page_size >self.totalMeituList.count) {
        page_size = self.totalMeituList.count - page_size*page_no;
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.collectionView.mj_footer endRefreshing];
    }
    
    NSArray *imageList = [self.totalMeituList subarrayWithRange:NSMakeRange(page_size*page_no, page_size)];
    
    for (XDSMeituModel *meituModel in imageList) {
        [self.meituList addObject:meituModel];
        if ([[XDSAdManager sharedManager] isAdAvailible] && self.meituList.count%[IHPConfigManager shareManager].adInfo.index  == 0) {
            //广告占位
            XDSMeituModel *model = [[XDSMeituModel alloc] init];
            [self.meituList addObject:model];
            NSString *indexIdentifier =[NSString stringWithFormat:@"%@_%ld", NSStringFromClass([XDSImageItemAdCell class]), self.meituList.count - 1];
            [self.collectionView registerClass:[XDSImageItemAdCell class] forCellWithReuseIdentifier:indexIdentifier];
        }
    }
    
    [self.collectionView reloadData];
}


- (void)fetchDetailImageListWithMd5key:(NSString *)md5key{
    
    //    NSString *url = @"http://134.175.54.80/ihappy/meizi/querydetail.php";
    //    NSDictionary *params = @{
    //                             @"md5key":md5key?md5key:@"",
    //                             };
    //    __weak typeof(self)weakSelf = self;
    //    [[[XDSHttpRequest alloc] init] GETWithURLString:url
    //                                           reqParam:params
    //                                      hudController:self
    //                                            showHUD:NO
    //                                            HUDText:nil
    //                                      showFailedHUD:YES
    //                                            success:^(BOOL success, NSDictionary *successResult) {
    //                                                XDSDetaimImageResponseModel *responseModel = [XDSDetaimImageResponseModel mj_objectWithKeyValues:successResult];
    //                                                NSArray *imageArray = responseModel.imageList;
    //                                                if (imageArray.count) {
    //                                                    [weakSelf showMediaBrowserView:imageArray];
    //                                                }
    //                                            } failed:nil];
    
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
    XDSMeituModel *model = _meituList[indexPath.row];
    
    if (model.image_src.length > 0) {
        INSImageItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageItemCollectionViewCellIdentifier forIndexPath:indexPath];
        NSURL *url = [NSURL URLWithString:model.image_src];
        [cell.bgImageView sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (!CGSizeEqualToSize(model.imageSize, image.size)) {
                model.imageSize = image.size;
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }];
        return cell;
    }else {
        NSString *indexIdentifier =[NSString stringWithFormat:@"%@_%ld", NSStringFromClass([XDSImageItemAdCell class]), indexPath.row];
        XDSImageItemAdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:indexIdentifier forIndexPath:indexPath];
        cell.adMargin = 10.f;
        [cell p_loadCell];
        return cell;
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    XDSMeituModel *model = _meituList[indexPath.row];
    
    if (model.md5key.length > 0) {
        [self fetchDetailImageListWithMd5key:model.md5key];
    }else if (model.image_src.length > 0) {
        [self showBrowserForSimpleCaseWithIndex:indexPath.row];
    }
    
}

//TODO:UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellWidth  = (DEVIECE_SCREEN_WIDTH - 3*kBiZhiCollectionViewCellsGap)/2;
    CGFloat cellHeight = cellWidth;
    
    XDSMeituModel *model = _meituList[indexPath.row];
    CGSize imageSize = model.imageSize;
    if (imageSize.height > 1) {
        cellHeight = (imageSize.height/imageSize.width)*(cellWidth - 2*kImageItemCollectionViewCellGap) + 2*kImageItemCollectionViewCellGap;
    } else {
        cellHeight = XDS_NATIVE_EXPRESS_AD_RETIO_HEIGHT_WIDTH*(cellWidth - 2*kImageItemCollectionViewCellGap) + 2*kImageItemCollectionViewCellGap;
    }
    return CGSizeMake(cellWidth, cellHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(kBiZhiCollectionViewCellsGap, kBiZhiCollectionViewCellsGap, 0, kBiZhiCollectionViewCellsGap);
}


- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView {
    return self.meituList.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    XDSMeituModel *model = self.meituList[index];
    YBImageBrowseCellData *data = [YBImageBrowseCellData new];
    data.url = [NSURL URLWithString:model.image_src];
    data.sourceObject = [self sourceObjAtIdx:index];
    return data;
}
#pragma mark - 点击事件处理
- (void)showBrowserForSimpleCaseWithIndex:(NSInteger)index {
    
    XDSMeituModel *meituModel = self.meituList[index];
    NSMutableArray *browserDataArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *img_url in meituModel.imageList) {
        YBImageBrowseCellData *data = [YBImageBrowseCellData new];
        data.url = [NSURL URLWithString:img_url];
        data.sourceObject = [self sourceObjAtIdx:index];
        data.maxZoomScale = 3.f;
        [browserDataArr addObject:data];
    }
    
    YBAdBrowserCellData *adCellData = [[YBAdBrowserCellData alloc] init];
    [browserDataArr addObject:adCellData];
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = browserDataArr;
    browser.currentIndex = 0;
    [browser show];
}
#pragma mark - 其他私有方法
- (id)sourceObjAtIdx:(NSInteger)idx {
    INSImageItemCollectionViewCell *cell = (INSImageItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
    return cell ? cell.bgImageView : nil;
}
#pragma mark - 内存管理相关
- (void)biZhiListViewControllerDataInit{
    @autoreleasepool {
        NSBundle* bundle = [NSBundle bundleForClass:self.class];
        NSString *filePath = [bundle pathForResource:@"shuaigetupian" ofType:@"txt"];
        NSData *imgListData = [NSData dataWithContentsOfFile:filePath];
        NSString *imgListString = [[NSString alloc] initWithData:imgListData encoding:NSUTF8StringEncoding];
        
        NSString *remoteImgListString = [IHPConfigManager shareManager].shuaige;
        if (remoteImgListString.length > 0) {
            imgListString = [NSString stringWithFormat:@"%@;%@",imgListString, remoteImgListString];
        }
        NSArray *imgList = [imgListString componentsSeparatedByString:@";"];
        
        NSSet *set = [NSSet setWithArray:imgList];
        imgList = nil;
        imgList = set.allObjects;
        
        NSMutableArray *smallIconArray = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *smallAndBigImgArray = [NSMutableArray arrayWithCapacity:0];
        for (NSString *subString in imgList) {
            @autoreleasepool {
                NSArray *urls = [subString componentsSeparatedByString:@","];
                if (urls.count == 4) {
                    NSString *smallIcon =urls[2];
                    NSString *bigImg = urls.lastObject;
                    [smallIconArray addObject:smallIcon];
                    [smallAndBigImgArray addObject:[NSString stringWithFormat:@"%@,%@", smallIcon, bigImg]];
                }
            }
        }
        
        
        [smallAndBigImgArray sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return ([obj1 compare:obj2] == NSOrderedAscending);
        }];
        
        NSMutableArray *meituModelList = [NSMutableArray arrayWithCapacity:0];
        XDSMeituModel *meituModel = nil;
        NSMutableArray *img_list = [NSMutableArray arrayWithCapacity:0];
        for (NSString *imgString in smallAndBigImgArray) {
            @autoreleasepool {
                NSArray *smallAndBig = [imgString componentsSeparatedByString:@","];
                //如果小图标的地址一样，表示同一组图片，否则为不同组
                //不同组图片的处理：先把第一张大图赋值给作为image_src（小图），把大图数组赋值，再新建model继续下一个循环
                if (![meituModel.image_src isEqualToString:smallAndBig.firstObject]) {
                    if (meituModel) {
                        //                        meituModel.image_src = img_list.firstObject;
                        meituModel.imageList = img_list;
                        [meituModelList addObject:meituModel];
                    }
                    meituModel = [XDSMeituModel new];
                    meituModel.image_src = smallAndBig.firstObject;
                    [img_list removeAllObjects];
                }
                [img_list addObject:smallAndBig.lastObject];
            }
        }
        
        //循环结束，添加最后一组图片
        meituModel.image_src = img_list.firstObject;
        meituModel.imageList = img_list;
        [meituModelList addObject:meituModel];
        
        //随机排序
        NSInteger location = arc4random()%30+1;
        NSInteger length = 1;
        [meituModelList sortUsingComparator:^NSComparisonResult(XDSMeituModel  *obj1, XDSMeituModel *obj2) {
            NSString *subString1 = [obj1.image_src.xds_md5 substringWithRange:NSMakeRange(location, length)];
            NSString *subString2 = [obj2.image_src.xds_md5 substringWithRange:NSMakeRange(location, length)];
            return ([subString1 compare:subString2] == NSOrderedAscending);
        }];
        
        for (XDSMeituModel *model in meituModelList) {
            model.image_src = model.imageList.firstObject;
        }
        
        self.totalMeituList = meituModelList;
        self.meituList = [NSMutableArray arrayWithCapacity:0];
    }
}

@end



