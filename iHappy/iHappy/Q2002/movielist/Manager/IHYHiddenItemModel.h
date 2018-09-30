//
//  IHYHiddenItemModel.h
//  iHappy
//
//  Created by Hmily on 2018/9/30.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Optional;
@interface IHYHiddenItemModel : JSONModel

@property (nonatomic,copy) NSString<Optional> *title;
@property (nonatomic,copy) NSString<Optional> *menuId;
@property (nonatomic,copy) NSArray<Optional> *unavailible_url_list;

@end

NS_ASSUME_NONNULL_END
