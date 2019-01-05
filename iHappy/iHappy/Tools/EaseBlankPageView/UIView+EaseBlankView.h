//
//  UIView+Common.h
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSEaseBlankPageView.h"

@interface UIView (EaseBlankView)

#pragma mark BlankPageView
@property (strong, nonatomic) XDSEaseBlankPageView *blankPageView;

//- (void)configBlankPage:(XDSEaseBlankPageType)blankPageType
//                hasData:(BOOL)hasData
//               hasError:(BOOL)hasError
//      reloadButtonBlock:(void (^)(id))reloadButtonBlock
//       clickButtonBlock:(void (^)(XDSEaseBlankPageType))clickButtonBlock;
//
//- (void)configBlankPage:(XDSEaseBlankPageType)blankPageType
//                hasData:(BOOL)hasData
//               hasError:(BOOL)hasError
//                offsetY:(CGFloat)offsetY
//      reloadButtonBlock:(void (^)(id))reloadButtonBlock
//       clickButtonBlock:(void (^)(XDSEaseBlankPageType))clickButtonBlock;


- (void)configWithType:(XDSEaseBlankPageType)blankPageType
               hasData:(BOOL)hasData
          errorMessage:(NSString *)errorMessage
     reloadButtonBlock:(void (^)(XDSEaseBlankPageType pageType))reloadButtonBlock
errorReloadButtonBlock:(void (^)(id obj))errorReloadButtonBlock;


- (void)configWithType:(XDSEaseBlankPageType)blankPageType
               offsetY:(CGFloat)offsetY
               hasData:(BOOL)hasData
          errorMessage:(NSString *)errorMessage
     reloadButtonBlock:(void (^)(XDSEaseBlankPageType pageType))reloadButtonBlock
errorReloadButtonBlock:(void (^)(id obj))errorReloadButtonBlock;

@end
