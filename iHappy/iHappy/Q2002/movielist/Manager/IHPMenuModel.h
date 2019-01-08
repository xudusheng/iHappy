//
//  IHPMenuModel.h
//  iHappy
//
//  Created by dusheng.xu on 2017/4/23.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHPSubMenuModel.h"

typedef NS_ENUM(NSInteger, IHPMenuType) {
    IHPMenuTypeReader   = 0,
    IHPMenuTypeQ2002    = 1,
    IHPMenuTypeVideo    = 2,
    IHPMenuTypeJuheNews = 3,
    IHPMenuTypeBizhi    = 4,
    IHPMenuTypeShuaige    = 5,
    IHPMenuTypeWelfare  = 6,
    IHPMenuTypeSetting = 100,
};
@interface IHPMenuModel : NSObject
@property (copy, nonatomic) NSString *title;//模块标题
@property (copy, nonatomic) NSString *menuId;//模块ID
@property (assign, nonatomic) IHPMenuType type;//模块类型
@property (copy, nonatomic) NSString *rooturl;//基础URL
@property (assign, nonatomic) BOOL enable;//模块是否可用，可用则显示，不可以则不显示，苹果审核期间《关闭》需要提交授权文件的模块。
@property (copy, nonatomic) NSArray<IHPSubMenuModel*> *subMenus;
@property (copy, nonatomic) NSArray *unavailible_url_list;//不可用的URL列表

@property (strong, nonatomic, readonly) UINavigationController *contentViewController;//这个model下的controller，单例

@end
