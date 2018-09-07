//
//  IHYMoviePlayButtonCell.h
//  iHappy
//
//  Created by xudosom on 2016/11/20.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSEpisodeModel.h"
#define XDS_EPISODE_CELL_IDENTIFIER @"XDSEpisodeCell"
@interface XDSEpisodeCell : UICollectionViewCell

@property (strong, nonatomic) XDSEpisodeModel *episodeModel;

- (void)setEpisodeModel:(XDSEpisodeModel *)episodeModel isSelected:(BOOL)isSelected;
@end
