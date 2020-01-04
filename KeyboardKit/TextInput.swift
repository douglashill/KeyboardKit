// Douglas Hill, November 2019
// The concepts implemented in this file were originally developed for PSPDFKit: <https://pspdfkit.com>

import UIKit

private var foundFirstResponder: UIResponder?

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

    /// The first responder or nil if there is no first responder.
    private static var firstResponder: UIResponder? {
        UIApplication.shared.sendAction(#selector(UIResponder.kbd_findFirstResponder), to: nil, from: nil, for: nil)
        return foundFirstResponder
    }

    @objc private func kbd_findFirstResponder(sender: Any?) {
        foundFirstResponder = self
    }
}

extension UIKeyCommand {

    /// Whether the key command would conflict with text input if text input is active. If this is false the key command can
    /// safely be active while text input is taking place.
    ///
    /// `UIKeyCommands` from further along the responder chain take priority over the first responder being used for text input.
    /// Overriding keys used for text input is a bad user experience and can easily lead to data loss.
    var doesConflictWithTextInput: Bool {
        guard let input = input else {
            // No input means no conflicts. But no way to press the key either.
            return false
        }

        // These inputs are used for text input with command so can’t be allowed. The thing with 8 is delete.
        enum __ { static let inputsThatConflict: Set<String> = [.delete, .upArrow, .downArrow, .leftArrow, .rightArrow] }
        if __.inputsThatConflict.contains(input) {
            return true
        }

        // Command is not used for text input (except for the cases above). Other modifiers are used for text input. Yes, even control.
        if modifierFlags.contains(.command) {
            return false
        }

        // Assume everything else is for text input. Might have forgotten something.
        return true
    }
}
