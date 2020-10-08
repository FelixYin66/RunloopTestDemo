//
//  ViewController.m
//  RunloopTestDemo
//
//  Created by FelixYin on 2020/10/5.
//

#import "ViewController.h"
#import "FYThread.h"
#import "FYRunLoopThread.h"

/*
 Runloop使用场景：
 
 描述RunLoop:
 RunLoop是与线程关联的，一个RunLoop对应一个线程。一个运行循环是一个事件处理循环，用它来安排工作
 并协调接收传入的事件。运行循环的目的是有事做事，没事的情况下让线程进入睡眠状态。
 
 1.RunLoop与线程的关系 一个线程对应一个运行循环
 2.AutoReleasePool与RunLoop关系 AutoReleasePool是在即将进入RunLoop被创建，在即将推出RunLoop销毁
 3.NSTimer是怎么实现的 ，NSTimer实际是CFRunLoopTimerRef封装
 4.怎么实现一个后台线程不退出，实现有事做事，没事休眠？在后台线程开启RunLoop，并向RunLoop中添加任务，最简单的是添加NSPort,添加其他也可以
 后台线程启动RunLoop需要注意点：
 1.退出时，后台线程能够销毁
 2.后台线程RunLoop能够被停止
 
 
 
 官方文档说明：
 {
 输入源:
 输入源将事件异步传递到您的线程。事件的来源取决于输入来源的类型，通常是两个类别之一。
 1.基于端口的输入源监视您的应用程序的Mach端口。
 2.定制输入源监视事件的定制源。就您的运行循环而言，输入源是基于端口的还是定制的都无关紧要。系统通常实现两种类型的输入源，您可以按原样使用。
 端口与定制源区别：
 1.两种信号源之间的唯一区别是信号的发送方式。
 2.基于端口的源由内核自动发出信号，而自定义源必须从另一个线程手动发出信号。

 创建输入源时，可以将其分配给运行循环的一种或多种模式。模式会影响在任何给定时刻监视哪些输入源。大多数情况下，您会在默认模式下运行运行循环，但也可以指定自定义模式。如果输入源不在当前监视的模式下，则它生成的任何事件都将保留，直到运行循环以正确的模式运行。
 }
 
 官方文档： https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW23
 
 主线程RunLoop内部结构：
 
 po [NSRunLoop currentRunLoop]
 
 <CFRunLoop 0x600001a3c100 [0x7fff8002e4e0]>{wakeup port = 0x1c03, stopped = false, ignoreWakeUps = true,
 current mode = (none),
 common modes = <CFBasicHash 0x600002860c60 [0x7fff8002e4e0]>{type = mutable set, count = 2,
 entries =>
     0 : <CFString 0x7fff806578e0 [0x7fff8002e4e0]>{contents = "UITrackingRunLoopMode"}
     2 : <CFString 0x7fff801ab348 [0x7fff8002e4e0]>{contents = "kCFRunLoopDefaultMode"}
 }
 ,
 common mode items = <CFBasicHash 0x600002850180 [0x7fff8002e4e0]>{type = mutable set, count = 10,
 entries =>
     0 : <CFRunLoopSource 0x600001338180 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = PurpleEventSignalCallback (0x7fff2b774bc2)}}
     1 : <CFRunLoopSource 0x600001334240 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3803, callout = PurpleEventCallback (0x7fff2b774bce)}}
     2 : <CFRunLoopObserver 0x6000017306e0 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = _afterCACommitHandler (0x7fff246910ff), context = <CFRunLoopObserver context 0x7f8f91f05700>}
     3 : <CFRunLoopSource 0x600001334480 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x600001d3c270, callout = __eventQueueSourceCallback (0x7fff24706192)}}
     6 : <CFRunLoopObserver 0x600001730780 [0x7fff8002e4e0]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _runLoopObserverCallout (0x7fff2413fd3e), context = (
 )}
     7 : <CFRunLoopSource 0x600001334540 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -2, context = <CFRunLoopSource context>{version = 0, info = 0x600002861830, callout = __eventFetcherSourceCallback (0x7fff24706204)}}
     9 : <CFRunLoopObserver 0x60000173c000 [0x7fff8002e4e0]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = _UIGestureRecognizerUpdateObserver (0x7fff24191d38), context = <CFRunLoopObserver context 0x600000d34d90>}
     10 : <CFRunLoopSource 0x600001328000 [0x7fff8002e4e0]>{signalled = Yes, valid = Yes, order = 0, context = <CFRunLoopSource context>{version = 0, info = 0x600000224060, callout = FBSSerialQueueRunLoopSourceHandler (0x7fff25aa3e2a)}}
     11 : <CFRunLoopObserver 0x600001730640 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = _beforeCACommitHandler (0x7fff24691096), context = <CFRunLoopObserver context 0x7f8f91f05700>}
     12 : <CFRunLoopObserver 0x600001730820 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _runLoopObserverCallout (0x7fff2413fd3e), context = (
 )}
 }
 ,
 modes = <CFBasicHash 0x600002860ba0 [0x7fff8002e4e0]>{type = mutable set, count = 3,
 entries =>
     0 : <CFRunLoopMode 0x600001d38340 [0x7fff8002e4e0]>{name = UITrackingRunLoopMode, port set = 0x3203, queue = 0x60000083d400, source = 0x60000083d500 (not fired), timer port = 0x4903,
     sources0 = <CFBasicHash 0x6000028501e0 [0x7fff8002e4e0]>{type = mutable set, count = 4,
 entries =>
     0 : <CFRunLoopSource 0x600001338180 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = PurpleEventSignalCallback (0x7fff2b774bc2)}}
     3 : <CFRunLoopSource 0x600001328000 [0x7fff8002e4e0]>{signalled = Yes, valid = Yes, order = 0, context = <CFRunLoopSource context>{version = 0, info = 0x600000224060, callout = FBSSerialQueueRunLoopSourceHandler (0x7fff25aa3e2a)}}
     4 : <CFRunLoopSource 0x600001334540 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -2, context = <CFRunLoopSource context>{version = 0, info = 0x600002861830, callout = __eventFetcherSourceCallback (0x7fff24706204)}}
     5 : <CFRunLoopSource 0x600001334480 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x600001d3c270, callout = __eventQueueSourceCallback (0x7fff24706192)}}
 }
 ,
     sources1 = <CFBasicHash 0x600002850210 [0x7fff8002e4e0]>{type = mutable set, count = 1,
 entries =>
     2 : <CFRunLoopSource 0x600001334240 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3803, callout = PurpleEventCallback (0x7fff2b774bce)}}
 }
 ,
     observers = (
     "<CFRunLoopObserver 0x600001730780 [0x7fff8002e4e0]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _runLoopObserverCallout (0x7fff2413fd3e), context = (\n)}",
     "<CFRunLoopObserver 0x60000173c000 [0x7fff8002e4e0]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = _UIGestureRecognizerUpdateObserver (0x7fff24191d38), context = <CFRunLoopObserver context 0x600000d34d90>}",
     "<CFRunLoopObserver 0x600001730640 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = _beforeCACommitHandler (0x7fff24691096), context = <CFRunLoopObserver context 0x7f8f91f05700>}",
     "<CFRunLoopObserver 0x6000017306e0 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = _afterCACommitHandler (0x7fff246910ff), context = <CFRunLoopObserver context 0x7f8f91f05700>}",
     "<CFRunLoopObserver 0x600001730820 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _runLoopObserverCallout (0x7fff2413fd3e), context = (\n)}"
 ),
     timers = (null),
     currently 623836714 (1438927367287868) / soft deadline in: 1.84453051e+10 sec (@ -1) / hard deadline in: 1.84453051e+10 sec (@ -1)
 },

     1 : <CFRunLoopMode 0x600001d38410 [0x7fff8002e4e0]>{name = GSEventReceiveRunLoopMode, port set = 0x4803, queue = 0x60000083d580, source = 0x60000083d680 (not fired), timer port = 0x3703,
     sources0 = <CFBasicHash 0x6000028502a0 [0x7fff8002e4e0]>{type = mutable set, count = 1,
 entries =>
     0 : <CFRunLoopSource 0x600001338180 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = PurpleEventSignalCallback (0x7fff2b774bc2)}}
 }
 ,
     sources1 = <CFBasicHash 0x6000028502d0 [0x7fff8002e4e0]>{type = mutable set, count = 1,
 entries =>
     2 : <CFRunLoopSource 0x600001334300 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3803, callout = PurpleEventCallback (0x7fff2b774bce)}}
 }
 ,
     observers = (null),
     timers = (null),
     currently 623836714 (1438927368994211) / soft deadline in: 1.84453051e+10 sec (@ -1) / hard deadline in: 1.84453051e+10 sec (@ -1)
 },

     2 : <CFRunLoopMode 0x600001d38270 [0x7fff8002e4e0]>{name = kCFRunLoopDefaultMode, port set = 0x4f03, queue = 0x60000083d080, source = 0x60000083d180 (not fired), timer port = 0x3003,
     sources0 = <CFBasicHash 0x600002850240 [0x7fff8002e4e0]>{type = mutable set, count = 4,
 entries =>
     0 : <CFRunLoopSource 0x600001338180 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = PurpleEventSignalCallback (0x7fff2b774bc2)}}
     3 : <CFRunLoopSource 0x600001328000 [0x7fff8002e4e0]>{signalled = Yes, valid = Yes, order = 0, context = <CFRunLoopSource context>{version = 0, info = 0x600000224060, callout = FBSSerialQueueRunLoopSourceHandler (0x7fff25aa3e2a)}}
     4 : <CFRunLoopSource 0x600001334540 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -2, context = <CFRunLoopSource context>{version = 0, info = 0x600002861830, callout = __eventFetcherSourceCallback (0x7fff24706204)}}
     5 : <CFRunLoopSource 0x600001334480 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x600001d3c270, callout = __eventQueueSourceCallback (0x7fff24706192)}}
 }
 ,
     sources1 = <CFBasicHash 0x600002850270 [0x7fff8002e4e0]>{type = mutable set, count = 1,
 entries =>
     2 : <CFRunLoopSource 0x600001334240 [0x7fff8002e4e0]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3803, callout = PurpleEventCallback (0x7fff2b774bce)}}
 }
 ,
 
 
 order = -2147483647 这个是创建自动释放池，优先级最高
     observers = (
     "<CFRunLoopObserver 0x600001730780 [0x7fff8002e4e0]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _runLoopObserverCallout (0x7fff2413fd3e), context = (\n)}",
     "<CFRunLoopObserver 0x60000173c000 [0x7fff8002e4e0]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = _UIGestureRecognizerUpdateObserver (0x7fff24191d38), context = <CFRunLoopObserver context 0x600000d34d90>}",
     "<CFRunLoopObserver 0x600001730640 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = _beforeCACommitHandler (0x7fff24691096), context = <CFRunLoopObserver context 0x7f8f91f05700>}",
     "<CFRunLoopObserver 0x6000017306e0 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = _afterCACommitHandler (0x7fff246910ff), context = <CFRunLoopObserver context 0x7f8f91f05700>}",
 
 order = 2147483647 这个是释放旧的释放池，优先级最低
 
     "<CFRunLoopObserver 0x600001730820 [0x7fff8002e4e0]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _runLoopObserverCallout (0x7fff2413fd3e), context = (\n)}"
 ),
     timers = <CFArray 0x60000022c840 [0x7fff8002e4e0]>{type = mutable-small, count = 1, values = (
     0 : <CFRunLoopTimer 0x6000013343c0 [0x7fff8002e4e0]>{valid = Yes, firing = No, interval = 0, tolerance = 0, next fire date = 623836705 (-9.12497604 @ 1438918246454571), callout = (Delayed Perform) UIApplication _accessibilitySetUpQuickSpeak (0x7fff20847db2 / 0x7fff23a7fbd2) (/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore), context = <CFRunLoopTimer context 0x60000332d280>}
 )},
     currently 623836714 (1438927369048399) / soft deadline in: 1.84467441e+10 sec (@ 1438918246454571) / hard deadline in: 1.84467441e+10 sec (@ 1438918246454571)
 },

 }
 }
 
 */
