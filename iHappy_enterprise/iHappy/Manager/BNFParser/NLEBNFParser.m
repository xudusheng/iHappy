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

#import "NLEBNFParser.h"
#import "NLEBNFParserState.h"
#import "NLEBNFSymbol.h"
#import "NLEBNFTokenizerFactory.h"

@implementation NLEBNFParser

- (id)initWithStateDefinitions:(NSMutableDictionary *)dic {
    self = [super init];
    
    if (self) {
        
        [self setSequenceMap:dic];
        
        NLEStack *stack = [[NLEStack alloc] init];
        [self setStack:stack];
    }
    
    return self;
}

- (NLEBNFParseResult *)parseString:(NSString *)s {
    NLEBNFTokenizerFactory *tokenizer = [[NLEBNFTokenizerFactory alloc] init];
    NLEBNFTokens *tokens = [tokenizer tokens:s];
    
    NLEBNFParseResult *result = [self parse:tokens];
    return result;
}

- (NLEBNFParseResult *)parse:(NLEBNFTokens *)tokens {
    return [self parse:tokens operation:nil];
}

- (NLEBNFParseResult *)parse:(NLEBNFTokens *)tokens operation:(NSBlockOperation *)operation {
    
    NLEBNFToken *token = [tokens nextToken];
    NSMutableArray *sd = [_sequenceMap objectForKey:@"@start"];
    [self addNLEParserStateSequences:sd token:token parserRepetition:NLEBNFParserRepetition_NONE repetition:NLEBNFRepetition_NONE];
    
    return [self parseSequences:token operation:operation];
}

- (NLEBNFParseResult *)parseSequences:(NLEBNFToken *)startToken operation:(NSBlockOperation *)operation {
    
    BOOL success = NO;
    BOOL cancelled = NO;
    
    NLEBNFParseResult *result = [[NLEBNFParseResult alloc] init];
    [result setTop:startToken];
    [result setMaxMatchToken:startToken];
    
    while (![_stack isEmpty]) {
        
        NLEBNFParserState *holder = [_stack peek];
        
        if ([holder state] == NLEParserState_EMPTY) {
            
            [_stack pop];
            
            NLEBNFToken *token = [[_stack peek] currentToken];
            if (![self isEmpty:token]) {
                [self rewindToNextSymbol];
            } else {
                success = YES;
                [result setError:nil];
                [self rewindToNextSequence];
            }
            
        } else if ([holder state] == NLEParserState_NO_MATCH_WITH_ZERO_REPETITION) {
            
            [self processNoMatchWithZeroRepetition];
            
        } else if ([holder state] == NLEParserState_MATCH_WITH_ZERO_REPETITION) {
            
            [self processMatchWithZeroRepetition];
            
        } else if ([holder state] == NLEParserState_NO_MATCH_WITH_ZERO_REPETITION_LOOKING_FOR_FIRST_MATCH) {
            
            NLEBNFToken *maxMatchToken = [self processNoMatchWithZeroRepetitionLookingForFirstMatch];
            [result setMaxMatchToken:maxMatchToken];
            [result setError:nil];
            success = YES;
            
        } else if ([holder state] == NLEParserState_MATCH) {
            
            NLEBNFToken *maxMatchToken = [self processMatch];
            [result setMaxMatchToken:maxMatchToken];
            [result setError:nil];
            success = YES;
            
        } else if ([holder state] == NLEParserState_NO_MATCH) {
            
            NLEBNFToken *eToken = [self processNoMatch];
            NLEBNFToken *errorToken = [self updateErrorToken:[result error] token2:eToken];
            [result setError:errorToken];
            success = NO;
            
        } else {
            [self processStack];
        }
        
        if ([operation isCancelled]) {
            cancelled = YES;
            break;
        }
    }
    
    if (cancelled) {
        return nil;
    }
    
    [self updateResult:result success:success];

    return result;
}

/**
 * Update BNFParserResult.
 */
- (void)updateResult:(NLEBNFParseResult *)result success:(BOOL)success {
    
    BOOL succ = success;
    NLEBNFToken *maxMatchToken = [result maxMatchToken];
    
    if (maxMatchToken && [maxMatchToken nextToken]) {
        
        if (![result error]) {
            [result setError:[maxMatchToken nextToken]];
        }
        
        succ = NO;
    }
    
    [result setSuccess:succ];
}

- (NLEBNFToken *)updateErrorToken:(NLEBNFToken *)token1 token2:(NLEBNFToken *)token2 {
    return token1 && [token1 identifier] > [token2 identifier] ? token1 : token2;
}

- (NLEBNFToken *)processNoMatch {
    
    [self debugPrintIndents];
//    NSLog(@"-> no match, rewinding to next sequence");
    
    [_stack pop];
    
    NLEBNFToken *token = [[_stack peek] currentToken];
    
    [self rewindToNextSequence];
    
    if (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        [holder resetToken];
    }
    
    return token;
}

