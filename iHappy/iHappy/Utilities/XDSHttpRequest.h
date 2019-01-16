//
//  XDSHttpRequest.h
//  Jurongbao
//
//  Created by wangrongchao on 15/11/14.
//  Copyright © 2015年 truly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDSBaseResponseModel.h"

UIKIT_EXTERN NSString *const kConnectWebFailed;//网络连接失败
UIKIT_EXTERN NSString *const kAnalysisFailed;//数据解析出错
UIKIT_EXTERN NSString *const kLoadFailed; //请求失败
UIKIT_EXTERN NSString *const kTimeCallOut;//链接超时

@interface XDSHttpRequest : NSObject

- (void)GETWithURLString:(NSString *)urlString
                reqParam:(NSDictionary *)reqParam
           hudController:(UIViewController *)hudController
                 showHUD:(BOOL)showHUD
                 HUDText:(NSString *)HUDText
           showFailedHUD:(BOOL)showFailedHUD
                 success:(void(^)(BOOL success, id successResult))success
                  failed:(void(^)(NSString * errorDescription))failed;

- (void)htmlRequestWithHref:(NSString *)htmlHref
              hudController:(UIViewController *)hudController
                    showHUD:(BOOL)showHUD
                    HUDText:(NSString *)HUDText
              showFailedHUD:(BOOL)showFailedHUD
                    success:(void(^)(BOOL success, NSData * htmlData))success
                     failed:(void(^)(NSString * errorDescription))failed;


- (void)queryInitialInfoWithUrlString:(NSString *)urlString
                             reqParam:(NSDictionary *)reqParam
                        hudController:(UIViewController *)hudController
                              showHUD:(BOOL)showHUD
                              HUDText:(NSString *)HUDText
                        showFailedHUD:(BOOL)showFailedHUD
                              success:(void(^)(BOOL success, id successResult))success
                               failed:(void(^)(NSString * errorDescription))failed;
#pragma mark - 取消请求
- (void)cancelRequest;


//----------------------------------------------------------------------
//以下为b_x的相关操作
//----------------------------------------------------------------------
- (NSDictionary *)signPackageWithParam:(NSDictionary *)param;
@end
