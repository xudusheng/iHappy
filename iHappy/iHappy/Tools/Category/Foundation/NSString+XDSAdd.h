//
//  NSString+XDSAdd.h
//  Demo
//
//  Created by Hmily on 2018/10/19.
//  Copyright © 2018年 BX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XDSAdd)

/**
 *  清空字符串中的空白字符
 *
 *  @return 清空空白字符串之后的字符串
 */
- (NSString *)trimString;

+ (NSString *)md5StringFromString:(NSString *)s;
+ (NSString *)md5:(NSString *)value;
+ (NSString *)stringOfAddPercentEscapesWithString:(NSString *)s;

+ (NSString *)base64StringFromData:(NSData *)data;
+ (NSData *) dataFromBase64String:(NSString *)string;


+ (NSString *)timeStringForTime:(NSUInteger)time;//整形时间转化为00:00字符串
+ (NSString *)stringTranslatedFromDate:(NSDate *)date;//NSDate转化为标准格式时间字符串
+(NSDate *) convertDateFromString:(NSString*)uiDate;//nsstring转化为nsdate
+(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;//比较2个日期大小
+ (NSDate *)fetchDateFromDay:(NSInteger)day Hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;//获取时间，转化为nsdate

+(NSString *)formatStringToSaveWithString:(NSString *)string digit:(NSInteger)digit decimalStyle:(BOOL)flag;//将一个数字字符串保留指定的位数,string为字符串，digit为保留的位数
+(NSString *)decimalwithFormat:(NSString *)format floatV:(float)floatV;//四舍五入方法
+(NSString *)formatStringForPercentageWithString:(NSString *)string;//将一个数字字符串转换为百分号显示,保留2位

//得到两位随机数
+ (NSString *)twoCharRandom;

//月转换成天
+ (NSString *)monthToDay:(NSString *)dayString;

+ (BOOL)validateIDCardNumber:(NSString *)value;//校验身份证
+ (BOOL)isMobileNumber:(NSString *)mobileNum;//校验手机号

/**
 Returns a new UUID NSString
 e.g. "D1178E50-2A4D-4F1F-9BD3-F6AAB00E06B1"
 */
+ (NSString *)stringWithUUID;


- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end

NS_ASSUME_NONNULL_END
