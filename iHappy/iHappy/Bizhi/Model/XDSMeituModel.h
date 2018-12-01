//
//  XDSMeituModel.h
//  iHappy
//
//  Created by Hmily on 2018/8/26.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XDSMeituModel;
@class XDSDetailImageModel;
@interface XDSMeiziResponseModel : NSObject

@property (nonatomic,strong) NSArray<XDSMeituModel*> *meiziList;
@property (nonatomic,assign) NSInteger error_code;
@property (nonatomic,copy) NSString *errormessage;

@end




@interface XDSDetaimImageResponseModel : NSObject

@property (nonatomic,strong) NSArray<XDSDetailImageModel*> *imageList;
@property (nonatomic,assign) NSInteger error_code;
@property (nonatomic,copy) NSString *errormessage;

@end




//--------------------

@interface XDSMeituModel : NSObject

@property (copy, nonatomic) NSString *md5key;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *image_src;
@property (copy, nonatomic) NSString *href;//详情的地址

@property (assign, nonatomic) CGSize imageSize;

@property (nonatomic, copy) NSArray<NSString*> *imageList;


@end


@interface XDSDetailImageModel : NSObject

@property (copy, nonatomic) NSString *md5key;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *image_src;

@end
