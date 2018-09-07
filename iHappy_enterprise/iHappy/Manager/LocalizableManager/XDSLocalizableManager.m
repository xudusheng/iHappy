//
//  XDSLocalizableManager.m
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import "XDSLocalizableManager.h"
#import <Foundation/Foundation.h>
#import "NLEZipArchive.h"
#import "NLEPropertyParser.h"
#import "XDSConfigManager.h"


#define kXDSLocalZipDirectory [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: @"Localizable"]

#define kXDSLocalFilePath(localizableName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent: [NSString stringWithFormat:@"Localizable/%@",(localizableName)]]

static NSString * localizableLocalFilePrefix = nil;
static NSString * noMatchToUseLanguage = nil;

@interface XDSLocalizableManager ()

@property (nonatomic, copy) NSString * localizableServerURLString;
@property (nonatomic, copy) XDSLocalizableUpdateFinishedBlock updateFinishedBlock;

@end

@implementation XDSLocalizableManager

+ (XDSLocalizableManager *)sharedManager
{
    static XDSLocalizableManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self instanceClass] alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Public methods

- (NSDictionary *)currentLanguageDictionary
{
    if (!_currentLanguageDictionary) {
        _currentLanguageDictionary = [self createCurrentLanguageDictionary];
    }
    return _currentLanguageDictionary;
}

//save and get default language
+ (NSString *)getAppDefaultLanguage
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString* preferredLang = [userDefaults objectForKey:@"CurrentLanguages"];
    
    if (!preferredLang) {
        preferredLang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    }
    
    return [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:preferredLang];
}

+ (void)saveAppDefaultLanguage:(NSString *)item
{
    item = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:item];
    
    BOOL languageChanged = NO;
    if (![[XDSLocalizableManager getAppDefaultLanguage] isEqualToString:item]) {
        languageChanged = YES;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:item forKey:@"CurrentLanguages"];
    [userDefaults synchronize];
    
    if (languageChanged) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        if (item) {
            [dic setObject:item forKey:@"language"];
        }
        
        [XDSLocalizableManager sharedManager].currentLanguageDictionary = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XDSAppDefaultLanguageChangedNotification
                                                            object:nil
                                                          userInfo:dic];
    }
}

+ (NSString *)matchSimilarLanguageFileWithSelectedLanuage:(NSString *)language
{
    language = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:language];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDir = kXDSLocalZipDirectory;
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];

#if TARGET_OS_TV
    fileList = [XDSLocalizableManager getLocalizableAllKey];
#else
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
#endif
    
    NSMutableSet * localLanguageSet = [NSMutableSet set];
    
    for (NSString * string in fileList) {
        if ([string rangeOfString:@".string"].length > 0) {
            
            NSString * language = [string stringByMatching:@"(?<=Localizable_).*(?=.string)"];
            
            [localLanguageSet addObject:language];
        }
    }
    
    NSArray * localPaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"string" inDirectory:nil];
    
    for (NSString * string in localPaths) {
        if ([string rangeOfString:@".string"].length > 0) {
            
            NSString * language = [string stringByMatching:@"(?<=Localizable_).*(?=.string)"];
            
            [localLanguageSet addObject:language];
        }
    }
    
    return [[XDSLocalizableManager matchSimilarLanguageWithSelectedLanuage:language localLanguageArray:localLanguageSet.allObjects] lowercaseString];
    
}

+ (NSString *)matchSimilarLanguageWithSelectedLanuage:(NSString *)language localLanguageArray:(NSArray *)localLanguageArray
{
    language = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:language];
    
    for (NSString * string in localLanguageArray) {
        NSString * aLanguage = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:string];
        if ([aLanguage isEqualToString:language]) {
            return language;
        }
    }
    
    NSRange range = [language rangeOfString:@"_" options:NSBackwardsSearch];
    
    if (range.length > 0) {
        NSString * similarLanguage = [language substringToIndex:range.location];
        return [XDSLocalizableManager matchSimilarLanguageWithSelectedLanuage:similarLanguage localLanguageArray:localLanguageArray];
    }
    
    return nil;
}

+ (NSString *)getSystemLanguage
{
    NSString * preferredLang = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    return [preferredLang lowercaseString];
}

+ (void)setLocalFilePrefix:(NSString *)prefix
{
    localizableLocalFilePrefix = prefix;
}

+ (void)setNoMatchToUseLanguage:(NSString *)language
{
    noMatchToUseLanguage = [self handleSymbolSubstitutionWithLanguage:language];
}

- (void)updateLocalizableFileWithServerURL:(NSString *)url finished:(XDSLocalizableUpdateFinishedBlock)finished
{
    [self updateLocalizableFileWithServerURL:url forLanguage:nil finished:finished];
}

