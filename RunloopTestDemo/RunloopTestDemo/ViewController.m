//
//  ViewController.m
//  RunloopTestDemo
//
//  Created by FelixYin on 2020/10/5.
//

#import "ViewController.h"
#import "FYThread.h"

/*
 Runloop使用场景
 */
@interface ViewController ()

@property (nonatomic,strong) FYThread *thread;
@property (nonatomic,assign) BOOL isStopRunLoop;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self performSelector:@selector(runTest) onThread:self.thread withObject:nil waitUntilDone:YES];
    NSLog(@"执行完再执行");
}

//创建线程执行任务
- (void) runTest{
    NSLog(@"%s === %@",__func__,[NSThread currentThread]);
}

- (void) startRunloop{
    /*
     1.RunLoop对象是不需要创建的，在获取的时候自动创建
     2.子线程中任何一个Mode都可以使用，使用默认mode即可
     3.子线程中获取的RunLoop一开始是没有source0，source1,timer，observer的，当向子线程RunLoop中添加source，timer可以保证子线程一直存活
     */
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

- (IBAction)stopRunloop{
    self.isStopRunLoop = YES;
    [self performSelector:@selector(stop) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void) stop{
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)dealloc{
    NSLog(@"%@ === %s",[self class],__func__);
    //ViewController销毁之前 停止RunLoop
    [self stopRunloop]; //这里执行stopRunLoop晚了，Thread不会被销毁.在ViewController被销毁之前weak指针会被清空,所以在while中条件是一直成立的，所以做一个weakSelf是否为空的判断
}


@end
