//
//  IHYNewsMultableImageCell.m
//  iHappy
//
//  Created by zhengda on 16/11/21.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import "IHYNewsMultableImageCell.h"
@interface IHYNewsMultableImageCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *autherLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icon1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *icon2ImageView;

@end
@implementation IHYNewsMultableImageCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)cellWithNewsModel:(XDSNewsModel *)newsModel{
    _titleLabel.text = newsModel.title;
    _dateLabel.text = newsModel.publishDateStr;
    _autherLabel.text = newsModel.posterScreenName;
    
    NSString *image1 = @"";
    NSString *image2 = @"";
    NSString *image3 = @"";
    if (newsModel.imageUrls.count < 1) {
        
    }else if (newsModel.imageUrls.count == 1) {
        image1 = newsModel.imageUrls.firstObject;
    }else if (newsModel.imageUrls.count == 2) {
        image1 = newsModel.imageUrls.firstObject;
        image2 = newsModel.imageUrls.lastObject;
    }else {
        image1 = newsModel.imageUrls.firstObject;
        image2 = newsModel.imageUrls[1];
        image3 = newsModel.imageUrls[2];

    }
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:image1] placeholderImage:nil];
    [_icon1ImageView sd_setImageWithURL:[NSURL URLWithString:image2] placeholderImage:nil];
    [_icon2ImageView sd_setImageWithURL:[NSURL URLWithString:image3] placeholderImage:nil];

}
@end