- (void)updateLocalizableFileWithServerURL:(NSString *)url forLanguage:(NSString *)language finished:(XDSLocalizableUpdateFinishedBlock)finished
{
    self.localizableServerURLString = url;
    self.updateFinishedBlock = finished;
    
    //开始写死本地文件
    //读取本地文字, 可通过网络请求获取远端文字文件
    [self requestFetchSucceeded:@"en"];
    
}

- (NSString *)localizableString:(NSString *)key
{
    return [self localizableString:key placeholder:nil exactMatch:NO];
}

- (NSString *)localizableString:(NSString *)key placeholder:(NSString *)placeholder
{
    return [self localizableString:key placeholder:placeholder exactMatch:NO];
}

- (NSString *)localizableString:(NSString *)key placeholder:(NSString *)placeholder exactMatch:(BOOL)exactMatch
{
    NSString * xdkey = @"@xdkey/";
    if ([key hasPrefix:xdkey]) {
        key = [key substringFromIndex:xdkey.length];
    }
    
    NSString *localizableString = [self.currentLanguageDictionary valueForKey:key];
    
    if (!exactMatch) {
        if (placeholder) {
            return localizableString?localizableString:placeholder;
        }else {
            return localizableString?localizableString:key;
        }
    }else {
        if (placeholder) {
            return localizableString?localizableString:placeholder;
        }else {
            return localizableString;
        }
    }
}

- (void)updateLocalizableFileWithData:(NSData *)data finished:(XDSLocalizableUpdateFinishedBlock)finished
{    
    self.updateFinishedBlock = finished;
    
    NSString * languageString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NLEPropertyParser *propertyParser = [[NLEPropertyParser alloc] init];
    NSMutableDictionary *dict = [propertyParser parse:languageString];
    
    self.currentLanguageDictionary = dict;
    
    if (self.updateFinishedBlock) {
        self.updateFinishedBlock(nil);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XDSLocalizableNeedGlobalRefreshNotification object:nil userInfo:nil];
}

- (void)updateLocalizableFileWithData:(NSData *)data forLanguage:(NSString *)language finished:(XDSLocalizableUpdateFinishedBlock)finished
{
    self.updateFinishedBlock = finished;
    language = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:language];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *localizableFile = [NSString stringWithFormat:@"Localizable_%@.string",language];
        [data writeToFile:kXDSLocalFilePath(localizableFile) atomically:YES];
        
        NSDictionary * currDict = [self createCurrentLanguageDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.currentLanguageDictionary = currDict;
            
            if (self.updateFinishedBlock) {
                self.updateFinishedBlock(nil);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:XDSLocalizableNeedGlobalRefreshNotification object:nil userInfo:nil];
            
        });
    });
}

#pragma mark - Private methods

+ (NSString *)handleSymbolSubstitutionWithLanguage:(NSString *)language
{
    return [[language lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
}

- (NSString *)string:(NSString *)string byReplacingSpecifiedItem:(NSDictionary *)dic
{
    __block NSString *newString = string;
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        newString = [newString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"${%@}",key] withString:obj];
    }];
    
    return newString;
}

- (NSDictionary *)localDicForAtPath:(NSString *)path
{
    if (!path) return nil;
    
    NSData *data = [NSData dataWithContentsOfFile: path];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!s || s.length == 0) {
        return  nil;
    }
    
    NLEPropertyParser *propertyParser = [[NLEPropertyParser alloc] init];
    NSMutableDictionary *dict = [propertyParser parse:s];
    
    return dict;
    
}

- (NSDictionary *)createCurrentLanguageDictionary
{
    NSString * language = [XDSLocalizableManager matchSimilarLanguageFileWithSelectedLanuage:[XDSLocalizableManager getAppDefaultLanguage]];
    
    if (!language) {
        language = [XDSLocalizableManager getAppDefaultLanguage];
    }
    
    NSDictionary * languageDic = nil;
    
    if (language) {
        languageDic = [self createLanguageDictionaryWithLanguage:language];
    }
    
    if (!languageDic) {
        languageDic = [self createLanguageDictionaryWithLanguage:noMatchToUseLanguage?noMatchToUseLanguage:@"en"];
    }
    
    return languageDic;
}

- (NSDictionary *)localDicForAtPathFormTV:(NSString *)path
{
    if (!path) return nil;
    
    NSData *data = [XDSLocalizableManager getLocalizable:path];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (!s || s.length == 0) {
        return  nil;
    }
    
    NLEPropertyParser *propertyParser = [[NLEPropertyParser alloc] init];
    NSMutableDictionary *dict = [propertyParser parse:s];
    
    return dict;
    
}

