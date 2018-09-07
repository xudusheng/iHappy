//
//  XDSVideoViewController.m
//  iHappy_enterprise
//
//  Created by Hmily on 2018/9/7.
//  Copyright © 2018年 XDS. All rights reserved.
//

#import "XDSVideoViewController.h"
#import "XDSHttpRequest.h"
@interface XDSVideoViewController ()


@property (copy, nonatomic) NSString * rootUrl;

@property (nonatomic,assign) NSInteger type;

@property (copy, nonatomic) NSString * firstPageUrl;

@property (copy, nonatomic) NSString * nextPageUrl;

@end

@implementation XDSVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.rootUrl = @"http://www.q2002.com";
    self.type = 2;
    self.firstPageUrl = [NSString stringWithFormat:@"%@/type/%ld.html",self.rootUrl, self.type];
    
    [self fetchMovieList:YES];
}



#pragma mark - 点击事件处理
- (void)fetchMovieList:(BOOL)isTop{
    __weak typeof(self)weakSelf = self;
    [[[XDSHttpRequest alloc] init] htmlRequestWithHref:isTop?_firstPageUrl:_nextPageUrl
                                         hudController:self
                                               showHUD:NO
                                               HUDText:nil
                                         showFailedHUD:YES
                                               success:^(BOOL success, NSData * htmlData) {
                                                   if (success) {
                                                       [weakSelf detailHtmlData:htmlData needClearOldData:isTop];
                                                   }else{
                                                       [XDSUtilities showHud:@"数据请求失败，请稍后重试" rootView:self.navigationController.view hideAfter:1.2];
                                                   }
                                               } failed:^(NSString *errorDescription) {
                                               }];
}

#pragma mark - 其他私有方法

- (void)detailHtmlData:(NSData *)htmlData needClearOldData:(BOOL)needClearOldData{
    TFHpple * hpp = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray * pageElements = [hpp searchWithXPathQuery:@"//div[@class =\"pages\"]//ul"];
    
    if (pageElements.count > 0) {
        TFHppleElement * pageElement = pageElements.firstObject;
        NSArray * childElements = [pageElement childrenWithTagName:@"li"];
        self.nextPageUrl = nil;
        for (int i = 0; i < childElements.count; i ++) {
            TFHppleElement * li_element = childElements[i];
            NSString * className = [li_element objectForKey:@"class"];
            if ([className isEqualToString:@"on"] && i + 1 < childElements.count) {
                TFHppleElement * nextPage_element = childElements[i+1];
                NSString * nextHref =  [[nextPage_element firstChildWithTagName:@"a"] objectForKey:@"href"];
                self.nextPageUrl =nextHref;
                break;
            }
        }
    }else{
        self.nextPageUrl = nil;
    }
    
    
    NSArray * rowElements = [hpp searchWithXPathQuery:@"//li[@class=\"p1 m1\"]"];
    NSMutableArray * sqlList = [NSMutableArray arrayWithCapacity:0];
    for (TFHppleElement * oneElements in rowElements) {
        TFHppleElement * a_link_hover =  [oneElements firstChildWithClassName:@"link-hover"];//跳转地址
        TFHppleElement * image_lazy =  [a_link_hover firstChildWithClassName:@"lazy"];//图片
        
        TFHppleElement * span_lzbz =  [a_link_hover firstChildWithClassName:@"lzbz"];
        TFHppleElement * p_name = [span_lzbz firstChildWithClassName:@"name"];//名称
        TFHppleElement * p_actor =  [span_lzbz childrenWithClassName:@"actor"].lastObject;//更新时间
        
        
        NSString * name = p_name.text;
        NSString * image_src = [image_lazy objectForKey:@"src"];
        NSString * update_time = p_actor.text;
        NSString * href = [a_link_hover objectForKey:@"href"];
        href = [self.rootUrl stringByAppendingString:href];
        NSString *md5key = [href cw_md5];

        NSLog(@"%@ = %@ = %@ = %@ = %@",md5key, name, href, image_src, update_time);

        
        NSString *sql = @"INSERT INTO video (md5key, type, name, href, image_src, update_time) VALUE (\'${md5key}\', \'${type}\', \'${name}\', \'${href}', \'${image_src}\', \'${update_time}\') ON DUPLICATE KEY UPDATE type = ${type}, name = \'${name}\', href = \'${href}\', image_src = \'${image_src}\', update_time = \'${update_time}'";
        sql = [sql stringByReplacingOccurrencesOfString:@"${md5key}" withString:md5key];
        sql = [sql stringByReplacingOccurrencesOfString:@"${type}" withString:@(_type).stringValue];
        sql = [sql stringByReplacingOccurrencesOfString:@"${name}" withString:name];
        sql = [sql stringByReplacingOccurrencesOfString:@"${href}" withString:href];
        sql = [sql stringByReplacingOccurrencesOfString:@"${image_src}" withString:image_src];
        sql = [sql stringByReplacingOccurrencesOfString:@"${update_time}" withString:update_time];

        [sqlList addObject:sql];
    }
    NSString *sqls = [sqlList componentsJoinedByString:@";"];
    NSLog(@"sqls = %@", sqls);
    [self updateVideoDataBase:sqls];
}

- (void)updateVideoDataBase:(NSString *)sql{
    __weak typeof(self)weakSelf = self;
//    NSString *url = [NSString stringWithFormat:@"http://172.16.6.81/ihappy/update?sql=%@",sql];
    NSString *url = @"http://localhost/ihappy/update";

    [[[XDSHttpRequest alloc] init] POSTWithURLString:url
                                           reqParam:@{@"sql":sql}
                                      hudController:self
                                            showHUD:NO
                                            HUDText:nil
                                      showFailedHUD:NO
                                            success:^(BOOL success, id successResult) {
                                                NSLog(@"successResult = %@", successResult);
                                            } failed:^(NSString *errorDescription) {
                                                
                                            }];
}


@end
