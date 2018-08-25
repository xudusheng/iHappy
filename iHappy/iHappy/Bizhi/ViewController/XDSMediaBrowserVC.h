//
//  XDSMediaBrowserVC.h
//  iHappy
//
//  Created by Hmily on 2018/8/25.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSBaseViewController.h"
#import "YSEImageModel.h"

@interface XDSMediaBrowserVC : XDSBaseViewController

- (instancetype)initWithMediaModelArray:(NSArray<YSEImageModel *> *)imageModelArray;

@property (nonatomic,strong) NSArray<YSEImageModel *> *imageModelArray;

@end


@interface XDSMediaBrowserVC (unavailible)
- (instancetype)init NS_UNAVAILABLE;

@end
