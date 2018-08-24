//
//  BNFTokens.m
//  BNFParser
//
//  Created by Mike Friesen on 2013-09-16.
//  Copyright (c) 2013 Mike Friesen. All rights reserved.
//

#import "NLEBNFTokens.h"

@implementation NLEBNFTokens

- (id)init {
    
    self = [super init];
    if (self) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [self setTokens:list];
        
        [self reset];
    }
    
    return self;
}

- (void)reset {
    [self setPos:0];
}

- (void)addToken:(NLEBNFToken *)token {
    [_tokens addObject:token];
}

- (NLEBNFToken *)nextToken {
    NLEBNFToken *tok = nil;
    
    if (_pos < [_tokens count]) {
        tok = [_tokens objectAtIndex:_pos];
        [self setPos:_pos + 1];
    }
    
    return tok;
}

@end
