// Douglas Hill, December 2019

import UIKit

/// A bar button item that can define keys that may be pressed on a keyboard to trigger the button’s action.
///
/// The key command is used automatically when the bar button items is used in the navigation bar or toolbar
/// of a KeyboardNavigationController.
///
/// Key commands use nil-targeted actions so the first object on the responder chain responding to
/// the selector will handle it. This means the action might be received by a different object if
/// the bar button item uses an explicit target.
///
/// The concept for this class was originally developed for PSPDFKit: https://pspdfkit.com
public class KeyboardBarButtonItem: UIBarButtonItem {

    /// The character corresponding to the key that must be pressed to trigger this bar button item’s action from a keyboard.
    public var keyEquivalentInput: String?

    /// The set of modifier flags that must be pressed to trigger this bar button item’s action from a keyboard.
    public var keyEquivalentModifierFlags: UIKeyModifierFlags = []

    /// Creates a key command that can be used to trigger this bar button item’s action.
    public var keyCommand: UIKeyCommand? {
        guard isEnabled, let input = keyEquivalentInput, let action = action else {
            return nil
        }

        // TODO: This will not find the text for system items.
         let title = self.title ?? self.accessibilityLabel

        return UIKeyCommand(maybeTitle: title, action: action, input: input, modifierFlags: keyEquivalentModifierFlags)
    }
}
