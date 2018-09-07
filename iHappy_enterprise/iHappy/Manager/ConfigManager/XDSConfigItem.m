//
//  XDSConfigItem.m
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import "XDSConfigItem.h"
#import <UIKit/UIKit.h>
#import "XDSLocalizableManager.h"
#define appConfigFileName [NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],@"appConfig"]
//#warning <#message#>
#define TestingConfigKey              @"TestingConfigKey"
#define ConfigurlFromTest  @"ConfigurlFromTest"

static NSMutableDictionary  *usedConfigs;

static XDSUrlItem * sGlobalParams;

@interface XDSConfigItem ()

@property (nonatomic, strong)   NSMutableDictionary * testUrlDictionary;


@end
@implementation XDSConfigItem
#pragma mark -

-(id)initConfigItemWithJsonStr:(NSString *)jsonStr{
    return   [self initConfigItemWithJsonStr:jsonStr DefaultContry:nil DefaultLanguage:nil];
}

-(id)initConfigItemWithJsonStr:(NSString *)jsonStr DefaultContry:(NSString *)defaultCountry DefaultLanguage:(NSString *)defaultLanguage{
    self = [self init];
    if (self){
        [XDSConfigItem writeConfigWithJsonStr:jsonStr];
        _defaultCountry = defaultCountry;
        _defaultLanguage = defaultLanguage;
        if (![self parseJsonStr:jsonStr]) {
            return nil;
        };
        [self configProperties];
    }
    return self;
}


-(id)initConfigItemBySystemLanguageWithJsonStr:(NSString *)jsonStr{
    return   [self initConfigItemWithJsonStr:jsonStr DefaultContry:nil DefaultLanguage:[XDSLocalizableManager getAppDefaultLanguage]];
}


