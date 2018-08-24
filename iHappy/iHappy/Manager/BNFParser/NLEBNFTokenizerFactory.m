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

#import "NLEBNFTokenizerFactory.h"
#import "NLEStack.h"
#import "NLEBNFFastForward.h"

@implementation NLEBNFTokenizerFactory

- (NLEBNFTokens *)tokens:(NSString *)text {
    return [self tokens:text operation:nil];
}

- (NLEBNFTokens *)tokens:(NSString *)text operation:(NSBlockOperation *)operation {
    NLEBNFTokenizerParams *params = [[NLEBNFTokenizerParams alloc] init];
    NLEBNFTokens *tokens = [self tokens:text params:params operation:operation];
    return tokens;
}

- (NLEBNFTokens *)tokens:(NSString *)text params:(NLEBNFTokenizerParams *)params {
    return [self tokens:text params:params operation:nil];
}

- (NLEBNFTokens *)tokens:(NSString *)text params:(NLEBNFTokenizerParams *)params operation:(NSBlockOperation *)operation {
    
    BOOL cancelled = NO;
    NLEStack *stack = [[NLEStack alloc] init];
    NLEBNFFastForward *ff = [[NLEBNFFastForward alloc] init];
    
    NLEBNFTokenizerType lastType = NLEBNFTokenizerType_NONE;

    NSInteger len = [text length];
    
    for (int i = 0; i < len; i++) {
        
        unichar c = [text characterAtIndex:i];
        NLEBNFTokenizerType type = [self getType:c lastType:lastType];
        
        
        if ([ff isActive]) {
            
            [ff appendIfActiveChar:c];
            
            BOOL isFastForwardComplete = [ff isComplete:type lastType:lastType position:i length:len];
            
            if (isFastForwardComplete) {
                
                [self finishFastForward:stack fastForward:ff];
                [ff complete];
            }
            
        } else {
            
            [self calculateFastForward:ff type:type stack:stack lastType:lastType];
            
            if ([ff isActive]) {
                
                [ff appendIfActiveChar:c];
				
            } else if ([self includeText:type params:params]) {
                
                if ([self isAppendable:lastType current:type]) {
                    
                    NLEBNFToken *token = [stack peek];
                    [token appendValue:c];
                    
                } else {
                    [self addBNFToken:stack type:type character:c];
                }
            }
        }
        
        lastType = type;
        
        if ([operation isCancelled]) {
            cancelled = YES;
            break;
        }
    }
    
    NLEBNFTokens *tokens = [self createTokens:stack cancelled:cancelled];

    return tokens;
}

- (NLEBNFTokens *)createTokens:(NLEStack *)stack cancelled:(BOOL)cancelled {
    
    NLEBNFTokens *tokens = [[NLEBNFTokens alloc] init];
    
    if (!cancelled) {
        
        if (![stack isEmpty]) {
            
            [tokens setTokens:[stack objects]];
            
        } else {
            
            NLEBNFToken *token = [[NLEBNFToken alloc] initWithValue:@""];
            [tokens addToken:token];
        }
    }
    
    return tokens;
}

- (BOOL)includeText:(NLEBNFTokenizerType) type params:(NLEBNFTokenizerParams *)params {
    return ([params includeWhitespace] && type == NLEBNFTokenizerType_WHITESPACE)
    || ([params includeWhitespaceOther] && type == NLEBNFTokenizerType_WHITESPACE_OTHER)
    || ([params includeWhitespaceNewlines] && type == NLEBNFTokenizerType_WHITESPACE_NEWLINE)
    || ![self isWhitespace:type];
}

- (void)calculateFastForward:(NLEBNFFastForward *)ff type:(NLEBNFTokenizerType)type stack:(NLEStack *)stack lastType:(NLEBNFTokenizerType) lastType {
    
    NLEBNFToken *last = ![stack isEmpty] ? [stack peek] : nil;
    [ff setStart:NLEBNFTokenizerType_NONE];
    
    // single line comment
    if (!self.ignoreDoubleForwordSlash && lastType == NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH && type == NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH) {
        
        [ff setStart:NLEBNFTokenizerType_COMMENT_SINGLE_LINE];
        [ff setEndWithType:NLEBNFTokenizerType_WHITESPACE_NEWLINE];
        
        NLEBNFToken *token = [stack pop];
        [ff appendIfActiveNSString:[token stringValue]];
        
		// multi line comment
    } else if (lastType == NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH && type == NLEBNFTokenizerType_SYMBOL_STAR) {
        
        [ff setStart:NLEBNFTokenizerType_COMMENT_MULTI_LINE];
        [ff setEndWithType:NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH type2:NLEBNFTokenizerType_SYMBOL_STAR];
        
        NLEBNFToken *token = [stack pop];
        [ff appendIfActiveNSString:[token stringValue]];
        
    } else if (type == NLEBNFTokenizerType_QUOTE_DOUBLE) {
        
        [ff setStart:NLEBNFTokenizerType_QUOTE_DOUBLE];
        [ff setEndWithType:NLEBNFTokenizerType_QUOTE_DOUBLE];
		
    } else if (type == NLEBNFTokenizerType_QUOTE_SINGLE && ![self isWord:last]) {
        
        [ff setStart:NLEBNFTokenizerType_QUOTE_SINGLE];
        [ff setEndWithType:NLEBNFTokenizerType_QUOTE_SINGLE];
    }
}

