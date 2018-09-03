//
//  IHYNewsListViewController.m
//  iHappy
//
//  Created by zhengda on 16/11/21.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHYNewsListViewController.h"
#import "IHYNewsListCell.h"
#import "IHYNewsMultableImageCell.h"
#import "XDSNewsModel.h"
@interface IHYNewsListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *newsTableView;
@property (strong, nonatomic) NSMutableArray<XDSNewsModel*> *newsList;

@property (nonatomic,assign) NSInteger currentPage;

@end

@implementation IHYNewsListViewController
NSString * const IHYNewsListViewController_IHYNewsListCellIdentifier = @"IHYNewsListCell";
NSString * const IHYNewsListViewController_IHYNewsMultableImageCellIdentifier = @"IHYNewsMultableImageCell";

- (void)dealloc{
    NSLog(@"%@ ==> dealloc", [self class]);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self newsListViewControllerDataInit];
    [self createNewsListViewControllerUI];
}

#pragma mark - UI相关
- (void)createNewsListViewControllerUI{
    self.newsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _newsTableView.delegate = self;
    _newsTableView.dataSource = self;
    _newsTableView.sectionHeaderHeight = CGFLOAT_MIN;
    [self.view addSubview:_newsTableView];
    [_newsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [_newsTableView registerNib:[UINib nibWithNibName:IHYNewsListViewController_IHYNewsListCellIdentifier bundle:nil]
         forCellReuseIdentifier:IHYNewsListViewController_IHYNewsListCellIdentifier];
    [_newsTableView registerNib:[UINib nibWithNibName:IHYNewsListViewController_IHYNewsMultableImageCellIdentifier bundle:nil]
         forCellReuseIdentifier:IHYNewsListViewController_IHYNewsMultableImageCellIdentifier];
    
    self.newsTableView.mj_header = [XDS_CustomMjRefreshHeader headerWithRefreshingBlock:^{
        [self fetchNewsListTop];
    }];
    
    __weak typeof(self)weakSelf = self;
    self.newsTableView.mj_footer = [XDS_CustomMjRefreshFooter footerWithRefreshingBlock:^{
        [weakSelf fetchNewsListBottom];
    }];

    [XDSUtilities showHud:self.view text:nil];
    [self fetchNewsListTop];
}

#pragma mark - 网络请求
- (void)fetchNewsListBottom {
    
}
- (void)fetchNewsListTop{
    __weak typeof(self)weakSelf = self;
    NSString *url = [NSString stringWithFormat:@"http://120.76.205.241:8000/news/qihoo?kw=头条&apikey=cz1wjvkzGtuomNDXgLxmdq5aIwgytQvHHe0Dc8OcfHQva6hKQgDoDyBdUAQngGt6&pageToken=%ld", _currentPage];
    [[[XDSHttpRequest alloc] init] GETWithURLString:url
                                           reqParam:nil
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:YES
                                            success:^(BOOL success, NSDictionary *successResult) {
                                                [weakSelf.newsTableView.mj_header endRefreshing];
                                                [weakSelf.newsTableView.mj_footer endRefreshing];
                                                XDSNewsResponstModel *responseModel = [XDSNewsResponstModel mj_objectWithKeyValues:successResult];
                                                if (responseModel.hasNext) {
                                                    [weakSelf.newsTableView.mj_footer endRefreshingWithNoMoreData];
                                                }
                                                
                                                (weakSelf.currentPage == 0) ? [weakSelf.newsList removeAllObjects] : NULL;
                                                [weakSelf.newsList addObjectsFromArray:responseModel.newsList];
                                                [weakSelf.newsTableView reloadData];
                                                
                                            } failed:^(NSString *errorDescription) {
                                                [weakSelf.newsTableView.mj_header endRefreshing];
                                                [weakSelf.newsTableView.mj_footer endRefreshing];
                                            }];
}

#pragma mark - 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _newsList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XDSNewsModel *newsModel = _newsList[indexPath.row];
    
    CGFloat imageWidth = (DEVIECE_SCREEN_WIDTH - 10*4)/3;
    CGFloat imageHeight = imageWidth*3/4;
    
    return imageHeight + (newsModel.isMultableImageNews?70:20);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XDSNewsModel *newsModel = _newsList[indexPath.row];
    
    if (newsModel.isMultableImageNews) {
        IHYNewsMultableImageCell *cell = [tableView dequeueReusableCellWithIdentifier:IHYNewsListViewController_IHYNewsMultableImageCellIdentifier forIndexPath:indexPath];
        [cell cellWithNewsModel:newsModel];
        return cell;
        
    }else{
        IHYNewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:IHYNewsListViewController_IHYNewsListCellIdentifier forIndexPath:indexPath];
        [cell cellWithNewsModel:newsModel];
        return cell;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    XDSNewsModel *newsModel = _newsList[indexPath.row];
    XDSWebViewController * webVC = [[XDSWebViewController alloc] init];
    webVC.requestURL = newsModel.url;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark - 点击事件处理

#pragma mark - 其他私有方法

#pragma mark - 内存管理相关
- (void)newsListViewControllerDataInit{
    //    http://v.juhe.cn/toutiao/index?type=top&key=f2b9c5a8243bc824253119ba09f7759a
    self.newsList = [[NSMutableArray alloc] initWithCapacity:0];
}


@end
