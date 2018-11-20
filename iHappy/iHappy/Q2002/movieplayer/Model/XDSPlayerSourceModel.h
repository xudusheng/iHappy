//
//  XDSPlayerSourceModel.h
//  iHappy
//
//  Created by Hmily on 2018/11/20.
//  Copyright © 2018 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDSPlayerSourceModel : NSObject

@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) BOOL isWebUrl;
@property (nonatomic,copy) NSString *videoUrl;

@end

NS_ASSUME_NONNULL_END
