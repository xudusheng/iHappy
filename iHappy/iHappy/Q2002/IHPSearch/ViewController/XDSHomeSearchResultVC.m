//
//  XDSHomeSearchResultVC.m
//  iHappy
//
//  Created by Hmily on 2018/9/27.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSHomeSearchResultVC.h"

#import "IHYMovieModel.h"
#import "IHPMovieCell.h"

#import "IHYMovieDetailViewController.h"
#import "IHPPlayerViewController.h"
@interface XDSHomeSearchResultVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray<IHYMovieModel *> * movieList;
@property (strong, nonatomic) UICollectionView * movieCollectionView;
@property (copy, nonatomic) NSString * nextPageUrl;
@property (nonatomic,assign) NSInteger currentPage;
@end

@implementation XDSHomeSearchResultVC

NSString * const XDSHomeSearchResultVC_movieCellIdentifier = @"XDSHomeSearchResultVC_movieCell";

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
    
    [_movieCollectionView registerNib:[UINib nibWithNibName:@"IHPMovieCell" bundle:nil] forCellWithReuseIdentifier:XDSHomeSearchResultVC_movieCellIdentifier];
    [_movieCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - 网络请求

- (void)fetchMovieList{
    NSString *url = self.rootUrl;
    NSDictionary *params = @{
                             @"keyword":self.keyword
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
                                                [weakSelf.movieList removeAllObjects];
                                                [self.movieList addObjectsFromArray:movieList];
                                                [self.movieCollectionView reloadData];
                                            } failed:^(NSString *errorDescription) {
                                            }];
}
#pragma mark - 代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _movieList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IHPMovieCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:XDSHomeSearchResultVC_movieCellIdentifier forIndexPath:indexPath];
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
- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    [self fetchMovieList];
}
#pragma mark - 内存管理相关
- (void)movieListViewControllerDataInit{
    self.movieList = [[NSMutableArray alloc] initWithCapacity:0];
}

@end
