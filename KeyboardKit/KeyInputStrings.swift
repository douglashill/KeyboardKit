// Douglas Hill, December 2019

import UIKit

/// Convenience strings for the `input` of a `UIKeyCommand`.
extension String {
    static let delete = "\u{8}" // This is the backspace ASCII control character, which is known as the delete key on Apple platforms.
    static let `return` = "\r"
    static let space = " "
    static let tab = "\t"
    static let escape = UIKeyCommand.inputEscape

    static let upArrow = UIKeyCommand.inputUpArrow
    static let downArrow = UIKeyCommand.inputDownArrow
    static let leftArrow = UIKeyCommand.inputLeftArrow
    static let rightArrow = UIKeyCommand.inputRightArrow

    // TODO: Change these to the public constants once Xcode 11.4 is out of beta.
    static let pageUp = "UIKeyInputPageUp"
    static let pageDown = "UIKeyInputPageDown"
    static let home = "UIKeyInputHome"
    static let end = "UIKeyInputEnd"
}
