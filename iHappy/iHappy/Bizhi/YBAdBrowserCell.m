//
//  YBAdBrowserCell.m
//  iHappy
//
//  Created by Hmily on 2018/11/30.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "YBAdBrowserCell.h"
#import "YBImageBrowserCellProtocol.h"


@interface YBAdBrowserCell() <YBImageBrowserCellProtocol>

@end

@implementation YBAdBrowserCell

- (void)yb_initializeBrowserCellWithData:(id<YBImageBrowserCellDataProtocol>)data layoutDirection:(YBImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {

    CGFloat width = CGRectGetWidth(self.contentView.bounds) - 20;
    CGFloat height = width *(1200.f/800.f);
    [[XDSAdManager sharedManager] loadNativeExpressAdInView:self.contentView adSize:CGSizeMake(width, height)];
    
}


@end
