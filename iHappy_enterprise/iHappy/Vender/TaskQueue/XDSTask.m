//
//  XDSTask.m
//
//  Copyright (c) 2014 xudusheng. All rights reserved.
//

#import "XDSTask.h"

@interface XDSTask ()

@property (nonatomic, strong) NSMutableArray * dependencyTasks;
- (void)executeBlockContent;

@end

@implementation XDSTask

- (void)dealloc
{

}

+ (XDSTask *)task
{
    return [[XDSTask alloc] init];
}

- (id)init
{
    if (self = [super init]) {
        self.dependencyTasks = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public methods

- (void)addDependency:(XDSTask *)task
{
    if (![self.dependencyTasks containsObject:task]) {
        [self.dependencyTasks addObject:task];
    }
}

- (void)removeDependency:(XDSTask *)task
{
    if ([self.dependencyTasks containsObject:task]) {
        [self.dependencyTasks removeObject:task];
    }
}

- (void)taskHasFinished
{
    [self handleTaskWithUpdateState:XDSTaskFinished];
}

- (void)cancelTask
{
    [self handleTaskWithUpdateState:XDSTaskCancelled];
}

- (NSArray *)dependencies
{
    return self.dependencyTasks;
}

- (void)executeBlockContent
{
    [self handleTaskWithUpdateState:XDSTaskExecuting];
}

- (void)handleTaskWithUpdateState:(XDSTaskState)state
{
    if (state != _taskState) {
        
        _taskState = state;
        
        if (self.taskStateChangedBlock) {
            self.taskStateChangedBlock(self);
        }
        
        if (_taskState == XDSTaskExecuting) {
            if (self.taskContentBlock) {
                self.taskContentBlock(self);
            }
        }
        
        if (_taskState == XDSTaskFinished || _taskState == XDSTaskCancelled) {
            [self.dependencyTasks removeAllObjects];
        }
    }
}

#pragma mark - Private methods


@end
