// Douglas Hill, December 2019

#import <KeyboardKit/KeyValueCoding.h>

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (KBDKeyValueCoding)

- (nullable id)kbd_valueForKey:(NSString *)key {
    @try {
        return [self valueForKey:key];
    } @catch (NSException *exception) {
        return nil;
    }
}

@end

NS_ASSUME_NONNULL_END