- (BOOL)isWord:(NLEBNFToken *)last {
    return last && [last isWord];
}

- (void)finishFastForward:(NLEStack *)stack fastForward:(NLEBNFFastForward *) ff {
    
    if ([self isComment:[ff start]]) {
        
        [self setNextToken:stack token:nil];
        
    } else {
        
        [self addBNFToken:stack type:[ff start] string:[ff getString]];
    }
}

- (void)addBNFToken:(NLEStack *)stack type:(NLEBNFTokenizerType) type character:(unichar) c {
    [self addBNFToken:stack type:type string:[NSString stringWithFormat:@"%C",c]];
}

- (void)addBNFToken:(NLEStack *)stack type:(NLEBNFTokenizerType)type string:(NSString *)s {
    
    NLEBNFToken *token = [self createBNFToken:s type:type];
    
    if (![stack isEmpty]) {
        NLEBNFToken *peek = [stack peek];
        [peek setNextToken:token];
        [token setIdentifier:[peek identifier] + 1];
    } else {
        [token setIdentifier:1];
    }
    
    [stack push:token];
}

- (void)setNextToken:(NLEStack *)stack token:(NLEBNFToken *)nextToken {
    if (![stack isEmpty]) {
        [[stack peek]setNextToken:nextToken];
    }
}

- (BOOL)isAppendable:(NLEBNFTokenizerType)lastType current:(NLEBNFTokenizerType) current {
    return lastType == current && (current == NLEBNFTokenizerType_LETTER || current == NLEBNFTokenizerType_NUMBER);
}

- (NLEBNFToken *)createBNFToken:(NSString *)value type:(NLEBNFTokenizerType)type {
    NLEBNFToken *token = [[NLEBNFToken alloc] init];
    [token setValueWithString:value];
    
    if ([self isComment:type]) {
        [token setType:NLEBNFTokenType_COMMENT];
    } else if ([self isNumber:type]) {
        [token setType:NLEBNFTokenType_NUMBER];
    } else if ([self isLetter:type]) {
        [token setType:NLEBNFTokenType_WORD];
    } else if ([self isSymbol:type]) {
        [token setType:NLEBNFTokenType_SYMBOL];
    } else if (type == NLEBNFTokenizerType_WHITESPACE_NEWLINE) {
        [token setType:NLEBNFTokenType_WHITESPACE_NEWLINE];
    } else if ([self isWhitespace:type]) {
        [token setType:NLEBNFTokenType_WHITESPACE];
    } else if ([self isQuote:type]) {
        [token setType:NLEBNFTokenType_QUOTED_STRING];
    }
    
    return token;
}

- (BOOL)isQuote:(NLEBNFTokenizerType)type {
    return type == NLEBNFTokenizerType_QUOTE_DOUBLE || type == NLEBNFTokenizerType_QUOTE_SINGLE;
}

- (BOOL)isSymbol:(NLEBNFTokenizerType)type {
    return type == NLEBNFTokenizerType_SYMBOL
    || type == NLEBNFTokenizerType_SYMBOL_HASH
    || type == NLEBNFTokenizerType_SYMBOL_AT
    || type == NLEBNFTokenizerType_SYMBOL_STAR
    || type == NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH
    || type == NLEBNFTokenizerType_SYMBOL_BACKWARD_SLASH;
}

- (BOOL)isWhitespace:(NLEBNFTokenizerType)type {
    return type == NLEBNFTokenizerType_WHITESPACE || type == NLEBNFTokenizerType_WHITESPACE_OTHER || type == NLEBNFTokenizerType_WHITESPACE_NEWLINE;
}

