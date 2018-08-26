//
//  XDSMediaBrowserVC.m
//  iHappy
//
//  Created by Hmily on 2018/8/25.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMediaBrowserVC.h"
#import "XDSMediaBrowser.h"

@interface XDSMediaBrowserVC ()

@property (nonatomic,strong) XDSMediaBrowser *mediaBrowser;

@end

@implementation XDSMediaBrowserVC


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createMediaView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hanldeSingleTap) name:kXDSPlayerViewNotificationNameSingleTap object:nil];
}


- (void)createMediaView {
    self.mediaBrowser = [[XDSMediaBrowser alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self.mediaBrowser.mediaModelArray = _mediaModelArray;
    self.mediaBrowser.zoomable = YES;
    self.mediaBrowser.clipsToBounds = YES;
    [self.view addSubview:self.mediaBrowser];
}


- (void)hanldeSingleTap {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)setMediaModelArray:(NSArray<XDSMediaModel *> *)mediaModelArray {
    _mediaModelArray = mediaModelArray;
    [self.mediaBrowser reloadData];
}



@end
