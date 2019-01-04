//
//  XDSAboutUSVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/4.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "XDSAboutUSVC.h"

@interface XDSAboutUSVC ()
@property (weak, nonatomic) IBOutlet UILabel *appNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@end

@implementation XDSAboutUSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appNameLabel.text = [UIApplication sharedApplication].appBundleDisplayeName;
    self.appVersionLabel.text = [NSString stringWithFormat:@"V %@", [UIApplication sharedApplication].appVersion];
}



@end
