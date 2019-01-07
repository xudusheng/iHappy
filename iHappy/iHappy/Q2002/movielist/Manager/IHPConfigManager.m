//
//  IHPConfigManager.m
//  iHappy
//
//  Created by dusheng.xu on 2017/4/23.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHPConfigManager.h"
@interface IHPConfigManager()
@property (strong, nonatomic) IHPConfigModel *configModel;
@end
@implementation IHPConfigManager

+ (instancetype)shareManager{
    static IHPConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IHPConfigManager alloc] init];
    });
    return manager;
}

- (void)configManagerWithJsondData:(NSData *)configData{
    NSError* err = nil;
    IHPConfigModel *configModel = [[IHPConfigModel alloc] initWithData:configData error:&err];
    if (!err) {
        [self setConfigModel:configModel];
    }else{
        NSLog(@"error = %@", err);
    }
}

- (IHPForceUpdateModel *)forceUpdate{
    return _configModel.forceUpdate;
}
- (XDSAdInfoModel *)adInfo {
    return _configModel.adInfo;
}
- (NSArray<NSString *> *)searchkeys {
    return _configModel.searchkeys;
}
- (NSArray<IHPMenuModel *> *)menus{
    NSMutableArray *availibleMenus = [NSMutableArray arrayWithCapacity:0];
    for (IHPMenuModel *aMenuModel in _configModel.menus) {
        if (aMenuModel.enable) {
            [availibleMenus addObject:aMenuModel];
        }
    }
    return availibleMenus;
}

- (void)setConfigModel:(IHPConfigModel *)configModel{
    _configModel = configModel;
}


- (void)configHiddenModelWithJsondData:(NSData *)hiddenModelData {
    NSError* err = nil;
    IHYHiddenModel *hiddenModel = [[IHYHiddenModel alloc] initWithData:hiddenModelData error:&err];
    if (!err) {
        for (IHPMenuModel *menuModel in self.menus) {
            for (IHYHiddenItemModel *hiddenItem in hiddenModel.unavailible_url_list) {
                if ([menuModel.menuId isEqualToString:hiddenItem.menuId]) {
                    menuModel.unavailible_url_list = hiddenItem.unavailible_url_list;
                }
            }
        }
    }else{
        NSLog(@"error = %@", err);
    }
}

@end
