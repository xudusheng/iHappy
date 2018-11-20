//
//  XDSZFPlayerCell.h
//  iHappy
//
//  Created by Hmily on 2018/11/20.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSPlayerSourceModel.h"

#import "ZFPlayer.h"
#import "ZFPlayerControlView.h"


#define XDS_PLAYER_SIZE CGSizeMake(DEVIECE_SCREEN_WIDTH, XDS_Q2002_PLAYER_HEIGHT)

NS_ASSUME_NONNULL_BEGIN

@interface XDSZFPlayerCell : UICollectionViewCell

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic,strong) XDSPlayerSourceModel *playerSourceModel;

@end

NS_ASSUME_NONNULL_END
