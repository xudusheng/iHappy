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

#import "NLEBNFSequenceFactory.h"
#import "NLEBNFSymbol.h"
#import "NLEBNFSequence.h"
#import "NLEPropertyParser.h"

@implementation NLEBNFSequenceFactory

- (NSMutableDictionary *)json {
    
    NSMutableDictionary *prop = [self getGrammarJSON];
    
    return [self buildMap:prop];
}

/**
 * @param prop - grammar property map
 * @return Map<String, BNFSequences>
 */
- (NSMutableDictionary *)buildMap:(NSMutableDictionary *)propertiesMap {
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    
    for (NSString *name in propertiesMap) {
        
        NSString *value = [propertiesMap objectForKey:name];
        
        NSMutableArray *sequenceNames = [self createSequenceNames:value];
        
        NSMutableArray *sequences = [self createBNFSequences:sequenceNames];
        [result setValue:sequences forKey:name];
    }
    
    return result;
}

/**
 * @param sequenceNames -
 * @return BNFSequences
 */
- (NSMutableArray *)createBNFSequences:(NSMutableArray *)sequenceNames {
    NSMutableArray *list = [self createBNFSequenceList:sequenceNames];
    return list;
}

/**
 * @param sequenceNames -
 * @return List<BNFSequence>
 */
- (NSMutableArray *)createBNFSequenceList:(NSMutableArray *)sequenceNames {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSString *s in sequenceNames) {
        NLEBNFSequence *sequence = [self createSequence:s];
        [list addObject:sequence];
    }
    
    return list;
}

/**
 * @param s -
 * @return BNFSequence
 */
- (NLEBNFSequence *)createSequence:(NSString *)s {
    
    NSMutableArray *symbols = [self createSymbols:s];
    NLEBNFSequence *seq = [[NLEBNFSequence alloc] init];
    [seq setSymbols:symbols];
    return seq;
}

/**
 * @param s -
 * @return List<BNFSymbol>
 */
- (NSMutableArray *)createSymbols:(NSString *)s {
    
    NSString *trimmed = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *split = [trimmed componentsSeparatedByString:@" "];
    
    NSMutableArray *symbols = [[NSMutableArray alloc] init];
    
    for (NSString *ss in split) {
        NLEBNFSymbol *symbol = [self createSymbol:ss];
        [symbols addObject:symbol];
    }

    return symbols;
}

/**
 * @param s -
 * @return BNFSymbol
 */
- (NLEBNFSymbol *)createSymbol:(NSString *)s {
    
    NLEBNFSymbol *symbol = [[NLEBNFSymbol alloc] init];
    [symbol setName:s];
    [symbol setRepetition:NLEBNFRepetition_NONE];
    
    if ([s hasSuffix:@"*"]) {
        NSString *newName = [s substringToIndex:[s length] - 1];
        [symbol setName:newName];
        [symbol setRepetition:NLEBNFRepetition_ZERO_OR_MORE];
    }
    
    return symbol;
}

/**
 * @param value -
 * @return List<String>
 */
- (NSMutableArray *)createSequenceNames:(NSString *)value {
    
    NSArray *split = [value componentsSeparatedByString:@"|"];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for (NSString *s in split) {
        
        NSString *str = s;
        if ([s hasSuffix:@";"]) {
            str = [s substringToIndex:[s length] - 1];
        }
        
        NSString *trimmed = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [list addObject:trimmed];
    }
    
    list = [self sortSequenceNames:list];
    
    return list;
}

/**
 * @param list -
 */
- (NSMutableArray *)sortSequenceNames:(NSMutableArray *)list {
    NSArray *sortedArray;
    sortedArray = [list sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = (NSString*)a;
        NSString *second = (NSString*)b;
        if ([first isEqualToString:@"Empty"]) {
            return 1;
        } else if ([second isEqualToString:@"Empty"]) {
            return -1;
        }
        return 0;
    }];
    
    return [sortedArray mutableCopy];

}

/**
 * Load JSON grammar.
 * @return Map<String, String>
 */
- (NSMutableDictionary *)getGrammarJSON {
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json.bnf" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile: path];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NLEPropertyParser *parser = [[NLEPropertyParser alloc] init];
    NSMutableDictionary *dic = [parser parse:s];
    
    return dic;
}

@end
