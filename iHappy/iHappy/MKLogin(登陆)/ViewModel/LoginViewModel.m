//
//  LoginViewModel.m
//  BiXuan
//
//  Created by ayi on 2018/7/12.
//  Copyright © 2018年 BSNL. All rights reserved.
//

#import "LoginViewModel.h"

@implementation LoginViewModel



/**
 手机区号接口
 
 @param param 传值
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)mobileRegionAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSError *error))fail{
//    [[XDSHttpRequest alloc] init] postWithURL:Bx_API_Mobile_Region params:param success:^(id response) {
//        if(success) success(response);
//    } fail:^(NSError *error) {
//        if(fail) fail(error);
//    }];

}

/**
 短信验证码下发接口
 
 @param param 传值
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)smsSendAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSString *errorDescription))fail{
//    [[Bx_AfnNetManager shareInstance]postWithURL:Bx_API_SmsSend params:param success:^(id response) {
//        if(success) success(response);
//    } fail:^(NSError *error) {
//        if(fail) fail(error);
//    }];
    
    XDSHttpRequest *request = [[XDSHttpRequest alloc] init];
    param = [request signPackageWithParam:param];
    [request GETWithURLString:@"https://bx.bisinuolan.cn/api/sms/send"
                                           reqParam:param
                                      hudController:[UIViewController xds_visiableViewController]
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:NO
                                            success:^(BOOL isSuccess, NSDictionary *successResult) {
                                                if(success) success(successResult);
                                            } failed:^(NSString *errorDescription) {
                                                if(fail) fail(errorDescription);
                                            }];
}

/**
手机号登录接口
 
 @param param 传值
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)loginMobileAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSError *error))fail{
//    [[Bx_AfnNetManager shareInstance]postWithURL:Bx_API_LoginMobile params:param success:^(id response) {
//        if(success) success(response);
//    } fail:^(NSError *error) {
//        if(fail) fail(error);
//    }];
}

/**
微信登录接口
 
 @param param 传值
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)loginWxAPIActionWithParam:(NSDictionary *)param andSuccess:(void(^)(id response))success andFail:(void(^)(NSError *error))fail{
//    [[Bx_AfnNetManager shareInstance]postWithURL:Bx_API_LoginWx params:param success:^(id response) {
//        if(success) success(response);
//    } fail:^(NSError *error) {
//        if(fail) fail(error);
//    }];
}

@end
