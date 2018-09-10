//
//  NSString+XDSAddition.m
//  iHappy
//
//  Created by Hmily on 2018/9/9.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "NSString+XDSAddition.h"

@implementation NSString (XDSAddition)

-(CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize {
    
    NSDictionary *attrs = @{NSFontAttributeName:font};
    
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
}

@end
