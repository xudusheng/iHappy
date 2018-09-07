//
//  XDSMediaBrowserViewLayout.m
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMediaBrowserViewLayout.h"

@implementation XDSMediaBrowserViewLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGSize size = self.collectionView.bounds.size;
    self.itemSize = CGSizeMake(size.width, size.height);
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *layoutAttsArray = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0;
    __block CGFloat min = CGFLOAT_MAX;
    __block NSUInteger minIdx;
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (ABS(centerX-obj.center.x) < min) {
            min = ABS(centerX-obj.center.x);
            minIdx = idx;
        }
    }];
    [layoutAttsArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (minIdx - 1 == idx) {
            obj.center = CGPointMake(obj.center.x-self.gapBetweenPages, obj.center.y);
        }
        if (minIdx + 1 == idx) {
            obj.center = CGPointMake(obj.center.x+self.gapBetweenPages, obj.center.y);
        }
    }];
    return layoutAttsArray;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
