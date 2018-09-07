//
// Copyright 2013 Mike Friesen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "NLEBNFIndexFactoryJSON.h"
#import "NLEBNFIndexNode.h"
#import "NLEBNFToken.h"
#import "NLEStack.h"
#import "NLEBNFIndex.h"
#import "NLEBNFParseResult.h"

@implementation NLEBNFIndexFactoryJSON

- (NLEBNFIndex *)createIndex:(NLEBNFParseResult *)result {
    return [self createIndex:result operation:nil];
}

- (NLEBNFIndex *)createIndex:(NLEBNFParseResult *)result operation:(NSBlockOperation *)operation {

    BOOL cancelled = NO;
    
    if (![result success]) {
        return nil;
    }
    
    NLEStack *stack = [[NLEStack alloc] init];
    
    NLEBNFIndex *index = [[NLEBNFIndex alloc] init];
    
    NSString *keyValue = nil;
    NLEBNFToken *token = [result top];
    
    while (token) {
        
        if ([self isStartNode:token]) {
            
            NLEBNFIndexNode *node = [self createIndexNode:token keyValue:keyValue];
            
            if (!keyValue) {
                [node setShouldSkip:YES];
            }
            
            [self addNode:stack index:index node:node];
            
            [stack push:node];
            keyValue = nil;
            
        } else if ([self isKey:token]) {
            
            keyValue = [self stringValue:token];
            
        } else if ([self isEndNode:token]) {
            
            [stack pop];
            
            NLEBNFIndexNode *node = [self createIndexNode:token keyValue:keyValue];
            [self addNode:stack index:index node:node];
            
        } else if ([self isValue:token]) {
            
            NLEBNFIndexNode *node = [[NLEBNFIndexNode alloc] initWithKeyValue:keyValue stringValue:[self stringValue:token]];
            [self addNode:stack index:index node:node];
            
            keyValue = nil;
        }
        
        token = [self nextToken:token];
        
        if ([operation isCancelled]) {
            cancelled = YES;
            break;
        }
    }
    
    
    if (cancelled) {
        return nil;
    }
    
    return index;
}

/**
 * Create an IndexNode.
 * @param token -
 * @param keyValue -
 * @return BNFIndexNode
 */
- (NLEBNFIndexNode *)createIndexNode:(NLEBNFToken *)token keyValue:(NSString *)keyValue {
    
    NLEBNFIndexNode *node = nil;
    
    if (keyValue) {
        node = [[NLEBNFIndexNode alloc] initWithKeyValue:keyValue stringValue:[self stringValue:token]];
    } else {
        node = [[NLEBNFIndexNode alloc] initWithKeyValue:[self stringValue:token] stringValue:nil];
    }
    
    return node;
}

/**
 * Add Node to Index.
 * @param stack -
 * @param index -
 * @param node -
 */
- (void)addNode:(NLEStack *)stack index:(NLEBNFIndex *)index node:(NLEBNFIndexNode *)node {
    if ([stack isEmpty]) {
        [index addNode:node];
    } else {
        [[stack peek] addNode:node];
    }
}

/**
 * Gets the String value for the token if String is QuotedString, removes quotes.
 * @param token -
 * @return String
 */
- (NSString *)stringValue:(NLEBNFToken *)token {
    
    NSString *value = [token stringValue];
    return value;
}

/**
 * Returns with token is a start token.
 * @param token -
 * @return boolean
 */
- (BOOL)isStartNode:(NLEBNFToken *)token {
    NSString *value = [token stringValue];
    return [value isEqualToString:@"{"] || [value isEqualToString:@"["];
}

/**
 * Returns with token is a end token.
 * @param token -
 * @return boolean
 */
- (BOOL)isEndNode:(NLEBNFToken *)token {
    NSString *value = [token stringValue];
    return [value isEqualToString:@"}"] || [value isEqualToString:@"]"];
}

/**
 * Returns with token is a key token.
 * @param token -
 * @return boolean
 */
- (BOOL)isKey:(NLEBNFToken *)token {
    
    BOOL key = NO;
    NSString *value = [token stringValue];
    
    if (value && [token nextToken]) {
        NLEBNFToken *nextToken = [token nextToken];
        key = [@":" isEqualToString:[nextToken stringValue]];
    }
    
    return key;
}

/**
 * Returns with token is a value token.
 * @param token -
 * @return boolean
 */
- (BOOL)isValue:(NLEBNFToken *)token {
    NSString *value = [token stringValue];
    return ![value isEqualToString:@":"] && ![value isEqualToString:@","];
}

/**
 * Returns the next token.
 * @param token -
 * @return BNFToken
 */
- (NLEBNFToken *)nextToken:(NLEBNFToken *)token {
    
    NLEBNFToken *nextToken = [token nextToken];
    return nextToken;
}

@end
