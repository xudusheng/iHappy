//
//  XDSImageItemAdCell.m
//  iHappy
//
//  Created by Hmily on 2018/11/30.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "XDSImageItemAdCell.h"

@implementation XDSImageItemAdCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0, 1);//偏移距离
        self.contentView.layer.shadowOpacity = 0.5;//不透明度
        self.contentView.layer.shadowRadius = 3.f;//半径
    }
    return self;
}

- (void)p_loadCell {
    CGFloat width = CGRectGetWidth(self.contentView.bounds) - 10*2;
    CGFloat height = width*XDS_NATIVE_EXPRESS_AD_RETIO_HEIGHT_WIDTH;
    [[XDSAdManager sharedManager] loadNativeExpressAdInView:self.contentView adSize:CGSizeMake(width, height)];
}

@end
