//
//  XDSRootViewController.h
//  Jurongbao
//
//  Created by wangrongchao on 15/10/17.
//  Copyright © 2015年 truly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDSBaseViewController : XDSRootRequestViewController

@property (nonatomic, assign) BOOL showNoNavShadow;

- (void)popBack:(UIBarButtonItem *)barButtonItem;

@end
