//
//  TouchView.m
//  RunloopTestDemo
//
//  Created by FelixYin on 2020/10/6.
//

#import "TouchView.h"

@implementation TouchView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
     CFRelease(mode);
     NSLog(@"%@ == touchesBegan == %@",[self class],mode);
}

//View中移动时，运行循环mode为kCFRunLoopDefaultMode 而不是UITrackingRunLoopMode （TrackingMode为ScrollView滚动时才会出现）
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
     CFRelease(mode);
     NSLog(@"%@ == touchesMoved == %@",[self class],mode);
}


@end
