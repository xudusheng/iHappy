//
//  IHPConfigModel.m
//  iHappy
//
//  Created by dusheng.xu on 2017/4/25.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPConfigModel.h"

@implementation IHPConfigModel

+(NSDictionary *)mj_objectClassInArray {
    return @{
             @"menus":@"IHPMenuModel",
             @"launch_pop_list":@"XDSSkipModel",
             @"home_pop_list":@"XDSSkipModel",
             };
}


- (void)downloadPopImage {
    if (self.home_pop_list.count < 1) {
        return;
    }
    
    XDSSkipModel *home_pop =[IHPConfigManager shareManager].home_pop;
    
    if (home_pop.pic.length > 0) {
        __weak typeof(self)weakSelf = self;
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:home_pop.pic]
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                      weakSelf.popImage = image;
                                                  }];
    }
}

@end
