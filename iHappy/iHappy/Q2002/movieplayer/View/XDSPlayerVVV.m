//
//  XDSPlayerVVV.m
//  iHappy
//
//  Created by Hmily on 2018/11/20.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "XDSPlayerVVV.h"
@interface XDSPlayerVVV ()

@property (nonatomic,strong) UILabel *mLabel;

@end
@implementation XDSPlayerVVV
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}
- (void)createUI {
    self.mLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 1;
        [self addSubview:label];
        label;
    });
    NSString *content = @"免责声明："
    "本网站所有内容都是靠程序在互联网上自动搜集而来，仅供测试和学习交流。"
    "目前正在逐步删除和规避程序自动搜索采集到的不提供分享的版权影视。"
    "若侵犯了您的权益，请即时发邮件通知站长 万分感谢！";
    self.mLabel.text = content;
    
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(15.f);
    }];
}

@end
