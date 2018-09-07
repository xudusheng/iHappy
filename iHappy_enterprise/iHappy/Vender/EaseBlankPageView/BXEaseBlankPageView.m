//
//  EaseBlankPageView.m
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "BXEaseBlankPageView.h"
#import <Masonry/Masonry.h>
@implementation BXEaseBlankPageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor bsnlcolor_F4F7F8];
    }
    return self;
}

- (void)configWithType:(BXEaseBlankPageType)blankPageType
               hasData:(BOOL)hasData
              hasError:(BOOL)hasError
               offsetY:(CGFloat)offsetY
     reloadButtonBlock:(void (^)(id))reloadButtonBlock
      clickButtonBlock:(void (^)(BXEaseBlankPageType))clickButtonBlock{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.loadAndShowStatusBlock) {
            self.loadAndShowStatusBlock();
        }
    });
    
    
    if (hasData) {
        [self removeFromSuperview];
        return;
    }
    self.alpha = 1.0;
    //图片
    if (!_blankImageView) {
        _blankImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_blankImageView];
    }
    //文字
    if (!_tipLabel) {
        self.tipLabel = ({
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            tipLabel.backgroundColor = [UIColor clearColor];
            tipLabel.numberOfLines = 0;
            tipLabel.font = [UIFont systemFontOfSize:13];
            tipLabel.textColor = [UIColor bsnlcolor_999999];
            tipLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:tipLabel];
            tipLabel;
        });

    }
    
    //布局
    [_blankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if (ABS(offsetY) > 1.0) {
            make.top.equalTo(self).offset(offsetY);
        }else{
            make.bottom.equalTo(self.mas_centerY).multipliedBy(0.7f);
        }
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerX.equalTo(self);
        make.top.equalTo(self.blankImageView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    _reloadButtonBlock = nil;
    NSString *imageName, *tipKey, *reloadTitleKey;
    if (hasError) {
        //加载失败
        if (!_reloadButton) {
            _reloadButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _reloadButton.adjustsImageWhenHighlighted = YES;
            [_reloadButton addTarget:self action:@selector(reloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_reloadButton];
            [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.tipLabel.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(160, 60));
            }];
        }
        _reloadButton.hidden = NO;
        _reloadButtonBlock = reloadButtonBlock;
        imageName = @"img_network";
        tipKey = @"bx.blank.page.tip.title.unknowerror";
        reloadTitleKey = @"bx.blank.page.reload.title.unknowerror";
    }else{
        //        空白数据
        if (_reloadButton) {
            _reloadButton.hidden = YES;
        }
        
        
        self.pageType = blankPageType;
        switch (blankPageType) {
                case BXEaseBlankPageTypeConnectError:{
                    imageName = @"img_network";
                    tipKey = @"bx.blank.page.tip.title.connecterror";
                    reloadTitleKey = @"bx.blank.page.reload.title.connecterror";
                    break;
                }
            case BXEaseBlankPageTypeAppError:{
                imageName = @"img-error";
                tipKey = @"bx.blank.page.tip.title.apperror";
                reloadTitleKey = @"bx.blank.page.reload.title.apperror";
                break;
            }
            case BXEaseBlankPageTypeAddress:{//
                imageName = @"blankpage_image_Hi";
                tipKey = @"bx.blank.page.tip.title.address";
                reloadTitleKey = @"bx.blank.page.reload.title.address";
                break;
            }
            case BXEaseBlankPageTypeOrder:{
                imageName = @"img_order";
                tipKey = @"bx.blank.page.tip.title.order";
                reloadTitleKey = @"bx.blank.page.reload.title.order";
                break;
            }
            case BXEaseBlankPageTypeShoppingCart:{
                imageName = @"img_shopping-car";
                tipKey = @"bx.blank.page.tip.title.shoppingcart";
                reloadTitleKey = @"bx.blank.page.reload.title.shoppingcart";
                break;
            }
            case BXEaseBlankPageTypeCollection:{
                imageName = @"img_collection";
                tipKey = @"bx.blank.page.tip.title.collection";
                reloadTitleKey = @"bx.blank.page.reload.title.collection";
                break;
            }
            case BXEaseBlankPageTypeSearchGoods:{
                imageName = @"img_Search-empty";
                tipKey = @"bx.blank.page.tip.title.searchgoods";
                reloadTitleKey = @"bx.blank.page.reload.title.searchgoods";
                break;
            }
            case BXEaseBlankPageTypeDaqu:{
                imageName = @"img_team";
                tipKey = @"bx.blank.page.tip.title.daqu";
                reloadTitleKey = @"bx.blank.page.reload.title.daqu";
                break;
            }
            case BXEaseBlankPageTypeWithdraw:{
                imageName = @"img_commission";
                tipKey = @"bx.blank.page.tip.title.withdraw";
                reloadTitleKey = @"bx.blank.page.reload.title.withdraw";
                break;
            }
            case BXEaseBlankPageTypeCoupon:{
                imageName = @"img_coupons";
                tipKey = @"bx.blank.page.tip.title.coupon";
                reloadTitleKey = @"bx.blank.page.reload.title.coupon";
                break;
            }
            case BXEaseBlankPageTypeEmpty:{
                imageName = @"img_Empty-page";
                tipKey = @"bx.blank.page.tip.title.empty";
                reloadTitleKey = @"bx.blank.page.reload.title.empty";
                break;
            }
            default:{
                imageName = @"img-error";
                tipKey = @"bx.blank.page.tip.title.unknowerror";
                reloadTitleKey = @"bx.blank.page.reload.title.unknowerror";
                break;
            }

        }
        self.blankImageView.image = [UIImage imageNamed:imageName];
        _tipLabel.text = XDSLocalizedString(tipKey, nil);
        //新增按钮
        UIButton *actionBtn=({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor blackColor];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = 5;
            button.layer.masksToBounds = YES;
            NSString *titleStr = XDSLocalizedString(reloadTitleKey, nil);
            [button setTitle:titleStr forState:UIControlStateNormal];
            
            button;
        });
        [self addSubview:actionBtn];
        
        [actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(160 , 40));
            make.top.equalTo(self.tipLabel.mas_bottom).offset(15);
            make.centerX.equalTo(self);
        }];
        
        _clickButtonBlock = nil;
        _clickButtonBlock = clickButtonBlock;
    }
}

- (void)reloadButtonClicked:(id)sender{
    self.hidden = YES;
    [self removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.reloadButtonBlock) {
            self.reloadButtonBlock(sender);
        }
    });
}

-(void)btnAction{
    self.hidden = YES;
    [self removeFromSuperview];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.clickButtonBlock) {
            __weak typeof(self)weakself = self;
            self.clickButtonBlock(weakself.pageType);
        }
    });
}

@end
