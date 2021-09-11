// Douglas Hill, December 2019

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// For KeyboardKit internal use.
/// Provides a workaround for initWithBarButtonSystemItem:target:action: not being a
/// designated initialiser and Swift hard requiring calling a designated initialiser.
@interface _KBDBarButtonItem : UIBarButtonItem

/// For KeyboardKit internal use.
/// Called after the bar button item is initialised with a system item.
/// Subclasses do not need to call super.
- (void)wasInitialisedWithSystemItem:(UIBarButtonSystemItem)systemItem;

@end

NS_ASSUME_NONNULL_END
