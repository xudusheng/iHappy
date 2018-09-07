//
//  XDSBaseManager.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
@interface XDSBaseManager : NSObject

+ (XDSBaseManager *)sharedManager;
+ (Class)instanceClass;
+ (NSString *)configForCurrentClass;
+ (void)readManagerMappingFile:(NSString *)fileName;

@end