-(id)init{
    self = [super init];
    if (self){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:XDSAppDefaultLanguageChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDefaultLanguageChangedNotification:)
                                                     name:XDSAppDefaultLanguageChangedNotification
                                                   object:nil];
        if(!usedConfigs){
            usedConfigs = [self getUsedConfig];
        }
        if(!self.testUrlDictionary){
            self.testUrlDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
-(BOOL)parseJsonStr:(NSString *)jsonsrt{
    
    NSDictionary *configDictionary = [self __serializationWithJsonStr:jsonsrt];
    if (!configDictionary || !configDictionary[@"base"]) {
        return NO;
    }
    self.deviceRedirect = [configDictionary valueForKeyPath:@"redirect.devices"];
    self.versionRedirect = [configDictionary valueForKeyPath:@"redirect.versions"];
    
    //dataSource  and  services
    NSArray *dataSource = [configDictionary valueForKeyPath:@"base.dataSource"];
    NSArray *services = [configDictionary valueForKeyPath:@"base.services"];
    self.services = [[NSMutableDictionary alloc] initWithCapacity:(dataSource.count+services.count)];
    for (NSDictionary * dic in dataSource) {
        XDSUrlItem * item = [[XDSUrlItem alloc] init];
        item.xdid = [dic objectForKey:@"xdid"];
        item.url = [dic objectForKey:@"url"];
        item.enable = (([dic objectForKey:@"enabled"] == nil)?YES:[[dic objectForKey:@"enabled"] boolValue]);
        item.params = [dic objectForKey:@"params"] ;
        if(item.enable){
            [self.services setValue:item forKey:item.xdid];
        }
    }
    for (NSDictionary * dic in services) {
        XDSUrlItem * item = [[XDSUrlItem alloc] init];
        item.xdid = [dic objectForKey:@"xdid"];
        item.url = [dic objectForKey:@"url"];
        item.enable =(([dic objectForKey:@"enabled"] == nil)?YES:[[dic objectForKey:@"enabled"] boolValue]);
        item.params = [dic objectForKey:@"params"];
        if(item.enable){
            [self.services setValue:item forKey:item.xdid];
        }
    }
    
    //appParams
    NSArray *appParams = [configDictionary valueForKeyPath:@"base.appParams"];
    self.appParams = [[NSMutableDictionary alloc] initWithCapacity:(appParams.count)];
    for (NSDictionary * dic in appParams) {
        XDSUrlItem * item = [[XDSUrlItem alloc] init];
        item.xdid = [dic objectForKey:@"xdid"];
        item.url = [dic objectForKey:@"url"];
        item.enable = (([dic objectForKey:@"enabled"] == nil)?YES:[[dic objectForKey:@"enabled"] boolValue]);
        item.params = [dic objectForKey:@"params"] ;
        if(item.enable){
            [self.appParams setValue:item forKey:item.xdid];
        }
    }
    
    sGlobalParams = [self.appParams objectForKey:@"xd.app.settings"];
    
    
    
    //country
    NSDictionary *country = [configDictionary valueForKeyPath:@"locale.country"];
    self.country = [[NSMutableDictionary alloc] initWithCapacity:(country.count)];
    for (NSString *countryCode in [country allKeys]) {
        NSMutableDictionary *servicesInCountry = [[NSMutableDictionary alloc]initWithCapacity:[(NSArray *)[country objectForKey:countryCode] count]];
        for (NSDictionary * dic in [country objectForKey:countryCode]) {
            XDSUrlItem * item = [[XDSUrlItem alloc] init];
            item.xdid = [dic objectForKey:@"xdid"];
            item.url = [dic objectForKey:@"url"];
            item.enable = (([dic objectForKey:@"enabled"] == nil)?YES:[[dic objectForKey:@"enabled"] boolValue]);
            item.params = [dic objectForKey:@"params"] ;
            if(item.enable){
                [servicesInCountry setValue:item forKey:item.xdid];
            }
        }
        [self.country setValue:servicesInCountry forKey:countryCode];
    }
    
    //language
    NSDictionary *language = [configDictionary valueForKeyPath:@"locale.language"];
    self.language = [[NSMutableDictionary alloc] initWithCapacity:(language.count)];
    for (NSString *languageCode in [language allKeys]) {
        NSMutableDictionary *servicesInLanguage= [[NSMutableDictionary alloc]initWithCapacity:[(NSArray *)[language objectForKey:languageCode] count]];
        for (NSDictionary * dic in [language objectForKey:languageCode]) {
            XDSUrlItem * item = [[XDSUrlItem alloc] init];
            item.xdid = [dic objectForKey:@"xdid"];
            item.url = [dic objectForKey:@"url"];
            item.enable = (([dic objectForKey:@"enabled"] == nil)?YES:[[dic objectForKey:@"enabled"] boolValue]);
            item.params = [dic objectForKey:@"params"] ;
            if(item.enable){
                [servicesInLanguage setValue:item forKey:item.xdid];
            }
        }
        [self.language setValue:servicesInLanguage forKey:languageCode];
    }
    
    //platforms
    NSArray *platforms ;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        platforms = [configDictionary valueForKeyPath:@"locale.platforms.ipad"];
    }else if (UIUserInterfaceIdiomPhone == UI_USER_INTERFACE_IDIOM()){
        platforms = [configDictionary valueForKeyPath:@"locale.platforms.iphone"];
    }
    self.platforms = [[NSMutableDictionary alloc] initWithCapacity:(platforms.count)];
    for (NSDictionary * dic in platforms) {
        XDSUrlItem * item = [[XDSUrlItem alloc] init];
        item.xdid = [dic objectForKey:@"xdid"];
        item.url = [dic objectForKey:@"url"];
        item.enable = (([dic objectForKey:@"enabled"] == nil)?YES:[[dic objectForKey:@"enabled"] boolValue]);
        item.params = [dic objectForKey:@"params"] ;
        if(item.enable){
            [self.platforms setValue:item forKey:item.xdid];
        }
    }

    return YES;
    
}

