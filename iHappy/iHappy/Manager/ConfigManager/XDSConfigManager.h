//
//  XDSConfigManager.h
//  Kit
//
//  Created by Hmily on 2018/7/22.
//  Copyright © 2018年 Hmily. All rights reserved.
//

#import "XDSBaseManager.h"
#import "XDSConfigItem.h"
@interface XDSConfigManager : XDSBaseManager

+ (XDSConfigManager *)sharedManager;

@property (nonatomic, strong) XDSConfigItem *configItem;

- (void)fetchAppConfigWithURL:(NSString *)urlString;

@end

extern NSString * const XDSConfigItemRefreshNotification;
