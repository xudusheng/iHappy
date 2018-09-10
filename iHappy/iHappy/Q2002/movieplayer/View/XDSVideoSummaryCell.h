//
//  XDSVideoSummaryCell.h
//  iHappy
//
//  Created by Hmily on 2018/9/9.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VIDEO_SUMMARY_CELL_HIDDEN_BUTTON_HEIGHT 44

#define VIDEO_SUMMARY_CELL_HEIGHT_EXCEPT_SUMMARY (10+20+VIDEO_SUMMARY_CELL_HIDDEN_BUTTON_HEIGHT)

#define VIDEO_SUMMARY_FONT [UIFont systemFontOfSize:13]
#define VIDEO_SUMMARY_MAX_SIZE CGSizeMake(DEVIECE_SCREEN_WIDTH - 20, CGFLOAT_MAX)
@interface XDSVideoSummaryCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *hiddenButton;
@property (copy, nonatomic) NSString *summary;

@end
