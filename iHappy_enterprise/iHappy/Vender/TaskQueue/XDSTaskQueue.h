//
//  XDSTaskQueue.h
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XDSTask.h"

@class XDSTaskQueue;
typedef void(^XDSTaskQueueFinishedBlock)(XDSTaskQueue * taskQueue);

@interface XDSTaskQueue : NSObject

@property (nonatomic, assign) NSInteger maxConcurrentTaskCount;
@property (nonatomic, strong, readonly) NSArray * tasks;

+ (XDSTaskQueue *)taskQueue;
- (void)addTask:(XDSTask *)task;
- (XDSTask *)taskWithTaskId:(NSString *)taskId;
- (void)cancelAllTasks;
- (void)resetQueue;
- (void)go;
- (void)goWithFinishedBlock:(XDSTaskQueueFinishedBlock)block;

@end