- (NLEBNFToken *)processMatchWithZeroRepetition {
    
    [_stack pop];
    
    NLEBNFToken *token = [[_stack peek] currentToken];
    
    [self debugPrintIndents];
//    NSLog(@"-> matched token %@ rewind to start of repetition", [token stringValue]);
    
    [self rewindToOutsideOfRepetition];
    
    if (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        [holder advanceToken:[token nextToken]];
    }
    
    return token;
}

- (NLEBNFToken *)processNoMatchWithZeroRepetitionLookingForFirstMatch {
    
    [_stack pop];
    
    NLEBNFToken *token = [[_stack peek] currentToken];
    
    [self debugPrintIndents];
//    NSLog(@"-> no match Zero Or More Looking for First Match token %@ rewind outside of Repetition", [self debug:token]);
    
    [self rewindToOutsideOfRepetition];
    [self rewindToNextSymbol];
    
    if (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        [holder advanceToken:token];
    }
    
    return token;
}

- (NLEBNFToken *)processMatch {
    
    [_stack pop];
    
    NLEBNFToken *token = [[_stack peek] currentToken];
    
    [self debugPrintIndents];
//    NSLog(@"-> matched token %@ rewind to next symbol", [token stringValue]);
    
    [self rewindToNextSymbolOrRepetition];
    
    if (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        
        token = [token nextToken];
        [holder advanceToken:token];
    }
    
    return token;
}

- (void)processNoMatchWithZeroRepetition {
    
    [self debugPrintIndents];
//    NSLog(@"-> NO_MATCH_WITH_ZERO_REPETITION, rewind to next symbol");
    
    [_stack pop];
    
    NLEBNFToken *token = [[_stack peek] currentToken];
    
    [self rewindToNextSymbol];
    
    if (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        [holder advanceToken:token];
    }
}

- (void)rewindToOutsideOfRepetition {
    
    while (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        
        if ([holder parserRepetition] != NLEBNFParserRepetition_NONE) {
            [_stack pop];
        } else {
            break;
        }
    }
}

/**
 * Rewinds to next incomplete sequence or to ZERO_OR_MORE repetition which
 * ever one is first.
 */
- (void)rewindToNextSymbolOrRepetition {
    
    while (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        
        if ([holder repetition] == NLEBNFRepetition_ZERO_OR_MORE && [holder isComplete]) {
            [holder reset];
            if ([holder repetition] != NLEBNFRepetition_NONE) {
                [holder setParserRepetition:NLEBNFParserRepetition_ZERO_OR_MORE_LOOKING_FOR_FIRST_MATCH];
            }
            break;
        } else if ([holder sequence] && ![holder isComplete]) {
            if ([holder parserRepetition] == NLEBNFParserRepetition_ZERO_OR_MORE_LOOKING_FOR_FIRST_MATCH) {
                [holder setParserRepetition:NLEBNFParserRepetition_NONE];
            }
            
            break;
        }
        
        [_stack pop];
    }
}

/**
 * Rewinds to next incomplete sequence or to ZERO_OR_MORE repetition which
 * ever one is first.
 */
- (void)rewindToNextSymbol {
    while (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        
        if ([holder sequence] && ![holder isComplete]) {
            break;
        }
        
        [_stack pop];
    }
}

/**
 * rewindToNextSequence.
 */
- (void)rewindToNextSequence {
    
    while (![_stack isEmpty]) {
        NLEBNFParserState *holder = [_stack peek];
        if ([holder sequences]) {
            break;
        }
        
        [_stack pop];
    }
}

/**
 * processStack.
 */
- (void)processStack {
    
    NLEBNFParserState *holder = [_stack peek];
    
    if ([holder isComplete]) {
        [_stack pop];
    } else {
        
        NLEBNFToken *currentToken = [holder currentToken];
        
        if ([holder sequences]) {
            
            NLEBNFSequence *sequence = [holder nextSequence];
            [self addNLEParserStateSequence:sequence token:currentToken parserRepetition:[holder parserRepetition] repetition:NLEBNFRepetition_NONE];
            
        } else if ([holder sequence]) {
            
            NLEBNFSymbol *symbol = [holder nextSymbol];
            NSMutableArray *sd = [_sequenceMap objectForKey:[symbol name]];
            
            NLEBNFParserRepetition parserRepetition = [self parserRepetition:holder symbol:symbol];
            
            if (sd) {
                
                [self addNLEParserStateSequences:sd token:currentToken parserRepetition:parserRepetition repetition:[symbol repetition]];
                 
            } else {
                     
                NLEParserState state = [self parserState:symbol token:currentToken parserRepetition:parserRepetition];
                [self addNLEParserState:state];
            }
        }
    }
}
                 
/**
 * Gets the Parser State.
 */
