// Douglas Hill, December 2019

#if SWIFT_PACKAGE
#import "BarButtonItem.h"
#else
#import <KeyboardKit/BarButtonItem.h>
#endif

@implementation KBDBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
    self = [super initWithBarButtonSystemItem:systemItem target:target action:action];
    if (self == nil) return nil;

    [self wasInitialisedWithSystemItem:systemItem];

    return self;
}

- (void)wasInitialisedWithSystemItem:(UIBarButtonSystemItem)systemItem {
    // For the Swift subclass.
}

@end
