//
//  BXRetailStoreGuideVC.m
//  iHappy
//
//  Created by Hmily on 2019/1/4.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "BXRetailStoreGuideVC.h"
#import "HQFlowView.h"

@interface BXRetailStoreGuideVC ()<HQFlowViewDelegate,HQFlowViewDataSource>

/**
 *  图片数组
 */
@property (nonatomic, strong) NSMutableArray *imageNameArray;
/**
 *  轮播图
 */
@property (nonatomic, strong) HQFlowView *pageFlowView;

@end

@implementation BXRetailStoreGuideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageNameArray = [NSMutableArray arrayWithObjects:@"购物省钱",@"纳新有礼",@"分享赚钱",@"专享礼遇", nil];
    
    [self.view addSubview:self.pageFlowView];
    
    [self.pageFlowView reloadData];//刷新轮播
}

- (HQFlowView *)pageFlowView {
    if (!_pageFlowView) {
        UIImage *image = [UIImage imageNamed:self.imageNameArray.firstObject];
        CGFloat height = image.size.height/image.size.width*(ScreenWidth-40*2);
        _pageFlowView = [[HQFlowView alloc] initWithFrame:CGRectMake(0, 35, ScreenWidth, height)];
        _pageFlowView.delegate = self;
        _pageFlowView.dataSource = self;
        _pageFlowView.minimumPageAlpha = 0.3;
        _pageFlowView.leftMargin = 20;
        _pageFlowView.rightMargin = 20;
        _pageFlowView.topMargin = 60;
        _pageFlowView.bottomMargin = 0;
        _pageFlowView.orginPageCount = self.imageNameArray.count;
        _pageFlowView.isOpenAutoScroll = NO;
        _pageFlowView.orientation = HQFlowViewOrientationHorizontal;
        
    }
    return _pageFlowView;
}


#pragma mark JQFlowViewDelegate
- (CGSize)sizeForPageInFlowView:(HQFlowView *)flowView{
    return CGSizeMake(ScreenWidth-2*40, self.pageFlowView.frame.size.height);
}

- (void)didSelectCell:(UIView *)subView withSubViewIndex:(NSInteger)subIndex{}
#pragma mark JQFlowViewDatasource
- (NSInteger)numberOfPagesInFlowView:(HQFlowView *)flowView {
    return self.imageNameArray.count;
}
- (HQIndexBannerSubview *)flowView:(HQFlowView *)flowView cellForPageAtIndex:(NSInteger)index {
    HQIndexBannerSubview *bannerView = (HQIndexBannerSubview *)[flowView dequeueReusableCell];
    if (!bannerView) {
        bannerView = [[HQIndexBannerSubview alloc] initWithFrame:CGRectMake(0, 0, self.pageFlowView.frame.size.width, self.pageFlowView.frame.size.height)];
        bannerView.layer.masksToBounds = NO;
        bannerView.layer.shadowOffset = CGSizeMake(0, -2);
        bannerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4].CGColor;
        bannerView.layer.shadowOpacity = 0.2;
        
        bannerView.coverView.backgroundColor = [UIColor clearColor];
    }
    //加载本地图片
    bannerView.mainImageView.image = [UIImage imageNamed:self.imageNameArray[index]];
    return bannerView;
}

- (void)didScrollToPage:(NSInteger)pageNumber inFlowView:(HQFlowView *)flowView {
    [self.pageFlowView.pageControl setCurrentPage:pageNumber];
}

- (void)dealloc {
    self.pageFlowView.delegate = nil;
    self.pageFlowView.dataSource = nil;
    [self.pageFlowView stopTimer];
}

@end
