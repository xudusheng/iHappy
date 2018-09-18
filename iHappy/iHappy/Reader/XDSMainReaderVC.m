//
//  XDSMainReaderVC.m
//  iHappy
//
//  Created by Hmily on 2018/9/17.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMainReaderVC.h"
#import "XDSBookCell.h"
@interface XDSMainReaderVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray * bookList;
@property (strong, nonatomic) UICollectionView * mCollectionView;

@end

@implementation XDSMainReaderVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self movieListViewControllerDataInit];
    [self createMovieListViewControllerUI];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UI相关
- (void)createMovieListViewControllerUI{
    self.view.backgroundColor = [UIColor whiteColor];
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置每个item的大小
    CGFloat itemMargin = 10;
    CGFloat width = (DEVIECE_SCREEN_WIDTH - itemMargin * 4)/3-0.1;
    layout.itemSize = CGSizeMake(width, width*4/3 + 45);
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

}

#pragma mark - 网络请求


#pragma mark - 代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _bookList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSBookCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSBookCell class]) forIndexPath:indexPath];
    XDSBookModel *bookModel = self.bookList[indexPath.row];
    cell.mTitleLabel.text = bookModel.bookBasicInfo.title;
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSBookModel *bookModel = self.bookList[indexPath.row];
    
    XDSReadPageViewController *pageView = [[XDSReadPageViewController alloc] init];
    [[XDSReadManager sharedManager] setResourceURL:bookModel.resource];//文件位置
    [[XDSReadManager sharedManager] setBookModel:bookModel];
    [[XDSReadManager sharedManager] setRmDelegate:pageView];
    [self presentViewController:pageView animated:YES completion:nil];
    
//    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDir = documentPaths.firstObject;
//    NSString *path = [NSString stringWithFormat:@"%@/斗气大陆.txt", documentDir];
//    [self showReadPageViewControllerWithFileURL:path.mj_url];
}
#pragma mark - 点击事件处理
- (void)showReadPageViewControllerWithFileURL:(NSURL *)fileURL{
    if (nil == fileURL) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        XDSBookModel *bookModel = [XDSBookModel getLocalModelWithURL:fileURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            XDSReadPageViewController *pageView = [[XDSReadPageViewController alloc] init];
            [[XDSReadManager sharedManager] setResourceURL:fileURL];//文件位置
            [[XDSReadManager sharedManager] setBookModel:bookModel];
            [[XDSReadManager sharedManager] setRmDelegate:pageView];
            [self presentViewController:pageView animated:YES completion:nil];
        });
    });
}



#pragma mark - 其他私有方法
- (void)loadLocalBooks {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = documentPaths.firstObject;
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    [self.bookList removeAllObjects];
    for (NSString *fileName in fileList) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", documentDir, fileName];
        XDSBookModel *bookModel = [XDSBookModel getLocalModelWithURL:path.mj_url];
        bookModel?[self.bookList addObject:bookModel]:NULL;
    }
    [self.mCollectionView reloadData];
}

#pragma mark - 内存管理相关
- (void)movieListViewControllerDataInit{
    self.bookList = [[NSMutableArray alloc] initWithCapacity:0];
    [self loadLocalBooks];
}

@end
