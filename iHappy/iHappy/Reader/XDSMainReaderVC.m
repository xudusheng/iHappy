//
//  XDSMainReaderVC.m
//  iHappy
//
//  Created by Hmily on 2018/9/17.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMainReaderVC.h"
#import "XDSBookCell.h"
#import "XDSWIFIFileTransferViewController.h"
#import "AppDelegate.h"
@interface XDSMainReaderVC ()<UICollectionViewDelegate, UICollectionViewDataSource, XDSWIFIFileTransferViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray<LPPBookInfoModel*> * bookList;
@property (strong, nonatomic) UICollectionView * mCollectionView;

@property (nonatomic,assign) BOOL hasFirstLoadBooks;
@end

@implementation XDSMainReaderVC
OCT_SYNTHESIZE_SINGLETON_FOR_CLASS(XDSMainReaderVC)

+ (instancetype)sharedReaderVC {
    return [XDSMainReaderVC sharedXDSMainReaderVC];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self movieListViewControllerDataInit];
    [self createMovieListViewControllerUI];
    [[XDSAdManager sharedManager] showInterstitialAD];
}

#pragma mark - 点击事件处理

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_hasFirstLoadBooks) {
        [XDSUtilities showHud:self.view text:nil];
        [self loadLocalBooks];
        self.hasFirstLoadBooks = YES;
    }else {
        [self sortBooksByModifyTime];
    }
}

#pragma mark - 点击事件处理


#pragma mark - UI相关
- (void)createMovieListViewControllerUI{
    self.view.backgroundColor = [UIColor whiteColor];

    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    CGFloat itemMargin = 20;
    CGFloat width = (DEVIECE_SCREEN_WIDTH - itemMargin * 4)/3-0.1;
    layout.itemSize = CGSizeMake(width, width*12/9 + 45);
    layout.sectionInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    //创建collectionView 通过一个布局策略layout来创建
    self.mCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _mCollectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //代理设置
    _mCollectionView.delegate=self;
    _mCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.view addSubview:_mCollectionView];
    
    [_mCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([XDSBookCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([XDSBookCell class])];
    [_mCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加书籍" style:UIBarButtonItemStyleDone target:self action:@selector(showWifiView)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

#pragma mark - 网络请求


#pragma mark - 代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _bookList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSBookCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSBookCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];

    LPPBookInfoModel *bookInfoModel = self.bookList[indexPath.row];
    UIImage *cover = [UIImage imageWithContentsOfFile:bookInfoModel.coverPath];
    cell.mImageView.image = cover;
    cell.mTitleLabel.text = bookInfoModel.title;
    
    cell.lastReadMark.hidden = !bookInfoModel.isLastRead;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LPPBookInfoModel *bookInfoModel = self.bookList[indexPath.row];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XDSBookModel *bookModel = [XDSBookModel bookModelWithBaseInfo:bookInfoModel];
        dispatch_async(dispatch_get_main_queue(), ^{
            XDSReadPageViewController *pageView = [[XDSReadPageViewController alloc] init];
            [[XDSReadManager sharedManager] setBookModel:bookModel];
            [[XDSReadManager sharedManager] setRmDelegate:pageView];
            [[XDSRootViewController sharedRootViewController].mainViewController presentViewController:pageView animated:YES completion:nil];
        });
    });
}

#pragma mark - XDSWIFIFileTransferViewControllerDelegate
- (void)didBooksChanged {
    [self loadLocalBooks];
}
#pragma mark - 点击事件处理
- (void)showReadPageViewControllerWithFileURL:(NSURL *)fileURL{
    if (nil == fileURL) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LPPBookInfoModel *bookInfo = [XDSReadOperation getBookInfoWithFile:fileURL];
        XDSBookModel *bookModel = [XDSBookModel bookModelWithBaseInfo:bookInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
            XDSReadPageViewController *pageView = [[XDSReadPageViewController alloc] init];
            [[XDSReadManager sharedManager] setBookModel:bookModel];
            [[XDSReadManager sharedManager] setRmDelegate:pageView];
            [self presentViewController:pageView animated:YES completion:nil];
        });
    });
}

- (void)showWifiView {
    XDSWIFIFileTransferViewController *wifiTransferVC = [XDSWIFIFileTransferViewController newInstance];
    wifiTransferVC.wDelegate = self;
    [self presentViewController:wifiTransferVC
                       animated: YES
              inRransparentForm:YES
                     completion:nil];
}

#pragma mark - 其他私有方法
- (void)loadLocalBooks {
    [self.bookList removeAllObjects];
    
    //本地文件-同步执行
    NSArray *fileList = @[@"生活小科普.txt"];
    for (NSString *fileName in fileList) {
        
        //注意，url初始化方法与从documents读取文件的url初始化方法的区别
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        
        LPPBookInfoModel *bookInfo = [XDSReadOperation getBookInfoWithFile:fileURL];
        bookInfo?[self.bookList addObject:bookInfo]:NULL;
        [self.mCollectionView reloadData];
    }
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = documentPaths.firstObject;
    NSError *error = nil;
    fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (NSString *fileName in fileList) {
            NSString *path = [NSString stringWithFormat:@"%@/%@", documentDir, fileName];
            LPPBookInfoModel *bookInfo = [XDSReadOperation getBookInfoWithFile:[NSURL fileURLWithPath:path]];
            bookInfo?[self.bookList addObject:bookInfo]:NULL;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sortBooksByModifyTime];
            [XDSUtilities hideHud:self.view];
        });
    });

}

- (void)sortBooksByModifyTime {
    [self.bookList sortUsingComparator:^NSComparisonResult(LPPBookInfoModel * _Nonnull book_1, LPPBookInfoModel * _Nonnull book_2) {
        BOOL isBig = book_2.latestModifyTime > book_1.latestModifyTime;
        if (isBig) {
            book_1.isLastRead = NO;
        }
        return isBig;
    }];
    [self.mCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

#pragma mark - 内存管理相关
- (void)movieListViewControllerDataInit{
    self.bookList = [[NSMutableArray alloc] initWithCapacity:0];
}

@end
