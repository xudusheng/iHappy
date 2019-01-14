
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

@property (nonatomic,assign) BOOL isIncheck;//是否正在审核
@property (nonatomic, readonly) IHPForceUpdateModel *forceUpdate;
@property (nonatomic, readonly) XDSAdInfoModel *adInfo;
@property (nonatomic, readonly) NSArray<IHPMenuModel *> *menus;
@property (strong, nonatomic) NSArray<NSString*> *searchkeys;
@property (nonatomic, readonly) NSArray<XDSSkipModel *> *launch_pop_list;//启动广告
@property (nonatomic, readonly) NSArray<XDSSkipModel *> *home_pop_list;//首页广告

//自定义字段
@property (nonatomic, readonly) XDSSkipModel *launch_pop;//启动广告
@property (nonatomic, readonly) XDSSkipModel *home_pop;//首页广告
- (void)downloadPopImage;
@property (nonatomic,strong) UIImage *popImage;

@property (nonatomic, copy) NSString *meizi;//远程下载的美女图片链接
@property (nonatomic, copy) NSString *shuaige;//远程下载的帅哥图片链接

@property (nonatomic, copy) NSString *movieRootUrl;//视频网站的跟路径

- (void)configManagerWithJsondData:(NSData *)configData;
- (void)configHiddenModelWithJsondData:(NSData *)hiddenModelData;

@end
