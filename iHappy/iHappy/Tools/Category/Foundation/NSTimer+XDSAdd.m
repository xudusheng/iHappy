//
//  NSTimer+XDSAdd.m
//  Demo
//
//  Created by Hmily on 2018/10/19.
//  Copyright © 2018年 BX. All rights reserved.
//

#import "NSTimer+XDSAdd.h"

@implementation NSTimer (XDSAdd)

+ (void)xds_ExecBlock:(NSTimer *)timer {
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        block(timer);
    }
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(xds_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats {
    return [NSTimer timerWithTimeInterval:seconds target:self selector:@selector(xds_ExecBlock:) userInfo:[block copy] repeats:repeats];
}

@end
