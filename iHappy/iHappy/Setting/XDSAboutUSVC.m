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
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation XDSAboutUSVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.appNameLabel.text = [UIApplication sharedApplication].appBundleDisplayeName;
    self.appVersionLabel.text = [NSString stringWithFormat:@"V %@", [UIApplication sharedApplication].appVersion];
    
    self.logoImageView.layer.cornerRadius = 15;
    self.logoImageView.layer.masksToBounds = YES;
}



@end
