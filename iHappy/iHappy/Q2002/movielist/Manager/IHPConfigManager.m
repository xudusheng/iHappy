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

@property (nonatomic, assign) XDSSkipModel *launch_pop;//启动广告
@property (nonatomic, assign) XDSSkipModel *home_pop;//首页广告
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
    IHPConfigModel *configModel = [IHPConfigModel mj_objectWithKeyValues:configData];
    [self setConfigModel:configModel];
    
    if (self.launch_pop_list.count > 0) {
        NSInteger index = arc4random()%(self.launch_pop_list.count -1);
        self.launch_pop =[IHPConfigManager shareManager].launch_pop_list[index];
    }

    if (self.home_pop_list.count > 0) {
        NSInteger index = arc4random()%(self.home_pop_list.count -1);
        self.home_pop =[IHPConfigManager shareManager].home_pop_list[index];
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

- (NSArray<XDSSkipModel *> *)launch_pop_list {
    return _configModel.launch_pop_list;
}
- (NSArray<XDSSkipModel *> *)home_pop_list {
    return _configModel.home_pop_list;
}
- (void)setConfigModel:(IHPConfigModel *)configModel{
    _configModel = configModel;
}

- (void)downloadPopImage {
    [_configModel downloadPopImage];
}

- (UIImage *)popImage {
    return _configModel.popImage;
}
- (void)setPopImage:(UIImage *)popImage {
    _configModel.popImage = popImage;
}

- (XDSSkipModel *)launch_pop {
    return self->_launch_pop;
}
- (XDSSkipModel *)home_pop {
    return self->_home_pop;
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
