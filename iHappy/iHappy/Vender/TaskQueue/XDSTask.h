//
//  XDSTask.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    XDSTaskWait = 0,
    XDSTaskExecuting,
    XDSTaskFinished,
    XDSTaskCancelled,
}XDSTaskState;

@class XDSTask;
typedef void(^XDSTaskStateChangedBlock)(XDSTask * task);
typedef void(^XDSTaskContentBlock)(XDSTask * task);

@interface XDSTask : NSObject

@property (nonatomic, copy) NSString * taskId;
@property (nonatomic, readonly) XDSTaskState taskState;
@property (nonatomic, copy) XDSTaskContentBlock taskContentBlock;
@property (nonatomic, copy) XDSTaskStateChangedBlock taskStateChangedBlock;
@property (nonatomic, strong, readonly) NSArray *dependencies;
@property (nonatomic, strong) id userInfo;

+ (XDSTask *)task;
- (void)addDependency:(XDSTask *)task;
- (void)removeDependency:(XDSTask *)task;
- (void)executeBlockContent;
- (void)taskHasFinished;
- (void)cancelTask;

@end
