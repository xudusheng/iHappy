//
//  LoginViewModel.h
//  BiXuan
//
//  Created by ayi on 2018/7/12.
//  Copyright © 2018年 BSNL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginViewModel : NSObject

/**
 手机区号接口
 
 @param param
 {
 参数名称    数据类型    是否必填    说明
 limit    Integer    否    返回记录数，默认10
 offset    Integer    否    返回记录的开始位置，默认1
 }
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)mobileRegionAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSError *error))fail;
/**
 短信验证码下发接口
 
 @param param
 {
 参数名称    数据类型    是否必填    说明
 region_code    String    是    手机区号
 mobile    String    是    手机号
 }
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)smsSendAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSString *errorDescription))fail;
/**
 手机号登录接口
 
 @param param
 {
 region_code    String    是    手机区域编码
 mobile    String    是    手机号
 sms_code    String    是    验证码
 open_id    String    否    微信唯一标识
 nickname    String    否    昵称
 head_img    String    否    头像
 }
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)loginMobileAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSString *errorDescription))fail;

/**
 微信登录接口
 
 @param param
 {
 参数名称    数据类型    是否必填    说明
 open_id    String    是    微信唯一标识
 }
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)loginWxAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSError *error))fail;



@end
