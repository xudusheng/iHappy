//
//  XDS_CustomMjRefreshHeader.h
//  iHappy
//
//  Created by Hmily on 2018/8/9.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//


#import <MJRefresh/MJRefresh.h>

@interface XDS_CustomMjRefreshHeader : MJRefreshHeader

@property (nonatomic, assign) BOOL hideLineImgBool;//隐藏虚线
@property (nonatomic, strong) UIColor *titleColor;

@end
