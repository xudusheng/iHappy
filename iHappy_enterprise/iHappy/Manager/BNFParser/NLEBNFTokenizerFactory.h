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

#import <Foundation/Foundation.h>
#import "NLEBNFTokenizerParams.h"
#import "NLEBNFTokens.h"

@interface NLEBNFTokenizerFactory : NSObject

typedef enum NLEBNFTokenizerType : NSInteger {
    NLEBNFTokenizerType_NONE,
    NLEBNFTokenizerType_COMMENT_SINGLE_LINE,
    NLEBNFTokenizerType_COMMENT_MULTI_LINE,
    NLEBNFTokenizerType_QUOTE_SINGLE,
    NLEBNFTokenizerType_QUOTE_SINGLE_ESCAPED,
    NLEBNFTokenizerType_QUOTE_DOUBLE,
    NLEBNFTokenizerType_QUOTE_DOUBLE_ESCAPED,
    NLEBNFTokenizerType_NUMBER,
    NLEBNFTokenizerType_LETTER,
    NLEBNFTokenizerType_SYMBOL,
    NLEBNFTokenizerType_SYMBOL_HASH,
    NLEBNFTokenizerType_SYMBOL_AT,
    NLEBNFTokenizerType_SYMBOL_STAR,
    NLEBNFTokenizerType_SYMBOL_FORWARD_SLASH,
    NLEBNFTokenizerType_SYMBOL_BACKWARD_SLASH,
    NLEBNFTokenizerType_WHITESPACE,
    NLEBNFTokenizerType_WHITESPACE_OTHER,
    NLEBNFTokenizerType_WHITESPACE_NEWLINE
} NLEBNFTokenizerType;

@property (nonatomic, assign) BOOL ignoreDoubleForwordSlash;

- (NLEBNFTokens *)tokens:(NSString *)text;
- (NLEBNFTokens *)tokens:(NSString *)text operation:(NSBlockOperation *)operation;

- (NLEBNFTokens *)tokens:(NSString *)text params:(NLEBNFTokenizerParams *)params;
- (NLEBNFTokens *)tokens:(NSString *)text params:(NLEBNFTokenizerParams *)params operation:(NSBlockOperation *)operation;
@end

