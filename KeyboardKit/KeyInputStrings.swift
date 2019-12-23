// Douglas Hill, December 2019

import UIKit

/// Convenience strings for the `input` of a `UIKeyCommand`.
extension String {
    static let delete = "\u{8}"
    static let `return` = "\r"
    static let space = " "

    static let upArrow = UIKeyCommand.inputUpArrow
    static let downArrow = UIKeyCommand.inputDownArrow
    static let leftArrow = UIKeyCommand.inputLeftArrow
    static let rightArrow = UIKeyCommand.inputRightArrow

    // These were found in the open source WebKit.
    static let pageUp = "UIKeyInputPageUp"
    static let pageDown = "UIKeyInputPageDown"
    // These were found by guessing.
    static let home = "UIKeyInputHome"
    static let end = "UIKeyInputEnd"
}
