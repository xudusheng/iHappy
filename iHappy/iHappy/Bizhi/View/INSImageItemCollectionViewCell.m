//
//  INSImageItemCollectionViewCell.m
//  iHappy
//
//  Created by dusheng.xu on 2017/5/14.
//  Copyright © 2017年 上海优蜜科技有限公司. All rights reserved.
//

#import "INSImageItemCollectionViewCell.h"

NSString *const kImageItemCollectionViewCellIdentifier = @"INSImageItemCollectionViewCell";
CGFloat const kImageItemCollectionViewCellGap = 10.f;

CGFloat const kBiZhiCollectionViewMinimumLineSpacing = 10.f;
CGFloat const kBiZhiCollectionViewMinimumInteritemSpacing = 10.f;
CGFloat const kBiZhiCollectionViewCellsGap = 10.f;

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
    self.bgImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.translatesAutoresizingMaskIntoConstraints = false;
        [self.contentView addSubview:imageView];
        imageView;
    });
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(kImageItemCollectionViewCellGap);
        make.bottom.right.mas_equalTo(-kImageItemCollectionViewCellGap);
    }];

}


@end
