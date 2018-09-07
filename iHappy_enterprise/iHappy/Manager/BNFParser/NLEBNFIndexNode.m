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

#import "NLEBNFIndexNode.h"

@implementation NLEBNFIndexNode

/**
 * default constructor.
 */
- (id)init {
    
    self = [super init];
    
    if (self) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        [self setNodes:list];
    }
    
    return self;
}

 /**
  <#Description#>

  @param id <#id description#>
  @return <#return value description#>
  */

- (id)initWithKeyValue:(NSString *)keyValue stringValue:(NSString *)stringValue {
    self = [self init];
    
    if (self) {
        [self setKeyValue:keyValue];
        [self setStringValue:stringValue];
    }
    
    return self;
}

- (NLEBNFIndexPath *)path:(NSString *)path {
    return [self path:_nodes path:path];
}

- (NLEBNFIndexPath *)node {
    return self;
}

- (BOOL)eq:(NSString *)string {
    return [_stringValue isEqualToString:string];
}

- (void)addNode:(NLEBNFIndexNode *)node {
    [_nodes addObject:node];
}

- (NSString *)pathName {
    return _keyValue;
}

- (NSMutableArray *)paths {
    return _nodes;
}

- (NSString *)value {
    return _stringValue;
}

@end
