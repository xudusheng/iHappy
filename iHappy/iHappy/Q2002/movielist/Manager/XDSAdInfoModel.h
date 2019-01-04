//
//  XDSAdInfoModel.h
//  iHappy
//
//  Created by Hmily on 2019/1/4.
//  Copyright © 2019 Dusheng Du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XDSAdInfoModel : JSONModel

@property (assign, nonatomic) BOOL enable;//广告是否开启
@property (assign, nonatomic) BOOL player_enable;//是否在播放器上显示广告
@property (assign, nonatomic) NSInteger index;//随机数，collectionView中碰到这个数的倍数，插入一天广告
@end

NS_ASSUME_NONNULL_END
