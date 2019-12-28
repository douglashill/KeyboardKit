// Douglas Hill, December 2019

#import <UIKit/UIKit.h>

/*
 This file is for debugging and is not included in the target by default. To use it, add it to the target, and then in the debugger run:

 (lldb) settings set target.language objc
 (lldb) e (void)[UIResponder kbd_debugPrintResponderChain]
 */

@implementation UIResponder (KBDDebug)

static UIResponder *foundFirstResponder;

/// The first responder or nil if there is no first responder.
+ (UIResponder *)kbd_firstResponder {
    [UIApplication.sharedApplication sendAction:@selector(kbd_debug_findFirstResponder:) to:nil from:nil forEvent:nil];
    return foundFirstResponder;
}

- (void)kbd_debug_findFirstResponder:(id)sender {
    foundFirstResponder = self;
}

+ (void)kbd_debugPrintResponderChain {
    UIResponder *responder = [UIResponder kbd_firstResponder];

    while (responder != nil) {
        NSLog(@"%@", responder);
        responder = [responder nextResponder];
    }
}

@end