@interface ViewController ()

@property (nonatomic,strong) FYThread *thread;
@property (nonatomic,assign) BOOL isStopRunLoop;
@property (nonatomic,strong) FYRunLoopThread *runLoopThread;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //后台线程启动RunLoop
//    [self backgroundThreadRunLoop];
    
    //后台线程启动定时器
//    [self backgroundThreadTimer];
    
    
    //测试FYRunLoopThread
    [self testRunLoopThread];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self addInputSourceForRunLoop];
    [self testRunLoopThreadDoTask];
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"滑动屏幕");
}

// MARK: Custom RunLoopThread

- (void) testRunLoopThread{
    self.runLoopThread = [[FYRunLoopThread alloc] init];
    [self.runLoopThread doTask:^{
        NSLog(@"FYRunLoopThread后台线程执行任务1 == %@",[NSThread currentThread]);
    }];
}

- (void) testRunLoopThreadDoTask{
    [self.runLoopThread doTask:^{
        NSLog(@"FYRunLoopThread后台线程执行任务2 == %@",[NSThread currentThread]);
    }];
}

// MARK: BackgroundThread RunLoop

- (void) backgroundThreadRunLoop{
    /*
     方式1：
     虽然Thread对象没有销毁，当触发touchesBegan函数执行runTest 会出现BAD_Access_Address错误（直接crash）
     ViewController，Thread都会销毁
     
     ？？为什么会Crash
     */
//    self.thread = [[FYThread alloc] initWithTarget:self selector:@selector(runTest) object:nil];
    
    /*
     方式2：
     启动子线程中RunLoop，向子线程中添加一个source， 保证RunLoop中有任务
     存在一个问题ViewController，Thread都不会被销毁（Thread会强引用ViewController）
     
     不销毁原因：
     1.RunLoop没有停止
     2.Thread强引用了ViewController
     3.使用NSRunLoop方法是没法停止运行循环，是一个无限循环执行
     
     
     */
//    self.thread = [[FYThread alloc] initWithTarget:self selector:@selector(startRunloop) object:nil];
    
    /*
     方式3：
     不使用withTarget方法，从而不强引用viewController
     
     存在一个问题：Thread对象没有被销毁
     */
//    self.thread = [[FYThread alloc] initWithBlock:^{
//        NSLog(@"开始执行任务");
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] run];
//        NSLog(@"结束执行任务");
//    }];
    
    
    /*
     方式4：
     此方式RunLoop只执行一次，就会退出运行循环
     */
