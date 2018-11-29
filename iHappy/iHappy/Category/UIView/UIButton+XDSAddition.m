//
//  UIButton+XDSAddition.m
//  MaiMkt
//
//  Created by ayi on 2018/5/15.
//  Copyright © 2018 ayi. All rights reserved.
//

#import "UIButton+XDSAddition.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImage+GIF.h>

#import "XDSMediaModel.h"
@implementation UIButton (XDSAddition)


- (void)btnTitleUnderImgWithHeight:(CGFloat )height{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(self.frame.size.height - height, -self.imageView.frame.size.width, 0, 0);
}

- (void)btnTitleLeftImg{
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, - self.imageView.frame.size.width, 0, self.imageView.frame.size.width)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, self.titleLabel.bounds.size.width, 0, -self.titleLabel.bounds.size.width - 10)];
}

static char expandSizeKey;

- (void)expandSize:(CGFloat)size {
    
    //OBJC_EXPORT void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
    //OBJC_EXPORT 打包lib时，用来说明该函数是暴露给外界调用的。
    //id object 表示关联者，是一个对象
    //id value 表示被关联者，可以理解这个value最后是关联到object上的
    //const void *key 被关联者也许有很多个，所以通过key可以找到指定的那个被关联者
    
    objc_setAssociatedObject(self, &expandSizeKey, [NSNumber numberWithFloat:size], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

//获取设置的扩大size，来扩大button的rect
//当前只是设置了一个扩大的size，当然也可以设置4个扩大的size，上下左右，具体扩大多少对应button的四个边传入对应的size
- (CGRect)expandRect {
    
    NSNumber *expandSize = objc_getAssociatedObject(self, &expandSizeKey);
    
    if (expandSize) {
        return CGRectMake(self.bounds.origin.x - expandSize.floatValue,
                          self.bounds.origin.y - expandSize.floatValue,
                          self.bounds.size.width + expandSize.floatValue + expandSize.floatValue,
                          self.bounds.size.height + expandSize.floatValue + expandSize.floatValue);
    } else {
        return self.bounds;
    }
}

//响应用户的点击事件
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect buttonRect = [self expandRect];
    if (CGRectEqualToRect(buttonRect, self.bounds)) {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(buttonRect, point) ? YES : NO;
}


#pragma mark - UIImageView兼容GIF图片
+ (void)load {
    [self swizzleMethod:@selector(sd_setImageWithURL:forState:) withMethod:@selector(replace_sd_setImageWithURL:forState:)];
    [self swizzleMethod:@selector(sd_setImageWithURL:forState:placeholderImage:) withMethod:@selector(replace_sd_setImageWithURL:forState:placeholderImage:)];
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

- (void)replace_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self bx_setImageWithURL:url forState:state placeholderImage:placeholder];
}
- (void)replace_sd_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state {
    [self bx_setImageWithURL:url forState:state];
}

- (void)bx_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder completed:(nullable void(^)(UIImage *image))completedBlock {
    [self setImage:placeholder forState:state];
    UIImage *cacheImage = [self imageFromSdcache:url forState:state];
    if (!cacheImage) {
        [self downloadImage:url forState:(UIControlState)state progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSURL * _Nullable imageURL) {
            [self imageFromSdcache:imageURL forState:state];
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
- (void)bx_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state placeholderImage:(nullable UIImage *)placeholder {
    [self bx_setImageWithURL:url forState:state placeholderImage:placeholder completed:nil];
}

- (void)bx_setImageWithURL:(nullable NSURL *)url forState:(UIControlState)state{
    [self bx_setImageWithURL:url forState:state placeholderImage:nil];
}

//查找url的图片是否有缓存
- (UIImage *)imageFromSdcache:(NSURL *)imgUrl forState:(UIControlState)state {
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
        [self setImage:image forState:state];
    }
    return image;
}

//下载图片
- (void)downloadImage:(NSURL *)url
             forState:(UIControlState)state
             progress:(nullable XDSMediaModelDownloadProgressBlock)progressBlock
            completed:(nullable XDSMediaModelDownloadCompletionBlock)completedBlock {
    [[SDWebImageManager sharedManager] loadImageWithURL:url
                                                options:0
                                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                                   if (progressBlock) {
                                                       progressBlock(receivedSize, expectedSize, targetURL);
                                                   }
                                               } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                   [self imageFromSdcache:imageURL forState:state];
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       if (completedBlock) {
                                                           completedBlock(image, data, error, finished, imageURL);
                                                       }
                                                   });
                                               }];
}


@end
