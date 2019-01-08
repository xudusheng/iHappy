//
//  XDSSkipModel.h
//  iHappy
//
//  Created by Hmily on 2019/1/8.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDSSkipModel : JSONModel

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *pic;
@property (assign, nonatomic) NSInteger type;//跳转类型，0H5
@property (copy, nonatomic) NSString *type_val;//值，配合类型使用，如类型为h5，则值为URL地址

@end

NS_ASSUME_NONNULL_END
