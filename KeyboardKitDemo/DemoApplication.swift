// Douglas Hill, January 2021

import KeyboardKit

// To show all key inputs overlaid on the screen for creating demo videos,
// define this condition and add https://github.com/jdg/MBProgressHUD.git
// using Swift Package Manager. This should not be committed because that
// causes Xcode to make changes to Package.resolved in parent projects,
// and it’s not worth inconveniencing parent projects for this.
#if ENABLE_KEY_INPUT_HUD
import MBProgressHUD
#endif

/// An application that can show all key inputs in a HUD overlay, which is useful for making demo videos.
class DemoApplication: KeyboardApplication {

#if ENABLE_KEY_INPUT_HUD
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)

        guard let pressesEvent = event as? UIPressesEvent else {
            return
        }
        let keys = pressesEvent.allPresses
            .filter { $0.phase == .began }
            .compactMap { $0.key }
            .filter { $0.charactersIgnoringModifiers.isEmpty == false }
        if keys.isEmpty {
            return
        }
        precondition(keys.count == 1)
        showHUD(forKeyInput: keys[0].charactersIgnoringModifiers, modifierFlags: keys[0].modifierFlags)
    }

    private func showHUD(forKeyInput input: String, modifierFlags: UIKeyModifierFlags) {
        let keyWindow = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }!

        MBProgressHUD.hide(for: keyWindow, animated: false)

        let hud = MBProgressHUD.showAdded(to: keyWindow, animated: false)
        hud.mode = .text
        hud.label.font = UIFont.systemFont(ofSize: 100, weight: .light)
        hud.minSize = CGSize(width: 160, height: 160)

        // Try to match how the keys are displayed in the discoverability HUD that is shown by iOS when holding the command key.
        var textComponents: [String] = []

        if modifierFlags.contains(.shift) {
            textComponents.append("⇧")
        }
        if modifierFlags.contains(.control) {
            textComponents.append("⌃")
        }
        if modifierFlags.contains(.alternate) {
            textComponents.append("⌥")
        }
        if modifierFlags.contains(.command) {
            textComponents.append("⌘")
        }

        let inputText: String
        switch input {
        case "\u{8}": inputText = "⌫"
        case "\r": inputText = "⏎"
        case " ": inputText = "space"
        case "\t": inputText = "⇥" // This does not look as good as the one in the disco HUD, but I couldn’t find a better one.
        case UIKeyCommand.inputEscape: inputText = "esc" // There is ⎋ but the disco HUD shows esc.

        case UIKeyCommand.inputUpArrow: inputText = "↑"
        case UIKeyCommand.inputDownArrow: inputText = "↓"
        case UIKeyCommand.inputLeftArrow: inputText = "←"
        case UIKeyCommand.inputRightArrow: inputText = "→"

        case UIKeyCommand.inputPageUp: inputText = "page up"
        case UIKeyCommand.inputPageDown: inputText = "page down"
        case UIKeyCommand.inputHome: inputText = "home"
        case UIKeyCommand.inputEnd: inputText = "end"

        default: inputText = input.uppercased()
        }
        textComponents.append(inputText)

        hud.label.text = textComponents.joined(separator: " ")

        hud.hide(animated: true, afterDelay: 0.7)
    }
#endif
}
