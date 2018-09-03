//
//  XDSNewsModel.h
//  iHappy
//
//  Created by Hmily on 2018/8/31.
//  Copyright © 2018年 dusheng.xu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XDSNewsModel;
@interface XDSNewsResponstModel : NSObject
//id": "493b58436eae5626de077e983fe78ff5",
//"tags": null,
//"shareCount": null,
//"posterScreenName": "www.umei.cc",
//"likeCount": null,
//"url": "http://www.umei.cc/meinvtupian/xingganmeinv/15535.htm",
//-"imageUrls": [
//               "http://p0.so.qhimg.com/t0196cbf9afb3f7ce8a.jpg?1600x2400",
//               "http://p0.so.qhimg.com/t012c50131521d6a0eb.jpg?1600x2400",
//               "http://p0.so.qhimg.com/t01f8cf461707d6a9cc.jpg?1600x2400"
//               ],
//"content": "",
//"posterId": "www.umei.cc",
//"publishDate": 1524010473,
//"publishDateStr": "2018-04-18T00:14:33",
//"title": "[TouTiao头条女神]模特芃芃运动风休闲写真翘臀诱",
//"commentCount": null

@property (nonatomic,assign) BOOL hasNext;
@property (nonatomic,strong) NSString *retcode;
@property (nonatomic,strong) NSString *appCode;
@property (nonatomic,strong) NSString *dataType;
@property (nonatomic,strong) NSString *pageToken;
@property (nonatomic,strong) NSArray<XDSNewsModel*> *newsList;
//@property (nonatomic,strong) NSString *retcode;
//@property (nonatomic,strong) NSString *retcode;
//@property (nonatomic,strong) NSString *retcode;

@end

@interface XDSNewsModel : NSObject
//posterId string null posterId
//content string 最新的剧情中,陆晨曦( 新闻内容
//posterScreenName string 腾讯 发布者名称
//tags string null tags
//url string http://ent.qq.com/a/20170508/023354.htm 新闻链接
//publishDateStr string 2017-05-08T03:46:00 发布时间（UTC时间
//title string 白百何陷医患风波 《外科》靳东职业生涯遇危机 标题
//publishDate number 1494215160 发布日期时间戳
//commentCount string null 评论数
//imageUrls string null 图片
//id string c028fc8126658124bc8f21a13650d51b 新闻id

@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *posterScreenName;//发布者名称
@property (nonatomic,strong) NSString *url;//详情地址
@property (nonatomic,strong) NSString *publishDateStr;//布时间（UTC时间
@property (nonatomic,assign) NSInteger publishDate;//发布日期时间戳
@property (nonatomic,strong) NSArray<NSString*> *imageUrls;//图片

- (BOOL)isMultableImageNews;
@end
