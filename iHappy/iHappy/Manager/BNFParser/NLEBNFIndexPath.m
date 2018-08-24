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

#import "NLEBNFIndexPath.h"
#import "NLEBNFIndexNode.h"

@implementation NLEBNFIndexPath

- (NLEBNFIndexPath *)path:(NSMutableArray *)nodes path:(NSString *)path {
    
    NLEBNFIndexPath *result = nil;
    
    for (NLEBNFIndexNode *node in nodes) {
        
        if ([node shouldSkip]) {
            
            result = [self path:[node nodes] path:path];
            break;
            
        } else {
            
            if ([[node keyValue] isEqualToString:path]) {
                result = node;
                break;
            }
        }
    }
    
    return result;
}

- (NLEBNFIndexPath *)path:(NSString *)path {
    return nil;
}

- (NLEBNFIndexPath *)node {
    return nil;
}

- (BOOL)eq:(NSString *)string {
    return NO;
}

- (NSString *)pathName {
    return nil;
}

- (NSString *)value {
    return nil;
}

- (NSMutableArray *)paths {
    return nil;
}

@end
