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
@property (nonatomic,strong) NSMutableArray<XDSMediaModel *> *mediaModelArray;

@end

@implementation XDSMediaBrowserVC

- (instancetype)initWithMediaModelArray:(NSArray<YSEImageModel *> *)imageModelArray{
    if (self = [super init]) {
        self.imageModelArray = imageModelArray;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.mediaModelArray = [NSMutableArray arrayWithCapacity:0];
    
    [self createMediaView];
}


- (void)createMediaView {
    self.mediaBrowser = [[XDSMediaBrowser alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    self.mediaBrowser.mediaModelArray = _mediaModelArray;
    self.mediaBrowser.zoomable = NO;
    self.mediaBrowser.clipsToBounds = NO;
    [self.view addSubview:self.mediaBrowser];
}


- (void)setImageModelArray:(NSArray<YSEImageModel *> *)imageModelArray {
    _imageModelArray = imageModelArray;
    [self.mediaModelArray removeAllObjects];
    for (YSEImageModel *imageModel in _imageModelArray) {
        [self.mediaModelArray addObject:imageModel.mediaModel];
    }
    [self.mediaBrowser reloadData];
}


@end
