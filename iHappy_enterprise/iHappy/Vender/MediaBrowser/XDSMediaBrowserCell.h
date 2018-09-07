//
//  XDSMediaBrowserCell.h
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSMediaModel.h"

#import "XDSPlayerView.h"
#import "XDSZoomingScrollView.h"

#define XDS_IMAGE_BROWSER_CELL_IDENTIFIER @"XDSMediaBrowserCell"

@interface XDSMediaBrowserCell : UICollectionViewCell

@property (nonatomic) XDSMediaModel *mediaModel;
- (void)resetZoomScale;

/**
 用于控制图片是否可以缩放
 */
@property (nonatomic,assign) BOOL zoomable;

//cell出现或者不显示
- (void)cellWillDisappear;
- (void)cellWillAppear;

@end
