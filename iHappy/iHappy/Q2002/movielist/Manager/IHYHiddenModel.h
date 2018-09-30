//
//  IHYHiddenModel.h
//  iHappy
//
//  Created by Hmily on 2018/9/30.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IHYHiddenItemModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol IHYHiddenItemModel;
@interface IHYHiddenModel : JSONModel

@property (nonatomic,copy) NSArray<IHYHiddenItemModel> *unavailible_url_list;

@end

NS_ASSUME_NONNULL_END
