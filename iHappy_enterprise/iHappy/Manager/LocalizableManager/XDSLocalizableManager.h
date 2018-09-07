//
//  XDSLocalizableManager.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDSBaseManager.h"

#define XDSLocalizedString(key, comment) \
[[XDSLocalizableManager sharedManager] localizableString:(key) placeholder:(comment)]

typedef void(^XDSLocalizableUpdateFinishedBlock)(NSError *error);

@interface XDSLocalizableManager : XDSBaseManager

@property (nonatomic, strong) NSDictionary * currentLanguageDictionary;

+ (XDSLocalizableManager *)sharedManager;
+ (NSString *)getAppDefaultLanguage;
+ (void)saveAppDefaultLanguage:(NSString *)language;
+ (NSString *)getSystemLanguage;
+ (void)setLocalFilePrefix:(NSString *)prefix;
+ (void)setNoMatchToUseLanguage:(NSString *)language; //Defalut en
+ (NSString *)matchSimilarLanguageWithSelectedLanuage:(NSString *)language localLanguageArray:(NSArray *)localLanguageArray;

- (void)updateLocalizableFileWithServerURL:(NSString *)url finished:(XDSLocalizableUpdateFinishedBlock)finished;
- (void)updateLocalizableFileWithServerURL:(NSString *)url forLanguage:(NSString *)language finished:(XDSLocalizableUpdateFinishedBlock)finished;
- (void)updateLocalizableFileWithData:(NSData *)data finished:(XDSLocalizableUpdateFinishedBlock)finished;
- (void)updateLocalizableFileWithData:(NSData *)data forLanguage:(NSString *)language finished:(XDSLocalizableUpdateFinishedBlock)finished;

- (NSString *)localizableString:(NSString *)key;
- (NSString *)localizableString:(NSString *)key placeholder:(NSString *)placeholder;
- (NSString *)localizableString:(NSString *)key placeholder:(NSString *)placeholder exactMatch:(BOOL)exactMatch;

@end

extern NSString * const XDSLocalizableNeedGlobalRefreshNotification;
extern NSString * const XDSAppDefaultLanguageChangedNotification;