//    self.thread = [[FYThread alloc] initWithBlock:^{
//        NSLog(@"开始执行任务");
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        NSLog(@"结束执行任务");
//    }];
    
    
    /*
     方式5：
     通过isStopRunLoop标记控制以及While控制RunLoop生命周期
     
     如果仅仅添加如下代码的话，RunLoop执行完一次就结束了
     [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
     */
    __weak typeof(self) weakSelf = self;
    self.thread = [[FYThread alloc] initWithBlock:^{
        NSLog(@"开始执行任务");
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        
        // 在ViewController被销毁之前weak指针会被清空,所以更严谨的做法是判断weakSelf是否为空
        while (weakSelf && !weakSelf.isStopRunLoop) {
            //当isStopRunLoop 为YES时就结束了
            NSLog(@"weakSelf === %@",weakSelf);
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; //使用此代码后，让当前线程RunLoop处于休眠状态
        }
        NSLog(@"结束执行任务");
    }];
    [self.thread start];
}

//创建线程执行任务
- (void) runTest{
    NSLog(@"%s === %@",__func__,[NSThread currentThread]);
}

//向线程添加输入源
- (void) addInputSourceForRunLoop{
    [self performSelector:@selector(runTest) onThread:self.thread withObject:nil waitUntilDone:YES];
    NSLog(@"执行完再执行");
}

