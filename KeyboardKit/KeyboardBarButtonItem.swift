// Douglas Hill, December 2019

#if SWIFT_PACKAGE
import KeyboardKitObjC
#endif

import UIKit

/// A bar button item that can define keys that may be pressed on a keyboard to trigger the button’s action selector.
///
/// The key command is used automatically when the bar button items is used in the navigation bar or toolbar
/// of a `KeyboardNavigationController`.
///
/// Sets default key equivalents for most system items.
///
/// Key commands use nil-targeted actions so the first object on the responder chain responding to
/// the selector will handle it. This means the action might be received by a different object if
/// the bar button item uses an explicit target.
///
/// Bar button items that use `primaryAction` (a `UIAction`) are not supported because `UIAction` does not provide access to its `handler`.
///
/// Bar button items that use `menu` (a `UIMenu`) are not supported because the menu would not be accessible with a keyboard.
/// Instead since `UIKeyCommand` is a menu element it makes more sense to create the menu contents using `UIKeyCommand` and
/// also expose these same command objects in an override of `keyCommands`.
///
/// The concept for this class was originally developed for PSPDFKit: <https://pspdfkit.com>
open class KeyboardBarButtonItem: KBDBarButtonItem {

    /// The character and the modifier flags corresponding to the keys that must be pressed to trigger this bar button item’s action from a keyboard.
    open var keyEquivalent: (modifierFlags: UIKeyModifierFlags, input: String)?

    /// Forwards to the `UIKeyCommand` property `wantsPriorityOverSystemBehavior`. Does nothing on iOS 14 and earlier.
    open var keyCommandWantsPriorityOverSystemBehavior: Bool = false

    /// Forwards to the `UIKeyCommand` property `allowsAutomaticLocalization`. Does nothing on iOS 14 and earlier.
    open var keyCommandAllowsAutomaticLocalization: Bool = true

    /// Forwards to the `UIKeyCommand` property `allowsAutomaticMirroring`. Does nothing on iOS 14 and earlier.
    open var keyCommandAllowsAutomaticMirroring: Bool = true

    private var systemItem: SystemItem?

    /// Creates a key command that can be used to trigger this bar button item’s action.
    /// This will return a key command even if it would override text input.
    var keyCommand: UIKeyCommand? {
        guard isEnabled, let keyEquivalent = keyEquivalent, let action = action else {
            return nil
        }

        // Neither the title nor the accessibilityLabel is set on the item for system items, so we need to use
        // our own translations (which are extracted from Apple’s localisation glossaries so are the same).
        let title: String? = self.title ?? accessibilityLabel ?? {
            if let key = systemItem?.titleLocalisedStringKey {
                return localisedString(key)
            } else {
                return nil
            }
        }()

        let command = UIKeyCommand(keyEquivalent, action: action, title: title)

        if #available(iOS 15.0, *) {
            command.wantsPriorityOverSystemBehavior = keyCommandWantsPriorityOverSystemBehavior
            command.allowsAutomaticLocalization = keyCommandAllowsAutomaticLocalization
            command.allowsAutomaticMirroring = keyCommandAllowsAutomaticMirroring
        }

        return command
    }

    /// For KeyboardKit internal use.
    public override func wasInitialised(with systemItem: SystemItem) {
        keyEquivalent = systemItem.keyEquivalent
        self.systemItem = systemItem
        keyCommandAllowsAutomaticMirroring = systemItem.allowsAutomaticMirroring
    }

    @available(iOS 14.0, *)
    open override var primaryAction: UIAction? {
        didSet {
            if primaryAction != nil {
                NSLog("[KeyboardKit] Warning: Setting the primaryAction of a KeyboardBarButtonItem. The action will not be accessible from a keyboard because UIAction does not expose its handler.");
            }
        }
    }

    @available(iOS 14.0, *)
    open override var menu: UIMenu? {
        didSet {
            if menu != nil {
                NSLog("[KeyboardKit] Warning: Setting the menu of a KeyboardBarButtonItem. The menu will not be accessible from a keyboard. The recommend design is to use a UIKeyCommand for each item in the menu and expose these same commands via an override of keyCommands.");
            }
        }
    }
}

private extension UIBarButtonItem.SystemItem {
    var keyEquivalent: (modifierFlags: UIKeyModifierFlags, input: String)? {
        switch self {
        case .cancel:      return ([], .escape)
        case .close:       return (.command, "w")
        // Apparently "\u{3}" might work for enter (not return) but not quite. Shows up in the HUD with no key and I couldn’t get it to trigger. For now use cmd + return instead.
        // Sources: https://forums.developer.apple.com/thread/119584 and https://stackoverflow.com/questions/56963348/uikeycommand-for-the-enter-key-on-mac-keyboards-numeric-keypad.
        case .done:        return (.command, .returnOrEnter)
        case .save:        return (.command, "s")
        case .action:      return (.command, "i") // Safari uses this for Email This Page. Also indirectly recommended in https://developer.apple.com/wwdc20/10117.
        case .edit:        return (.command, "e")
        case .add:         return (.command, "n")
        case .compose:     return (.command, "n")
        case .reply:       return (.command, "r")
        case .refresh:     return (.command, "r")
        case .bookmarks:   return (.command, "b") // opt + cmd + B or shift + cmd + B might be better to be more like Safari.
        case .search:      return (.command, "f")
        case .trash:       return (.command, .delete)
        case .rewind:      return (.command, .leftArrow)
        case .fastForward: return (.command, .rightArrow)
        // More obscure items that are hard to pick a standard key equivalent for.
        case .organize:    return nil
        case .camera:      return nil
        case .play:        return nil
        case .pause:       return nil
        case .stop:        return nil
        case .pageCurl:    return nil
        // These should never get key equivalents. System already has good support for undo and redo.
        case .undo, .redo, .flexibleSpace, .fixedSpace: fallthrough @unknown default: return nil
        }
    }

    var allowsAutomaticMirroring: Bool {
        switch self {
        case .rewind, .fastForward: return false // This is based on the assumption that these are being used for media playback, which typically progresses left-to-right even in right-to-left layouts.
        default:                    return true  // This doesn’t matter since all these inputs aren’t mirrored anyway, but might as well match the UIKit default.
        }
    }

    var titleLocalisedStringKey: LocalisedStringKey? {
        switch self {
        case .action: return .barButton_action
        case .add: return .barButton_add
        case .bookmarks: return .barButton_bookmarks
        case .camera: return .barButton_camera
        case .cancel: return .barButton_cancel
        case .close: return .barButton_close
        case .compose: return .barButton_compose
        case .done: return .barButton_done
        case .edit: return .barButton_edit
        case .fastForward: return .barButton_fastForward
        case .organize: return .barButton_organize
        case .pause: return .barButton_pause
        case .play: return .barButton_play
        case .redo: return .barButton_redo
        case .refresh: return .refresh
        case .reply: return .barButton_reply
        case .rewind: return .barButton_rewind
        case .save: return .barButton_save
        case .search: return .barButton_search
        case .stop: return .barButton_stop
        case .trash: return .delete
        case .undo: return .barButton_undo
        // The system does not provide an accessibility label for page curl.
        case .fixedSpace, .flexibleSpace, .pageCurl: fallthrough @unknown default: return nil
        }
    }
}
