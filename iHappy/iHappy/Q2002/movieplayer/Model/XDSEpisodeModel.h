//
//  XDSEpisodeModel.h
//  iHappy
//
//  Created by Hmily on 2018/9/7.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XDSEpisodeModel : NSObject

@property (nonatomic,copy) NSString *ekey;
@property (nonatomic,copy) NSString *md5key;
@property (nonatomic,copy) NSString *title;//标题
@property (nonatomic,copy) NSString *href;//地址
@property (nonatomic,copy) NSString *player;//视频地址
@property (nonatomic,copy) NSString *player_alter;//备选地址
@property (nonatomic,copy) NSString *video;//备选地址
@property (nonatomic,assign) NSInteger sort;//剧集顺序
@property (nonatomic,assign) NSInteger section;


@end


@interface XDSEpisodeListModel : NSObject

@property (nonatomic,strong) NSArray<XDSEpisodeModel*> *episodeList;

@end
