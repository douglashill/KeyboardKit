// Douglas Hill, August 2024

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputUpArrow` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputUpArrow(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputDownArrow` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputDownArrow(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputLeftArrow` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputLeftArrow(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputRightArrow` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputRightArrow(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputEscape` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputEscape(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputPageUp` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputPageUp(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputPageDown` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputPageDown(void);

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputHome` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputHome(void) API_AVAILABLE(ios(13.4));

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputEnd` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputEnd(void) API_AVAILABLE(ios(13.4));

/// For KeyboardKit internal use. Works around `UIKeyCommand.inputDelete` being incorrectly isolated to the main actor.
NSString *_KBDKeyInputDelete(void) API_AVAILABLE(ios(15.0));

NS_ASSUME_NONNULL_END
