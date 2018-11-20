//
//  XDSPlayerDisclaimerView.m
//  iHappy
//
//  Created by Hmily on 2018/11/20.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import "XDSPlayerDisclaimerView.h"
@interface XDSPlayerDisclaimerView ()

@property (nonatomic,strong) UILabel *mLabel;

@end
@implementation XDSPlayerDisclaimerView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}
- (void)createUI {
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.mLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor darkTextColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        [self addSubview:label];
        label;
    });
    NSString *content = @"免责声明：\n\n"
    "1、本APP所有内容都是靠程序在互联网上自动搜集而来，仅供测试和学习交流。\n"
    "2、目前正在逐步删除和规避程序自动搜索采集到的不提供分享的版权影视。\n"
    "3、如果您发现网站上有侵犯您的知识产权的作品，请与我们取得联系，我们会及时修改或删除！";
    self.mLabel.text = content;
    
    [self.mLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(15);
        make.bottom.right.mas_equalTo(-15);
    }];
}

@end
