//
// UIImageView+XDSAdditionm
//  BiXuan
//
//  Created by bsnl on 2018/7/25.
//  Copyright © 2018年 BSNL. All rights reserved.
//


#import "UIImageView+XDSAddition.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImage+GIF.h>

#import <objc/runtime.h>

#import "XDSMediaModel.h"

@implementation UIImageView (XDSAddition)
- (void)setBadgeValue:(NSInteger)badgeValue {
    self.clipsToBounds = NO;
    objc_setAssociatedObject(self, @"badgeValue", @(badgeValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UILabel *badgeLabel = objc_getAssociatedObject(self, @"badgeLabel");
    if (badgeLabel == nil) {
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        badgeLabel.font = [UIFont systemFontOfSize:12];
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.backgroundColor = [UIColor redColor];
        [self addSubview:badgeLabel];
        objc_setAssociatedObject(self, @"badgeLabel", badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    badgeLabel.hidden = NO;
    badgeLabel.text = @(badgeValue).stringValue;

    CGFloat width = 15.f;
    if (badgeValue <= 0) {
        badgeLabel.hidden = YES;
    }else if (badgeValue > 9){
        width = width/2;
        badgeLabel.text = @"";
    }
    CGFloat height = width;
    CGFloat originX = CGRectGetWidth(self.bounds) - width/2;
    CGFloat originY = -height/2;
    CGRect frame = CGRectMake(originX, originY, width, height);
    badgeLabel.frame = frame;
    
    badgeLabel.layer.cornerRadius = width/2;
    badgeLabel.layer.masksToBounds = YES;
//    badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
//    badgeLabel.layer.borderWidth = 2.0f;
}


- (NSInteger)badgeValue {
    NSNumber *badgeValue = objc_getAssociatedObject(self, @"badgeValue");
    return badgeValue.integerValue;
}


#pragma mark - UIImageView兼容GIF图片
- (void)downloadImage:(NSURL *)url
             progress:(nullable XDSMediaModelDownloadProgressBlock)progressBlock
            completed:(nullable XDSMediaModelDownloadCompletionBlock)completedBlock {
    [[SDWebImageManager sharedManager] loadImageWithURL:url
                                                options:0
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                   if (progressBlock) {
                                                       progressBlock(receivedSize, expectedSize, targetURL);
                                                   }
                                               } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                   [self imageFromSdcache:imageURL];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (completedBlock) {
                                                           completedBlock(image, data, error, finished, imageURL);
                                                       }
                                                   });
                                               }];
}

+ (void)load {
    [self swizzleMethod:@selector(sd_setImageWithURL:) withMethod:@selector(replace_sd_setImageWithURL:)];
    [self swizzleMethod:@selector(sd_setImageWithURL:placeholderImage:) withMethod:@selector(replace_sd_setImageWithURL:placeholderImage:)];
}

+ (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector {
    Class cls = self;
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    BOOL didAddMethod = class_addMethod(cls,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)replace_sd_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self bx_setImageWithURL:url placeholderImage:placeholder];
}
- (void)replace_sd_setImageWithURL:(nullable NSURL *)url {
    [self bx_setImageWithURL:url];
}

- (void)bx_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable void(^)(UIImage *image))completedBlock {
    self.image = placeholder;
    UIImage *cacheImage = [self imageFromSdcache:url];
    if (!cacheImage) {
        [self downloadImage:url progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSURL * _Nullable imageURL) {
            [self imageFromSdcache:imageURL];
            if (completedBlock) {
                completedBlock(image);
            }
        }];
    }else {
        if (completedBlock) {
            completedBlock(cacheImage);
        }
    }
}
- (void)bx_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self bx_setImageWithURL:url placeholderImage:placeholder completed:nil];
}

- (void)bx_setImageWithURL:(nullable NSURL *)url {
    [self bx_setImageWithURL:url placeholderImage:nil];
}

//查找url的图片是否有缓存
- (UIImage *)imageFromSdcache:(NSURL *)imgUrl{
    XDSMediaType type = [imgUrl.absoluteString hasSuffix:@".gif"]?XDSMediaTypeGif:XDSMediaTypeImage;
    NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:imgUrl];
    UIImage *image = nil;
    if (cacheImageKey) {
        if (type == XDSMediaTypeGif) {
            NSData *data = [[SDImageCache sharedImageCache] diskImageDataForKey:cacheImageKey];
            image = [UIImage sd_animatedGIFWithData:data];
        }else {
            image = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheImageKey];
        }
    }
    if (image) {
        self.image = image;
    }
    return image;
}

@end
