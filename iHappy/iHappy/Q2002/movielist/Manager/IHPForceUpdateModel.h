//
//  IHPForceUpdateModel.h
//  iHappy
//
//  Created by dusheng.xu on 2017/4/25.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface IHPForceUpdateModel : JSONModel

@property (assign, nonatomic) BOOL enable;//是否需要升级
@property (assign, nonatomic) BOOL isForce;//是否强制升级
@property (copy, nonatomic) NSString *updateMessage;//升级信息
@property (copy, nonatomic) NSString *url;//升级下载地址url;
@property (copy, nonatomic) NSString *ios_download_url;//升级下载地址ios_download_url;
@property (nonatomic,copy) NSString *version;//版本号

@end
