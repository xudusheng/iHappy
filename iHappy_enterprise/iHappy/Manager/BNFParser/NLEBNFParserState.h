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
#import "NLEBNFToken.h"
#import "NLEBNFSequence.h"
#import "NLEBNFSymbol.h"

@interface NLEBNFParserState : NSObject

typedef enum NLEBNFParserRepetition : NSInteger {
    NLEBNFParserRepetition_NONE,
    NLEBNFParserRepetition_ZERO_OR_MORE,
    NLEBNFParserRepetition_ZERO_OR_MORE_LOOKING_FOR_FIRST_MATCH
} NLEBNFParserRepetition;

typedef enum NLEParserState : NSInteger {
    NLEParserState_NONE,
    NLEParserState_MATCH,
    NLEParserState_NO_MATCH_WITH_ZERO_REPETITION_LOOKING_FOR_FIRST_MATCH,
    NLEParserState_NO_MATCH,
    NLEParserState_MATCH_WITH_ZERO_REPETITION,
    NLEParserState_NO_MATCH_WITH_ZERO_REPETITION,
    NLEParserState_EMPTY
} NLEParserState;

@property (nonatomic, assign) NSInteger currentPosition;
@property (nonatomic, assign) NLEParserState state;
@property (nonatomic, retain) NLEBNFToken *originalToken;
@property (nonatomic, retain) NLEBNFToken *currentToken;
@property (nonatomic, retain) NSMutableArray *sequences;
@property (nonatomic, retain) NLEBNFSequence *sequence;
@property (nonatomic, assign) NLEBNFRepetition repetition;
@property (nonatomic, assign) NLEBNFParserRepetition parserRepetition;

- (id)init;
- (id)initWithNLEParserState:(NLEParserState)parserState;
- (id)initWithSequences:(NSMutableArray *)seqs token:(NLEBNFToken *)token;
- (id)initWithToken:(NLEBNFToken *)token;
- (id)initWithSequence:(NLEBNFSequence *)seq token:(NLEBNFToken *)token;
- (id)initWithSequences:(NSMutableArray *)sd token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)parserRep repetition:(NLEBNFRepetition)rep;
- (id)initWithSequence:(NLEBNFSequence *)seq token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)parserRep repetition:(NLEBNFRepetition)rep;

- (void)advanceToken:(NLEBNFToken *)token;
- (void)resetToken;
- (BOOL)isComplete;
- (void)reset;
- (NLEBNFSequence *)nextSequence;
- (NLEBNFSymbol *)nextSymbol;

@end
