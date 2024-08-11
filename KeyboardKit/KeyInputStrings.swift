// Douglas Hill, December 2019

#if SWIFT_PACKAGE
import KeyboardKitObjC
#endif

import UIKit

/// Convenience strings for the `input` of a `UIKeyCommand`.
extension String {
    static let delete: String = { if #available(iOS 15.0, *) { return _KBDKeyInputDelete() } else { return "\u{8}" } }() // This is the backspace ASCII control character.
    static let returnOrEnter = "\r" // Unfortunately there is no way to distinguish between return and enter with only the input string. You need UIKeyboardHIDUsage for that.
    static let space = " "
    static let tab = "\t"
    static let escape = _KBDKeyInputEscape()

    static let upArrow = _KBDKeyInputUpArrow()
    static let downArrow = _KBDKeyInputDownArrow()
    static let leftArrow = _KBDKeyInputLeftArrow()
    static let rightArrow = _KBDKeyInputRightArrow()

    static let pageUp = _KBDKeyInputPageUp()
    static let pageDown = _KBDKeyInputPageDown()
    // Home and End work as early as 13.3 and possibly 13.2. However the main reason for the fallback is that propagating
    // the limited availability is annoying. There is no negative impact on old versions. The input just won’t be matched.
    static let home: String = { if #available(iOS 13.4, *) { return _KBDKeyInputHome() } else { return "UIKeyInputHome" } }()
    static let end: String = { if #available(iOS 13.4, *) { return _KBDKeyInputEnd() } else { return "UIKeyInputEnd" } }()
}
