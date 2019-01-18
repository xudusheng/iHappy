//
//  UIWebView+XDSAdd.h
//  iHappy
//
//  Created by Hmily on 2019/1/18.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (XDSAdd)

//UIWebView内容转tUIImage
- (UIImage *)imageRepresentation;
- (void)saveAsImageToPhoto;

@end

NS_ASSUME_NONNULL_END
