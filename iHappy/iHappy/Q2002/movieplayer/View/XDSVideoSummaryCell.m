//
//  XDSVideoSummaryCell.m
//  iHappy
//
//  Created by Hmily on 2018/9/9.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSVideoSummaryCell.h"

@interface XDSVideoSummaryCell ()

@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hiddenButtonHeight;

- (IBAction)hiddenButtonClick:(id)sender;

@end

@implementation XDSVideoSummaryCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


- (void)setSummary:(NSString *)summary {
    _summary = summary;
    self.summaryLabel.text = summary;
    
    CGSize size = [summary sizeWithFont:VIDEO_SUMMARY_FONT maxSize:VIDEO_SUMMARY_MAX_SIZE];
    if (size.height < 60) {
        self.hiddenButtonHeight.constant = 0.f;
        self.hidden = YES;
    }else {
        self.hiddenButtonHeight.constant = VIDEO_SUMMARY_CELL_HIDDEN_BUTTON_HEIGHT;
        self.hidden = NO;
//        if (self.hiddenButton.selected) {
//            self.summaryLabel.numberOfLines = 0;
//        }else {
//            self.summaryLabel.numberOfLines = 3;
//        }
    }    
}
- (IBAction)hiddenButtonClick:(UIButton *)hiddenButton {
    hiddenButton.selected = !hiddenButton.selected;

    if ([self.superview isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView*)self.superview;
        [collectionView.collectionViewLayout invalidateLayout];
        [collectionView reloadData];
    }
}
@end
