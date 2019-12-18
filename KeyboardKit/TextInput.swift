// Douglas Hill, November 2019
// The concepts implemented in this file were originally developed for PSPDFKit: <https://pspdfkit.com>

import UIKit

private var foundFirstResponder: UIResponder?

extension UIResponder {

    /// Whether the first responder accepts text input.
    static var isTextInputActive: Bool {
        firstResponder is UITextInput
    }

    /// The first responder or nil if there is no first responder.
    private static var firstResponder: UIResponder? {
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder), to: nil, from: nil, for: nil)
        return foundFirstResponder
    }

    @objc private func findFirstResponder(sender: Any?) {
        foundFirstResponder = self
    }
}

extension UIKeyCommand {

    /// Whether the key command should be allowed to be active while text input is taking place. This is false if the key command would override text input.
    ///
    /// `UIKeyCommands` from further along the responder chain take priority over the first responder being used for text input.
    /// Overriding keys used for text input is a bad user experience and can easily lead to data loss.
    var isAllowedWhileTextInputIsActive: Bool {
        guard let input = input else {
            // No input means no conflicts. But no way to press the key either.
            return true
        }

        // These inputs are used for text input with command so can’t be allowed. The thing with 8 is delete.
        enum __ { static let inputsThatConflict: Set<String> = ["\u{8}", UIKeyCommand.inputUpArrow, UIKeyCommand.inputDownArrow, UIKeyCommand.inputLeftArrow, UIKeyCommand.inputRightArrow] }
        if __.inputsThatConflict.contains(input) {
            return false
        }

        // Command is not used for text input (except for the cases above). Other modifiers are used for text input. Yes, even control.
        if modifierFlags.contains(.command) {
            return true
        }

        // Assume everything else is for text input. Might have forgotten something.
        return false
    }
}
