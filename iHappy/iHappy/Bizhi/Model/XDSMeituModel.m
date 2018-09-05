//
//  XDSMeituModel.m
//  iHappy
//
//  Created by Hmily on 2018/8/26.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMeituModel.h"

@implementation XDSMeiziResponseModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"meiziList":@"result"};
}
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"meiziList":@"XDSMeituModel"};
}

@end



@implementation XDSDetaimImageResponseModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"imageList":@"result"};
}
+ (NSDictionary *)mj_objectClassInArray {
    return @{@"imageList":@"XDSDetailImageModel"};
}

@end


@implementation XDSMeituModel

@end

@implementation XDSDetailImageModel

@end