-(void)parseTestJsonStr:(NSString *)jsonsrt{
    //test
    [self.testUrlDictionary removeAllObjects];
    NSDictionary *configDictionary = [self __serializationWithJsonStr:jsonsrt];
    self.testEnable = [[configDictionary valueForKeyPath:@"enabled"] boolValue];
    NSArray *arr = [configDictionary valueForKeyPath:@"group"];
    NSMutableArray *groupArr = [[NSMutableArray alloc] initWithCapacity:arr.count];
    for (NSDictionary *tempdic in arr) {
        NSMutableDictionary *groupDic = [[NSMutableDictionary alloc] init];
        
        NSArray * jsoncellArr = tempdic[testItems];
        NSMutableArray *cellArr = [[NSMutableArray alloc] initWithCapacity:jsoncellArr.count];
        
        [cellArr addObject:@{testName:defaultTestCell}];//
        
        NSString *usedStr = defaultTestCell ;
        
        for (NSDictionary *tempCelldic in jsoncellArr) {
            NSMutableDictionary *cellDic = [[NSMutableDictionary alloc] init];
            NSArray *tempcellArr =  tempCelldic[testItems];
            NSMutableArray * urlArr = [[NSMutableArray alloc] initWithCapacity:tempcellArr.count];
            for (NSDictionary *tempurldic  in tempcellArr) {
                XDSUrlItem * item = [[XDSUrlItem alloc] init];
                item.xdid = [tempurldic objectForKey:@"xdid"];
                item.url = [tempurldic objectForKey:@"url"];
                item.enable = (([tempurldic objectForKey:@"enabled"] == nil)?YES:[[tempurldic objectForKey:@"enabled"] boolValue]);
                item.params = [tempurldic objectForKey:@"params"] ;
                if(item.enable){
                    [urlArr addObject:item];
                    if ([item.xdid isEqualToString:@"xd.app.config"]) {
                        [self.testUrlDictionary setValue:item.url forKey:[NSString stringWithFormat:@"%@%@",tempdic[testName],tempCelldic[testName]]];
                    }
                }
            }
            cellDic[testName] = tempCelldic[testName];//
            cellDic[testItems] = urlArr;
            [cellArr addObject:cellDic];//
            
            if ([usedConfigs[tempdic[testName]] isEqualToString:cellDic[testName]]) {
                usedStr = cellDic[testName] ;
            }
        }
        //        if (!usedConfigs[tempdic[testName]]) {
        //            usedConfigs[tempdic[testName]] = defaultTestCell;
        //        }
        usedConfigs[tempdic[testName]] = usedStr;
        
        groupDic[testName] = tempdic[testName];//
        groupDic[testItems] = cellArr;//
        [groupArr addObject:groupDic];//
    }
    //
    self.testConfigs = groupArr;
    
    
}


