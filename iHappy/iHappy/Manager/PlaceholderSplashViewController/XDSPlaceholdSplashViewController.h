//
//  XDSPlaceholdSplashViewController.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDSPlaceholdSplashViewController : UIViewController

@property (nonatomic, assign) BOOL isCustomView;

-(NSString *)getCurrentLaunchImageName;
#if TARGET_OS_IOS
+(NSString *)getCurrentLaunchImageNameWithImageSize:(CGSize)size orientation:(UIInterfaceOrientation)orientation;
+(void)setSplashVCStatusBarStyle:(UIStatusBarStyle)style;
#endif


@end