//开启RunLoop
- (void) startRunloop{
    /*
     1.RunLoop对象是不需要创建的，在获取的时候自动创建
     2.子线程中任何一个Mode都可以使用，使用默认mode即可
     3.子线程中获取的RunLoop一开始是没有source0，source1,timer，observer的，当向子线程RunLoop中添加source，timer可以保证子线程一直存活
     */
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}


/*
 停止RunLoop
 停止RunLoop的话，需要向当前线程发送消息，内部停止当前线程运行循环
 */
- (IBAction)stopRunloop{
    if (self.thread) {
        self.isStopRunLoop = YES;
        [self performSelector:@selector(__stopRunloop) onThread:self.thread withObject:nil waitUntilDone:NO];
    }
}

- (void) __stopRunloop{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

// MARK: BackgroundThread Timer

//在非主线程中创建定时器
- (void) backgroundThreadTimer{
    __weak typeof(self) weakSelf = self;
    self.thread = [[FYThread alloc] initWithBlock:^{
        NSLog(@"后台线程开始执行任务");
        [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(timerHandle) userInfo:nil repeats:YES];
    }];
    [self.thread start];
}

- (void) timerHandle{
    NSLog(@"后台线程定时器执行任务中%@ ===",[NSThread currentThread]);
}

- (void)dealloc{
    NSLog(@"%@ === %s",[self class],__func__);
    //ViewController销毁之前 停止RunLoop
    [self stopRunloop]; //这里执行stopRunLoop晚了，Thread不会被销毁.在ViewController被销毁之前weak指针会被清空,所以在while中条件是一直成立的，所以做一个weakSelf是否为空的判断
}


@end
