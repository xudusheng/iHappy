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

#import "NLEPropertyParser.h"
#import "NLEBNFTokenizerFactory.h"
#import "NLEBNFTokenizerParams.h"
#import "NLEBNFTokens.h"

@implementation NLEPropertyParser

- (NSMutableDictionary *)parse:(NSString *)s {
   
    NLEBNFTokenizerFactory *tokenizer = [[NLEBNFTokenizerFactory alloc] init];
    tokenizer.ignoreDoubleForwordSlash = YES;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    NLEBNFTokenizerParams *params = [[NLEBNFTokenizerParams alloc] init];
    [params setIncludeWhitespace:YES];
    [params setIncludeWhitespaceNewlines:YES];
    
    NLEBNFTokens *tokens = [tokenizer tokens:s params:params];
    NLEBNFToken *token = [tokens nextToken];
    
    NSString *start = @"";
    NSMutableString *sb = [[NSMutableString alloc] init];
    
    while (token) {
		
        if ([token type] == NLEBNFTokenType_WHITESPACE_NEWLINE) {
            
            [self addValue:dic sb:sb start:start];
            
            start = @"";
            [sb setString:@""];
            
        } else if ([[token stringValue] isEqualToString:@"="]) {
            
            start = [NSString stringWithString:sb];
            [sb setString:@""];
            
        } else {
            
            [sb appendString:[token stringValue]];
        }
        
        token = [tokens nextToken];
    }
    
    [self addValue:dic sb:sb start:start];
    
    return dic;
}

- (void)addValue:(NSMutableDictionary *)dic sb:(NSMutableString *)sb start:(NSString *)start {
    if ([self hasText:start] && [self hasText:sb]) {
        
        NSString *key = [start stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *value = [[NSString stringWithString:sb] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (value) {
            value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        }
        [dic setValue:value forKey:key];
    }
}

- (BOOL)hasText:(NSString *)s {
    return s && [s length] > 0;
}

@end
