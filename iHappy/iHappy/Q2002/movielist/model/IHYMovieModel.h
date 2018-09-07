//
//  IHYMovieModel.h
//  iHappy
//
//  Created by xudosom on 2016/11/19.
//  Copyright © 2016年 上海优蜜科技有限公司. All rights reserved.
//

#import "XDSRootModel.h"

@interface IHYMovieModel : XDSRootModel
    
@property (copy, nonatomic) NSString *md5key;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *update_time;
@property (copy, nonatomic) NSString *image_src;
@property (copy, nonatomic) NSString *href;
@property (copy, nonatomic) NSString *hdtag;
@property (copy, nonatomic) NSString *director;
@property (copy, nonatomic) NSString *casts;
@property (copy, nonatomic) NSString *style;
@property (copy, nonatomic) NSString *nation;
@property (copy, nonatomic) NSString *update_status;
@property (copy, nonatomic) NSString *score;
@property (copy, nonatomic) NSString *summary;
    
@end
