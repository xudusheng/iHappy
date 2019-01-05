//
//  UIView+Common.m
//  XDSThirdParty
//
//  Created by Hmily on 2016/12/15.
//  Copyright © 2016年 Hmily. All rights reserved.
//

#import "UIView+EaseBlankView.h"
#import <objc/runtime.h>

@implementation UIView (EaseBlankView)


#pragma mark BlankPageView
static char BlankPageViewKey;
- (void)setBlankPageView:(XDSEaseBlankPageView *)blankPageView{
    [self willChangeValueForKey:@"BlankPageViewKey"];
    objc_setAssociatedObject(self, &BlankPageViewKey,
                             blankPageView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"BlankPageViewKey"];
}

- (XDSEaseBlankPageView *)blankPageView{
    return objc_getAssociatedObject(self, &BlankPageViewKey);
}




- (void)configWithType:(XDSEaseBlankPageType)blankPageType
               hasData:(BOOL)hasData
          errorMessage:(NSString *)errorMessage
     reloadButtonBlock:(void (^)(XDSEaseBlankPageType))reloadButtonBlock
errorReloadButtonBlock:(void (^)(id))errorReloadButtonBlock{
    
    [self configWithType:blankPageType
                 offsetY:0
                 hasData:hasData
            errorMessage:errorMessage
       reloadButtonBlock:reloadButtonBlock
  errorReloadButtonBlock:errorReloadButtonBlock];
    
}
- (void)configWithType:(XDSEaseBlankPageType)blankPageType
               offsetY:(CGFloat)offsetY
               hasData:(BOOL)hasData
            errorMessage:(NSString *)errorMessage
     reloadButtonBlock:(void (^)(XDSEaseBlankPageType))reloadButtonBlock
errorReloadButtonBlock:(void (^)(id))errorReloadButtonBlock {

    if (hasData) {
        if (self.blankPageView) {
            self.blankPageView.hidden = YES;
            [self.blankPageView removeFromSuperview];
        }
    }else{
        if (!self.blankPageView) {
            self.blankPageView = [[XDSEaseBlankPageView alloc] initWithFrame:self.bounds];

        }
        self.blankPageView.hidden = NO;
        
//        [self.blankPageContainer insertSubview:self.blankPageView atIndex:0];
        [self.blankPageContainer addSubview:self.blankPageView];

        [self.blankPageView configWithType:blankPageType
                                   offsetY:offsetY
                                   hasData:hasData
                              errorMessage:errorMessage
                         reloadButtonBlock:reloadButtonBlock
                    errorReloadButtonBlock:errorReloadButtonBlock];
        
        
    }
}

- (UIView *)blankPageContainer{
    UIView *blankPageContainer = self;
//    for (UIView *aView in [self subviews]) {
//        if ([aView isKindOfClass:[UITableView class]] ||
//            [aView isKindOfClass:[UICollectionView class]]) {
//            blankPageContainer = aView;
//        }
//    }
    return blankPageContainer;
}
@end
