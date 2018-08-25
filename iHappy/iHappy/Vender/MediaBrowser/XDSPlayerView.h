//
//  XDSPlayerView.h
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/22.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XDSMediaModel.h"

typedef NS_ENUM(NSInteger, XDSPlayerViewPlayStatus) {
    XDSPlayerViewPlayStatusLoaing,
    XDSPlayerViewPlayStatusReadyToPlay,
    XDSPlayerViewPlayStatusPlaying,
    XDSPlayerViewPlayStatusPause,
    XDSPlayerViewPlayStatusEnd,
    XDSPlayerViewPlayStatusError,
};
//点击全屏按钮的通知
UIKIT_EXTERN NSString *const kXDSPlayerViewNotificationNameFullScreen;

@interface XDSPlayerView : UIView

@property (strong, nonatomic, readonly)AVPlayer *myPlayer;//播放器
@property (nonatomic,strong) XDSMediaModel *mediaModel;

//记录最后一次消失时的播放转态
@property (nonatomic,assign, readonly) XDSPlayerViewPlayStatus playStatusWhenDisappear;

//player出现或者不显示，控制播放器播放或者暂停
- (void)playerDisappear;
- (void)playerAppear;

/**
 销毁播放器
 */
- (void)destroyPlayer;

@end
