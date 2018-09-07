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

#import "NLEBNFParserState.h"

@implementation NLEBNFParserState

- (id)init {
    self = [super init];
    
    if (self) {
        [self setCurrentPosition:-1];
        [self setState:NLEParserState_NONE];
        [self setParserRepetition:NLEBNFParserRepetition_NONE];
    }
    
    return self;
}

- (id)initWithNLEParserState:(NLEParserState)parserState {
    self = [self init];
    
    if (self) {
        [self setState:parserState];
        [self setParserRepetition:NLEBNFParserRepetition_NONE];
    }
    
    return self;
}

- (id)initWithSequences:(NSMutableArray *)seqs token:(NLEBNFToken *)token {
    self = [self initWithToken:token];
    
    if (self) {
        [self setSequences:seqs];
    }
    
    return self;
}

- (id)initWithToken:(NLEBNFToken *)token {
    self = [self init];
    
    if (self) {
        [self setOriginalToken:token];
        [self setCurrentToken:token];
    }
    
    return self;
}

- (id)initWithSequence:(NLEBNFSequence *)seq token:(NLEBNFToken *)token {
    self = [self initWithToken:token];
    
    if (self) {
        [self setSequence:seq];
    }
    
    return self;
}

- (id)initWithSequences:(NSMutableArray *)sd token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)parserRep repetition:(NLEBNFRepetition)rep {
    self = [self initWithSequences:sd token:token];
    
    if (self) {
        [self setParserRepetition:parserRep];
        [self setRepetition:rep];
    }
    
    return self;
}

- (id)initWithSequence:(NLEBNFSequence *)seq token:(NLEBNFToken *)token parserRepetition:(NLEBNFParserRepetition)parserRep repetition:(NLEBNFRepetition)rep {
    self = [self initWithSequence:seq token:token];
    
    if (self) {
        [self setParserRepetition:parserRep];
        [self setRepetition:rep];
    }
    
    return self;
}

- (void)advanceToken:(NLEBNFToken *)token {
    [self setCurrentToken:token];
}

- (void)resetToken {
    [self setCurrentToken:_originalToken];
}

- (BOOL)isSequences {
    return _sequences == NULL;
}

- (BOOL)isSequence {
    return _sequence == NULL;
}

- (BOOL)isComplete {
    return [self isCompleteSequence] || [self isCompleteSymbol];
}

- (NLEBNFSequence *)nextSequence {
    
    NLEBNFSequence *seq = nil;
    NSInteger i = _currentPosition + 1;
    
    if (i < [_sequences count]) {
        seq = [_sequences objectAtIndex:i];
        [self setCurrentPosition:i];
    }
    
    return seq;
}

- (BOOL)isCompleteSequence {

    BOOL complete = NO;
    
    if (_sequences) {
        NSInteger count = [_sequences count] - 1;
        complete = _currentPosition >= count;
    }
    
    return complete;
}

- (NLEBNFSymbol *)nextSymbol {
    
    NLEBNFSymbol *symbol = nil;
    NSInteger i = _currentPosition + 1;
    
    if (i < [[_sequence symbols] count]) {
        symbol = [[_sequence symbols] objectAtIndex:i];
        [self setCurrentPosition:i];
    }
    
    return symbol;
}

- (BOOL)isCompleteSymbol {
    BOOL complete = NO;
    
    if (_sequence) {
        NSInteger count = [[_sequence symbols] count] - 1;
        complete = _currentPosition >= count;
    }
    
    return complete;
}

- (void)reset {
    [self setCurrentPosition:-1];
}

@end
