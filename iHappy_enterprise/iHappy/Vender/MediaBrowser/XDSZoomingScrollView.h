//
//  XDSZoomingScrollView.h
//  YBImageBrowserDemo
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSMediaModel.h"

UIKIT_EXTERN NSString *const kXDSPlayerViewNotificationNameSingleTap;

@interface XDSZoomingScrollView : UIScrollView

@property (nonatomic,strong) XDSMediaModel *mediaModel;

/**
 用于控制图片是否可以缩放
 */
@property (nonatomic,assign) BOOL zoomable;
@end
