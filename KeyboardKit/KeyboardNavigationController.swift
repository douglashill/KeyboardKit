// Douglas Hill, December 2019

import UIKit

/// A navigation controller that supports using a hardware keyboard to navigate back using command + left
/// (or right for right-to-left layout) and triggering the actions of the bar button items in the navigation
/// bar and toolbar. Bar button items must be instances of `KeyboardBarButtonItem` to support this, even for
/// system items (because otherwise there is no way to know the system item after initialisation).
///
/// The concept for this class was originally developed for PSPDFKit: <https://pspdfkit.com>
open class KeyboardNavigationController: UINavigationController {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    private lazy var leftToRightBackKeyCommands = [
        UIKeyCommand((.command, .leftArrow), action: #selector(kbd_goBackFromKeyCommand), title: localisedString(.navigationController_back)),
        UIKeyCommand((.command, "["), action: #selector(kbd_goBackFromKeyCommand)),
    ]

    private lazy var rightToLeftBackKeyCommands = [
        UIKeyCommand((.command, .rightArrow), action: #selector(kbd_goBackFromKeyCommand), title: localisedString(.navigationController_back)),
        UIKeyCommand((.command, "]"), action: #selector(kbd_goBackFromKeyCommand)),
    ]

    private var backKeyCommands: [UIKeyCommand] {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .rightToLeft: return rightToLeftBackKeyCommands
        case .leftToRight: fallthrough @unknown default: return leftToRightBackKeyCommands
        }
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if let topViewController = topViewController {
            let navigationItem = topViewController.navigationItem
            var additionalCommands: [UIKeyCommand] = []

            let canGoBack = viewControllers.count > 1 && self.presentedViewController == nil && navigationItem.hidesBackButton == false && (navigationItem.nnLeadingBarButtonItems.isEmpty || navigationItem.leftItemsSupplementBackButton)
            if (canGoBack) {
                additionalCommands += backKeyCommands
            }

            let keyCommandFromBarButtonItem: (UIBarButtonItem) -> UIKeyCommand? = {
                $0.isEnabled ? ($0 as? KeyboardBarButtonItem)?.keyCommand : nil
            }

            additionalCommands += navigationItem.nnLeadingBarButtonItems.compactMap(keyCommandFromBarButtonItem)
            additionalCommands += navigationItem.nnTrailingBarButtonItems.compactMap(keyCommandFromBarButtonItem).reversed()
            additionalCommands += topViewController.nnToolbarItems.compactMap(keyCommandFromBarButtonItem)

            if UIResponder.isTextInputActive {
                additionalCommands = additionalCommands.filter { $0.doesConflictWithTextInput == false }
            }

            commands += additionalCommands
        }

        return commands
    }
}

private extension UINavigationController {

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
