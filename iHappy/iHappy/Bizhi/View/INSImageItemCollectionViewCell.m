//
//  INSImageItemCollectionViewCell.m
//  iHappy
//
//  Created by dusheng.xu on 2017/5/14.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "INSImageItemCollectionViewCell.h"

NSString *const kImageItemCollectionViewCellIdentifier = @"INSImageItemCollectionViewCell";

@implementation INSImageItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self createImageItemCollectionViewCellUI];
    }
    return self;
}


//MARK:UI
- (void)createImageItemCollectionViewCellUI{
    CGFloat margin = 5;
    self.bgImageView = ({
        CGRect frame = CGRectMake(margin,
                                  margin,
                                  CGRectGetWidth(self.contentView.bounds) - margin*2,
                                  CGRectGetWidth(self.contentView.bounds) - margin * 2);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:imageView];
        imageView;
    });

    self.titleLabel = ({
        CGRect frame = CGRectMake(margin,
                                  CGRectGetMaxY(self.bgImageView.frame),
                                  CGRectGetWidth(self.bgImageView.frame) - margin*2,
                                  XDS_IMAGE_ITEM_TITLE_LABEL_HEIGHT);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont systemFontOfSize:12];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:label];
        label;
        
    });

    
}


- (void)p_loadCell{
    self.backgroundColor = [UIColor whiteColor];
//    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.layer.borderWidth = 0.5f;
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;//shadowColor阴影颜色
    self.layer.shadowOffset = CGSizeMake(2, 2);//
    self.layer.shadowOpacity = 0.5;//阴影透明度，默认0
    self.layer.shadowRadius = 4 ;//阴影半径，默认3
    
    if (self.imageModel == nil) {
        return;
    }
    NSURL *url = [NSURL URLWithString:_imageModel.image_src];
    [_bgImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageTransformAnimatedImage];
    _titleLabel.text = _imageModel.name;
}

@end
