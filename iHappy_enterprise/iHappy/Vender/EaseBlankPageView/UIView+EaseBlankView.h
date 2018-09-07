//
//  UIView+Common.h
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BXEaseBlankPageView.h"

@interface UIView (EaseBlankView)

#pragma mark BlankPageView
@property (strong, nonatomic) BXEaseBlankPageView *blankPageView;

- (void)configBlankPage:(BXEaseBlankPageType)blankPageType
                hasData:(BOOL)hasData
               hasError:(BOOL)hasError
      reloadButtonBlock:(void (^)(id))reloadButtonBlock
       clickButtonBlock:(void (^)(BXEaseBlankPageType))clickButtonBlock;

- (void)configBlankPage:(BXEaseBlankPageType)blankPageType
                hasData:(BOOL)hasData
               hasError:(BOOL)hasError
                offsetY:(CGFloat)offsetY
      reloadButtonBlock:(void (^)(id))reloadButtonBlock
       clickButtonBlock:(void (^)(BXEaseBlankPageType))clickButtonBlock;
@end
