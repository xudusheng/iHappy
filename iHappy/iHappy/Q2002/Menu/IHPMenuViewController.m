//
//  IHPMenuViewController.m
//  iHappy
//
//  Created by dusheng.xu on 2017/4/25.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPMenuViewController.h"
#import "AppDelegate.h"
#import "XDSMainReaderVC.h"
@interface IHPMenuViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *menuTable;
@property (copy, nonatomic) NSArray *menuList;
@end

@implementation IHPMenuViewController
static NSString *kMenuTableViewCellIdentifier = @"MenuTableViewCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    [self menuViewControllerDataInit];
    [self createMenuViewControllerUI];
}


#pragma mark - UI相关
- (void)createMenuViewControllerUI{
    self.menuTable = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kMenuTableViewCellIdentifier];
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        tableView;
    });
}

#pragma mark - 网络请求

#pragma mark - 代理方法
#pragma mark UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _menuList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *sectionArray = _menuList[section];
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuTableViewCellIdentifier forIndexPath:indexPath];
    
    IHPMenuModel *theMenu = _menuList[indexPath.section][indexPath.row];
    cell.textLabel.text = theMenu.title;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IHPMenuModel *theMenu = _menuList[indexPath.section][indexPath.row];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.mainmeunVC hideMenuViewController];
    delegate.mainmeunVC.contentViewController = theMenu.contentViewController;

}


#pragma mark - XDSSideMenuDelegate

#pragma mark - 点击事件处理

#pragma mark - 其他私有方法

#pragma mark - 内存管理相关
- (void)menuViewControllerDataInit{
    self.menuList = [IHPConfigManager shareManager].menus;
    
    NSArray<IHPMenuModel *> *menus = [IHPConfigManager shareManager].menus;
    NSMutableArray *firstSectionArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *secondSectionArray = [NSMutableArray arrayWithCapacity:0];
    for (IHPMenuModel *menu in menus) {
        if (menu.type == IHPMenuTypeWelfare || menu.type == IHPMenuTypeSetting) {
            [secondSectionArray addObject:menu];
        }else {
            [firstSectionArray addObject:menu];
        }
    }
    
    self.menuList = [NSArray arrayWithObjects:firstSectionArray, secondSectionArray, nil];
}



@end
