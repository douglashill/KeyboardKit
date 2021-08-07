// Douglas Hill, May 2019

import UIKit

/// A tab bar controller that supports navigating between tabs using cmd+number on a hardware keyboard.
/// So cmd+1 for the first tab, cmd+2 for the second tab etc.
///
/// Setting more view controllers than the number displayable by a tab bar such that the More item is added is not supported.
/// This is partly because the view controller hierarchy modifications done by the More tab are hard to support well, and partly
/// because the More list and navigation controller don’t support keyboard input so would result in an inconsistent user experience.
open class KeyboardTabBarController: UITabBarController {

    open override var canBecomeFirstResponder: Bool {
        true
    }

    open override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if presentedViewController == nil, let items = tabBar.items {
            precondition(items.count == viewControllers?.count, "More tab is not supported.")

            commands += items.prefix(9).enumerated().map { index, tabBarItem in
                UIKeyCommand((.command, String(index + 1)), action: #selector(selectTabByNumberFromKeyCommand), title: tabBarItem.title)
            }
        }

        return commands
    }

    // For using command-1 to command-9.
    @objc private func selectTabByNumberFromKeyCommand(_ sender: UIKeyCommand) {
        guard let keyInput = sender.input, let targetTabNumber = Int(keyInput), targetTabNumber > 0 else {
            return
        }

        let incomingIndex = targetTabNumber - 1
        let incomingViewController = viewControllers![incomingIndex]

        // To match the callbacks tapping the tabs, call the delegate even if selecting the already selected tab.

        guard delegate?.tabBarController?(self, shouldSelect: incomingViewController) ?? true else {
            return
        }

        selectedIndex = incomingIndex

        precondition(selectedViewController == incomingViewController)
        self.delegate?.tabBarController?(self, didSelect: incomingViewController)
    }

    // On Big Sur, the tabs in the bar are focusable, but you can’t activate the selection to select a tab.
    // Overriding shouldUpdateFocusInContext to return false can break the focus system though
    // so just allow this bogus focus. It’s not an issue on iOS 15 on iPad.
}
