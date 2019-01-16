//
//  BSNL_ChooseAreaNumberViewController.m
//  BiXuan
//
//  Created by ayi on 2018/7/12.
//  Copyright © 2018年 BSNL. All rights reserved.
//

#import "ChooseAreaNumberViewController.h"


#import "LoginViewModel.h"
@interface ChooseAreaNumberViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *listAry;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation ChooseAreaNumberViewController

- (NSMutableArray *)listAry{if(!_listAry)_listAry = [NSMutableArray arrayWithCapacity:0];return _listAry;}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"nav_return_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.title = @"选择你所在的地区";
    self.tableview.tableFooterView = [UIView new];
    self.tableview.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self dataFromNetWithNew:YES];
    [self addMjfresh];
}

- (void)addMjfresh{
    __weak typeof(self) weakself = self;;
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself dataFromNetWithNew:YES];
    }];
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakself dataFromNetWithNew:NO];
    }];
}

- (void)dataFromNetWithNew:(BOOL)isNew{
    if (isNew) {
        self.pageIndex = 1;
    }
    __weak typeof(self) weakself = self;;
    [LoginViewModel mobileRegionAPIActionWithParam:@{@"page_no":@(self.pageIndex)} andSuccess:^(id response) {//@{@"page_no":@(self.pageIndex)}
        NSArray *ary = response;
        if (weakself.pageIndex==1) {
            [weakself.listAry removeAllObjects];
        }
        [weakself.listAry addObjectsFromArray:ary];
        [weakself.tableview reloadData];
        weakself.pageIndex ++;
        [weakself.tableview.mj_footer endRefreshing];
        [weakself.tableview.mj_header endRefreshing];
    } andFail:^(NSError *error) {
        [weakself.tableview.mj_footer endRefreshing];
        [weakself.tableview.mj_header endRefreshing];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.listAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellDefault"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCellDefault"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    }
    cell.textLabel.text = self.listAry[indexPath.row][@"region"];
    cell.detailTextLabel.text = self.listAry[indexPath.row][@"region_code"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.areaCallBack) {
        self.areaCallBack(self.listAry[indexPath.row]);
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
