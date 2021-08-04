// Douglas Hill, December 2019

import UIKit

/// A navigation controller that supports using a hardware keyboard to navigate back using command + left
/// (or right for right-to-left layout) and triggering the actions of the bar button items in the navigation
/// bar and toolbar. Bar button items must be instances of `KeyboardBarButtonItem` to support this, even for
/// system items (because otherwise there is no way to know the system item after initialisation).
///
/// The concept for this class was originally developed for PSPDFKit: <https://pspdfkit.com>
open class KeyboardNavigationController: UINavigationController {

    open override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var leftToRightBackKeyCommands = [
        UIKeyCommand((.command, .leftArrow), action: #selector(kbd_goBackFromKeyCommand), title: localisedString(.navigation_back)),
        UIKeyCommand((.command, "["), action: #selector(kbd_goBackFromKeyCommand)),
    ]

    private lazy var rightToLeftBackKeyCommands = [
        // Note that on iOS 14 and earlier the system will incorrectly show this in the discoverability HUD as a leftwards
        // pointing arrow. The discoverability HUD mirrors the arrow keys it displays when in a right-to-left layout, but
        // the inputs on the actual events received are not mirrored. This was reported as FB8963593 and resolved in iOS 15.
        UIKeyCommand((.command, .rightArrow), action: #selector(kbd_goBackFromKeyCommand), title: localisedString(.navigation_back)),
        UIKeyCommand((.command, "]"), action: #selector(kbd_goBackFromKeyCommand)),
    ]

    private var backKeyCommands: [UIKeyCommand] {
        if #available(iOS 15.0, *) {
            // Handled by allowsAutomaticMirroring.
            return leftToRightBackKeyCommands
        } else {
            switch view.effectiveUserInterfaceLayoutDirection {
            case .rightToLeft: return rightToLeftBackKeyCommands
            case .leftToRight: fallthrough @unknown default: return leftToRightBackKeyCommands
            }
        }
    }

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if let topViewController = topViewController {
            let navigationItem = topViewController.navigationItem
            var additionalCommands: [UIKeyCommand] = []

            // On iOS 15 and later, UIKit provides cmd-[ to go back in UINavigationController.
            // However as of iOS 15.0 beta 2 this has a bug seen in the KeyboardKit demo app table
            // view or list in compact widths where it pops all the way to the root (the sidebar
            // VC) instead of just popping one level. Additionally, the KeyboardKit command has a
            // localised title and the user can use either cmd-[ or cmd-left. Therefore filter
            // out the system provided command for going back and add our own instead.
            commands = commands.filter { systemCommand in
                (systemCommand.input == "[" && systemCommand.modifierFlags == .command) == false
            }

            // It’s useful to check this otherwise these commands can block rewind/fast-forward bar button items unnecessarily.
            if canGoBack {
                additionalCommands += backKeyCommands
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
        if action == #selector(kbd_goBackFromKeyCommand) {
            return canGoBack
        }

        return super.canPerformAction(action, withSender: sender)
    }

    private var canGoBack: Bool {
        viewControllers.count > 1 && presentedViewController == nil && navigationItem.hidesBackButton == false && (navigationItem.nnLeadingBarButtonItems.isEmpty || navigationItem.leftItemsSupplementBackButton)
    }

    // Important to not put this on all UINavigationController instances via an extension because those
    // instances lack our override of canPerformAction so could allow the action incorrectly.
    @objc func kbd_goBackFromKeyCommand(_ keyCommand: UIKeyCommand) {
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
