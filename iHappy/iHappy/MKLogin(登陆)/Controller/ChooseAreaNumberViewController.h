//
//  BSNL_ChooseAreaNumberViewController.h
//  BiXuan
//
//  Created by ayi on 2018/7/12.
//  Copyright © 2018年 BSNL. All rights reserved.
//

#import "XDSBaseViewController.h"

@interface ChooseAreaNumberViewController : XDSBaseViewController

@property (nonatomic, copy) void(^areaCallBack)(id result);

@end
