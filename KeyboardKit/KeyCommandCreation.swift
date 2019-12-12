// Douglas Hill, May 2019

import UIKit

extension UIKeyCommand {
    /// Consistent API whether there is a title or not and on iOS 12 and 12.
    /// Tuple means usage reads more nicely too.
    convenience init(_ keys: (modifierFlags: UIKeyModifierFlags, input: String), action: Selector, title: String? = nil) {
        if let title = title {
            if #available(iOS 13, *) {
                self.init(title: title, action: action, input: keys.input, modifierFlags: keys.modifierFlags)
            } else {
                self.init(input: keys.input, modifierFlags: keys.modifierFlags, action: action, discoverabilityTitle: title)
            }
        } else {
            self.init(input: keys.input, modifierFlags: keys.modifierFlags, action: action)
        }
    }

    /// Shorthand for when there are no modifier keys.
    convenience init(_ input: String, action: Selector, title: String? = nil) {
        self.init(([], input), action: action, title: title)
    }
}
