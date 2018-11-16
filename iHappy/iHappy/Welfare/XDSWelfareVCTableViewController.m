//
//  XDSWelfareVCTableViewController.m
//  iHappy
//
//  Created by Hmily on 2018/11/16.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSWelfareVCTableViewController.h"
#import "XDSWelfareWebViewController.h"
@interface XDSWelfareVCTableViewController ()

@property (nonatomic,strong) NSArray *channelList;
@end

@implementation XDSWelfareVCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataInit];
}

#pragma mark - UI相关

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channelList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *channel = self.channelList[indexPath.row];
    cell.textLabel.text = channel[@"title"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *channel = self.channelList[indexPath.row];
    NSString *url = channel[@"url"];
    
    XDSWelfareWebViewController *webVC = [[XDSWelfareWebViewController alloc] init];
    webVC.requestURL = url;
    [self.navigationController pushViewController:webVC animated:YES];
    
}
#pragma mark - event response 事件响应处理

#pragma mark - private method 其他私有方法

#pragma mark - setter & getter

#pragma mark - memery 内存管理相关
- (void)dataInit {
    self.channelList = @[@{@"title":@"爱奇艺", @"url":@"https://www.iqiyi.com"},
                        @{@"title":@"腾讯视频", @"url":@"https://v.qq.com"},
                        @{@"title":@"优酷", @"url":@"https://www.youku.com"},
                        @{@"title":@"土豆", @"url":@"http://www.tudou.com"},
                        @{@"title":@"芒果TV", @"url":@"https://www.mgtv.com"},
                        @{@"title":@"乐视网", @"url":@"http://www.le.com"},
                        ];
}


@end
