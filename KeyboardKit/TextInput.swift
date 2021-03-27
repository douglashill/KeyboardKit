// Douglas Hill, November 2019
// Some concepts implemented in this file were originally developed for PSPDFKit: <https://pspdfkit.com>

import UIKit

extension UIResponder {

    /// Whether the first responder accepts text input.
    static var isTextInputActive: Bool {
        guard let view = firstResponder as? UIView else {
            return false
        }

        if let textView = view as? UITextView {
            return textView.isEditable
        }

        return view.isUserInteractionEnabled && view is UITextInput
    }

    var isInResponderChain: Bool {
        var maybeResponderInChain = UIResponder.firstResponder
        while let responderInChain = maybeResponderInChain {
            if responderInChain === self {
                return true
            }
            maybeResponderInChain = responderInChain.next
        }
        return false
    }

    private static var foundFirstResponder: UIResponder?

    /// The first responder or nil if there is no first responder.
    private static var firstResponder: UIResponder? {
        UIApplication.shared.sendAction(#selector(UIResponder.kbd_findFirstResponder), to: nil, from: nil, for: nil)
        let result = foundFirstResponder
        foundFirstResponder = nil
        return result
    }

    @objc private func kbd_findFirstResponder(sender: Any?) {
        UIResponder.foundFirstResponder = self
    }
}

extension UIKeyCommand {

    /// Whether the key command would conflict with text input if text input is active. If this is false the key command can
    /// safely be active while text input is taking place. This will allow some key combinations that are used for text input
    /// but don’t do anything unique. For example, shift + control + option + tab types a tab character and this can also be
    /// done by pressing tab with no modifiers, so this is not considered a conflict.
    ///
    /// `UIKeyCommands` from further along the responder chain take priority over the first responder being used for text input.
    /// Overriding keys used for text input is a bad user experience and can easily lead to data loss.
    var doesConflictWithTextInput: Bool {
        guard let input = input else {
            // No input means no conflicts. But no way to press the key either.
            return false
        }

        switch (input) {
        case .delete, .upArrow, .downArrow, .leftArrow, .rightArrow:
            switch modifierFlags {
            case [], .shift, .control, .alternate, .command, [.shift, .control], [.shift, .alternate], [.shift, .command]:
                return true
            default:
                return false
            }
        case .space:
            // Option + space type a non-breaking space. Shift might be held while typing all caps.
            switch modifierFlags {
            case [], .shift, .alternate, [.shift, .alternate]:
                return true
            default:
                return false
            }
        case .returnOrEnter, .tab, .escape:
            // With modifiers these either do nothing or do the same as with no modifiers.
            return modifierFlags.isEmpty
        case .pageUp, .pageDown, .home, .end:
            // These are never used for text input.
            return false
        default:
            break
        }
        // Normalise case because the system ignores the case. Can’t do this at the start because lowercasing strings like UIKeyInputUpArrow makes them not match.
        switch (input.lowercased()) {
        case "a", "b", "d", "e", "f", "h", "i", "j", "k", "m", "n", "o", "p", "t":
            // http://www.hcs.harvard.edu/~jrus/Site/system-bindings.html minus some that don’t work on iOS, plus some that do something on iOS but not on Mac.
            // These do something useful in text input with control or shift + control. Command or control + option are not used for text input.
            let notUsedForTextInput = modifierFlags.contains(.command) || modifierFlags.contains(.control) && modifierFlags.contains(.alternate)
            return notUsedForTextInput == false
        default:
            // These don’t do anything with the control key.
            let notUsedForTextInput = modifierFlags.contains(.command) || modifierFlags.contains(.control)
            return notUsedForTextInput == false
        }
    }
}
