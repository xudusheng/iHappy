//
//  XDSNewsModel.m
//  iHappy
//
//  Created by Hmily on 2018/8/31.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSNewsModel.h"

@implementation XDSNewsResponstModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"newsList":@"XDSNewsModel",
             };
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"newsList":@"data"};
}

@end




@implementation XDSNewsModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"imageUrls":@"NSString",
             };
}


- (BOOL)isMultableImageNews{
    return (self.imageUrls.count > 1);
}


@end
