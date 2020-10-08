//
//  FYRunLoopThread.m
//  RunloopTestDemo
//
//  Created by FelixYin on 2020/10/8.
//

#import "FYRunLoopThread.h"

@interface TestThread : NSThread

@end

@implementation TestThread

- (void)dealloc
{
    NSLog(@"%@ === %s",[self class],__func__);
}

@end

@interface FYRunLoopThread ()

//@property (nonatomic,strong) NSThread *thread;
@property (nonatomic,strong) TestThread *thread;
@property (nonatomic,assign) BOOL isStop;
@property (nonatomic,assign) BOOL isStart;

@end

@implementation FYRunLoopThread

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
//        self.thread = [[NSThread alloc] initWithBlock:^{
        self.thread = [[TestThread alloc] initWithBlock:^{
            //监听当前RunLoop状态
            [weakSelf observerRunLoopStatus];
            
            //启动线程时，创建当前线程运行循环,并添加NSPort保证defaultmode中有事情可做，如果没有的话，会退出当前运行循环
            /*
             方式1：
             通过监听状态得知，执行一次任务后，退出RunLoop,如果在使用此线程执行任务时会Crash
             
             RunLoop日志：
             进入RunLoop
             即将处理Timer
             即将处理Source
             后台线程执行任务1 == <TestThread: 0x600002f5d8c0>{number = 7, name = (null)}
             退出RunLoop
             
             */
//            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            
            /*
             方式2：
             状态日志：
             
             第一次执行任务：
              进入RunLoop
              即将处理Timer
              即将处理Source
              后台线程执行任务1 == <TestThread: 0x6000020f7140>{number = 7, name = (null)}
              退出RunLoop
              进入RunLoop
              即将处理Timer
              即将处理Source
              即将进入休眠
             
             第二次执行任务：
             
             唤醒运行循环
             即将处理Timer
             即将处理Source
             后台线程执行任务2 == <TestThread: 0x6000001af640>{number = 7, name = (null)}
             退出RunLoop
             进入RunLoop
             即将处理Timer
             即将处理Source
             即将进入休眠
             */
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.isStop) {
                //一直唤醒，当没任务是进入休眠（通过日志得知）
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }];
    }
    return self;
}



// MARK: 执行任务

- (void)doTask:(FYRunLoopThreadTask)task{
    if (self.thread&&task) {
        if (!self.isStart) {
            self.isStart = YES;
            [self.thread start];
        }
        [self performSelector:@selector(__doTask:) onThread:self.thread withObject:task waitUntilDone:YES];
    }
}

- (void) __doTask:(FYRunLoopThreadTask)task{
    task();
}

// MARK: 停止运行循环

- (void) stop{
    if (self.thread) {
        self.isStop = YES;
        [self performSelector:@selector(__stop) onThread:self.thread withObject:nil waitUntilDone:NO];
    }
}

- (void) __stop{
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    CFRunLoopStop(loop);
}

// MARK: Observer

//监听当前RunLoop状态
- (void) observerRunLoopStatus{
    CFRunLoopRef loop = CFRunLoopGetCurrent();
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, true, 0, ThreadCFRunLoopObserverCallBack, NULL);
    CFRunLoopAddObserver(loop, observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}


//kCFRunLoopEntry = (1UL << 0),
//kCFRunLoopBeforeTimers = (1UL << 1),
//kCFRunLoopBeforeSources = (1UL << 2),
//kCFRunLoopBeforeWaiting = (1UL << 5),
//kCFRunLoopAfterWaiting = (1UL << 6),
//kCFRunLoopExit = (1UL << 7),
void ThreadCFRunLoopObserverCallBack(CFRunLoopObserverRef observer,CFRunLoopActivity activity,void *info){
    if (activity == kCFRunLoopEntry) {
        NSLog(@"进入RunLoop");
    }else if (activity == kCFRunLoopBeforeTimers){
        NSLog(@"即将处理Timer");
    }else if (activity == kCFRunLoopBeforeSources){
        NSLog(@"即将处理Source");
    }else if (activity == kCFRunLoopBeforeWaiting){
        NSLog(@"即将进入休眠");
    }else if (activity == kCFRunLoopAfterWaiting){
        NSLog(@"唤醒运行循环");
    }else if (activity == kCFRunLoopExit){
        NSLog(@"退出RunLoop");
    }
}

- (void) runLoopExit{
    NSLog(@"退出运行循环");
}

- (void)dealloc
{
    [self stop];
    
    NSLog(@"%@ === %s",[self class],__func__);
}

@end
