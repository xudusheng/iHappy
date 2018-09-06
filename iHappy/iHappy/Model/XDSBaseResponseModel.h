//
//  XDSBaseResponseModel.h
//  iHappy
//
//  Created by Hmily on 2018/9/6.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XDSBaseResponseModel : NSObject

@property (nonatomic,strong) id result;
@property (nonatomic,assign) NSInteger error_code;
@property (nonatomic,copy) NSString *errormessage;

@end
