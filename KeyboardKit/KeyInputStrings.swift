// Douglas Hill, December 2019

import UIKit

/// Convenience strings for the `input` of a `UIKeyCommand`.
@MainActor extension String {
    static let delete: String = { if #available(iOS 15.0, *) { return UIKeyCommand.inputDelete } else { return "\u{8}" } }() // This is the backspace ASCII control character.
    static let returnOrEnter = "\r" // Unfortunately there is no way to distinguish between return and enter with only the input string. You need UIKeyboardHIDUsage for that.
    static let space = " "
    static let tab = "\t"
    static let escape = UIKeyCommand.inputEscape

    static let upArrow = UIKeyCommand.inputUpArrow
    static let downArrow = UIKeyCommand.inputDownArrow
    static let leftArrow = UIKeyCommand.inputLeftArrow
    static let rightArrow = UIKeyCommand.inputRightArrow

    static let pageUp = UIKeyCommand.inputPageUp
    static let pageDown = UIKeyCommand.inputPageDown
    // Home and End work as early as 13.3 and possibly 13.2. However the main reason for the fallback is that propagating
    // the limited availability is annoying. There is no negative impact on old versions. The input just won’t be matched.
    static let home: String = { if #available(iOS 13.4, *) { return UIKeyCommand.inputHome } else { return "UIKeyInputHome" } }()
    static let end: String = { if #available(iOS 13.4, *) { return UIKeyCommand.inputEnd } else { return "UIKeyInputEnd" } }()
}
