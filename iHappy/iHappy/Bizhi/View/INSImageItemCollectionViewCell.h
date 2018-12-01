//
//  INSImageItemCollectionViewCell.h
//  iHappy
//
//  Created by dusheng.xu on 2017/5/14.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kImageItemCollectionViewCellIdentifier;
UIKIT_EXTERN CGFloat const kImageItemCollectionViewCellGap;

UIKIT_EXTERN CGFloat const kBiZhiCollectionViewMinimumLineSpacing ;
UIKIT_EXTERN CGFloat const kBiZhiCollectionViewMinimumInteritemSpacing ;
UIKIT_EXTERN CGFloat const kBiZhiCollectionViewCellsGap ;

@interface INSImageItemCollectionViewCell : IHPRootCollectionCell

@property (strong, nonatomic) UIImageView *bgImageView;

@end
