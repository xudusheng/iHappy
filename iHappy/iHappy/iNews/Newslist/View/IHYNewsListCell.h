//
//  IHYNewsListCell.h
//  iHappy
//
//  Created by zhengda on 16/11/21.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDSNewsModel.h"
@interface IHYNewsListCell : UITableViewCell

- (void)cellWithNewsModel:(XDSNewsModel *)newsModel;
@end
