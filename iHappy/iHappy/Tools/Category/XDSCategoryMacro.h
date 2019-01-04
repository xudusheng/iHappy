//
//  XDSCategoryMacro.h
//  Demo
//
//  Created by Hmily on 2018/10/19.
//  Copyright © 2018年 BX. All rights reserved.
//

#import <sys/time.h>
#import <pthread.h>


/**
 Whether in main queue/thread.
 */
static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

/**
 Submits a block for asynchronous execution on a main queue and returns immediately.
 */
static inline void dispatch_async_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/**
 Submits a block for execution on a main queue and waits until the block completes.
 */
static inline void dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

//动态关联
#ifndef XDSSYNTH_DYNAMIC_PROPERTY_OBJECT
#define XDSSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
[self willChangeValueForKey:@#_getter_]; \
objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
[self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif

