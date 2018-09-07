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

#import "NLEBNFFastForward.h"

@implementation NLEBNFFastForward

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [self setEnd:list];
        
        [self setEndWithType:NLEBNFTokenizerType_NONE];
        
        NSMutableString *s = [[NSMutableString alloc] init];
        [self setMs:s];
    }
    
    return self;
}

- (BOOL)isActive {
    return _start != NLEBNFTokenizerType_NONE;
}

- (BOOL)isComplete:(NLEBNFTokenizerType)type lastType:(NLEBNFTokenizerType) lastType position:(NSInteger)i length:(NSInteger)len {
    return [self isMatch:type lastType:lastType] || (i == len - 1);
}

- (BOOL)isMatch:(NLEBNFTokenizerType)type lastType:(NLEBNFTokenizerType) lastType {
    
    BOOL match = NO;
    
    if ([_end count] == 1) {
        NSNumber *num = [_end objectAtIndex:0];
        match = type == [num integerValue];
    } else if ([_end count] == 2) {
        NSNumber *num0 = [_end objectAtIndex:0];
        NSNumber *num1 = [_end objectAtIndex:1];
        match = type == [num0 integerValue] && lastType == [num1 integerValue];
    }
    
    return match;
}

- (void)complete {
    _start = NLEBNFTokenizerType_NONE;
    
    [self setEndWithType:NLEBNFTokenizerType_NONE];

    [_ms setString:@""];
}

- (void)setEndWithType:(NLEBNFTokenizerType)type {
    [_end removeAllObjects];
    [_end addObject:[NSNumber numberWithInt:type]];
}

- (void)setEndWithType:(NLEBNFTokenizerType)type1 type2:(NLEBNFTokenizerType)type2 {
    [_end removeAllObjects];
    [_end addObject:[NSNumber numberWithInt:type1]];
    [_end addObject:[NSNumber numberWithInt:type2]];
}

- (void)appendIfActiveChar:(unichar)c {
    if ([self isActive]) {
        [_ms appendFormat:@"%C", c];
    }
}

- (void)appendIfActiveNSString:(NSString *)s {
    if ([self isActive]) {
        [_ms appendString:s];
    }
}

- (NSString *)getString {
    NSString *immutableString = [NSString stringWithString:_ms];
    return immutableString;
}

@end