-(void)configProperties{
    //support platforms override, the features same as current country and language, the parser priority is [country, language, platforms]
    
    for (NSString * xdidKey in [self.platforms allKeys]) {
        XDSUrlItem * platform =  [self.platforms objectForKey:xdidKey];
        XDSUrlItem * servicesItem =  [self.services objectForKey:xdidKey];
        if (platform && servicesItem) {
            [self.services setObject:[servicesItem merge:platform] forKey:xdidKey];
        }
    }
    
    
    //国家更新
    for (NSString * countryCode in [self.country allKeys]) {
        NSMutableDictionary   *servicesInCountry  = (NSMutableDictionary *)[self.country objectForKey:countryCode];
        if (servicesInCountry.count) {
            for (NSString * xdidKey in [servicesInCountry allKeys]) {
                XDSUrlItem * countryItem =  [servicesInCountry objectForKey:xdidKey];
                XDSUrlItem * servicesItem =  [self.services objectForKey:xdidKey];
                if (countryItem && servicesItem) {
                    [servicesInCountry setObject:[servicesItem merge:countryItem] forKey:xdidKey];
                }
            }
        }
    }
    
    
    //语言更新
    for (NSString * languageCode in [self.language allKeys]) {
        NSMutableDictionary   *servicesInLanguage  = (NSMutableDictionary *)[self.language objectForKey:languageCode];
        if (servicesInLanguage.count) {
            for (NSString * xdidKey in [servicesInLanguage allKeys]) {
                XDSUrlItem * languageItem =  [servicesInLanguage objectForKey:xdidKey];
                XDSUrlItem * servicesItem =  [self.services objectForKey:xdidKey];
                if (languageItem && servicesItem) {
                    [servicesInLanguage setObject:[servicesItem merge:languageItem] forKey:xdidKey];
                }
            }
        }
    }
    
    //default country & language
    if (self.defaultCountry.length && self.defaultLanguage.length) {
        NSMutableDictionary   *servicesInCountry  = (NSMutableDictionary *)[self.country objectForKey:self.defaultCountry];
        NSMutableDictionary   *servicesInLanguage  = (NSMutableDictionary *)[self.language objectForKey:[self  languageCode]];
        if (servicesInCountry.count &&  servicesInLanguage.count) {
            for (NSString * xdidKey in [servicesInCountry allKeys]) {
                XDSUrlItem * countryItem =  [servicesInCountry objectForKey:xdidKey];
                XDSUrlItem * languageItem =  [servicesInLanguage objectForKey:xdidKey];
                /*
                 if (countryItem && languageItem) {
                 [self.services setValue:[languageItem merge:countryItem] forKey:xdidKey];//  万一有相同的key，国家的优先级高
                 }else if (countryItem){
                 [self.services setValue: countryItem forKey:xdidKey];
                 }else if(languageItem){
                 [self.services setValue: languageItem forKey:xdidKey];
                 }
                 */
                if (languageItem) {
                    [self.services setValue:[languageItem merge:countryItem] forKey:xdidKey];//  万一有相同的key，国家的优先级高
                }else{
                    [self.services setValue: countryItem forKey:xdidKey];
                }
            }
            NSMutableArray * xdidArrForCountry = [[NSMutableArray alloc] initWithArray:[servicesInCountry allKeys]];
            NSMutableArray * xdidArrForLanguage = [[NSMutableArray alloc] initWithArray:[servicesInLanguage allKeys]];
            [xdidArrForLanguage removeObjectsInArray:xdidArrForCountry];
            if (xdidArrForLanguage.count) {
                for (NSString * xdidKey in xdidArrForLanguage) {
                    [self.services setValue:[servicesInLanguage objectForKey:xdidKey] forKey:xdidKey];
                }
            }
            
        }else if (servicesInCountry.count){
            for (NSString * xdidKey in [servicesInCountry allKeys]) {
                [self.services setValue:[servicesInCountry objectForKey:xdidKey] forKey:xdidKey];
            }
            
        }else if (servicesInLanguage.count){
            for (NSString * xdidKey in [servicesInLanguage allKeys]) {
                [self.services setValue:[servicesInLanguage objectForKey:xdidKey] forKey:xdidKey];
            }
            
        }
    }else if(self.defaultCountry.length){
        NSMutableDictionary   *servicesInCountry  = (NSMutableDictionary *)[self.country objectForKey:self.defaultCountry];
        for (NSString * xdidKey in [servicesInCountry allKeys]) {
            [self.services setValue:[servicesInCountry objectForKey:xdidKey] forKey:xdidKey];
        }
    }else if(self.defaultLanguage.length){
        NSMutableDictionary   *servicesInLanguage  = (NSMutableDictionary *)[self.language objectForKey:[self languageCode]];
        for (NSString * xdidKey in [servicesInLanguage allKeys]) {
            [self.services setValue:[servicesInLanguage objectForKey:xdidKey] forKey:xdidKey];
        }
    }
    
    
}


-(void)configTestProperties{
    //testting
    for (NSString *titlekey in usedConfigs ) {
        if ([usedConfigs[titlekey] isEqualToString:defaultTestCell]) {
            continue;
        }
        for (NSDictionary *groupDic in self.testConfigs) {
            if ([titlekey isEqualToString:groupDic[testName]]) {
                for (NSDictionary *cellDic in groupDic[testItems]) {
                    if ([cellDic[testName] isEqualToString:usedConfigs[titlekey]]) {
                        for (XDSUrlItem *urlItem in cellDic[testItems]) {
                            XDSUrlItem * servicesItem =  [self.services objectForKey:urlItem.xdid];
                            if (servicesItem) {
                                [self.services setObject:[servicesItem merge:urlItem] forKey:urlItem.xdid];
                            }else{
                                [self.services setObject:urlItem forKey:urlItem.xdid];
                            }
                        }
                    }
                }
            }
        }
    }
    
}

-(void)addTestByJsonStr:(NSString *)jsonStr{
    [self parseTestJsonStr:jsonStr];
    [self configTestProperties];
}


- (NSString *)redirectUrlStr
{
    NSString *config = nil;
    
    NSString *serialStr = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    for (NSDictionary *item in self.deviceRedirect) {
        NSString *url = [item objectForKey:@"url"];
        
        NSDictionary *dict = [item objectForKey:@"deviceId"];
        for (NSString *deviceId in [dict allValues]) {
            if ([deviceId isEqualToString:serialStr]) {
                config = url;
                return config;
            }
        }
    }
    
    NSString *versionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//    versionStr = @"3.3";
    for (NSDictionary *item in self.versionRedirect) {
        NSString *url = [item objectForKey:@"url"];
        
        NSArray *array = [item objectForKey:@"numbers"];
        for (NSString *versionId in array) {
//            if ([versionId isEqualToString:versionStr]) {
//                config = url;
//                return config;
//            }
            NSRange range = [versionStr rangeOfString:versionId options:NSRegularExpressionSearch];
            if (range.location != NSNotFound) {
                config = url;
                return config;
            }
        }
    }
    
    return config;
}

#pragma mark - read UrlItem

-(XDSUrlItem *)urlItemByXdid:(NSString *)xdid{
    XDSUrlItem * urlItem;
    urlItem = (XDSUrlItem *)[self.services objectForKey:xdid];
    if (urlItem) {
        [urlItem urlItemByNLLocalized];
        return  urlItem;
    }
    return [[self.appParams objectForKey:xdid] urlItemByNLLocalized];
}

-(id)urlItemByXdid:(NSString *)xdid  paramPath:(NSString *)paramPath{
    XDSUrlItem * urlItem;
    urlItem = (XDSUrlItem *)[self.services objectForKey:xdid];
    if (urlItem) {
        [urlItem urlItemByNLLocalized];
        return  [urlItem paramsValueBykey:paramPath];
    }
    return [((XDSUrlItem *)[[self.appParams objectForKey:xdid] urlItemByNLLocalized]) paramsValueBykey:paramPath];
}

- (void)saveUsedConfig
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:usedConfigs];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:data forKey:TestingConfigKey];
    [userDefaults synchronize];
}

- (NSMutableDictionary *)getUsedConfig
{
    if (!usedConfigs) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSData * data = [userDefaults objectForKey:TestingConfigKey];
        if (data) {
            usedConfigs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }else{
            usedConfigs = [[NSMutableDictionary alloc] init];
        }
    }
    
    return usedConfigs;
    
}


-(void)saveConfigurlFromTest:(NSString *)configurlkey{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:configurlkey forKey:ConfigurlFromTest];
    [userDefaults synchronize];
}
-(NSString *)getConfigurlFromTest{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * configurlkey = [userDefaults objectForKey:ConfigurlFromTest];
    return [self.testUrlDictionary objectForKey:configurlkey];
}


+(XDSUrlItem *)globalParams{
    return sGlobalParams;
}
#pragma mark - file

+(BOOL)writeConfigWithJsonStr:(NSString *)jsonStr{
    return  [self writeConfigWithJsonStr:jsonStr FilePath:appConfigFileName];
}

