//
//  EaseBlankPageView.h
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BXEaseBlankPageType) {
    BXEaseBlankPageTypeConnectError = 0,//网络异常，无网络连接
    BXEaseBlankPageTypeAppError,
    BXEaseBlankPageTypeAddress,
    BXEaseBlankPageTypeOrder,
    BXEaseBlankPageTypeCollection,
    BXEaseBlankPageTypeShoppingCart,
    BXEaseBlankPageTypeSearchGoods,
    BXEaseBlankPageTypeDaqu,
    BXEaseBlankPageTypeWithdraw,
    BXEaseBlankPageTypeEmpty,
    BXEaseBlankPageTypeCoupon,
    BXEaseBlankPageTypeUnknownError,
//    bx.blank.page.tip.title.connecterror = 网络出错，请检查您的网络
//    bx.blank.page.reload.title.connecterror = 刷新
//    bx.blank.page.tip.title.apperror = 很抱歉，程序出问题了
//    bx.blank.page.reload.title.apperror = 刷新
//    bx.blank.page.tip.title.address = 您还没有添加新的地址
//    bx.blank.page.reload.title.address = 添加新的地址
//    bx.blank.page.tip.title.order = 您还没有交易的订单哦~
//    bx.blank.page.reload.title.order = 去下单
//    bx.blank.page.tip.title.shoppingcart = 您的购物车空空如也~
//    bx.blank.page.reload.title.shoppingcart = 去逛逛
//    bx.blank.page.tip.title.collection = 您还没有任何收藏的商品
//    bx.blank.page.reload.title.collection = 去逛逛
//    bx.blank.page.tip.title.searchgoods = 没找到您要找的商品
//    bx.blank.page.reload.title.searchgoods = 回首页
//    bx.blank.page.tip.title.daqu = 您暂无大区成员
//    bx.blank.page.reload.title.daqu = 分享二维码
//    bx.blank.page.tip.title.withdraw = 您暂无获得佣金哦~
//    bx.blank.page.reload.title.withdraw = 回首页
//    bx.blank.page.tip.title.empty = 空页面
//    bx.blank.page.reload.title.empty = 回首页
//    bx.blank.page.tip.title.coupon = 您暂时没有可以使用的优惠券哦~
//    bx.blank.page.reload.title.coupon = 取领券
//    bx.blank.page.reload.title.unknowerror = 貌似出了点差错\n真忧伤呢
//    bx.blank.page.reload.title.unknowerror  = 刷新
};


@interface BXEaseBlankPageView : UIView

@property (strong, nonatomic) UIImageView *blankImageView;
@property (strong, nonatomic) UILabel *tipLabel;
@property (strong, nonatomic) UIButton *reloadButton;
@property (assign, nonatomic) BXEaseBlankPageType pageType;
@property (copy, nonatomic) void(^reloadButtonBlock)(id sender);
@property (copy, nonatomic) void(^loadAndShowStatusBlock)(void);
@property (copy, nonatomic) void(^clickButtonBlock)(BXEaseBlankPageType pageType);
- (void)configWithType:(BXEaseBlankPageType)blankPageType
               hasData:(BOOL)hasData
              hasError:(BOOL)hasError
               offsetY:(CGFloat)offsetY
     reloadButtonBlock:(void(^)(id sender))reloadButtonBlock
      clickButtonBlock:(void (^)(BXEaseBlankPageType pageType))clickButtonBlock;

@end
