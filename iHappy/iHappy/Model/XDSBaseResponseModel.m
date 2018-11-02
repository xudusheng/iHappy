//
//  XDSBaseResponseModel.m
//  iHappy
//
//  Created by Hmily on 2018/9/6.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSBaseResponseModel.h"

@implementation XDSBaseResponseModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"errormessage":@"msg",
             @"error_code":@"code",
             @"result":@"data",
             };
}
@end