- (NLEParserState)parserState:(NLEBNFSymbol *)symbol token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition) repetition {

    NLEParserState state = NLEParserState_NO_MATCH;

    NSString *symbolName = [symbol name];

    if ([symbolName isEqualToString:@"Empty"]) {

        state = NLEParserState_EMPTY;

    } else if ([self isMatch:symbolName token:token]) {

        state = NLEParserState_MATCH;

    } else if (repetition == NLEBNFParserRepetition_ZERO_OR_MORE_LOOKING_FOR_FIRST_MATCH) {

        state = NLEParserState_NO_MATCH_WITH_ZERO_REPETITION_LOOKING_FOR_FIRST_MATCH;

    } else if (repetition == NLEBNFParserRepetition_ZERO_OR_MORE) {

        state = NLEParserState_NO_MATCH_WITH_ZERO_REPETITION;
    }

    return state;
}

- (BOOL)isMatch:(NSString *)symbolName token:(NLEBNFToken *)token {

    BOOL match = NO;

    if (token) {
        NSString *s = [self isQuotedString:symbolName] ? [symbolName substringWithRange:NSMakeRange(1, [symbolName length] - 2)] : symbolName;
        match = [s isEqualToString:[token stringValue]] || [self isQuotedString:symbolName token:token] || [self isNumber:symbolName token:token];
    }

    return match;
}

- (BOOL)isQuotedString:(NSString *)value {
    return ([value hasPrefix:@"\""] && [value hasSuffix:@"\""]) || ([value hasPrefix:@"'"] && [value hasSuffix:@"'"]);
}

- (BOOL)isQuotedString:(NSString *)symbolName token:(NLEBNFToken *)token {
    NSString *value = [token stringValue];
    return [symbolName isEqualToString:@"QuotedString"] && [self isQuotedString:value];
}

- (BOOL)isNumber:(NSString *)symbolName token:(NLEBNFToken *)token {

    BOOL match = NO;
    
    if (token && [symbolName isEqualToString:@"Number"]) {
        NSError *error = NULL;
        
        NSString *string = [token stringValue];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[\\d\\-\\.]+$"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                            options:0
                                                              range:NSMakeRange(0, [string length])];
        match = numberOfMatches > 0;
    }
    
    return match;
}

- (void)addNLEParserState:(NLEParserState)state {
    NLEBNFParserState *pstate = [[NLEBNFParserState alloc] initWithNLEParserState:state];
    [_stack push:pstate];
}

- (void)addNLEParserStateSequences:(NSMutableArray *)sequences token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)parserRepetition repetition:(NLEBNFRepetition)repetition {

    if ([sequences count] == 1) {
        [self addNLEParserStateSequence:[sequences objectAtIndex:0] token:token parserRepetition:parserRepetition repetition:repetition];
    } else {
        [self debugSequences:sequences token:token parserRepetition:parserRepetition];

        NLEBNFParserState *state = [[NLEBNFParserState alloc] initWithSequences:sequences token:token parserRepetition:parserRepetition repetition:repetition];
        [_stack push:state];
    }
}

- (void)addNLEParserStateSequence:(NLEBNFSequence *)sequence token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)parserRepetition repetition:(NLEBNFRepetition)repetition {
    [self debugSequence:sequence token:token parserRepetition:parserRepetition];

    NLEBNFParserState *state = [[NLEBNFParserState alloc] initWithSequence:sequence token:token parserRepetition:parserRepetition repetition:repetition];
    [_stack push:state];
}

- (NLEBNFParserRepetition)parserRepetition:(NLEBNFParserState *)holder symbol:(NLEBNFSymbol *)symbol {
   
   NLEBNFRepetition symbolRepetition = [symbol repetition];
   NLEBNFParserRepetition holderRepetition = [holder parserRepetition];
   
   if (symbolRepetition != NLEBNFRepetition_NONE && holderRepetition == NLEBNFParserRepetition_NONE) {
       holderRepetition = NLEBNFParserRepetition_ZERO_OR_MORE_LOOKING_FOR_FIRST_MATCH;
   } else if (symbolRepetition != NLEBNFRepetition_NONE && holderRepetition != NLEBNFParserRepetition_NONE) {
       holderRepetition = NLEBNFParserRepetition_ZERO_OR_MORE;
   }
   
   return holderRepetition;
}

- (BOOL)isEmpty:(NLEBNFToken *)currentToken {
   return !([[currentToken stringValue] length] > 0);
}

- (void)debugPrintIndents {
//   NSInteger size = [_stack count] - 1;
//   for (int i = 0; i < size; i++) {
//       NSLog(@" ");
//   }
}

- (NSString *)debug:(NLEBNFToken *)token {
   return token ? [token stringValue] : NULL;
}

     
- (void)debugSequence:(NLEBNFSequence *)sequence token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)repetition {
//   [self debugPrintIndents];
//   NSLog(@"-> procesing pipe line %@ for token %@ with repetition %ld", sequence, [self debug:token], repetition);
}

- (void)debugSequences:(NSMutableArray *)sd token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)repetition {
//   [self debugPrintIndents];
//   NSLog(@"-> adding pipe lines %@ for token %@ with repetition %ld", sd, [self debug:token], repetition);
}

@end
