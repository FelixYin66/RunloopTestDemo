//
//  FYRunLoopThread.h
//  RunloopTestDemo
//
//  Created by FelixYin on 2020/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FYRunLoopThreadTask)(void);

@interface FYRunLoopThread : NSObject

- (void) doTask:(FYRunLoopThreadTask) task;

@end

NS_ASSUME_NONNULL_END