+(BOOL)writeConfigWithJsonStr:(NSString *)jsonStr FilePath:(NSString *)filePath{
    
#if TARGET_OS_IOS
    NSError * error;
    [jsonStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    return error?NO:YES;
#elif TARGET_OS_TV
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    [userDefaults setObject:data forKey:@"XDSTVAppConfig"];
    [userDefaults synchronize];
    return YES;
#endif
    
}

+(NSString *)readConfig{
    return  [self readConfig:appConfigFileName];
}

+(NSString *)readConfig:(NSString *)filePath{
#if TARGET_OS_IOS
    NSError * error;
    return  [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
#elif TARGET_OS_TV
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * appConfig = [userDefaults objectForKey:@"XDSTVAppConfig"];
    return [[NSString alloc] initWithData:appConfig encoding:NSUTF8StringEncoding];
#endif
}

-(void)readConfigFileAnConfigProperties{
    [self readConfigFileAnConfigProperties:appConfigFileName];
}

-(void)readConfigFileAnConfigProperties:(NSString *)filePath{
    NSString * jsonStr = [XDSConfigItem readConfig:filePath];
    [self parseJsonStr:jsonStr];
    [self configProperties];
}

#pragma mark - set DefaultCountry&DefaultLanguage

-(void)setDefaultCountry:(NSString *)defaultCountry{
    _defaultCountry = defaultCountry;
    [self readConfigFileAnConfigProperties];
}


-(void)setDefaultLanguage:(NSString *)defaultLanguage{
    _defaultLanguage = defaultLanguage;
    [self readConfigFileAnConfigProperties];
    
}

-(void)setDefaultContry:(NSString*)defaultCountry DefaultLanguage:(NSString *)defaultLanguage{
    _defaultCountry = defaultCountry;
    _defaultLanguage = defaultLanguage;
    [self readConfigFileAnConfigProperties];
    
}

-(BOOL)isDefaultCountryValid{
    if (!self.defaultCountry.length) {
        return NO;
    }else{
         NSMutableDictionary   *servicesInCountry  = (NSMutableDictionary *)[self.country objectForKey:self.defaultCountry];
        return  servicesInCountry.count;
    }

}
-(BOOL)isDefaultLanguageValid{
    if (!self.defaultLanguage.length) {
        return NO;
    }else{
        NSMutableDictionary   *servicesInCountry  = (NSMutableDictionary *)[self.language objectForKey: [self languageCode]];
        return  servicesInCountry.count;
    }
}

-(void)updateConfigWithTestting{
    [self readConfigFileAnConfigProperties];
    [self configTestProperties];
}

#pragma mark - NSNotification
-(void)appDefaultLanguageChangedNotification:(NSNotification *)notification{
    [self setDefaultLanguage:notification.userInfo[@"language"]];
    
}


#pragma mark - private
- (id)__serializationWithJsonStr:(NSString *) JsonStr{
    if(self == nil){
        return self;
    }
    NSError *err = nil;
    NSData *data = [JsonStr dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!data) {
        return nil;
    }
    
    id jsonValue = [NSJSONSerialization JSONObjectWithData:data
                                                   options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                                     error:&err];
    
    if(err){
        NSLog(@"%@", [err description]);
        return  nil;
    }
    return jsonValue;
}

-(NSString *)languageCode{
//    return seld.defaultLanguage;
    return  [XDSLocalizableManager matchSimilarLanguageWithSelectedLanuage:self.defaultLanguage localLanguageArray:[self.language allKeys]];
}

#pragma mark - get
-(BOOL )isLogging{
    return  [[self urlItemByXdid:@"xd.app.settings" paramPath:@"debugLog"] boolValue];
}

-(BOOL )useAirPlay{
    return  [[self urlItemByXdid:@"xd.app.settings" paramPath:@"useAirPlay"] boolValue];
}

-(NSString *)locServer{
    return  [self urlItemByXdid:@"xd.service.locServer"].url;
}

-(NSTimeInterval)pollInterval{
    return  [[self urlItemByXdid:@"xd.service.interval" paramPath:@"default"] doubleValue];
    
}

-(BOOL)qosEnable{
    return  [[self urlItemByXdid:@"xd.service.qos" paramPath:@"enable"] boolValue];
    
}
-(NSString *)qosServer{
    return  [self urlItemByXdid:@"xd.service.qos"].url ;
    
}
-(NSString *)qosSiteID{
    return  [self urlItemByXdid:@"xd.service.qos" paramPath:@"siteID"] ;
    
}
-(NSUInteger )qosPeriodTime{
    return  [[self urlItemByXdid:@"xd.service.qos" paramPath:@"sampleInterval"] unsignedIntValue];
    
}
-(NSString *)qosProductID{
    return  [self urlItemByXdid:@"xd.service.qos" paramPath:@"productID"] ;
    
}

#pragma mark - set
-(void)setTestEnable:(BOOL)testEnable{
    if (_testEnable != testEnable) {
        _testEnable = testEnable;
        [[NSNotificationCenter defaultCenter] postNotificationName:XDSConfigItemTestEnableChangedNotification
                                                            object:nil
                                                          userInfo:nil];
    }
}


@end
