// Douglas Hill, December 2019

import UIKit

/// A navigation controller that supports using a hardware keyboard to navigate back using command + left
/// (or right for right-to-left layout) and triggering the actions of the bar button items in the navigation
/// bar and toolbar. Bar button items must be instances of KeyboardBarButtonItem to support this.
///
/// The concept for this class was originally developed for PSPDFKit: https://pspdfkit.com
public class KeyboardNavigationController: UINavigationController {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        guard let topViewController = topViewController else {
            return commands
        }

        let navigationItem = topViewController.navigationItem

        let canGoBack = viewControllers.count > 1 && self.presentedViewController == nil && navigationItem.hidesBackButton == false && (navigationItem.nnLeadingBarButtonItems.isEmpty || navigationItem.leftItemsSupplementBackButton)
        if (canGoBack) {
            let (primaryInput, secondaryInput) = backInputs
            commands.append(UIKeyCommand(title: localisedString(.navigationController_back), action: #selector(goBackFromKeyCommand), input: primaryInput, modifierFlags: .command))
            commands.append(UIKeyCommand(input: secondaryInput, modifierFlags: .command, action: #selector(goBackFromKeyCommand)))
        }

        let keyCommandFromBarButtonItem: (UIBarButtonItem) -> UIKeyCommand? = {
            $0.isEnabled ? ($0 as? KeyboardBarButtonItem)?.keyCommand : nil
        }

        commands += navigationItem.nnLeadingBarButtonItems.compactMap(keyCommandFromBarButtonItem)
        commands += navigationItem.nnTrailingBarButtonItems.compactMap(keyCommandFromBarButtonItem)
        commands += topViewController.nnToolbarItems.compactMap(keyCommandFromBarButtonItem)

        return commands
    }

    private var backInputs: (primary: String, secondary: String) {
        switch view.effectiveUserInterfaceLayoutDirection {
        case .rightToLeft: return (UIKeyCommand.inputRightArrow, "]")
        case .leftToRight: fallthrough @unknown default: return (UIKeyCommand.inputLeftArrow, "[")
        }
    }

    @objc private func goBackFromKeyCommand(_ keyCommand: UIKeyCommand) {
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
