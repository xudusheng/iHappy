
//
//  IHPConfigManager.h
//  iHappy
//
//  Created by dusheng.xu on 2017/4/23.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHPConfigModel.h"
#import "IHYHiddenModel.h"
#import "XDSAdInfoModel.h"

#import "XDSSkipModel.h"
@interface IHPConfigManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, readonly) IHPForceUpdateModel *forceUpdate;
@property (nonatomic, readonly) XDSAdInfoModel *adInfo;
@property (nonatomic, readonly) NSArray<IHPMenuModel *> *menus;
@property (strong, nonatomic) NSArray<NSString*> *searchkeys;
@property (nonatomic, readonly) NSArray<XDSSkipModel *> *launch_pop_list;//启动广告
@property (nonatomic, readonly) NSArray<XDSSkipModel *> *home_pop_list;//首页广告

- (void)configManagerWithJsondData:(NSData *)configData;
- (void)configHiddenModelWithJsondData:(NSData *)hiddenModelData;

@end
