//
//  XDSUrlItem.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NSString * _Nullable (^XDSUrlItemHandler)(NSString * _Nullable url);

@interface XDSUrlItem:NSObject
@property (nonatomic, copy) NSString * xdid;
@property (nonatomic, copy, nullable) NSString * url;
@property (nonatomic, assign) BOOL  enable;
//@property (nonatomic, strong) NSDictionary * params;
//@property (nonatomic, strong) NSMutableDictionary * urlParams;

-(nullable XDSUrlItem *)merge:(nullable XDSUrlItem *)urlItem;

-(nullable NSString *)originalURL;

-(nullable id)paramsValueBykey:(nullable NSString *)key;

-(void)replacingUrlItem:(nullable NSDictionary *)dic;
-(void)replacingUrlItem:(nullable NSDictionary *)dic byParamKey:(nullable NSString *)key;

-(nullable XDSUrlItem *)urlItemByNLLocalized;
-(void)setParams:(nullable NSDictionary *)params;

+(void)handleURLWithBlock:(XDSUrlItemHandler)handler;

@end
NS_ASSUME_NONNULL_END
