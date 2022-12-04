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
    public static let close = KeyboardAction.close.keyboardShortcut

    /// A keyboard shortcut for a done action, consisting of the Return (↩) key and the Command (⌘) modifier.
    public static let done = KeyboardAction.done.keyboardShortcut

    /// A keyboard shortcut for a save action, consisting of the 'S' key and the Command (⌘) modifier.
    public static let save = KeyboardAction.save.keyboardShortcut

    /// A keyboard shortcut for showing the share sheet, consisting of the 'I' key and the Command (⌘) modifier.
    public static let share = KeyboardAction.share.keyboardShortcut

    /// A keyboard shortcut for an edit action, consisting of the 'E' key and the Command (⌘) modifier.
    public static let edit = KeyboardAction.edit.keyboardShortcut

    /// A keyboard shortcut for a creation action, consisting of the 'N' key and the Command (⌘) modifier.
    public static let new = KeyboardAction.new.keyboardShortcut

    /// A keyboard shortcut for a reply action, consisting of the 'R' key and the Command (⌘) modifier.
    public static let reply = KeyboardAction.reply.keyboardShortcut

    /// A keyboard shortcut for a refresh action, consisting of the 'R' key and the Command (⌘) modifier.
    public static let refresh = KeyboardAction.refresh.keyboardShortcut

    /// A keyboard shortcut for an action for viewing bookmarks, consisting of the 'B' key and the Command (⌘) modifier.
    public static let bookmarks = KeyboardAction.bookmarks.keyboardShortcut

    /// A keyboard shortcut for a search action, consisting of the 'F' key and the Command (⌘) modifier.
    public static let search = KeyboardAction.search.keyboardShortcut

    /// A keyboard shortcut for a deletion action, consisting of the Delete (⌫) key and the Command (⌘) modifier.
    public static let delete = KeyboardAction.delete.keyboardShortcut

    /// A keyboard shortcut for an action for viewing content relating to the current day, consisting of the 'T' key and the Command (⌘) modifier.
    public static let today = KeyboardAction.today.keyboardShortcut

    /// A keyboard shortcut for a zoom-in action, consisting of the equals (=) key and the Command (⌘) modifier.
    public static let zoomIn = KeyboardAction.zoomIn.keyboardShortcut

    /// A keyboard shortcut for a zoom-out action, consisting of the minus (-) key and the Command (⌘) modifier.
    public static let zoomOut = KeyboardAction.zoomOut.keyboardShortcut

    /// A keyboard shortcut for an action to zoom content to its actual size, consisting of the 0 key and the Command (⌘) modifier.
    public static let zoomToActualSize = KeyboardAction.zoomToActualSize.keyboardShortcut

    /// A keyboard shortcut for a rewind action, consisting of the left arrow (←) key and the Command (⌘) modifier.
    public static let rewind = KeyboardAction.rewind.keyboardShortcut

    /// A keyboard shortcut for a fast-forward action, consisting of the right arrow (→) key and the Command (⌘) modifier.
    public static let fastForward = KeyboardAction.fastForward.keyboardShortcut
}

@available(iOS 13.0, *)
private extension UIKeyModifierFlags {
    var eventModifiers: EventModifiers {
        var eventModifiers: EventModifiers = []

        if self.contains(.command) {
            eventModifiers.insert(.command)
        }
        if self.contains(.numericPad) {
            eventModifiers.insert(.numericPad)
        }
        if self.contains(.shift) {
            eventModifiers.insert(.shift)
        }
        if self.contains(.control) {
            eventModifiers.insert(.control)
        }
        if self.contains(.alphaShift) {
            eventModifiers.insert(.capsLock)
        }

        return eventModifiers
    }
}

@available(iOS 14.0, *)
private extension KeyboardAction {
    var keyboardShortcut: KeyboardShortcut {
        let equivalent = keyEquivalent
        let keyEquivalent = KeyEquivalent(Character(equivalent.input))
        let modifiers = equivalent.modifierFlags.eventModifiers

        switch self {
        case .cancel:
            return .cancelAction
        case .rewind, .fastForward:
            if #available(iOS 15.0, *) {
                return .init(keyEquivalent, modifiers: modifiers, localization: .withoutMirroring)
            }
            fallthrough
        default:
            return .init(keyEquivalent, modifiers: modifiers)
        }
    }
}

#endif
