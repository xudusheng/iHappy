//
//  XDSConfigItem.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDSUrlItem.h"
#define XDSConfigItemTestEnableChangedNotification               @"XDSConfigItemTestEnableChangedNotification"

#define defaultTestCell  @"Default"
#define testName  @"name"
#define testItems  @"items"

NS_ASSUME_NONNULL_BEGIN

@interface XDSConfigItem : NSObject

@property (nonatomic, assign) BOOL testEnable;
@property (nonatomic, strong, nullable) NSArray *testConfigs;
@property (nonatomic, strong, nullable) NSString * configUrlFromTest;


@property (nonatomic, strong, nullable) NSMutableDictionary *services;
@property (nonatomic, strong, nullable) NSMutableDictionary *country;
@property (nonatomic, strong, nullable) NSMutableDictionary *language;
@property (nonatomic, strong, nullable) NSMutableDictionary *platforms;
@property (nonatomic, strong, nullable) NSMutableDictionary *appParams;//对外在实现各种直接方法，例如：getDebugLog
@property (nonatomic, strong, nullable) NSArray *deviceRedirect;
@property (nonatomic, strong, nullable) NSArray *versionRedirect;

@property (nonatomic, strong, nullable) NSString * defaultCountry;
@property (nonatomic, strong, nullable) NSString * defaultLanguage;


-(nullable id)initConfigItemWithJsonStr:(nullable NSString *)jsonStr;
-(nullable id)initConfigItemBySystemLanguageWithJsonStr:(nullable NSString *)jsonStr;
-(nullable id)initConfigItemWithJsonStr:(nullable NSString *)jsonStr DefaultContry:(nullable NSString *)defaultCountry DefaultLanguage:(nullable NSString *)defaultLanguage;
//-(void)parseJsonStr:(NSString *)jsonsrt;
-(void)addTestByJsonStr:(nullable NSString *)jsonStr;

-(void)setDefaultCountry:(NSString *)defaultCountry;
-(void)setDefaultLanguage:(NSString *)defaultLanguage;
-(void)setDefaultContry:(nullable NSString *)defaultCountry DefaultLanguage:(nullable NSString *)defaultLanguage;
-(BOOL)isDefaultCountryValid;
-(BOOL)isDefaultLanguageValid;



-(void)updateConfigWithTestting;


- (nullable NSString *)redirectUrlStr;


+(BOOL)writeConfigWithJsonStr:(nullable NSString *)jsonStr;
//+(BOOL)writeConfigWithJsonStr:(NSString *)jsonStr FilePath:(NSString *)filePath;
+(nullable NSString *)readConfig;
//+(NSString *)readConfig:(NSString *)filePath;
-(void)readConfigFileAnConfigProperties;


-(nullable XDSUrlItem *)urlItemByXdid:(NSString *)xdid;
-(nullable id)urlItemByXdid:(NSString *)xdid  paramPath:(NSString *)paramPath;


-(nullable NSMutableDictionary *)getUsedConfig;
- (void)saveUsedConfig;


-(void)saveConfigurlFromTest:(nullable NSString *)configurl;
-(nullable NSString *)getConfigurlFromTest;



+(nullable XDSUrlItem *)globalParams;

#pragma mark -
@property (nonatomic, assign) BOOL isV2Config;

#pragma mark - appParams
@property (nonatomic, assign) BOOL  isLogging;
@property (nonatomic, assign) BOOL  useAirPlay;
#pragma mark - services
@property (nonatomic, copy, nullable) NSString * locServer;
#pragma mark - interval
@property (nonatomic, assign) NSTimeInterval pollInterval;
#pragma mark - qos
@property (nonatomic, assign) BOOL qosEnable;
@property (nonatomic, copy, nullable) NSString * qosServer;
@property (nonatomic, copy, nullable) NSString * qosSiteID;
@property (nonatomic, assign) NSUInteger qosPeriodTime;
@property (nonatomic, copy, nullable) NSString * qosProductID;




@end
NS_ASSUME_NONNULL_END
