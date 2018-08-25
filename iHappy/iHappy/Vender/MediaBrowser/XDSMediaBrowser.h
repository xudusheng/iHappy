//
//  XDSMediaBrowser.h
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSMediaBrowserCell.h"
#import "XDSMediaModel.h"
@protocol XDSMediaBrowserDelegate;

@interface XDSMediaBrowser : UIView

/**
 数据源
 */
@property (nonatomic,strong) NSArray<XDSMediaModel*> *mediaModelArray;
@property (nonatomic,weak) id<XDSMediaBrowserDelegate> mDelegate;
@property (nonatomic,assign) NSInteger currentIndex;

/**
 用于控制图片是否可以缩放，默认可以缩放
 */
@property (nonatomic,assign) BOOL zoomable;

/**
 刷新数据
 */
- (void)reloadData;


/**
 将图片设置到放大之前的转态
 */
- (void)resetZoomScale;

@end


@protocol XDSMediaBrowserDelegate <NSObject>

@optional

- (void)mediaBrowser:(XDSMediaBrowser *)mediaBrowser didScrollToIndex:(NSInteger)index;

@end
