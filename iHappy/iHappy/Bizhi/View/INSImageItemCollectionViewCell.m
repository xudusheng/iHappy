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
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
        self.contentView.layer.shadowOffset = CGSizeMake(0, 1);//偏移距离
        self.contentView.layer.shadowOpacity = 0.5;//不透明度
        self.contentView.layer.shadowRadius = 3.f;//半径
        [self createImageItemCollectionViewCellUI];
    }
    return self;
}


//MARK:UI
- (void)createImageItemCollectionViewCellUI{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat gap = 10.f;
    CGFloat imageWidth = width - gap*2;
    self.bgImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(gap, gap, imageWidth, imageWidth)];
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:imageView];
        imageView;
    });

    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(gap, CGRectGetMaxY(self.bgImageView.frame), imageWidth, height - CGRectGetMaxY(self.bgImageView.frame))];
        label.translatesAutoresizingMaskIntoConstraints = false;
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor darkGrayColor];
        label.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:label];
        label;
    });

//    self.contentView.clipsToBounds = NO;
//    self.contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
//    self.contentView.layer.shadowOffset = CGSizeMake(3, 3);
    

    
    
}


- (void)p_loadCell{
    if (self.imageModel == nil) {
        return;
    }
    NSURL *url = [NSURL URLWithString:_imageModel.image_src];
    [_bgImageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageTransformAnimatedImage];
    _titleLabel.text = _imageModel.name;
}

@end
