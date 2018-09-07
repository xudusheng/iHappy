//
//  XDSMediaModel.m
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import "XDSMediaModel.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImage+GIF.h>

@interface SDImageCache(DiskCache)

- (nullable NSData *)diskImageDataBySearchingAllPathsForKey:(nullable NSString *)key;

@end

@implementation XDSMediaModel

- (void)downloadImage:(NSURL *)url
             progress:(nullable XDSMediaModelDownloadProgressBlock)progressBlock
            completed:(nullable XDSMediaModelDownloadCompletionBlock)completedBlock {
    [[SDWebImageManager sharedManager] loadImageWithURL:self.mediaURL
                                                options:0
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                   if (progressBlock) {
                                                       progressBlock(receivedSize, expectedSize, targetURL);
                                                   }
                                               } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                   self.image = image;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (completedBlock) {
                                                           completedBlock(image, data, error, finished, imageURL);
                                                       }
                                                   });
                                               }];
}


- (UIImage *)image {
    if (_image) return _image;
    return [self imageFromSdcache:self.mediaURL];
}

//查找url的图片是否有缓存
- (UIImage *)imageFromSdcache:(NSURL *)imgUrl{
    self.mediaType = XDSMediaTypeGif;
    NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:imgUrl];
    if (cacheImageKey) {
        UIImage *image = nil;
        if (self.mediaType == XDSMediaTypeGif) {
            NSData *data = [[SDImageCache sharedImageCache] diskImageDataBySearchingAllPathsForKey:cacheImageKey];
            image = [UIImage sd_animatedGIFWithData:data];
        }else {
            image = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheImageKey];
        }
        self.image = image;
    }
    return _image;
}
@end
