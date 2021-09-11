// Douglas Hill, December 2019

#if SWIFT_PACKAGE
#import "BarButtonItem.h"
#else
#import <KeyboardKit/BarButtonItem.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@implementation _KBDBarButtonItem

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(nullable id)target action:(nullable SEL)action {
    self = [super initWithBarButtonSystemItem:systemItem target:target action:action];
    if (self == nil) return nil;
    [self wasInitialisedWithSystemItem:systemItem];
    return self;
}

// The two below won’t work anyway because primaryAction and menu aren’t supported, but might as well capture the system item for completeness.

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem primaryAction:(nullable UIAction *)primaryAction API_AVAILABLE(ios(14.0)) {
    self = [super initWithBarButtonSystemItem:systemItem primaryAction:primaryAction];
    if (self == nil) return nil;
    [self wasInitialisedWithSystemItem:systemItem];
    return self;
}

- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem menu:(nullable UIMenu *)menu API_AVAILABLE(ios(14.0)) {
    self = [super initWithBarButtonSystemItem:systemItem menu:menu];
    if (self == nil) return nil;
    [self wasInitialisedWithSystemItem:systemItem];
    return self;
}

- (void)wasInitialisedWithSystemItem:(UIBarButtonSystemItem)systemItem {
    // For the Swift subclass.
}

@end

NS_ASSUME_NONNULL_END
