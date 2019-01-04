//
//  XDSSettingVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/4.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSSettingVC.h"
#import "BXRetailStoreGuideVC.h"

@interface XDSSettingVC ()
@property (weak, nonatomic) IBOutlet UILabel *memeryLabel;

@end

@implementation XDSSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUsedMemerySize];
}

#pragma mark - UI相关

#pragma mark - request method 网络请求

#pragma mark - delegate method 代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        BXRetailStoreGuideVC *guideVC = [[BXRetailStoreGuideVC alloc] init];
        [self.navigationController pushViewController:guideVC animated:YES];

    }else if (indexPath.section == 0 && indexPath.row == 1) {
        [self clearMemery];
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        [self shareAction];
    }
}
#pragma mark - event response 事件响应处理

#pragma mark - private method 其他私有方法
- (void)clearMemery {
    __weak typeof(self)weakSelf = self;
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [XDSUtilities showHudSuccess:@"缓存清理成功~" rootView:self.view imageName:nil];
        [weakSelf setUsedMemerySize];
    }];
}

- (void)setUsedMemerySize{
    [[SDImageCache sharedImageCache]calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        long long sizeLength = totalSize;
        NSString *sizeString = @"";
        if (sizeLength < 1024) {// 小于1k
                sizeString = [NSString stringWithFormat:@"%ldB",(long)sizeLength] ;
        }else if (sizeLength < 1024 * 1024){// 小于1m
            CGFloat aFloat = sizeLength/1024;
            sizeString = [NSString stringWithFormat:@"%.0fK",aFloat];
        }else if (sizeLength < 1024 * 1024 * 1024){// 小于1G
            CGFloat aFloat = sizeLength/(1024 * 1024);
                sizeString = [NSString stringWithFormat:@"%.1fM",aFloat];
        }else{
            CGFloat aFloat = sizeLength/(1024*1024*1024);
                sizeString = [NSString stringWithFormat:@"%.1fG",aFloat];
        }
        self.memeryLabel.text = sizeString;
    }];
}
- (void)shareAction {
    NSURL *urlToShare = [NSURL URLWithString:[IHPConfigManager shareManager].forceUpdate.url];
    NSArray *activityItems = @[urlToShare];
    [self shareWithContentArray:activityItems];
    
}

- (void)shareWithContentArray:(NSArray *)contentArray {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:contentArray applicationActivities:nil];
    activityVC.completionWithItemsHandler = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError) {
        NSLog(@"%@", activityType);
        if (completed) { // 确定分享
            NSLog(@"分享成功");
        } else {
            NSLog(@"分享失败");
        }
    };
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

#pragma mark - setter & getter

#pragma mark - memery 内存管理相关

@end
