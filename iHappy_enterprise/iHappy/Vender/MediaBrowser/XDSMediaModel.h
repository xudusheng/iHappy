//
//  XDSMediaModel.h
//  XDSPhotoBrowser
//
//  Created by Hmily on 2018/8/21.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XDSMediaType) {
    XDSMediaTypeImage = 0,
    XDSMediaTypeVideo,
    XDSMediaTypeGif,
};

typedef void(^XDSMediaModelDownloadProgressBlock)(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL);
typedef void(^XDSMediaModelDownloadCompletionBlock)(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSURL * _Nullable imageURL);

@interface XDSMediaModel : NSObject

@property (nonatomic,assign) XDSMediaType mediaType;

@property (nonatomic,strong) NSURL *mediaURL;

@property (nonatomic,strong) UIImage *image;

@property (nonatomic,strong) UIImage *placeholderImage;


- (void)downloadImage:(NSURL *)url
             progress:(nullable XDSMediaModelDownloadProgressBlock)progressBlock
            completed:(nullable XDSMediaModelDownloadCompletionBlock)completedBlock;


@end
