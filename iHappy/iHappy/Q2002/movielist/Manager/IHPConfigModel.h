//
//  IHPConfigModel.h
//  iHappy
//
//  Created by dusheng.xu on 2017/4/25.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "IHPForceUpdateModel.h"
#import "IHPMenuModel.h"
#import "XDSAdInfoModel.h"
#import "XDSSkipModel.h"
@interface IHPConfigModel : NSObject

@property (strong, nonatomic) IHPForceUpdateModel *forceUpdate;
@property (strong, nonatomic) XDSAdInfoModel *adInfo;
@property (strong, nonatomic) NSArray<IHPMenuModel*> *menus;
@property (strong, nonatomic) NSArray<NSString*> *searchkeys;
@property (strong, nonatomic) NSArray<XDSSkipModel*> *launch_pop_list;//启动广告
@property (strong, nonatomic) NSArray<XDSSkipModel*> *home_pop_list;//首页广告

@end