- (BOOL)isComment:(NLEBNFTokenizerType) type {
    return type == NLEBNFTokenizerType_COMMENT_MULTI_LINE
    || type == NLEBNFTokenizerType_COMMENT_SINGLE_LINE;
}

- (BOOL)isNumber:(NLEBNFTokenizerType)type {
    return type == NLEBNFTokenizerType_NUMBER;
}

- (BOOL)isLetter:(NLEBNFTokenizerType)type {
    return type == NLEBNFTokenizerType_LETTER;
}

- (NLEBNFTokenizerType)getType:(unichar)c lastType:(NLEBNFTokenizerType)lastType {
    if (c == 10 || c == 13) {
        return NLEBNFTokenizerType_WHITESPACE_NEWLINE;
    } else if (c >= 0 && c <= 31) { // From: 0 to: 31 From:0x00 to:0x20
        return NLEBNFTokenizerType_WHITESPACE_OTHER;
    } else if (c == 32) {
        return NLEBNFTokenizerType_WHITESPACE;
    } else if (c == 33) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c == '"') { // From: 34 to: 34 From:0x22 to:0x22
        return NLEBNFTokenizerType_SYMBOL;
        //return lastType == NLEBNFTokenizerType_SYMBOL_BACKWARD_SLASH ? NLEBNFTokenizerType_QUOTE_DOUBLE_ESCAPED : NLEBNFTokenizerType_QUOTE_DOUBLE;
    } else if (c == '#') { // From: 35 to: 35 From:0x23 to:0x23
        return NLEBNFTokenizerType_SYMBOL_HASH;
    } else if (c >= 36 && c <= 38) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c == '\'') { // From: 39 to: 39 From:0x27 to:0x27
        return NLEBNFTokenizerType_SYMBOL;
        //return lastType == NLEBNFTokenizerType_SYMBOL_BACKWARD_SLASH ? NLEBNFTokenizerType_QUOTE_SINGLE_ESCAPED : NLEBNFTokenizerType_QUOTE_SINGLE;
    } else if (c >= 40 && c <= 41) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c == 42) {
        return NLEBNFTokenizerType_SYMBOL_STAR;
    } else if (c == '+') { // From: 43 to: 43 From:0x2B to:0x2B
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c == 44) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c == '-') { // From: 45 to: 45 From:0x2D to:0x2D
        return NLEBNFTokenizerType_NUMBER;
    } else if (c == '.') { // From: 46 to: 46 From:0x2E to:0x2E
        return NLEBNFTokenizerType_NUMBER;
    } else if (c == '/') { // From: 47 to: 47 From:0x2F to:0x2F
        return NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH;
    } else if (c >= '0' && c <= '9') { // From: 48 to: 57 From:0x30 to:0x39
        return NLEBNFTokenizerType_NUMBER;
    } else if (c >= 58 && c <= 63) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c == '@') { // From: 64 to: 64 From:0x40 to:0x40
        return NLEBNFTokenizerType_SYMBOL_AT;
    } else if (c >= 'A' && c <= 'Z') { // From: 65 to: 90 From:0x41 to:0x5A
        return NLEBNFTokenizerType_LETTER;
    } else if (c == 92) { // /
        return NLEBNFTokenizerType_SYMBOL_BACKWARD_SLASH;
    } else if (c >= 91 && c <= 96) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 'a' && c <= 'z') { // From: 97 to:122 From:0x61 to:0x7A
        return NLEBNFTokenizerType_LETTER;
    } else if (c >= 123 && c <= 191) {
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0xC0 && c <= 0xFF) { // From:192 to:255 From:0xC0 to:0xFF
        return NLEBNFTokenizerType_LETTER;
    } else if (c >= 0x19E0 && c <= 0x19FF) { // khmer symbols
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0x2000 && c <= 0x2BFF) { // various symbols
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0x2E00 && c <= 0x2E7F) { // supplemental punctuation
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0x3000 && c <= 0x303F) { // cjk symbols & punctuation
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0x3200 && c <= 0x33FF) { // enclosed cjk letters and months, cjk compatibility
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0x4DC0 && c <= 0x4DFF) { // yijing hexagram symbols
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0xFE30 && c <= 0xFE6F) { // cjk compatibility forms, small form variants
        return NLEBNFTokenizerType_SYMBOL;
    } else if (c >= 0xFF00 && c <= 0xFFFF) { // hiragana & katakana halfwitdh & fullwidth forms, Specials
        return NLEBNFTokenizerType_SYMBOL;
    } else {
        return NLEBNFTokenizerType_LETTER;
    }
}

@end

