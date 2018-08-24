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
#import "NLEBNFParseResult.h"
#import "NLEStack.h"
#import "NLEBNFTokens.h"

@interface NLEBNFParser : NSObject

@property (nonatomic, retain) NLEStack *stack;
@property (nonatomic, retain) NSMutableDictionary *sequenceMap;

- (id)initWithStateDefinitions:(NSMutableDictionary *)dic;

- (NLEBNFParseResult *)parseString:(NSString *)token;

- (NLEBNFParseResult *)parse:(NLEBNFTokens *)token;

- (NLEBNFParseResult *)parse:(NLEBNFTokens *)token operation:(NSBlockOperation *)operation;

@end