- (NSDictionary *)createLanguageDictionaryWithLanguage:(NSString *)language
{
    NSDictionary * resultDictionary = nil;
    language = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:language];
    @try {
        //get default language
        NSString *localizableFile = [NSString stringWithFormat:@"Localizable_%@.string",language];
        NSDictionary *localizableDic;
        
#if TARGET_OS_TV
        localizableFile = [NSString stringWithFormat:@"XDSTV_%@",localizableFile];
        localizableDic = [self localDicForAtPathFormTV:localizableFile];
#else
        localizableDic = [self localDicForAtPath:kXDSLocalFilePath(localizableFile)];
#endif
        
        /*
        NSString * bundleFilePrefix = localizableLocalFilePrefix.length > 0 ? localizableLocalFilePrefix : @"Localizable";
        NSString * defalutPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@",bundleFilePrefix,language] ofType:@"string"];
        */
        NSString * defalutPath = [XDSLocalizableManager getSimilarLocalLanguagePathWithSelectedLanuage:language];
         
        NSDictionary *defaultDic = [self localDicForAtPath:defalutPath];
        
        if ([localizableDic count] > 0 && [defaultDic count] > 0) {
            NSMutableDictionary *currDict = [NSMutableDictionary dictionaryWithDictionary:defaultDic];
            [currDict addEntriesFromDictionary:localizableDic];
            resultDictionary = currDict;
        }else if ([localizableDic count] > 0){
            resultDictionary = localizableDic;
        }else if ([defaultDic count] > 0) {
            resultDictionary = defaultDic;
        }else {
            
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return resultDictionary;
}

+ (NSString *)getSimilarLocalLanguagePathWithSelectedLanuage:(NSString *)language
{
    language = [XDSLocalizableManager handleSymbolSubstitutionWithLanguage:language];
    
    NSString * bundleFilePrefix = localizableLocalFilePrefix.length > 0 ? localizableLocalFilePrefix : @"Localizable";
    
    NSString * defalutPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_%@",bundleFilePrefix,language] ofType:@"string"];
    
    if (defalutPath.length) {
        
        return defalutPath;
        
    }else {
        
        NSRange range = [language rangeOfString:@"_" options:NSBackwardsSearch];
        
        if (range.length > 0) {
            NSString * similarLanguage = [language substringToIndex:range.location];
            return [XDSLocalizableManager getSimilarLocalLanguagePathWithSelectedLanuage:similarLanguage];
        }else {
            return nil;
        }
        
    }
}



- (void)requestFetchSucceeded:(NSString *)language
{
#warning 测试-从本地读取国际化文件
    NSData *stringData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Localizable_en.string" ofType:nil]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *manager = [NSFileManager defaultManager];
        if(![manager contentsOfDirectoryAtPath:kXDSLocalZipDirectory error:nil]){
            [manager createDirectoryAtPath:kXDSLocalZipDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        }
        

        NSString *localizableFile = [NSString stringWithFormat:@"Localizable_%@.string",language];
#if TARGET_OS_TV
        localizableFile = [NSString stringWithFormat:@"XDSTV_%@",localizableFile];
        [XDSLocalizableManager saveLocalizable:localizableFile data:package.responseDataBuffer];
#else
        [stringData writeToFile:kXDSLocalFilePath(localizableFile) atomically:YES];
#endif
        
        
        NSDictionary * currDict = [self createCurrentLanguageDictionary];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.currentLanguageDictionary = currDict;
            
            if (self.updateFinishedBlock) {
                self.updateFinishedBlock(nil);
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:XDSLocalizableNeedGlobalRefreshNotification object:nil userInfo:nil];
            
        });
    });
}


#pragma mark - NSUserDefaults methods
//localizable file
+ (NSData *)getLocalizable:(NSString *)language
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * data;
    data = [userDefaults objectForKey:language];
    return data;
}

+ (void)saveLocalizable:(NSString *)language data:(NSData *)item
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:item forKey:language];
    [userDefaults synchronize];
}

+ (NSArray *)getLocalizableAllKey
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *currArray = [NSMutableArray array];
    
    for (NSString *item in userDefaults.dictionaryRepresentation.allKeys) {
        if ([item isKindOfClass:[NSString class]] && [item hasPrefix:@"XDSTV_"] && [item hasSuffix:@".string"]) {
            NSString *language = [item stringByReplacingOccurrencesOfString:@"XDSTV_" withString:@""];
            [currArray addObject:language];
        }
    }
    
    return currArray;
}


@end

NSString * const XDSLocalizableNeedGlobalRefreshNotification = @"XDSLocalizableNeedGlobalRefreshNotification";
NSString * const XDSAppDefaultLanguageChangedNotification = @"XDSAppDefaultLanguageChangedNotification";
