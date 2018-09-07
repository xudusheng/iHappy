//
//  IHYHomsSearchViewController.m
//  iHappy
//
//  Created by dusheng.xu on 2017/5/5.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHYHomsSearchViewController.h"
#import "IHYMovieListViewController.h"
@interface IHYHomsSearchViewController ()<PYSearchViewControllerDelegate>

@property (strong, nonatomic) IHYMovieListViewController *resultVC;

@end

@implementation IHYHomsSearchViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchBar.text.length) {
        return;
    }
    
    self.searchBar.placeholder = self.searchPlaceholder;
    
    //    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    //    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [self.cancelButton setTitle:XDSLocalizedString(@"bx.search.cancel.title", nil) forState:UIControlStateNormal];
    
    //    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    //    [self setSearchBarBackgroundColor:[UIColor bsnlcolor_F5F5F5]];
    
    self.searchHistoryStyle = PYSearchHistoryStyleBorderTag;
    self.hotSearchStyle = PYHotSearchStyleBorderTag;
    self.swapHotSeachWithSearchHistory = YES;
    //    self.hotSearchTitle = XDSLocalizedString(@"bx.search.hotsearch.title", nil);
    //    self.searchHistoryTitle = XDSLocalizedString(@"bx.search.historysearch.title", nil);
    [self.emptyButton setTitle:@"" forState:UIControlStateNormal];
    //    self.emptyButton.x += self.emptyButton.width/2;
    //    self.emptyButton.width /= 2;
    
    
    self.searchHistoriesCount = 10;
    
    
    self.searchResultShowMode = PYSearchResultShowModeEmbed;
    self.searchResultController = self.resultVC;
    
    self.delegate = self;
}

#pragma mark - UI相关

#pragma mark - 事件响应处理
- (void)cancelButtonClick
{
    [self.searchBar resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark - 其他私有方法

#pragma mark - 网络请求

#pragma mark - 代理方法
- (void)searchViewController:(PYSearchViewController *)searchViewController
      didSearchWithSearchBar:(UISearchBar *)searchBar
                  searchText:(NSString *)searchText {
    self.resultVC.keyword = searchText;
}

- (void)searchViewController:(PYSearchViewController *)searchViewController
   didSelectHotSearchAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText{
    self.resultVC.keyword = searchText;
}

- (void)searchViewController:(PYSearchViewController *)searchViewController
didSelectSearchHistoryAtIndex:(NSInteger)index
                  searchText:(NSString *)searchText {
    self.resultVC.keyword = searchText;
    
}
#pragma mark - setter & getter
- (UIViewController *)searchResultController {
    if (!_resultVC) {
        _resultVC = [[IHYMovieListViewController alloc] init];
    }
    return _resultVC;
}
#pragma mark - 内存管理相关


@end
