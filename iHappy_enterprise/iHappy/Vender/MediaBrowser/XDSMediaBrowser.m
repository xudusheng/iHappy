//
//  XDSMediaBrowser.m
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMediaBrowser.h"

#import "XDSMediaBrowserViewLayout.h"

@interface XDSMediaBrowser () <
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>

//@property (nonatomic, strong) XDSMediaBrowserView *browserView;
@property (nonatomic, strong) UICollectionView *mCollectionView;

@end


@implementation XDSMediaBrowser
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createBrowserUI];
    }
    return self;
}

- (void)createBrowserUI {
    self.zoomable = YES;
    [self addSubview:self.mCollectionView];
//    _mCollectionView.clipsToBounds = NO;
}

- (void)setMediaModelArray:(NSArray<XDSMediaModel *> *)mediaModelArray {
    _mediaModelArray = mediaModelArray;
    [self reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mediaModelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XDSMediaBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XDS_IMAGE_BROWSER_CELL_IDENTIFIER forIndexPath:indexPath];
    XDSMediaModel *mediaModel = self.mediaModelArray[indexPath.row];
    cell.backgroundColor = [UIColor blackColor];
    cell.zoomable = _zoomable;
    cell.mediaModel = mediaModel;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XDSMediaBrowserCell *mediaCell = (XDSMediaBrowserCell *)cell;
    [mediaCell cellWillAppear];
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    XDSMediaBrowserCell *mediaCell = (XDSMediaBrowserCell *)cell;
    [mediaCell cellWillDisappear];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_mDelegate && [_mDelegate respondsToSelector:@selector(mediaBrowser:didScrollToIndex:)]) {
        NSInteger index = [self currentIndex];
        [_mDelegate mediaBrowser:self didScrollToIndex:index];
    }
}

- (void)reloadData {
    [self.mCollectionView.collectionViewLayout invalidateLayout];
    [self.mCollectionView reloadData];
}

- (void)resetZoomScale {
    NSArray *visibleCells = self.mCollectionView.visibleCells;
    for (XDSMediaBrowserCell *cell in visibleCells) {
        [cell resetZoomScale];
    }
}


- (void)setZoomable:(BOOL)zoomable {
    _zoomable = zoomable;
    NSArray *visibleCells = self.mCollectionView.visibleCells;
    for (XDSMediaBrowserCell *cell in visibleCells) {
        cell.zoomable = _zoomable;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (currentIndex > self.mediaModelArray.count - 1) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:currentIndex];
    [self.mCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}
- (NSInteger)currentIndex {
    NSArray *cells = self.mCollectionView.visibleCells;
    if (cells.count < 1) {
        return 0;
    }
    UICollectionViewCell *cell = cells.firstObject;
    NSIndexPath *indexPath = [self.mCollectionView indexPathForCell:cell];
    return indexPath.row;
    
}

- (UICollectionView *)mCollectionView {
    if (_mCollectionView == nil) {
        XDSMediaBrowserViewLayout *flowLayout = [XDSMediaBrowserViewLayout new];
        flowLayout.gapBetweenPages = 10;
        _mCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        [_mCollectionView registerClass:NSClassFromString(XDS_IMAGE_BROWSER_CELL_IDENTIFIER) forCellWithReuseIdentifier:XDS_IMAGE_BROWSER_CELL_IDENTIFIER];
        _mCollectionView.pagingEnabled = YES;
        _mCollectionView.showsHorizontalScrollIndicator = NO;
        _mCollectionView.showsVerticalScrollIndicator = NO;
        _mCollectionView.alwaysBounceVertical = NO;
        _mCollectionView.delegate = self;
        _mCollectionView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            _mCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _mCollectionView;
}

@end
