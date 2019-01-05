//
//  EaseBlankPageView.m
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "XDSEaseBlankPageView.h"
#import <Masonry/Masonry.h>
@implementation XDSEaseBlankPageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)configWithType:(XDSEaseBlankPageType)blankPageType
               offsetY:(CGFloat)offsetY
               hasData:(BOOL)hasData
          errorMessage:(NSString *)errorMessage
        reloadButtonBlock:(void (^)(XDSEaseBlankPageType))reloadButtonBlock
    errorReloadButtonBlock:(void (^)(id))errorReloadButtonBlock{
    
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
            tipLabel.textColor = [UIColor colorWithHexString:@"#999999"];
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
            make.bottom.equalTo(self.mas_centerY).multipliedBy(0.8f);
        }
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerX.equalTo(self);
        make.top.equalTo(self.blankImageView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    _errorReloadButtonBlock = nil;
    NSString *imageName, *tipKey, *reloadTitleKey;
    if (errorMessage.length) {
        if (errorReloadButtonBlock) {
            //加载失败
            if (!_reloadButton) {
                _reloadButton = [[UIButton alloc] initWithFrame:CGRectZero];
                _reloadButton.adjustsImageWhenHighlighted = YES;
                _reloadButton.backgroundColor = [UIColor blackColor];
                _reloadButton.titleLabel.font = [UIFont systemFontOfSize:13];
                [_reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                reloadTitleKey = @"xds.blank.page.reload.title.unknowerror";
                NSString *titleStr = XDSLocalizedString(reloadTitleKey, nil);
                [_reloadButton setTitle:titleStr forState:UIControlStateNormal];
                [_reloadButton addTarget:self action:@selector(errorReloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                _reloadButton.layer.cornerRadius = 5;
                _reloadButton.layer.masksToBounds = YES;
                [self addSubview:_reloadButton];
                [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.top.equalTo(self.tipLabel.mas_bottom);
                    make.size.mas_equalTo(CGSizeMake(160, 40));
                }];
            }
        }

        _reloadButton.hidden = !errorReloadButtonBlock;
        _errorReloadButtonBlock = errorReloadButtonBlock;
        self.blankImageView.image = [UIImage imageNamed:@"img_network"];
        _tipLabel.text = errorMessage;
        
        return;
    }else{
        //        空白数据
        if (_reloadButton) {
            _reloadButton.hidden = YES;
        }
        
        
        self.pageType = blankPageType;
        switch (blankPageType) {
                case XDSEaseBlankPageTypeConnectError:{
                    imageName = @"img_network";
                    tipKey = @"xds.blank.page.tip.title.connecterror";
                    reloadTitleKey = @"xds.blank.page.reload.title.connecterror";
                    break;
                }
            case XDSEaseBlankPageTypeAppError:{
                imageName = @"img_error";
                tipKey = @"xds.blank.page.tip.title.apperror";
                reloadTitleKey = @"xds.blank.page.reload.title.apperror";
                break;
            }
            
            case XDSEaseBlankPageTypeEmpty:{
                imageName = @"img_empty_page";
                tipKey = @"xds.blank.page.tip.title.empty";
                reloadTitleKey = @"xds.blank.page.reload.title.empty";
                break;
            }
            case XDSEaseBlankPageTypeEmptyBookShelf:{
                imageName = @"img_empty_page";
                tipKey = @"xds.blank.page.tip.title.empty.bookshelf";
                reloadTitleKey = @"xds.blank.page.reload.title.empty.bookshelf";
                break;
            }
            default:{
                imageName = @"img_error";
                tipKey = @"xds.blank.page.tip.title.unknowerror";
                reloadTitleKey = @"xds.blank.page.reload.title.unknowerror";
                break;
            }

        }
        self.blankImageView.image = [UIImage imageNamed:imageName];
        _tipLabel.text = XDSLocalizedString(tipKey, nil);
        
        if (reloadButtonBlock) {
            //新增按钮
            UIButton *actionBtn=({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.backgroundColor = [UIColor blackColor];
                button.titleLabel.font = [UIFont systemFontOfSize:13];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [button addTarget:self action:@selector(reloadButtonAction) forControlEvents:UIControlEventTouchUpInside];
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
            
            _reloadButtonBlock = nil;
            _reloadButtonBlock = reloadButtonBlock;
        }

    }
}

- (void)errorReloadButtonClicked:(id)sender{
    self.hidden = YES;
    [self removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.errorReloadButtonBlock) {
            self.errorReloadButtonBlock(sender);
        }
    });
}

-(void)reloadButtonAction{
    self.hidden = YES;
    [self removeFromSuperview];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.reloadButtonBlock) {
            __weak typeof(self)weakself = self;
            self.reloadButtonBlock(weakself.pageType);
        }
    });
}

@end
