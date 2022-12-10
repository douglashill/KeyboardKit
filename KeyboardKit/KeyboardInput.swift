// Douglas Hill, December 2022

/// Input required on a hardware keyboard (a combination of keys).
///
/// A keyboard command consists of input (this type) + action (code to run).
struct KeyboardInput {
    let modifierFlags: UIKeyModifierFlags
    let character: String
    let allowsAutomaticMirroring: Bool

    // The default for mirroring doesn’t matter for most inputs since they’re not directional, but might as well match the UIKit and SwiftUI default.

    init(_ modifierFlags: UIKeyModifierFlags, _ character: String, allowsAutomaticMirroring: Bool = true) {
        self.modifierFlags = modifierFlags
        self.character = character
        self.allowsAutomaticMirroring = allowsAutomaticMirroring
    }

    /// An action to cancelling an in-progress task or dismiss a prompt, consisting of the Escape (⎋) key and no modifiers.
    static let cancel = KeyboardInput([], .escape)

    /// A close action, consisting of the 'W' key and the Command (⌘) modifier.
    static let close = KeyboardInput(.command, "w")

    /// A done action, consisting of the Return (↩) key and the Command (⌘) modifier.
    static let done = KeyboardInput(.command, .returnOrEnter) // Apparently "\u{3}" might work for enter (not return) but not quite. Shows up in the HUD with no key and I couldn’t get it to trigger. For now use cmd + return instead. Sources: https://forums.developer.apple.com/thread/119584 and https://stackoverflow.com/questions/56963348/uikeycommand-for-the-enter-key-on-mac-keyboards-numeric-keypad.

    /// A save action, consisting of the 'S' key and the Command (⌘) modifier.
    static let save = KeyboardInput(.command, "s")

    /// An action that shows the share sheet, consisting of the 'I' key and the Command (⌘) modifier.
    static let share = KeyboardInput(.command, "i") // Safari uses this for Email This Page. Also indirectly recommended in https://developer.apple.com/wwdc20/10117.

    /// An edit action, consisting of the 'E' key and the Command (⌘) modifier.
    static let edit = KeyboardInput(.command, "e")

    /// A creation action, consisting of the 'N' key and the Command (⌘) modifier.
    static let new = KeyboardInput(.command, "n")

    /// A reply action, consisting of the 'R' key and the Command (⌘) modifier.
    static let reply = KeyboardInput(.command, "r")

    /// A refresh action, consisting of the 'R' key and the Command (⌘) modifier.
    static let refresh = KeyboardInput(.command, "r")

    /// An action for viewing bookmarks, consisting of the 'B' key and the Command (⌘) modifier.
    static let bookmarks = KeyboardInput(.command, "b") // opt + cmd + B or shift + cmd + B might be better to be more like Safari.

    /// A search action, consisting of the 'F' key and the Command (⌘) modifier.
    static let search = KeyboardInput(.command, "f")

    /// A deletion action, consisting of the Delete (⌫) key and the Command (⌘) modifier.
    static let delete = KeyboardInput(.command, .delete)

    /// An action for viewing content relating to the current day, consisting of the 'T' key and the Command (⌘) modifier.
    static let today = KeyboardInput(.command, "t")

    /// A zoom-in action, consisting of the equals (=) key and the Command (⌘) modifier.
    static let zoomIn = KeyboardInput(.command, "=")

    /// A zoom-out action, consisting of the minus (-) key and the Command (⌘) modifier.
    static let zoomOut = KeyboardInput(.command, "-")

    /// An action to zoom content to its actual size, consisting of the 0 key and the Command (⌘) modifier.
    static let zoomToActualSize = KeyboardInput(.command, "0")

    // Mirroring for these two is based on the assumption that these are being used for media playback, which typically progresses left-to-right even in right-to-left layouts.

    /// A rewind action, consisting of the left arrow (←) key and the Command (⌘) modifier.
    static let rewind = KeyboardInput(.command, .leftArrow, allowsAutomaticMirroring: false)

    /// A fast-forward action, consisting of the right arrow (→) key and the Command (⌘) modifier.
    static let fastForward = KeyboardInput(.command, .rightArrow, allowsAutomaticMirroring: false)
}
