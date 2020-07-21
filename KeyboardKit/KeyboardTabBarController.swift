// Douglas Hill, May 2019

import UIKit

/// A tab bar controller that supports navigating between tabs using cmd+number on a hardware keyboard.
/// So cmd+1 for the first tab, cmd+2 for the second tab etc.
///
/// Setting more view controllers than the number displayable by a tab bar such that the More item is added is not supported.
/// This is partly because the view controller hierarchy modifications done by the More tab are hard to support well, and partly
/// because the More list and navigation controller don’t support keyboard input so would result in an inconsistent user experience.
open class KeyboardTabBarController: UITabBarController {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        if presentedViewController == nil, let items = tabBar.items {
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

        selectedIndex = targetTabNumber - 1
    }
}
