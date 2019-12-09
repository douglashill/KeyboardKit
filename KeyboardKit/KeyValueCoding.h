// Douglas Hill, December 2019

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KBDKeyValueCoding)

/// For KeyboardKit internal use.
/// Swallows exceptions and returns nil in that case.
/// Note this can’t be distinguished from the value being read OK but actually being nil. This functionality is not needed.
- (nullable id)kbd_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
