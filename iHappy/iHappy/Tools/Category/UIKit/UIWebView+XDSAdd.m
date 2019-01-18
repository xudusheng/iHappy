//
//  UIWebView+XDSAdd.m
//  iHappy
//
//  Created by Hmily on 2019/1/18.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import "UIWebView+XDSAdd.h"

@implementation UIWebView(XDSAdd)

//获取图片
- (UIImage *)imageRepresentation{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    CGSize contentSize = self.scrollView.contentSize;
    CGFloat contentHeight = contentSize.height;
    CGPoint offset = self.scrollView.contentOffset;
    
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    
    NSMutableArray *images = [NSMutableArray array];
    while(contentHeight > 0){
        UIGraphicsBeginImageContextWithOptions(boundsSize, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [images addObject:image];
        
        CGFloat offsetY = self.scrollView.contentOffset.y;
        [self.scrollView setContentOffset:CGPointMake(0, offsetY + boundsHeight)];
        contentHeight -= boundsHeight;
    }
    
    [self.scrollView setContentOffset:offset];
    
    CGSize imageSize = CGSizeMake(contentSize.width * scale,
                                  contentSize.height * scale);
    UIGraphicsBeginImageContext(imageSize);
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop){
        [image drawInRect:CGRectMake(0,
                                     scale * boundsHeight * idx,
                                     scale * boundsWidth,
                                     scale * boundsHeight)];
    }];
    UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}
//保存图片到相册
- (void)saveImageToPhotos:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:),NULL);
}
//保存回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error != NULL){
        msg =@"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    [SVProgressHUD showInfoWithStatus:msg];
}

- (void)saveAsImageToPhoto {
    UIImage *image = [self imageRepresentation];
    [self saveImageToPhotos:image];
}

@end
