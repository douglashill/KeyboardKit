// Douglas Hill, May 2019

import UIKit

/// A tab bar controller that supports navigating between tabs using cmd+number on a hardware keyboard.
/// So cmd+1 for the first tab, cmd+2 for the second tab etc.
open class KeyboardTabBarController: UITabBarController {

    public override var canBecomeFirstResponder: Bool {
        true
    }

    public override var keyCommands: [UIKeyCommand]? {
        var commands = super.keyCommands ?? []

        guard presentedViewController == nil else {
            return commands
        }

        if let items = tabBar.items {
            commands += items.prefix(9).enumerated().map { index, tabBarItem in
                UIKeyCommand((.command, String(index + 1)), action: #selector(scrollToNumberedTab), title: tabBarItem.title)
            }
        }

        return commands
    }

    // For using command-1 to command-9.
    @objc private func scrollToNumberedTab(_ sender: UIKeyCommand) {
        guard let keyInput = sender.input, let targetTabNumber = Int(keyInput), targetTabNumber > 0 else {
            return
        }

        selectedIndex = targetTabNumber - 1
    }
}
