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

#define EPISODE_CELL_HEIGHT 30.F
#define EPISODE_CELL_HEIGHT_EXCEPT_CONTENT 21.F
#define EPISODE_CELL_FONT [UIFont systemFontOfSize:13]
#define EPISODE_CELL_MAX_SIZE CGSizeMake(DEVIECE_SCREEN_WIDTH - 20, CGFLOAT_MAX)

@interface XDSEpisodeCell : UICollectionViewCell

@property (strong, nonatomic) XDSEpisodeModel *episodeModel;

- (void)setEpisodeModel:(XDSEpisodeModel *)episodeModel isSelected:(BOOL)isSelected;
@end
