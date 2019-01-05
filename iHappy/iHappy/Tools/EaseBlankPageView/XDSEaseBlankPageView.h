//
//  EaseBlankPageView.h
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XDSEaseBlankPageType) {
    XDSEaseBlankPageTypeConnectError = 0,//网络异常，无网络连接
    XDSEaseBlankPageTypeAppError,
    XDSEaseBlankPageTypeUnknownError,
    XDSEaseBlankPageTypeEmpty,
    XDSEaseBlankPageTypeEmptyBookShelf = 100,
};

//xds.blank.page.tip.title.connecterror = 网络出错，请检查您的网络
//xds.blank.page.tip.title.apperror = 很抱歉，程序出问题了
//xds.blank.page.tip.title.empty = 暂无数据哦~
//xds.blank.page.tip.title.unknowerror = 未知错误~

@interface XDSEaseBlankPageView : UIView

@property (strong, nonatomic) UIImageView *blankImageView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIButton *reloadButton;
@property (assign, nonatomic) XDSEaseBlankPageType pageType;
@property (copy, nonatomic) void(^errorReloadButtonBlock)(id sender);
@property (copy, nonatomic) void(^loadAndShowStatusBlock)(void);
@property (copy, nonatomic) void(^reloadButtonBlock)(XDSEaseBlankPageType pageType);
- (void)configWithType:(XDSEaseBlankPageType)blankPageType
               offsetY:(CGFloat)offsetY
               hasData:(BOOL)hasData
          errorMessage:(NSString *)errorMessage
     reloadButtonBlock:(void (^)(XDSEaseBlankPageType))reloadButtonBlock
errorReloadButtonBlock:(void (^)(id))errorReloadButtonBlock;

@end
