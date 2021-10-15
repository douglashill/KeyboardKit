// Douglas Hill, December 2019

import UIKit

/// A navigation controller that supports using a hardware keyboard to navigate back using ⌘ + `[` or
/// ⌘ + ← (mirrored for right-to-left layouts) and triggering the actions of the bar button items in
/// the navigation bar and toolbar.
///
/// Bar button items must be instances of `KeyboardBarButtonItem` to support keyboard equivalents, even
/// for system items (because otherwise there is no way to know the system item after initialisation).
///
/// From iOS 15, `UINavigationController` itself provides a ⌘  + `[` key command to go back, but
/// the UIKit implementation doesn’t correctly handle nested navigation controllers which is common
/// when `UISplitViewController` collapses. Therefore `KeyboardNavigationController` will remove
/// this key command from the superclass and adds in its own commands.
///
/// The concept for this class was originally developed for [PSPDFKit]( https://pspdfkit.com/ ).
open class KeyboardNavigationController: UINavigationController {

    open override var canBecomeFirstResponder: Bool {
        true
    }

    /// A key command that enables users to go back.
    ///
    /// Title: Back
    ///
    /// Input: ⌘`[` (Users can also use ⌘←. Both of these inputs are mirrored in right-to-left layouts.)
    ///
    /// UIKit has this functionality on iOS 15, but KeyboardKit does this back to iOS 12.
    /// This API is only available from iOS 15 because using a single key command for this requires automatic
    /// mirroring, which was not available until iOS 15. However KeyboardKit provides this functionality back
    /// to iOS 12 using multiple internal key commands to implement mirroring.
    @available(iOS 15.0, *)
    public static let backKeyCommand = discoverableLeftToRightBackCommand

    private static let discoverableLeftToRightBackCommand = DiscoverableKeyCommand((.command, "["), action: #selector(kbd_handleCmdLeftBracket), title: localisedString(.navigation_back))
    // Note that on iOS 14 and earlier the system will incorrectly show this in the discoverability HUD as a leftwards
    // pointing arrow. The discoverability HUD mirrors the arrow keys it displays when in a right-to-left layout, but
    // the inputs on the actual events received are not mirrored. This was reported as FB8963593 and resolved in iOS 15.
    // TODO: Update this comment since the discoverable one was switched to ] so maybe that doesn’t have the same problem.
    private static let discoverableRightToLeftBackCommand = UIKeyCommand((.command, "]"), action: #selector(kbd_handleCmdRightBracket), title: localisedString(.navigation_back))

    private static let nonDiscoverableLeftToRightBackCommand = UIKeyCommand((.command, .leftArrow), action: #selector(kbd_goBackFromKeyCommand))
    private static let nonDiscoverableRightToLeftBackCommand = UIKeyCommand((.command, .rightArrow), action: #selector(kbd_goBackFromKeyCommand))

    private var shouldUseRightToLeftBackCommand: Bool {
        if #available(iOS 15.0, *) {
            // Handled by allowsAutomaticMirroring.
            return false
        } else {
            switch view.effectiveUserInterfaceLayoutDirection {
            case .rightToLeft: return true
            case .leftToRight: fallthrough @unknown default: return false
            }
        }
    }

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if let topViewController = topViewController {
            let navigationItem = topViewController.navigationItem
            var additionalCommands: [UIKeyCommand] = []

            // On iOS 15 and later, UIKit provides cmd-[ to go back in UINavigationController.
            // However as of iOS 15.0 beta 4 this has a bug seen in the KeyboardKit demo app table
            // view or list in compact widths where it pops all the way to the root (the sidebar
            // VC) instead of just popping one level. Additionally, the KeyboardKit command has a
            // localised title and the user can use either cmd-[ or cmd-left. Therefore filter
            // out the system provided command for going back and add our own instead.
            commands = commands.filter { systemCommand in
                (systemCommand.input == "[" && systemCommand.modifierFlags == .command) == false
            }

            // It’s useful to check canGoBack otherwise these commands can block rewind/fast-forward bar button items unnecessarily.
            // Although when using the menu builder we can’t do anything about that.
            if canGoBack {
                if shouldUseRightToLeftBackCommand {
                    additionalCommands.append(Self.nonDiscoverableRightToLeftBackCommand)
                    additionalCommands.append(Self.discoverableRightToLeftBackCommand)
                } else {
                    additionalCommands.append(Self.nonDiscoverableLeftToRightBackCommand)
                    if Self.discoverableLeftToRightBackCommand.shouldBeIncludedInResponderChainKeyCommands {
                        additionalCommands.append(Self.discoverableLeftToRightBackCommand)
                    }
                }
            }

            let keyCommandFromBarButtonItem: (UIBarButtonItem) -> UIKeyCommand? = {
                $0.isEnabled ? ($0 as? KeyboardBarButtonItem)?.keyCommand : nil
            }

            additionalCommands += navigationItem.nnLeadingBarButtonItems.compactMap(keyCommandFromBarButtonItem)
            additionalCommands += navigationItem.nnTrailingBarButtonItems.compactMap(keyCommandFromBarButtonItem).reversed()
            additionalCommands += topViewController.nnToolbarItems.compactMap(keyCommandFromBarButtonItem)

            if #available(iOS 15.0, *) {
                /* wantsPriorityOverSystemBehavior defaulting to false handles commands not overriding text input. */
            } else if UIResponder.isTextInputActive {
                additionalCommands = additionalCommands.filter { $0.doesConflictWithTextInput == false }
            }

            commands += additionalCommands
        }

        return commands
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // The menu builder provides both the LtR and RtL commands, so block the wrong one. For this reason, the menu
        // builder support here can’t be used on Catalyst since it would show the available command as disabled.

        switch action {
        case #selector(kbd_goBackFromKeyCommand):
            return canGoBack
        case #selector(kbd_handleCmdLeftBracket):
            return shouldUseRightToLeftBackCommand ? false : canGoBack
        case #selector(kbd_handleCmdRightBracket):
            return shouldUseRightToLeftBackCommand ? canGoBack : false
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }

    private var canGoBack: Bool {
        viewControllers.count > 1 && presentedViewController == nil && navigationItem.hidesBackButton == false && (navigationItem.nnLeadingBarButtonItems.isEmpty || navigationItem.leftItemsSupplementBackButton)
    }

    @objc private func kbd_handleCmdLeftBracket(sender: UIKeyCommand) { self.kbd_goBackFromKeyCommand(sender) }
    @objc private func kbd_handleCmdRightBracket(sender: UIKeyCommand) { self.kbd_goBackFromKeyCommand(sender) }

    // Important to not put this on all UINavigationController instances via an extension because those
    // instances lack our override of canPerformAction so could allow the action incorrectly.
    @objc private func kbd_goBackFromKeyCommand(_ keyCommand: UIKeyCommand) {
        let allowsPop = navigationBar.delegate?.navigationBar?(navigationBar, shouldPop: topViewController!.navigationItem) ?? true
        guard allowsPop else {
            return
        }

        popViewController(animated: true)
    }
}

private extension UINavigationItem {
    var nnLeadingBarButtonItems: [UIBarButtonItem] { leftBarButtonItems ?? [] }
    var nnTrailingBarButtonItems: [UIBarButtonItem] { rightBarButtonItems ?? [] }
}

private extension UIViewController {
    var nnToolbarItems: [UIBarButtonItem] { toolbarItems ?? [] }
}
