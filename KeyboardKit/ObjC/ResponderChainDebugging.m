// Douglas Hill, December 2019

#if DEBUG

#import <UIKit/UIKit.h>

/*
 This file is for debugging and is not included in the target by default. To use it, add it to the target, and then in the debugger run:

 (lldb) settings set target.language objc
 (lldb) e (void)[UIResponder kbd_debugPrintResponderChain]

 This does not work on Mac Catalyst for some reason.
 */

@implementation UIResponder (KBDDebug)

static UIResponder *foundFirstResponder;

/// The first responder or nil if there is no first responder.
///
/// For some reason this does not work on Mac Catalyst even though basically the same thing in TextInput.swift works fine.
+ (UIResponder *)kbd_firstResponder {
    [UIApplication.sharedApplication sendAction:@selector(kbd_debug_findFirstResponder:) to:nil from:nil forEvent:nil];
    UIResponder *result = foundFirstResponder;
    foundFirstResponder = nil;
    return result;
}

- (void)kbd_debug_findFirstResponder:(id)sender {
    foundFirstResponder = self;
}

+ (void)kbd_debugPrintResponderChain {
    // This is just for additional context and isn’t really needed.
    UIResponder *explicitResponder = [UIResponder kbd_firstResponder];

    // Use private API to find the source of truth. Don’t ship this. Tested on iOS 14.5 and iOS 15.0 beta 3.
    // This handles the case at scene connection where becomeFirstResponder has never been called.
    // UIKit infers a sensible responder with a ‘reverse responder chain’ lookup called deepestActionResponder.
    UIResponder *responder = [[UIApplication sharedApplication] valueForKey:@"responderForKeyEvents"];

    if (responder == nil) {
        NSAssert(explicitResponder == nil, @"If responderForKeyEvents is nil then the explicit first responder should be nil too.");
        print(@"There is no responderForKeyEvents.");
    } else if (explicitResponder == nil) {
        print(@"There is no explicit first responder. Used private API find responderForKeyEvents instead.");
    } else {
        NSAssert(responder == explicitResponder, @"Explicit responder should be same as responderForKeyEvents.");
    }

    while (responder != nil) {
        print([responder description]);

        for (UIKeyCommand *command in [responder keyCommands]) {
            print([NSString stringWithFormat:@"  | %@", command]);
        }

        responder = [responder nextResponder];
    }
}

static void print(NSString *message) {
    printf("%s\n", [message cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end

#endif
