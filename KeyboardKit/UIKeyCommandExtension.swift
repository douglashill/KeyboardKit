// Douglas Hill, May 2019

import UIKit

extension UIKeyCommand {
    /// Makes the title optional compared to the UIKit method.
    convenience init(maybeTitle: String?, action: Selector, input: String, modifierFlags: UIKeyModifierFlags) {
        if let title = maybeTitle {
            if #available(iOS 13, *) {
                self.init(title: title, action: action, input: input, modifierFlags: modifierFlags)
            } else {
                self.init(input: input, modifierFlags: modifierFlags, action: action, discoverabilityTitle: title)
            }
        } else {
            self.init(input: input, modifierFlags: modifierFlags, action: action)
        }
    }
}
