// Douglas Hill, December 2022

import SwiftUI

@available(iOS 14.0, *)
extension KeyboardShortcut {
    /// The namespace for keyboard shortcuts defined by KeyboardKit.
    public enum KeyboardKit {}
}

@available(iOS 14.0, *)
@MainActor extension KeyboardShortcut.KeyboardKit {
    /// A keyboard shortcut for a close action, consisting of the 'W' key and the Command (⌘) modifier.
    public static let close = KeyboardShortcut(keyboardInput: .close)

    /// A keyboard shortcut for a done action, consisting of the Return (↩) key and the Command (⌘) modifier.
    public static let done = KeyboardShortcut(keyboardInput: .done)

    /// A keyboard shortcut for a save action, consisting of the 'S' key and the Command (⌘) modifier.
    public static let save = KeyboardShortcut(keyboardInput: .save)

    /// A keyboard shortcut for showing the share sheet, consisting of the 'I' key and the Command (⌘) modifier.
    public static let share = KeyboardShortcut(keyboardInput: .share)

    /// A keyboard shortcut for an edit action, consisting of the 'E' key and the Command (⌘) modifier.
    ///
    /// This shortcut should not be used in contexts where text selection is possible, since this key combination should
    /// be reserved for the “Use Selection for Find” action, which is supported by `UIFindInteraction` and `KeyboardTextView`.
    /// In these contexts, using ⌥⌘E for Edit is recommend.
    public static let edit = KeyboardShortcut(keyboardInput: .edit)

    /// A keyboard shortcut for a creation action, consisting of the 'N' key and the Command (⌘) modifier.
    public static let new = KeyboardShortcut(keyboardInput: .new)

    /// A keyboard shortcut for a reply action, consisting of the 'R' key and the Command (⌘) modifier.
    public static let reply = KeyboardShortcut(keyboardInput: .reply)

    /// A keyboard shortcut for a refresh action, consisting of the 'R' key and the Command (⌘) modifier.
    public static let refresh = KeyboardShortcut(keyboardInput: .refresh)

    /// A keyboard shortcut for an action for viewing bookmarks, consisting of the 'B' key and the Command (⌘) modifier.
    public static let bookmarks = KeyboardShortcut(keyboardInput: .bookmarks)

    /// A keyboard shortcut for a search/find action, consisting of the 'F' key and the Command (⌘) modifier.
    public static let search = KeyboardShortcut(keyboardInput: .search)

    /// A keyboard shortcut for a deletion action, consisting of the Delete (⌫) key and the Command (⌘) modifier.
    public static let delete = KeyboardShortcut(.delete)

    /// A keyboard shortcut for an action for viewing content relating to the current day, consisting of the 'T' key and the Command (⌘) modifier.
    public static let today = KeyboardShortcut(keyboardInput: .today)

    /// A keyboard shortcut for a zoom-in action, consisting of the equals (=) key and the Command (⌘) modifier.
    public static let zoomIn = KeyboardShortcut(keyboardInput: .zoomIn)

    /// A keyboard shortcut for a zoom-out action, consisting of the minus (-) key and the Command (⌘) modifier.
    public static let zoomOut = KeyboardShortcut(keyboardInput: .zoomOut)

    /// A keyboard shortcut for an action to zoom content to its actual size, consisting of the 0 key and the Command (⌘) modifier.
    public static let zoomToActualSize = KeyboardShortcut(keyboardInput: .zoomToActualSize)

    /// A keyboard shortcut for a rewind action, consisting of the left arrow (←) key and the Command (⌘) modifier.
    ///
    /// This input is not flipped for right-to-left layouts.
    public static let rewind = KeyboardShortcut(keyboardInput: .rewind)

    /// A keyboard shortcut for a fast-forward action, consisting of the right arrow (→) key and the Command (⌘) modifier.
    ///
    /// This input is not flipped for right-to-left layouts.
    public static let fastForward = KeyboardShortcut(keyboardInput: .fastForward)
}

private extension EventModifiers {
    init(keyModifierFlags: UIKeyModifierFlags) {
        self = []

        if keyModifierFlags.contains(.command) {
            self.insert(.command)
        }
        if keyModifierFlags.contains(.numericPad) {
            self.insert(.numericPad)
        }
        if keyModifierFlags.contains(.shift) {
            self.insert(.shift)
        }
        if keyModifierFlags.contains(.control) {
            self.insert(.control)
        }
        if keyModifierFlags.contains(.alphaShift) {
            self.insert(.capsLock)
        }
    }
}

@available(iOS 14.0, *)
private extension KeyboardShortcut {
    init(keyboardInput: KeyboardInput) {
        let characterKey = KeyEquivalent(Character(keyboardInput.character))
        let modifiers = EventModifiers(keyModifierFlags: keyboardInput.modifierFlags)

        if #available(iOS 15.0, *) {
            self.init(characterKey, modifiers: modifiers, localization: keyboardInput.allowsAutomaticMirroring ? .automatic : .withoutMirroring)
        } else {
            self.init(characterKey, modifiers: modifiers)
        }
    }
}
