//
//  IHYMainViewController.m
//  iHappy
//
//  Created by xudosom on 2016/11/19.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHYMainViewController.h"
#import "IHYMovieListViewController.h"
#import "IHPMenuViewController.h"
#import "AppDelegate.h"
#import "IHYNewsListViewController.h"
#import "IHPMeituListViewController.h"

#import "IHYHomsSearchViewController.h"
@interface IHYMainViewController ()<UISearchBarDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation IHYMainViewController

- (void)viewDidLoad {
    self.menuViewStyle = WMMenuViewStyleLine;
    [super viewDidLoad];
    [self mainViewControllerDataInit];
    [self createMainViewControllerUI];
    [self reloadData];
    [[XDSAdManager sharedManager] showInterstitialAD];

}



#pragma mark - UI相关
- (void)createMainViewControllerUI{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    
    CGFloat navHeight = 44;
    CGFloat searchbarHeight = 29;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEVIECE_SCREEN_WIDTH - 66, navHeight)];

    [self configSearchBar];
    _searchBar.frame = CGRectMake(0, navHeight/2 - searchbarHeight/2, CGRectGetWidth(titleView.frame) - searchbarHeight, searchbarHeight);
    
    [titleView addSubview:_searchBar];
    
    self.navigationItem.titleView = titleView;
}

- (void)configSearchBar {
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.searchTextPositionAdjustment = UIOffsetMake(10, 0);
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.placeholder = @"输入搜索关键字";
    self.searchBar = searchBar;
}

- (void)setBarItems{
    if ([IHPConfigManager shareManager].menus.count > 1) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu_icon"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(showMenu)];
        self.navigationItem.leftBarButtonItem = leftItem;
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    if (_menuModel.type < IHPMenuTypeJuheNews) {
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"搜索"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(showSearchVC)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - 网络请求

#pragma mark - 代理方法
#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return _menuModel.subMenus.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    IHPSubMenuModel * model = _menuModel.subMenus[index];
    if (_menuModel.type == IHPMenuTypeJuheNews) {
        IHYNewsListViewController * newsVC = [[IHYNewsListViewController alloc]init];
        newsVC.rootUrl = _menuModel.rooturl;
        newsVC.typeName = model.title;
        return newsVC;
    }else if(_menuModel.type == IHPMenuTypeBizhi){
        IHPMeituListViewController * bizhiVC = [[IHPMeituListViewController alloc]init];
        bizhiVC.rootUrl = _menuModel.rooturl;
        bizhiVC.firstPageUrl = model.url;
        return bizhiVC;
        
    }else{
        IHYMovieListViewController * movieVC = [[IHYMovieListViewController alloc]init];
        movieVC.rootUrl = _menuModel.rooturl;
        movieVC.type = model.url;
        return movieVC;
    }
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    IHPSubMenuModel * model = _menuModel.subMenus[index];
    return model.title;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGRect frame = [UIScreen mainScreen].bounds;
    CGFloat height = DEVIECE_SCREEN_HEIGHT - [self getSafeAreaTop] - [self getSafeAreaBottom] - DEVICE_NAVBAR_HEIGHT - 35;
    frame.origin.y = 35;
    frame.size.height = height;
    return frame;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    menuView.backgroundColor = [UIColor whiteColor];
    CGRect menuFrame = CGRectMake(0, 0, DEVIECE_SCREEN_WIDTH, 35);
    return menuFrame;
}

- (void)pageController:(WMPageController *)pageController lazyLoadViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    NSLog(@"%@", info);
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    NSLog(@"%@", info);
}


- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    NSLog(@"%s", __FUNCTION__);
}

- (void)menuView:(WMMenuView *)menu didLayoutItemFrame:(WMMenuItem *)menuItem atIndex:(NSInteger)index {
    NSLog(@"%@", NSStringFromCGRect(menuItem.frame));
}

#pragma mark - PYSearchViewControllerDelegate
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText {
    if (searchText.length) {
        // Simulate a send request to get a search suggestions
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableArray *searchSuggestionsM = [NSMutableArray array];
            for (int i = 0; i < searchViewController.searchHistories.count; i++) {
                NSString *historySearch = searchViewController.searchHistories[i];
                if ([historySearch.lowercaseString containsString:searchText.lowercaseString]) {
                    [searchSuggestionsM addObject:historySearch];
                }
            }
            // Refresh and display the search suggustions
            searchViewController.searchSuggestions = searchSuggestionsM;
        });
    }else {
        searchViewController.searchSuggestions = @[];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self showSearchVC];
    return NO;
}
#pragma mark - 点击事件处理
//TODO:菜单
- (void)showMenu{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.mainmeunVC presentLeftMenuViewController];
}

//TODO:搜索
- (void)showSearchVC{
    
    IHYHomsSearchViewController *searchVC = [[IHYHomsSearchViewController alloc] init];
    searchVC.searchPlaceholder = @"输入视频关键字";
    searchVC.rootUrl = self.menuModel.rooturl;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    nav.navigationBar.translucent = NO;
    [self presentViewController:nav animated:NO completion:nil];
    
}
#pragma mark - 其他私有方法
- (void)setMenuModel:(IHPMenuModel *)menuModel{
    _menuModel = menuModel;
    self.title = _menuModel.title;
    [self reloadData];
}

#pragma mark - 内存管理相关
- (void)mainViewControllerDataInit{
    
}


//// New Autorotation support.
////是否自动旋转,返回YES可以自动旋转
//- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED {
//    return YES;
//}
////返回支持的方向
//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
//- (NSUInteger)supportedInterfaceOrientations
//#else
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//#endif
//{
//    return UIInterfaceOrientationMaskAll;
//}


@end
