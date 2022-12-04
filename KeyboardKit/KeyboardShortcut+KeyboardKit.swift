// Douglas Hill, December 2022

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 14.0, *)
extension KeyboardShortcut {
    /// The namespace for keyboard shortcuts defined by KeyboardKit.
    public enum KeyboardKit {}
}

@available(iOS 14.0, *)
extension KeyboardShortcut.KeyboardKit {
    /// A keyboard shortcut for a close action, consisting of the 'W' key and the Command (⌘) modifier.
    public static let close = KeyboardShortcut(keyboardAction: .close)

    /// A keyboard shortcut for a done action, consisting of the Return (↩) key and the Command (⌘) modifier.
    public static let done = KeyboardShortcut(keyboardAction: .done)

    /// A keyboard shortcut for a save action, consisting of the 'S' key and the Command (⌘) modifier.
    public static let save = KeyboardShortcut(keyboardAction: .save)

    /// A keyboard shortcut for showing the share sheet, consisting of the 'I' key and the Command (⌘) modifier.
    public static let share = KeyboardShortcut(keyboardAction: .share)

    /// A keyboard shortcut for an edit action, consisting of the 'E' key and the Command (⌘) modifier.
    public static let edit = KeyboardShortcut(keyboardAction: .edit)

    /// A keyboard shortcut for a creation action, consisting of the 'N' key and the Command (⌘) modifier.
    public static let new = KeyboardShortcut(keyboardAction: .new)

    /// A keyboard shortcut for a reply action, consisting of the 'R' key and the Command (⌘) modifier.
    public static let reply = KeyboardShortcut(keyboardAction: .reply)

    /// A keyboard shortcut for a refresh action, consisting of the 'R' key and the Command (⌘) modifier.
    public static let refresh = KeyboardShortcut(keyboardAction: .refresh)

    /// A keyboard shortcut for an action for viewing bookmarks, consisting of the 'B' key and the Command (⌘) modifier.
    public static let bookmarks = KeyboardShortcut(keyboardAction: .bookmarks)

    /// A keyboard shortcut for a search action, consisting of the 'F' key and the Command (⌘) modifier.
    public static let search = KeyboardShortcut(keyboardAction: .search)

    /// A keyboard shortcut for a deletion action, consisting of the Delete (⌫) key and the Command (⌘) modifier.
    public static let delete = KeyboardShortcut(keyboardAction: .delete)

    /// A keyboard shortcut for an action for viewing content relating to the current day, consisting of the 'T' key and the Command (⌘) modifier.
    public static let today = KeyboardShortcut(keyboardAction: .today)

    /// A keyboard shortcut for a zoom-in action, consisting of the equals (=) key and the Command (⌘) modifier.
    public static let zoomIn = KeyboardShortcut(keyboardAction: .zoomIn)

    /// A keyboard shortcut for a zoom-out action, consisting of the minus (-) key and the Command (⌘) modifier.
    public static let zoomOut = KeyboardShortcut(keyboardAction: .zoomOut)

    /// A keyboard shortcut for an action to zoom content to its actual size, consisting of the 0 key and the Command (⌘) modifier.
    public static let zoomToActualSize = KeyboardShortcut(keyboardAction: .zoomToActualSize)

    /// A keyboard shortcut for a rewind action, consisting of the left arrow (←) key and the Command (⌘) modifier.
    public static let rewind = KeyboardShortcut(keyboardAction: .rewind)

    /// A keyboard shortcut for a fast-forward action, consisting of the right arrow (→) key and the Command (⌘) modifier.
    public static let fastForward = KeyboardShortcut(keyboardAction: .fastForward)
}

@available(iOS 13.0, *)
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
    init(keyboardAction: KeyboardAction) {
        let equivalent = keyboardAction.keyEquivalent
        let characterKey = KeyEquivalent(Character(equivalent.input))
        let modifiers = EventModifiers(keyModifierFlags: equivalent.modifierFlags)

        switch keyboardAction {
        case .cancel:
            self = .cancelAction
        case .rewind, .fastForward:
            if #available(iOS 15.0, *) {
                self.init(characterKey, modifiers: modifiers, localization: .withoutMirroring)
            }
            fallthrough
        default:
            self.init(characterKey, modifiers: modifiers)
        }
    }
}

#endif
