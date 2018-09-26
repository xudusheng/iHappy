//
//  IHYMovieListViewController.m
//  iHappy
//
//  Created by xudosom on 2016/11/19.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHYMovieListViewController.h"
#import "IHYMovieModel.h"
#import "IHPMovieCell.h"

#import "IHYMovieDetailViewController.h"
#import "IHPPlayerViewController.h"
@interface IHYMovieListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray<IHYMovieModel *> * movieList;
@property (strong, nonatomic) UICollectionView * movieCollectionView;
@property (copy, nonatomic) NSString * nextPageUrl;
@property (nonatomic,assign) NSInteger currentPage;
@end

@implementation IHYMovieListViewController

NSString * const MovieListViewController_movieCellIdentifier = @"IHPMovieCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self movieListViewControllerDataInit];
    [self createMovieListViewControllerUI];
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
    layout.itemSize = CGSizeMake(width, width*4/3);
    layout.sectionInset = UIEdgeInsetsMake(itemMargin, itemMargin, itemMargin, itemMargin);
    //创建collectionView 通过一个布局策略layout来创建
    self.movieCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    _movieCollectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //代理设置
    _movieCollectionView.delegate=self;
    _movieCollectionView.dataSource=self;
    //注册item类型 这里使用系统的类型
    [self.view addSubview:_movieCollectionView];
    
    [_movieCollectionView registerNib:[UINib nibWithNibName:@"IHPMovieCell" bundle:nil] forCellWithReuseIdentifier:MovieListViewController_movieCellIdentifier];
    [_movieCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    _movieCollectionView.mj_header = [XDS_CustomMjRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRequest)];
    _movieCollectionView.mj_footer = [XDS_CustomMjRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRequest)];
    [self.movieCollectionView.mj_header beginRefreshing];
}

#pragma mark - 网络请求

- (void)headerRequest{
    self.currentPage = 0;
    [self fetchMovieList:YES];
    [_movieCollectionView.mj_footer resetNoMoreData];
}
- (void)footerRequest{
    self.currentPage += 1;
    [self fetchMovieList:NO];
}


- (void)fetchMovieList:(BOOL)isTop{
    NSString *url = self.rootUrl;
    NSDictionary *params = @{
                             @"type":self.type,
                             @"size":@(REQUEST_PAGE_SIZE),
                             @"page":@(_currentPage),
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
                                                NSArray *movieList = [IHYMovieModel mj_objectArrayWithKeyValuesArray:responseModel.result];
                                                
                                                if (movieList.count) {
                                                    (weakSelf.currentPage == 0) ? [weakSelf.movieList removeAllObjects] : NULL;
                                                }
                                                [self.movieList addObjectsFromArray:movieList];
                                                [self.movieCollectionView reloadData];
                                                [weakSelf endRefresh];
                                            } failed:^(NSString *errorDescription) {
                                                [weakSelf endRefresh];
                                            }];
}
#pragma mark - 代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _movieList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IHPMovieCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:MovieListViewController_movieCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    IHYMovieModel * movieModel = _movieList[indexPath.row];
    [cell cellWithMovieModel:movieModel];
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    IHYMovieModel * movieModel = _movieList[indexPath.row];
    //    IHYMovieDetailViewController * movieDetailVC = [[IHYMovieDetailViewController alloc] init];
    //    movieDetailVC.movieModel = movieModel;
    //    [self.navigationController pushViewController:movieDetailVC animated:YES];
    
    IHYMovieModel * movieModel = _movieList[indexPath.row];
    IHPPlayerViewController * movieDetailVC = [[IHPPlayerViewController alloc] init];
    movieDetailVC.movieModel = movieModel;
    [self.navigationController pushViewController:movieDetailVC animated:YES];
    
    
}
#pragma mark - 点击事件处理

#pragma mark - 其他私有方法

- (void)endRefresh{
    [_movieCollectionView.mj_header endRefreshing];
    [_movieCollectionView.mj_footer endRefreshing];
    if (_movieList.count%REQUEST_PAGE_SIZE > 0) {
        [self.movieCollectionView.mj_footer endRefreshingWithNoMoreData];
    }
}
#pragma mark - 内存管理相关
- (void)movieListViewControllerDataInit{
    self.movieList = [[NSMutableArray alloc] initWithCapacity:0];
}
@end
