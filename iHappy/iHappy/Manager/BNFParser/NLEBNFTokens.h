//
//  BNFTokens.h
//  BNFParser
//
//  Created by Mike Friesen on 2013-09-16.
//  Copyright (c) 2013 Mike Friesen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLEBNFToken.h"

@interface NLEBNFTokens : NSObject

@property (nonatomic, assign) NSInteger pos;
@property (nonatomic, retain) NSMutableArray *tokens;

- (void)reset;
- (NLEBNFToken *)nextToken;
- (void)addToken:(NLEBNFToken *)token;

@end
