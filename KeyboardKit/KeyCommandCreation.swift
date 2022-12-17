// Douglas Hill, May 2019

import UIKit

extension UIKeyCommand {
    /// Consistent API whether there is a title or not.
    /// Tuple means usage reads more nicely too.
    convenience init(_ keys: (modifierFlags: UIKeyModifierFlags, input: String), action: Selector, title: String? = nil, wantsPriorityOverSystemBehavior: Bool = false, allowsAutomaticLocalization: Bool = true, allowsAutomaticMirroring: Bool = true) {
        if let title = title {
            self.init(title: title, action: action, input: keys.input, modifierFlags: keys.modifierFlags)
        } else {
            self.init(input: keys.input, modifierFlags: keys.modifierFlags, action: action)
        }

        if #available(iOS 15.0, *)  {
            self.wantsPriorityOverSystemBehavior = wantsPriorityOverSystemBehavior
            self.allowsAutomaticLocalization = allowsAutomaticLocalization
            self.allowsAutomaticMirroring = allowsAutomaticMirroring
        }
    }

    /// Shorthand for when there are no modifier keys.
    convenience init(_ input: String, action: Selector, title: String? = nil, wantsPriorityOverSystemBehavior: Bool = false, allowsAutomaticLocalization: Bool = true, allowsAutomaticMirroring: Bool = true) {
        self.init(([], input), action: action, title: title, wantsPriorityOverSystemBehavior: wantsPriorityOverSystemBehavior, allowsAutomaticLocalization: allowsAutomaticLocalization, allowsAutomaticMirroring: allowsAutomaticMirroring)
    }

    convenience init(keyboardInput: KeyboardInput, action: Selector, title: String? = nil, wantsPriorityOverSystemBehavior: Bool = false, allowsAutomaticLocalization: Bool = true) {
        self.init((keyboardInput.modifierFlags, keyboardInput.character), action: action, title: title, wantsPriorityOverSystemBehavior: wantsPriorityOverSystemBehavior, allowsAutomaticLocalization: allowsAutomaticLocalization, allowsAutomaticMirroring: keyboardInput.allowsAutomaticMirroring)
    }
}
