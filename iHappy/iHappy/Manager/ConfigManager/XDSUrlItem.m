//
//  XDUrlItem.m

//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import "XDSUrlItem.h"
#import "RegexKitLite.h"
#import "XDSConfigItem.h"
#import "XDSConfigManager.h"

#define RegexStr @"(?<=\\$\\{)\\w+(?=\\})"
//static NSString  * const  kLocalozableTag = @"@xdkey/";

@interface XDSUrlItem ()
@property (nonatomic, strong) NSDictionary * params;
@property (nonatomic, strong) NSMutableDictionary * urlParams;
@end

static XDSUrlItemHandler urlItemHandler = nil;

@implementation XDSUrlItem

-(id)init {
    
    if (self = [super init]) {
        self.urlParams = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(XDSUrlItem *)merge:(XDSUrlItem *)urlItem{
    //urlItem的优先级高
    if (!(self.xdid.length && [self.xdid isEqualToString:urlItem.xdid])) {
        return nil;
    }
    
    XDSUrlItem * newItem = [[XDSUrlItem alloc] init];
    newItem.xdid = urlItem.xdid;
    newItem.url = urlItem.url.length?urlItem.url:self.url;
    newItem.enable = urlItem.enable;
    
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    for (NSString * key in [self.params allKeys]) {
        [dic setObject:[self.params objectForKey:key] forKey:key ];
    }
    for (NSString * key in [urlItem.params allKeys]) {
        [dic setObject:[urlItem.params objectForKey:key] forKey:key ];
    }
    if (dic.count) {
        newItem.params = dic;
    }
    
    return newItem;
}


-(NSString *)url{
    NSArray * keyArr = [_url componentsMatchedByRegex:RegexStr];
    NSMutableDictionary *urldic = self.urlParams[@"url"];
    if (!urldic) {
        urldic = [[NSMutableDictionary alloc] init];
    }
    for (NSString *key in keyArr) {
        if (!urldic[key]) {
            NSString * value = [self.params objectForKey:key];
            if (value) {
                urldic[key] = value;
                continue;
            }
            XDSUrlItem * urlItem =  [XDSConfigItem globalParams];
            value = [urlItem.params objectForKey:key];
            if (value) {
                urldic[key] = value;
                continue;
            }
            
        }
    }
    //handle config parameters
    __block NSString *newString = _url;
    [urldic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        newString = [newString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"${%@}",key] withString:obj];
    }];
    [urldic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        newString = [newString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"${%@}",key] withString:obj];
    }];
    
    //handle timestamp
    int timestampRefreshInterval = [[[XDSConfigManager sharedManager].configItem urlItemByXdid:@"xd.service.interval" paramPath:@"timestamp"] intValue];
    NSTimeInterval timestamp = timestampRefreshInterval > 0 ? [[NSDate date] timeIntervalSince1970]/timestampRefreshInterval : [[NSDate date] timeIntervalSince1970];
    NSString * timestampString = [NSString stringWithFormat:@"%.f",timestamp];
    newString = [newString stringByReplacingOccurrencesOfString:@"${timestamp}" withString:timestampString];
    
    //custom handle
    if (urlItemHandler) {
        newString = urlItemHandler(newString);
    }
    
    return newString;
}

+(void)handleURLWithBlock:(XDSUrlItemHandler)handler
{
    urlItemHandler = handler;
}

-(NSString *)originalURL{
    return _url;
}


-(id)paramsValueBykey:(NSString *)key{
    id value = [self.params valueForKeyPath:key];
    if (!value|| ![value isKindOfClass:[NSString class]]) {
        return value;
    }
    NSString *paramsKey = [NSString stringWithFormat:@"%@%@",@"params",key];
    NSString *url = (NSString *)value;
    NSArray * keyArr = [url componentsMatchedByRegex:RegexStr];
    NSMutableDictionary *urldic = self.urlParams[paramsKey];
    if (!urldic) {
        urldic = [[NSMutableDictionary alloc] init];
    }
    for (NSString *key in keyArr) {
        if (!urldic[key]) {
            NSString * value = [self.params objectForKey:key];
            if (value) {
                urldic[key] = value;
                continue;
            }
            XDSUrlItem * urlItem =  [XDSConfigItem globalParams];
            value = [urlItem.params objectForKey:key];
            if (value) {
                urldic[key] = value;
                continue;
            }
            
        }
    }
    __block NSString *newString = url;
    [urldic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        newString = [newString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"${%@}",key] withString:obj];
    }];
    [urldic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        newString = [newString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"${%@}",key] withString:obj];
    }];
    NSString * xdkey = @"@xdkey/";
    if ([newString hasPrefix:xdkey]) {
//        newString = NLLocalizedString(newString, nil);
        newString = newString;
    }
    
    return newString;
}

-(void)replacingUrlItem:(NSDictionary *)dic{
    NSMutableDictionary *urldic = self.urlParams[@"url"];
    if (!urldic) {
        urldic = [[NSMutableDictionary alloc] init];
    }
    for (NSString *key in dic) {
        urldic[key] = dic[key];
    }
    self.urlParams[@"url"] = urldic;
}


-(void)replacingUrlItem:(NSDictionary *)dic byParamKey:(NSString *)key{
    NSString *paramsKey = [NSString stringWithFormat:@"%@%@",@"params",key];
    NSMutableDictionary *urldic = self.urlParams[paramsKey];
    if (!urldic) {
        urldic = [[NSMutableDictionary alloc] init];
    }
    for (NSString *key in dic) {
        urldic[key] = dic[key];
    }
    self.urlParams[paramsKey] = urldic;
}

-(XDSUrlItem *)urlItemByNLLocalized{
    self.params = [self __parseByNLLocalized:self.params];
    return self;
}

-(NSDictionary *)__parseByNLLocalized:(NSDictionary *)params{
    if (!params) {
        return nil;
    }
    NSMutableDictionary *returnParams = [[NSMutableDictionary alloc] initWithCapacity:params.count];
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        if (!value) {
            continue;
        }
        if ([value isKindOfClass:[NSString class]]) {
            
//            NSString * xdkey = @"@xdkey/";
//            if ([value hasPrefix:xdkey]) {
//                value = NLLocalizedString(value,nil);
//            }
            
            [returnParams setObject:value forKey:key];
            continue;
        }else  if ([value isKindOfClass:[NSDictionary class]]) {
         [returnParams setObject:[self __parseByNLLocalized:value] forKey:key];
           continue;
        }else {
            [returnParams setObject:value forKey:key];
            continue;
        }
    }
    return returnParams ;
}


-(void)setParams:(NSDictionary *)params{
    _params = params;
}

@end
