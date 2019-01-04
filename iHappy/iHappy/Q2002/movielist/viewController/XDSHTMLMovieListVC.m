//
//  IHYMovieListViewController.m
//  iHappy
//
//  Created by xudosom on 2016/11/19.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import "XDSHTMLMovieListVC.h"
#import "XDSHTMLMovieModel.h"
#import "IHPMovieCell.h"
#import "XDSImageItemAdCell.h"

#import "XDSHTMLPlayerVC.h"
@interface XDSHTMLMovieListVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSMutableArray<XDSHTMLMovieModel *> * movieList;
@property (strong, nonatomic) UICollectionView * movieCollectionView;

@property (copy, nonatomic) NSString *firstPageUrl;
@property (copy, nonatomic) NSString *nextPageUrl;

@end

@implementation XDSHTMLMovieListVC

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
    
    [_movieCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([IHPMovieCell class]) bundle:nil]
           forCellWithReuseIdentifier:NSStringFromClass([IHPMovieCell class])];
    [_movieCollectionView registerClass:[XDSImageItemAdCell class]
             forCellWithReuseIdentifier:NSStringFromClass([XDSImageItemAdCell class])];
    
    [_movieCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    _movieCollectionView.mj_header = [XDS_CustomMjRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRequest)];
    _movieCollectionView.mj_footer = [XDS_CustomMjRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRequest)];
}

#pragma mark - 网络请求
- (void)headerRequest{
    [self fetchMovieList:YES];
    [_movieCollectionView.mj_footer resetNoMoreData];
}
- (void)footerRequest{
    if (_nextPageUrl.length) {
        [self fetchMovieList:NO];
    }
}
#pragma mark - 代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _movieList.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSHTMLMovieModel *movieModel = _movieList[indexPath.row];
    
    if (movieModel.href.length > 0) {
        IHPMovieCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([IHPMovieCell class]) forIndexPath:indexPath];
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        XDSHTMLMovieModel *movieModel = _movieList[indexPath.row];
        [cell cellWithHTMLMovieModel:movieModel];
        return cell;
    }else {
        XDSImageItemAdCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([XDSImageItemAdCell class]) forIndexPath:indexPath];
        [cell p_loadCell];
        return cell;
    }
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    XDSHTMLMovieModel *movieModel = _movieList[indexPath.row];
    XDSHTMLPlayerVC *movieDetailVC = [[XDSHTMLPlayerVC alloc] init];
    movieDetailVC.htmlMovieModel = movieModel;
    [self.navigationController pushViewController:movieDetailVC animated:YES];
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:movieDetailVC];
//    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
#pragma mark - 点击事件处理
- (void)fetchMovieList:(BOOL)isTop{
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:isTop?_firstPageUrl:_nextPageUrl
                                         hudController:self
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   if (success) {
                                                       [weakSelf detailHtmlData:htmlData needClearOldData:isTop];
                                                   }else{
                                                       [XDSUtilities showHud:@"数据请求失败，请稍后重试" rootView:self.navigationController.view hideAfter:1.2];
                                                   }
                                                   [weakSelf endRefresh];
                                               } failed:^(NSString *errorDescription) {
                                                   [weakSelf endRefresh];
                                               }];
}

#pragma mark - 其他私有方法

- (void)endRefresh{
    [XDSUtilities hideHud:self.view];
    [_movieCollectionView.mj_header endRefreshing];
    [_movieCollectionView.mj_footer endRefreshing];
    if (!self.nextPageUrl.length) {
        [_movieCollectionView.mj_footer endRefreshingWithNoMoreData];
    }else {
        [_movieCollectionView.mj_footer resetNoMoreData];
    }
}
- (void)detailHtmlData:(NSData *)htmlData needClearOldData:(BOOL)needClearOldData{
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray * pageElements = [hpp searchWithXPathQuery:@"//div[@class =\"pages\"]//ul"];
    
    if (pageElements.count > 0) {
        TFHppleElement * pageElement = pageElements.firstObject;
        NSArray * childElements = [pageElement childrenWithTagName:@"li"];
        self.nextPageUrl = nil;
        for (int i = 0; i < childElements.count; i ++) {
            TFHppleElement * li_element = childElements[i];
            NSString * className = [li_element objectForKey:@"class"];
            if ([className isEqualToString:@"on"] && i + 1 < childElements.count) {
                TFHppleElement * nextPage_element = childElements[i+1];
                NSString * nextHref =  [[nextPage_element firstChildWithTagName:@"a"] objectForKey:@"href"];
                self.nextPageUrl =nextHref;
                break;
            }
        }
    }else{
        self.nextPageUrl = nil;
    }
    
    
    NSArray * rowElements = [hpp searchWithXPathQuery:@"//li[@class=\"p1 m1\"]"];
    NSMutableArray * newMovies = [NSMutableArray arrayWithCapacity:0];
    for (TFHppleElement * oneElements in rowElements) {
        TFHppleElement * a_link_hover =  [oneElements firstChildWithClassName:@"link-hover"];//跳转地址
        TFHppleElement * image_lazy =  [a_link_hover firstChildWithClassName:@"lazy"];//图片
        
        TFHppleElement * span_lzbz =  [a_link_hover firstChildWithClassName:@"lzbz"];
        TFHppleElement * p_name = [span_lzbz firstChildWithClassName:@"name"];//名称
        TFHppleElement * p_actor =  [span_lzbz childrenWithClassName:@"actor"].lastObject;//更新时间
        TFHppleElement * p_other =  [a_link_hover firstChildWithClassName:@"other"];//其他描述
        
        NSString * name = p_name.text;
        NSString * href = [a_link_hover objectForKey:@"href"];
        NSString * update = p_actor.text;
        NSString * other = p_other.text;
        
        NSString * imageurl = [image_lazy objectForKey:@"src"];

        if (imageurl && [imageurl hasPrefix:@"//"]) {
            imageurl = [@"http:" stringByAppendingString:imageurl];
        }
        
        NSLog(@"%@", href);

        
        //过滤需要禁止显示的url
        NSString *fullHref = [self.menuModel.rooturl stringByAppendingString:href];
        if ([self.menuModel.unavailible_url_list containsObject:fullHref] || [self.menuModel.unavailible_url_list containsObject:href]) {
            continue;
        }

        XDSHTMLMovieModel *model = [[XDSHTMLMovieModel alloc] init];
        model.name = name;
        model.href = href;
        model.imageurl = imageurl;
        model.update = update;
        model.other = other;
        [newMovies addObject:model];
        
        
        if ([[XDSAdManager sharedManager] isAdAvailible] && (newMovies.count + _movieList.count)%[IHPConfigManager shareManager].adInfo.index  == 0) {
            XDSHTMLMovieModel *model = [[XDSHTMLMovieModel alloc] init];
            [newMovies addObject:model];
        }
    }
    if (newMovies.count > 0) {
        if (needClearOldData) {
            [_movieList removeAllObjects];
        }
        [_movieList addObjectsFromArray:newMovies];
        [_movieCollectionView reloadData];
    }else{
        [_movieCollectionView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)setSubMenuModel:(IHPSubMenuModel *)subMenuModel {
    _subMenuModel = subMenuModel;
    self.firstPageUrl = subMenuModel.url;
    
    [XDSUtilities showHud:self.view text:nil];
    [self headerRequest];
}
#pragma mark - 内存管理相关
- (void)movieListViewControllerDataInit{
    self.movieList = [[NSMutableArray alloc] initWithCapacity:0];
}
@end
